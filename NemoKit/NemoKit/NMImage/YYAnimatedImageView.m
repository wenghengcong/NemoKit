//
//  YYAnimatedImageView.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 14/10/19.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYAnimatedImageView.h"
#import "YYWeakProxy.h"
#import "UIDevice+YYAdd.h"
#import "YYImageCoder.h"
#import "YYKitMacro.h"

#define BUFFER_SIZE (10 * 1024 * 1024) // 10MB (minimum memory buffer size)

/// learn: 利用宏来精简代码，优化语义显示
#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

#define LOCK_VIEW(...) dispatch_semaphore_wait(view->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(view->_lock);


typedef NS_ENUM(NSUInteger, YYAnimatedImageType) {
    YYAnimatedImageTypeNone = 0,
    YYAnimatedImageTypeImage,
    YYAnimatedImageTypeHighlightedImage,
    YYAnimatedImageTypeImages,
    YYAnimatedImageTypeHighlightedImages,
};

@interface YYAnimatedImageView() {
    /*
     private: 只有当前类能访问
     pubLic: 在任何地方都可以访问
     protect：只有当前类及其之类能够访问，是默认的访问类型
     package：介于 private 和 public之间，在当前框架内可以使用。在不同的包中，使用package声明的变量就是private。
     如果在同一个包中，package声明的变量，就是public
     */
    @package
    UIImage <YYAnimatedImage> *_curAnimatedImage;
    
    dispatch_semaphore_t _lock; ///< lock for _buffer
    NSOperationQueue *_requestQueue; ///< image request queue, serial
    
    CADisplayLink *_link; ///< ticker for change frame
    NSTimeInterval _time; ///< time after last frame
    
    UIImage *_curFrame; ///< current frame to display
    NSUInteger _curIndex; ///< current frame index (from 0)
    NSUInteger _totalFrameCount; ///< total frame count
    
    BOOL _loopEnd; ///< whether the loop is end.
    NSUInteger _curLoop; ///< current loop count (from 0)
    NSUInteger _totalLoop; ///< total loop count, 0 means infinity
    
    NSMutableDictionary *_buffer; ///< frame buffer
    BOOL _bufferMiss; ///< whether miss frame on last opportunity
    NSUInteger _maxBufferCount; ///< maximum buffer count
    NSInteger _incrBufferCount; ///< current allowed buffer count (will increase by step)
    
    CGRect _curContentsRect;
    BOOL _curImageHasContentsRect; ///< image has implementated "animatedImageContentsRectAtIndex:"
}
@property (nonatomic, readwrite) BOOL currentIsPlayingAnimation;
- (void)calcMaxBufferCount;
@end

/// An operation for image fetch
/*
 NSOperation 之类要实现 main 方法。
 更多参考：https://developer.apple.com/documentation/foundation/nsoperation
 https://juejin.im/post/5bf89cc5518825719f209144#heading-10
 */
@interface _YYAnimatedImageViewFetchOperation : NSOperation
@property (nonatomic, weak) YYAnimatedImageView *view;
@property (nonatomic, assign) NSUInteger nextIndex;
@property (nonatomic, strong) UIImage <YYAnimatedImage> *curImage;
@end

@implementation _YYAnimatedImageViewFetchOperation
- (void)main {
    __strong YYAnimatedImageView *view = _view;
    if (!view) return;
    if ([self isCancelled]) return;
    view->_incrBufferCount++;
    if (view->_incrBufferCount == 0) [view calcMaxBufferCount];
    if (view->_incrBufferCount > (NSInteger)view->_maxBufferCount) {
        view->_incrBufferCount = view->_maxBufferCount;
    }
    NSUInteger idx = _nextIndex;
    NSUInteger max = view->_incrBufferCount < 1 ? 1 : view->_incrBufferCount;
    NSUInteger total = view->_totalFrameCount;
    view = nil;
    
    for (int i = 0; i < max; i++, idx++) {
        @autoreleasepool {
            if (idx >= total) idx = 0;
            if ([self isCancelled]) break;
            __strong YYAnimatedImageView *view = _view;
            if (!view) break;
            LOCK_VIEW(BOOL miss = (view->_buffer[@(idx)] == nil));
            if (miss) {
                UIImage *img = [_curImage animatedImageFrameAtIndex:idx];
                img = img.imageByDecoded;
                if ([self isCancelled]) break;
                LOCK_VIEW(view->_buffer[@(idx)] = img ? img : [NSNull null]);
                view = nil;
            }
        }
    }
}
@end

@implementation YYAnimatedImageView

#pragma mark - Init
/// learn: 初始化，设置了最基本的变量
- (instancetype)init {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    self.frame = (CGRect) {CGPointZero, image.size };
    self.image = image;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    self = [super init];
    _runloopMode = NSRunLoopCommonModes;
    _autoPlayAnimatedImage = YES;
    CGSize size = image ? image.size : highlightedImage.size;
    self.frame = (CGRect) {CGPointZero, size };
    self.image = image;
    self.highlightedImage = highlightedImage;
    return self;
}

// init the animated params.
/// 重置动画相关的参数，基本上所有变量都被重置了
- (void)resetAnimated {
    if (!_link) {
        _lock = dispatch_semaphore_create(1);
        _buffer = [NSMutableDictionary new];
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;      // 1
        _link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(step:)];
        if (_runloopMode) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        _link.paused = YES;
        // 监听系统事件的处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    
    [_requestQueue cancelAllOperations];
    LOCK(
         // tips: 在后台线程延迟释放
         if (_buffer.count) {
        NSMutableDictionary *holder = _buffer;
        _buffer = [NSMutableDictionary new];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Capture the dictionary to global queue,
            // release these images in background to avoid blocking UI thread.
            [holder class];
        });
    }
         );
    _link.paused = YES;
    _time = 0;
    if (_curIndex != 0) {
        // 通过 kvo 来监听当前的 frame 状态
        [self willChangeValueForKey:@"currentAnimatedImageIndex"];
        _curIndex = 0;
        [self didChangeValueForKey:@"currentAnimatedImageIndex"];
    }
    _curAnimatedImage = nil;
    _curFrame = nil;
    _curLoop = 0;
    _totalLoop = 0;
    _totalFrameCount = 1;
    _loopEnd = NO;
    _bufferMiss = NO;
    _incrBufferCount = 0;
}

#pragma mark - Set Image

/// learn: 所有的 set方法都进入了 setImage:withType:
- (void)setImage:(UIImage *)image {
    if (self.image == image) return;
    [self setImage:image withType:YYAnimatedImageTypeImage];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    if (self.highlightedImage == highlightedImage) return;
    [self setImage:highlightedImage withType:YYAnimatedImageTypeHighlightedImage];
}

- (void)setAnimationImages:(NSArray *)animationImages {
    if (self.animationImages == animationImages) return;
    [self setImage:animationImages withType:YYAnimatedImageTypeImages];
}

- (void)setHighlightedAnimationImages:(NSArray *)highlightedAnimationImages {
    if (self.highlightedAnimationImages == highlightedAnimationImages) return;
    [self setImage:highlightedAnimationImages withType:YYAnimatedImageTypeHighlightedImages];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (_link) [self resetAnimated];
    [self imageChanged];
}

- (id)imageForType:(YYAnimatedImageType)type {
    switch (type) {
            /// 下面getter 使用的是 self，而 setImage: withType: 中 setter 使用的是super
            /// 使用 super 而不是 self，是因为 setImage 被重写了
        case YYAnimatedImageTypeNone: return nil;
        case YYAnimatedImageTypeImage: return self.image;
        case YYAnimatedImageTypeHighlightedImage: return self.highlightedImage;
        case YYAnimatedImageTypeImages: return self.animationImages;
        case YYAnimatedImageTypeHighlightedImages: return self.highlightedAnimationImages;
    }
    return nil;
}

- (YYAnimatedImageType)currentImageType {
    YYAnimatedImageType curType = YYAnimatedImageTypeNone;
    if (self.highlighted) {
        if (self.highlightedAnimationImages.count) curType = YYAnimatedImageTypeHighlightedImages;
        else if (self.highlightedImage) curType = YYAnimatedImageTypeHighlightedImage;
    }
    if (curType == YYAnimatedImageTypeNone) {
        if (self.animationImages.count) curType = YYAnimatedImageTypeImages;
        else if (self.image) curType = YYAnimatedImageTypeImage;
    }
    return curType;
}

- (void)setImage:(id)image withType:(YYAnimatedImageType)type {
    [self stopAnimating];
    if (_link) [self resetAnimated];
    _curFrame = nil;
    switch (type) {
        case YYAnimatedImageTypeNone: break;
        case YYAnimatedImageTypeImage: super.image = image; break;  // 这里是 super，而不是 self，防止无限循环
        case YYAnimatedImageTypeHighlightedImage: super.highlightedImage = image; break;
        case YYAnimatedImageTypeImages: super.animationImages = image; break;
        case YYAnimatedImageTypeHighlightedImages: super.highlightedAnimationImages = image; break;
    }
    [self imageChanged];
}

/// 图像变动时，调用刷新
/// 调用层级：setHightlighted/setImage:withType
- (void)imageChanged {
    YYAnimatedImageType newType = [self currentImageType];
    id newVisibleImage = [self imageForType:newType];   // 获取当前显示的 image
    NSUInteger newImageFrameCount = 0;
    BOOL hasContentsRect = NO;
    
    // 判断是不是 spritesheet
    if ([newVisibleImage isKindOfClass:[UIImage class]] &&
        [newVisibleImage conformsToProtocol:@protocol(YYAnimatedImage)]) {
        newImageFrameCount = ((UIImage<YYAnimatedImage> *) newVisibleImage).animatedImageFrameCount;
        if (newImageFrameCount > 1) {
            // 是否只显示部分图像，YYImage 中只有 YYSpriteSheetImage 实现了该协议方法
            hasContentsRect = [((UIImage<YYAnimatedImage> *) newVisibleImage) respondsToSelector:@selector(animatedImageContentsRectAtIndex:)];
        }
    }
    
    /// 若上一次是 SpriteSheet 类型而当前显示的图片不是，归位 self.layer.contentsRect
    if (!hasContentsRect && _curImageHasContentsRect) {
        if (!CGRectEqualToRect(self.layer.contentsRect, CGRectMake(0, 0, 1, 1)) ) {
            /// 归位self.layer.contentsRect为CGRectMake(0, 0, 1, 1)
            /// 使用了CATransaction事务来取消隐式动画。（由于此处完全不需要那 0.25 秒的隐式动画）
            /*
             CATransaction事务类可以对多个layer的属性同时进行修改，它分隐式事务和显式事务。
             当我们向图层添加显式或隐式动画时，Core Animation都会自动创建隐式事务。
             * 区分隐式动画和隐式事务：隐式动画通过隐式事务实现动画 。
             * 区分显式动画和显式事务：显式动画有多种实现方式，显式事务是一种实现显式动画的方式。
             * 除显式事务外,任何对于CALayer属性的修改,都是隐式事务.
             */
            [CATransaction begin];  // 显示事务
            [CATransaction setDisableActions:YES];  // 设置动画过程是否显示
            self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            [CATransaction commit];
        }
    }
    _curImageHasContentsRect = hasContentsRect;
    
    // 如果是精灵图
    if (hasContentsRect) {
        CGRect rect = [((UIImage<YYAnimatedImage> *) newVisibleImage) animatedImageContentsRectAtIndex:0];
        [self setContentsRect:rect forImage:newVisibleImage];
    }
    
    // 3、多帧的图片，初始化显示多帧动画需要的配置
    if (newImageFrameCount > 1) {
        [self resetAnimated];
        _curAnimatedImage = newVisibleImage;
        _curFrame = newVisibleImage;
        _totalLoop = _curAnimatedImage.animatedImageLoopCount;
        _totalFrameCount = _curAnimatedImage.animatedImageFrameCount;
        [self calcMaxBufferCount];
    }
    [self setNeedsDisplay];
    [self didMoved];
}

// dynamically adjust buffer size for current memory.
- (void)calcMaxBufferCount {
    int64_t bytes = (int64_t)_curAnimatedImage.animatedImageBytesPerFrame;
    if (bytes == 0) bytes = 1024;
    // learn: calculate memory size
    int64_t total = [UIDevice currentDevice].memoryTotal;
    int64_t free = [UIDevice currentDevice].memoryFree;
    int64_t max = MIN(total * 0.2, free * 0.6); // 0.2 的总内存、0.6 的空余内存的最小值，作为可使用内存的最大值
    max = MAX(max, BUFFER_SIZE);        // BUFFER_SIZE 默认最小的为 10M
    if (_maxBufferSize) max = max > _maxBufferSize ? _maxBufferSize : max;
    double maxBufferCount = (double)max / (double)bytes;    // 可缓存的帧数
    maxBufferCount = YY_CLAMP(maxBufferCount, 1, 512);
    _maxBufferCount = maxBufferCount;
}

- (void)dealloc {
    [_requestQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_link invalidate];
}

- (BOOL)isAnimating {
    return self.currentIsPlayingAnimation;
}

- (void)stopAnimating {
    [super stopAnimating];  // UIImageView 就支持 stopAnimating
    [_requestQueue cancelAllOperations];
    _link.paused = YES;
    self.currentIsPlayingAnimation = NO;
}

- (void)startAnimating {
    YYAnimatedImageType type = [self currentImageType];
    if (type == YYAnimatedImageTypeImages || type == YYAnimatedImageTypeHighlightedImages) {
        NSArray *images = [self imageForType:type];
        if (images.count > 0) { // 如果是动图数组，调用 UIImageView startAnimating
            [super startAnimating];
            self.currentIsPlayingAnimation = YES;
        }
    } else {
        // 非动图
        if (_curAnimatedImage && _link.paused) {
            _curLoop = 0;
            _loopEnd = NO;
            _link.paused = NO;
            self.currentIsPlayingAnimation = YES;
        }
    }
}

#pragma mark - Cache Clear Time

/// 收到内存警告，清理缓存
- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [_requestQueue cancelAllOperations];
    [_requestQueue addOperationWithBlock: ^{
        _incrBufferCount = -60 - (int)(arc4random() % 120); // about 1~3 seconds to grow back..
        NSNumber *next = @((_curIndex + 1) % _totalFrameCount);
        LOCK(
             NSArray * keys = _buffer.allKeys;
             for (NSNumber * key in keys) {
            if (![key isEqualToNumber:next]) { // keep the next frame for smoothly animation
                [_buffer removeObjectForKey:key];
            }
        }
             )//LOCK
    }];
}

/// 退到后台，清理缓存
- (void)didEnterBackground:(NSNotification *)notification {
    [_requestQueue cancelAllOperations];
    NSNumber *next = @((_curIndex + 1) % _totalFrameCount);
    LOCK(
         NSArray * keys = _buffer.allKeys;
         for (NSNumber * key in keys) {
        if (![key isEqualToNumber:next]) { // keep the next frame for smoothly animation
            [_buffer removeObjectForKey:key];
        }
    }
         )//LOCK
}

- (void)step:(CADisplayLink *)link {
    UIImage <YYAnimatedImage> *image = _curAnimatedImage;
    NSMutableDictionary *buffer = _buffer;
    UIImage *bufferedImage = nil;
    NSUInteger nextIndex = (_curIndex + 1) % _totalFrameCount;
    BOOL bufferIsFull = NO;
    
    if (!image) return;
    if (_loopEnd) { // view will keep in last frame
        [self stopAnimating];
        return;
    }
    
    NSTimeInterval delay = 0;
    if (!_bufferMiss) { // 上一次未丢帧
        _time += link.duration;
        delay = [image animatedImageDurationAtIndex:_curIndex];
        if (_time < delay) return;  // 刷新时间还没到
        _time -= delay;
        if (nextIndex == 0) {   // 下一帧是首帧，检查是否超过 loop 数目
            _curLoop++;
            if (_curLoop >= _totalLoop && _totalLoop != 0) {
                _loopEnd = YES;
                [self stopAnimating];
                [self.layer setNeedsDisplay]; // let system call `displayLayer:` before runloop sleep
                return; // stop at last frame
            }
        }
        delay = [image animatedImageDurationAtIndex:nextIndex];
        if (_time > delay) _time = delay; // do not jump over frame
    }
    LOCK(
         // 获取当前 nextIndex 图片
         bufferedImage = buffer[@(nextIndex)];
         // 命中
         if (bufferedImage) {
        if ((int)_incrBufferCount < _totalFrameCount) {
            [buffer removeObjectForKey:@(nextIndex)];
        }
        [self willChangeValueForKey:@"currentAnimatedImageIndex"];
        _curIndex = nextIndex;
        [self didChangeValueForKey:@"currentAnimatedImageIndex"];
        _curFrame = bufferedImage == (id)[NSNull null] ? nil : bufferedImage;
        if (_curImageHasContentsRect) {
            _curContentsRect = [image animatedImageContentsRectAtIndex:_curIndex];
            [self setContentsRect:_curContentsRect forImage:_curFrame];
        }
        // 计算下一个图片
        nextIndex = (_curIndex + 1) % _totalFrameCount;
        _bufferMiss = NO;
        
        if (buffer.count == _totalFrameCount) {
            // 已获取所有图像
            bufferIsFull = YES;
        }
    } else {
        _bufferMiss = YES;
    }
         )//LOCK
    
    if (!_bufferMiss) {
        [self.layer setNeedsDisplay]; // let system call `displayLayer:` before runloop sleep
    }
    
    if (!bufferIsFull && _requestQueue.operationCount == 0) { // if some work not finished, wait for next opportunity
        _YYAnimatedImageViewFetchOperation *operation = [_YYAnimatedImageViewFetchOperation new];
        operation.view = self;
        operation.nextIndex = nextIndex;
        operation.curImage = image;
        [_requestQueue addOperation:operation];
    }
}


/// 重绘：setNeedsDisplay 会回调该方法，displayLayer是 CALayerDelegate 的方法之一
- (void)displayLayer:(CALayer *)layer {
    if (_curFrame) {
        layer.contents = (__bridge id)_curFrame.CGImage;
    }
}

- (void)setContentsRect:(CGRect)rect forImage:(UIImage *)image{
    CGRect layerRect = CGRectMake(0, 0, 1, 1);
    if (image) {
        CGSize imageSize = image.size;
        if (imageSize.width > 0.01 && imageSize.height > 0.01) {
            layerRect.origin.x = rect.origin.x / imageSize.width;
            layerRect.origin.y = rect.origin.y / imageSize.height;
            layerRect.size.width = rect.size.width / imageSize.width;
            layerRect.size.height = rect.size.height / imageSize.height;
            layerRect = CGRectIntersection(layerRect, CGRectMake(0, 0, 1, 1));
            if (CGRectIsNull(layerRect) || CGRectIsEmpty(layerRect)) {
                layerRect = CGRectMake(0, 0, 1, 1);
            }
        }
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.contentsRect = layerRect;
    [CATransaction commit];
}

#pragma mark - Strat/Stop time
- (void)didMoved {
    if (self.autoPlayAnimatedImage) {
        if(self.superview && self.window) {
            [self startAnimating];
        } else {
            [self stopAnimating];
        }
    }
}
/// 在视图层级变更时调用是否启动动画 didMoved
/// 在 imageview 添加到父视图或者从父视图移除时，window 更改会回调该方法
- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self didMoved];
}
/// 在 imageview 添加到父视图或者从父视图移除时，会回调该方法
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self didMoved];
}

- (void)setCurrentAnimatedImageIndex:(NSUInteger)currentAnimatedImageIndex {
    if (!_curAnimatedImage) return;
    if (currentAnimatedImageIndex >= _curAnimatedImage.animatedImageFrameCount) return;
    if (_curIndex == currentAnimatedImageIndex) return;
    
    dispatch_async_on_main_queue(^{
        LOCK(
             [_requestQueue cancelAllOperations];
             [_buffer removeAllObjects];
             [self willChangeValueForKey:@"currentAnimatedImageIndex"];
             _curIndex = currentAnimatedImageIndex;
             [self didChangeValueForKey:@"currentAnimatedImageIndex"];
             _curFrame = [_curAnimatedImage animatedImageFrameAtIndex:_curIndex];
             if (_curImageHasContentsRect) {
            _curContentsRect = [_curAnimatedImage animatedImageContentsRectAtIndex:_curIndex];
        }
             _time = 0;
             _loopEnd = NO;
             _bufferMiss = NO;
             [self.layer setNeedsDisplay];
             )//LOCK
    });
}

- (NSUInteger)currentAnimatedImageIndex {
    return _curIndex;
}

- (void)setRunloopMode:(NSString *)runloopMode {
    if ([_runloopMode isEqual:runloopMode]) return;
    if (_link) {
        if (_runloopMode) {
            [_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:_runloopMode];
        }
        if (runloopMode.length) {
            [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:runloopMode];
        }
    }
    _runloopMode = runloopMode.copy;
}

#pragma mark - Overrice NSObject(NSKeyValueObservingCustomization)

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"currentAnimatedImageIndex"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _runloopMode = [aDecoder decodeObjectForKey:@"runloopMode"];
    if (_runloopMode.length == 0) _runloopMode = NSRunLoopCommonModes;
    if ([aDecoder containsValueForKey:@"autoPlayAnimatedImage"]) {
        _autoPlayAnimatedImage = [aDecoder decodeBoolForKey:@"autoPlayAnimatedImage"];
    } else {
        _autoPlayAnimatedImage = YES;
    }
    
    UIImage *image = [aDecoder decodeObjectForKey:@"YYAnimatedImage"];
    UIImage *highlightedImage = [aDecoder decodeObjectForKey:@"YYHighlightedAnimatedImage"];
    if (image) {
        self.image = image;
        [self setImage:image withType:YYAnimatedImageTypeImage];
    }
    if (highlightedImage) {
        self.highlightedImage = highlightedImage;
        [self setImage:highlightedImage withType:YYAnimatedImageTypeHighlightedImage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_runloopMode forKey:@"runloopMode"];
    [aCoder encodeBool:_autoPlayAnimatedImage forKey:@"autoPlayAnimatedImage"];
    
    BOOL ani, multi;
    ani = [self.image conformsToProtocol:@protocol(YYAnimatedImage)];
    multi = (ani && ((UIImage <YYAnimatedImage> *)self.image).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.image forKey:@"YYAnimatedImage"];
    
    ani = [self.highlightedImage conformsToProtocol:@protocol(YYAnimatedImage)];
    multi = (ani && ((UIImage <YYAnimatedImage> *)self.highlightedImage).animatedImageFrameCount > 1);
    if (multi) [aCoder encodeObject:self.highlightedImage forKey:@"YYHighlightedAnimatedImage"];
}

@end
