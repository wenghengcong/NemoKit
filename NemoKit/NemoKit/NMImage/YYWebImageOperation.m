//
//  YYWebImageOperation.m
//  YYKit <https://github.com/ibireme/YYKit>
//
//  Created by ibireme on 15/2/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYWebImageOperation.h"
#import "UIApplication+YYAdd.h"
#import "YYImage.h"
#import "YYWeakProxy.h"
#import "UIImage+YYAdd.h"
#import <ImageIO/ImageIO.h>
#import "YYKitMacro.h"

#if __has_include("YYDispatchQueuePool.h")
#import "YYDispatchQueuePool.h"
#else
#import <libkern/OSAtomic.h>
#endif

#define MIN_PROGRESSIVE_TIME_INTERVAL 0.2
#define MIN_PROGRESSIVE_BLUR_TIME_INTERVAL 0.4

/// Returns YES if the right-bottom pixel is filled.
static BOOL YYCGImageLastPixelFilled(CGImageRef image) {
    if (!image) return NO;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    if (width == 0 || height == 0) return NO;
    CGContextRef ctx = CGBitmapContextCreate(NULL, 1, 1, 8, 0, YYCGColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrderDefault);
    if (!ctx) return NO;
    CGContextDrawImage(ctx, CGRectMake( -(int)width + 1, 0, width, height), image);
    uint8_t *bytes = CGBitmapContextGetData(ctx);
    BOOL isAlpha = bytes && bytes[0] == 0;
    CFRelease(ctx);
    return !isAlpha;
}

/// Returns JPEG SOS (Start Of Scan) Marker
static NSData *JPEGSOSMarker() {
    // "Start Of Scan" Marker
    static NSData *marker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint8_t bytes[2] = {0xFF, 0xDA};
        marker = [NSData dataWithBytes:bytes length:2];
    });
    return marker;
}

// url 黑名单
static NSMutableSet *URLBlacklist;      //  learn: 相比于 array和 dictionary 效率更高效
static dispatch_semaphore_t URLBlacklistLock;

static void URLBlacklistInit() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        URLBlacklist = [NSMutableSet new];
        URLBlacklistLock = dispatch_semaphore_create(1);
    });
}

static BOOL URLBlackListContains(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return NO;
    URLBlacklistInit();
    dispatch_semaphore_wait(URLBlacklistLock, DISPATCH_TIME_FOREVER);
    BOOL contains = [URLBlacklist containsObject:url];
    dispatch_semaphore_signal(URLBlacklistLock);
    return contains;
}

static void URLInBlackListAdd(NSURL *url) {
    if (!url || url == (id)[NSNull null]) return;
    URLBlacklistInit();
    dispatch_semaphore_wait(URLBlacklistLock, DISPATCH_TIME_FOREVER);
    [URLBlacklist addObject:url];
    dispatch_semaphore_signal(URLBlacklistLock);
}


/// learn: 认证研读并学习自定义并发 NSOperation 的实现
@interface YYWebImageOperation() <NSURLConnectionDelegate>
@property (readwrite, getter=isExecuting) BOOL executing;
@property (readwrite, getter=isFinished) BOOL finished;
@property (readwrite, getter=isCancelled) BOOL cancelled;
@property (readwrite, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) NSInteger expectedSize;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskID;

@property (nonatomic, assign) NSTimeInterval lastProgressiveDecodeTimestamp;
@property (nonatomic, strong) YYImageDecoder *progressiveDecoder;
@property (nonatomic, assign) BOOL progressiveIgnored;
@property (nonatomic, assign) BOOL progressiveDetected;
@property (nonatomic, assign) NSUInteger progressiveScanedLength;
@property (nonatomic, assign) NSUInteger progressiveDisplayCount;

@property (nonatomic, copy) YYWebImageProgressBlock progress;
@property (nonatomic, copy) YYWebImageTransformBlock transform;
@property (nonatomic, copy) YYWebImageCompletionBlock completion;
@end


@implementation YYWebImageOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

/// Network thread entry point.
+ (void)_networkThreadMain:(id)object {
    @autoreleasepool {
        // 线程保活
        // 一个 runLoop 中如果source/timer/observer 都为空则会直接退出，并不进入循环。这里 runLoop 添加了一个 NSMachPort ，这个port开启相当于添加了一个Source1事件源，但是这个事件源并没有真正的监听什么东西，只是为了不让 runLoop 退出。
        [[NSThread currentThread] setName:@"com.ibireme.yykit.webimage.request"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

/// Global image request network thread, used by NSURLConnection delegate.
+ (NSThread *)_networkThread {
    static NSThread *thread = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 创建一个线程来执行 image download 的操作
        thread = [[NSThread alloc] initWithTarget:self selector:@selector(_networkThreadMain:) object:nil];
        if ([thread respondsToSelector:@selector(setQualityOfService:)]) {
            thread.qualityOfService = NSQualityOfServiceBackground;
        }
        // 启动线程
        [thread start];
    });
    return thread;
}

/// Global image queue, used for image reading and decoding.
+ (dispatch_queue_t)_imageQueue {
#ifdef YYDispatchQueuePool_h
    return YYDispatchQueueGetForQOS(NSQualityOfServiceUtility);
#else
    // learn: 在区间内定义 #define / #undef
    #define MAX_QUEUE_COUNT 16
    static int queueCount;
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
                queues[i] = dispatch_queue_create("com.ibireme.yykit.decode", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.yykit.decode", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
            }
        }
    });
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
    #undef MAX_QUEUE_COUNT
#endif
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYWebImageOperation init error" reason:@"YYWebImageOperation must be initialized with a request. Use the designated initializer to init." userInfo:nil];
    return [self initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]] options:0 cache:nil cacheKey:nil progress:nil transform:nil completion:nil];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                        options:(YYWebImageOptions)options
                          cache:(YYImageCache *)cache
                       cacheKey:(NSString *)cacheKey
                       progress:(YYWebImageProgressBlock)progress
                      transform:(YYWebImageTransformBlock)transform
                     completion:(YYWebImageCompletionBlock)completion {
    self = [super init];
    if (!self) return nil;
    if (!request) return nil;
    _request = request;
    _options = options;
    _cache = cache;
    _cacheKey = cacheKey ? cacheKey : request.URL.absoluteString;
    _shouldUseCredentialStorage = YES;
    _progress = progress;
    _transform = transform;
    _completion = completion;
    _executing = NO;
    _finished = NO;
    _cancelled = NO;
    _taskID = UIBackgroundTaskInvalid;
    _lock = [NSRecursiveLock new];
    return self;
}

- (void)dealloc {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        [[UIApplication sharedExtensionApplication] endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    if ([self isExecuting]) {
        self.cancelled = YES;
        self.finished = YES;
        if (_connection) {
            [_connection cancel];
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                // decrementNetworkActivityCount 维护了一个全局的活动网络请求数
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
        }
        if (_completion) {
            @autoreleasepool {
                _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
            }
        }
    }
    [_lock unlock];
}

- (void)_endBackgroundTask {
    [_lock lock];
    if (_taskID != UIBackgroundTaskInvalid) {
        // 假如启用了background task，必须调用该方法，否则系统会杀掉 APP
        [[UIApplication sharedExtensionApplication] endBackgroundTask:_taskID];
        _taskID = UIBackgroundTaskInvalid;
    }
    [_lock unlock];
}

#pragma mark - Runs in operation thread

- (void)_finish {
    self.executing = NO;
    self.finished = YES;
    [self _endBackgroundTask];
}

// runs on network thread
- (void)_startOperation {
    if ([self isCancelled]) return;
    @autoreleasepool {
        // get image from cache
        if (_cache &&
            !(_options & YYWebImageOptionUseNSURLCache) &&
            !(_options & YYWebImageOptionRefreshImageCache)) {
            // 不采用NSURLCache，不刷新本地 cache image
            
            // 1. 先从内存缓存取 image
            UIImage *image = [_cache getImageForKey:_cacheKey withType:YYImageCacheTypeMemory];
            if (image) {
                [_lock lock];
                if (![self isCancelled]) {
                    if (_completion) _completion(image, _request.URL, YYWebImageFromMemoryCache, YYWebImageStageFinished, nil);
                }
                [self _finish];
                [_lock unlock];
                return;
            }
            
            // 2. 从磁盘缓存取 image
            if (!(_options & YYWebImageOptionIgnoreDiskCache)) {
                __weak typeof(self) _self = self;
                dispatch_async([self.class _imageQueue], ^{
                    __strong typeof(_self) self = _self;
                    if (!self || [self isCancelled]) return;
                    UIImage *image = [self.cache getImageForKey:self.cacheKey withType:YYImageCacheTypeDisk];
                    if (image) {
                        // learn: 注意一个缓存的策略，就是从 disk 读取到的 image，一定要 set memory
                        [self.cache setImage:image imageData:nil forKey:self.cacheKey withType:YYImageCacheTypeMemory];
                        [self performSelector:@selector(_didReceiveImageFromDiskCache:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
                    } else {
                        // 3. 未取到 image，开始从 network 获取
                        [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
                    }
                });
                return;
            }
        }
    }
    
    // 3. 既不从 memory，也不从 disk 获取，直接从 network 获取
    [self performSelector:@selector(_startRequest:) onThread:[self.class _networkThread] withObject:nil waitUntilDone:NO];
}

// runs on network thread
- (void)_startRequest:(id)object {
    if ([self isCancelled]) return;
    @autoreleasepool {
        if ((_options & YYWebImageOptionIgnoreFailedURL) && URLBlackListContains(_request.URL)) {
            //  1. 是否需要忽略已经失败的 url
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
            [_lock lock];
            if (![self isCancelled]) {
                if (_completion) _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
            }
            [self _finish];
            [_lock unlock];
            return;
        }
        
        /*
         learn: An NSURL is a file URL only if it begins with file://
         If you want to create an NSURL from a file path, you must use NSURL fileURLWithPath:.
         The use of URLWithString assumes the string is a non-file URL
         */
        if (_request.URL.isFileURL) {
            // learn: 从file path 读取 file 的相关属性，这是从本地读取的图片
            NSArray *keys = @[NSURLFileSizeKey];
            NSDictionary *attr = [_request.URL resourceValuesForKeys:keys error:nil];
            NSNumber *fileSize = attr[NSURLFileSizeKey];
            // learn: -1 一般代表异常
            _expectedSize = (fileSize != nil) ? fileSize.unsignedIntegerValue : -1;
        }
        
        // request image from web
        [_lock lock];
        if (![self isCancelled]) {
            // 2. 开始进行网络请求
            _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:[YYWeakProxy proxyWithTarget:self]];
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] incrementNetworkActivityCount];
            }
        }
        [_lock unlock];
    }
}

// runs on network thread, called from outer "cancel"
- (void)_cancelOperation {
    @autoreleasepool {
        if (_connection) {
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
        }
        [_connection cancel];
        _connection = nil;
        if (_completion) _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageCancelled, nil);
        [self _endBackgroundTask];  // 结束后台任务
    }
}


// runs on network thread
- (void)_didReceiveImageFromDiskCache:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (image) {
                if (_completion) _completion(image, _request.URL, YYWebImageFromDiskCache, YYWebImageStageFinished, nil);
                [self _finish];
            } else {
                [self _startRequest:nil];
            }
        }
        [_lock unlock];
    }
}

- (void)_didReceiveImageFromWeb:(UIImage *)image {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_cache) {
                if (image || (_options & YYWebImageOptionRefreshImageCache)) {
                    NSData *data = _data;
                    dispatch_async([YYWebImageOperation _imageQueue], ^{
                        YYImageCacheType cacheType = (_options & YYWebImageOptionIgnoreDiskCache) ? YYImageCacheTypeMemory : YYImageCacheTypeAll;
                        [_cache setImage:image imageData:data forKey:_cacheKey withType:cacheType];

                    });
                }
            }
            _data = nil;
            NSError *error = nil;
            if (!image) {
                error = [NSError errorWithDomain:@"com.ibireme.yykit.image" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Web image decode fail." }];
                if (_options & YYWebImageOptionIgnoreFailedURL) {
                    if (URLBlackListContains(_request.URL)) {
                        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{ NSLocalizedDescriptionKey : @"Failed to load URL, blacklisted." }];
                    } else {
                        URLInBlackListAdd(_request.URL);
                    }
                }
            }
            if (_completion) _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageFinished, error);
            [self _finish];
        }
        [_lock unlock];
    }
}

#pragma mark - NSURLConnectionDelegate runs in operation thread

/// 是否存储 credential storage
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return _shouldUseCredentialStorage;
}

/*
learn: 1. 只要请求的地址是HTTPS的, 就会调用这个代理方法
我们需要在该方法中告诉系统, 是否信任服务器返回的证书
challenge: NSURLAuthenticationChallenge, 挑战 质问 (包含了受保护的区域)，包含了以下：
 - protectionSpace : 受保护区域
 - NSURLAuthenticationMethodServerTrust : 证书的类型是 服务器信任
 - error ：最后一次授权失败的错误信息
 - failureResponse ：最后一次授权失败的错误信息
 - previousFailureCount ：授权失败的次数
 - proposedCredential ：建议使用的证书
 - protectionSpace ：NSURLProtectionSpace对象，代表了服务器上的一块需要授权信息的区域。包括了服务器地址、端口等信息。在此指的是challenge.protectionSpace。其中Auth-scheme指protectionSpace所支持的验证方法，NSURLAuthenticationMethodServerTrust指对protectionSpace执行证书验证。
*/
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    @autoreleasepool {
        // 1.判断服务器返回的证书类型, 是否是服务器信任
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if (!(_options & YYWebImageOptionAllowInvalidSSLCertificates) &&
                [challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
                [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
            } else {
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            }
        } else {
            // 2. 非服务器信任，使用凭据，此处由 YYWebImageManager 传入有 username、password 的凭据
            if ([challenge previousFailureCount] == 0) {
                if (_credential) {
                    // 使用凭据连接
                    [[challenge sender] useCredential:_credential forAuthenticationChallenge:challenge];
                } else {
                    // 不使用凭据，继续连接
                    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
                }
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        }
    }
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if (!cachedResponse) return cachedResponse;
    if (_options & YYWebImageOptionUseNSURLCache) {
        return cachedResponse;
    } else {
        // ignore NSURLCache
        return nil;
    }
}

/*
 * 2. 当接受到服务器响应的时候会调用:response(响应头)，代理会收到connection:didReceiveResponse:消息。
 * 这个代理方法会检查NSURLResponse对象并确认数据的content-type，MIME类型，文件 名和其它元数据。
 * 需要注意的是，对于单个连接，我们可能会接多次收到connection:didReceiveResponse:消息；这咱情况发生在
 * 响应是多重MIME编码的情况下。每次代理接收到connection:didReceiveResponse:时，应该重设进度标识
 * 并丢弃之前接收到的数据。
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @autoreleasepool {
        NSError *error = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (id) response;
            NSInteger statusCode = httpResponse.statusCode;
            if (statusCode >= 400 || statusCode == 304) {
                // 304 内容未做更改，4** 客户端错误，请求包含语法错误或无法完成请求
                error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil];
            }
        }
        if (error) {
            [_connection cancel];
            [self connection:_connection didFailWithError:error];
        } else {
            // 处理_expectedSize
            if (response.expectedContentLength) {
                _expectedSize = (NSInteger)response.expectedContentLength;
                if (_expectedSize < 0) _expectedSize = -1;
            }
            _data = [NSMutableData dataWithCapacity:_expectedSize > 0 ? _expectedSize : 0];
            if (_progress) {
                [_lock lock];
                if (![self isCancelled]) _progress(0, _expectedSize);
                [_lock unlock];
            }
        }
    }
}

/* learn: 3. 当接受到服务器返回数据的时候调用(会调用多次)，该消息用于接收服务端返回的数据实体。
    该方法负责存储数据。我们也可以用这个方法提供进度信息.
 * 这种情况下，我们需要在connection:didReceiveResponse:方法中
 * 调用响应对象的expectedContentLength方法来获取数据的总长度。
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @autoreleasepool {
        [_lock lock];
        BOOL canceled = [self isCancelled];
        [_lock unlock];
        if (canceled) return;
        
        if (data) [_data appendData:data];
        // progress block
        if (_progress) {
            [_lock lock];
            if (![self isCancelled]) {
                _progress(_data.length, _expectedSize);
            }
            [_lock unlock];
        }
        
        /*--------------------------- progressive ----------------------------*/
        BOOL progressive = (_options & YYWebImageOptionProgressive) > 0;
        BOOL progressiveBlur = (_options & YYWebImageOptionProgressiveBlur) > 0;
        if (!_completion || !(progressive || progressiveBlur)) return;
        if (data.length <= 16) return;
        if (_expectedSize > 0 && data.length >= _expectedSize * 0.99) return;   // > 0.99 表示已下载完成
        if (_progressiveIgnored) return;
        
        NSTimeInterval min = progressiveBlur ? MIN_PROGRESSIVE_BLUR_TIME_INTERVAL : MIN_PROGRESSIVE_TIME_INTERVAL;
        NSTimeInterval now = CACurrentMediaTime();
        if (now - _lastProgressiveDecodeTimestamp < min) return;
        
        if (!_progressiveDecoder) {
            _progressiveDecoder = [[YYImageDecoder alloc] initWithScale:[UIScreen mainScreen].scale];
        }
        [_progressiveDecoder updateData:_data final:NO];
        if ([self isCancelled]) return;
        
        if (_progressiveDecoder.type == YYImageTypeUnknown ||
            _progressiveDecoder.type == YYImageTypeWebP ||
            _progressiveDecoder.type == YYImageTypeOther) {
            _progressiveDecoder = nil;
            _progressiveIgnored = YES;
            return;
        }
        if (progressiveBlur) { // only support progressive JPEG and interlaced PNG
            if (_progressiveDecoder.type != YYImageTypeJPEG &&
                _progressiveDecoder.type != YYImageTypePNG) {
                _progressiveDecoder = nil;
                _progressiveIgnored = YES;
                return;
            }
        }
        if (_progressiveDecoder.frameCount == 0) return;
        
        if (!progressiveBlur) {
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            if (frame.image) {
                [_lock lock];
                if (![self isCancelled]) {
                    _completion(frame.image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
            return;
        } else {
            if (_progressiveDecoder.type == YYImageTypeJPEG) {
                if (!_progressiveDetected) {
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *jpeg = dic[(id)kCGImagePropertyJFIFDictionary];
                    NSNumber *isProg = jpeg[(id)kCGImagePropertyJFIFIsProgressive];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
                
                NSInteger scanLength = (NSInteger)_data.length - (NSInteger)_progressiveScanedLength - 4;
                if (scanLength <= 2) return;
                NSRange scanRange = NSMakeRange(_progressiveScanedLength, scanLength);
                NSRange markerRange = [_data rangeOfData:JPEGSOSMarker() options:kNilOptions range:scanRange];
                _progressiveScanedLength = _data.length;
                if (markerRange.location == NSNotFound) return;
                if ([self isCancelled]) return;
                
            } else if (_progressiveDecoder.type == YYImageTypePNG) {
                if (!_progressiveDetected) {
                    NSDictionary *dic = [_progressiveDecoder framePropertiesAtIndex:0];
                    NSDictionary *png = dic[(id)kCGImagePropertyPNGDictionary];
                    NSNumber *isProg = png[(id)kCGImagePropertyPNGInterlaceType];
                    if (!isProg.boolValue) {
                        _progressiveIgnored = YES;
                        _progressiveDecoder = nil;
                        return;
                    }
                    _progressiveDetected = YES;
                }
            }
            
            YYImageFrame *frame = [_progressiveDecoder frameAtIndex:0 decodeForDisplay:YES];
            UIImage *image = frame.image;
            if (!image) return;
            if ([self isCancelled]) return;
            
            if (!YYCGImageLastPixelFilled(image.CGImage)) return;
            _progressiveDisplayCount++;
            
            CGFloat radius = 32;
            if (_expectedSize > 0) {
                radius *= 1.0 / (3 * _data.length / (CGFloat)_expectedSize + 0.6) - 0.25;
            } else {
                radius /= (_progressiveDisplayCount);
            }
            image = [image imageByBlurRadius:radius tintColor:nil tintMode:0 saturation:1 maskImage:nil];
            
            if (image) {
                [_lock lock];
                if (![self isCancelled]) {
                    _completion(image, _request.URL, YYWebImageFromRemote, YYWebImageStageProgress, nil);
                    _lastProgressiveDecodeTimestamp = now;
                }
                [_lock unlock];
            }
        }
    }
}

// learn: 4.2 当请求完成的回调
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @autoreleasepool {
        [_lock lock];
        _connection = nil;
        if (![self isCancelled]) {
            __weak typeof(self) _self = self;
            dispatch_async([self.class _imageQueue], ^{
                __strong typeof(_self) self = _self;
                if (!self) return;
                
                BOOL shouldDecode = (self.options & YYWebImageOptionIgnoreImageDecoding) == 0;
                BOOL allowAnimation = (self.options & YYWebImageOptionIgnoreAnimatedImage) == 0;
                UIImage *image;
                BOOL hasAnimation = NO;
                if (allowAnimation) {
                    image = [[YYImage alloc] initWithData:self.data scale:[UIScreen mainScreen].scale];
                    if (shouldDecode) image = [image imageByDecoded];
                    if ([((YYImage *)image) animatedImageFrameCount] > 1) {
                        hasAnimation = YES;
                    }
                } else {
                    YYImageDecoder *decoder = [YYImageDecoder decoderWithData:self.data scale:[UIScreen mainScreen].scale];
                    image = [decoder frameAtIndex:0 decodeForDisplay:shouldDecode].image;
                }
                
                /*
                 If the image has animation, save the original image data to disk cache.
                 If the image is not PNG or JPEG, re-encode the image to PNG or JPEG for
                 better decoding performance.
                 */
                YYImageType imageType = YYImageDetectType((__bridge CFDataRef)self.data);
                switch (imageType) {
                    case YYImageTypeJPEG:
                    case YYImageTypeGIF:
                    case YYImageTypePNG:
                    case YYImageTypeWebP: { // save to disk cache
                        if (!hasAnimation) {
                            if (imageType == YYImageTypeGIF ||
                                imageType == YYImageTypeWebP) {
                                self.data = nil; // clear the data, re-encode for disk cache
                            }
                        }
                    } break;
                    default: {
                        self.data = nil; // clear the data, re-encode for disk cache
                    } break;
                }
                if ([self isCancelled]) return;
                
                if (self.transform && image) {
                    UIImage *newImage = self.transform(image, self.request.URL);
                    if (newImage != image) {
                        self.data = nil;
                    }
                    image = newImage;
                    if ([self isCancelled]) return;
                }
                
                [self performSelector:@selector(_didReceiveImageFromWeb:) onThread:[self.class _networkThread] withObject:image waitUntilDone:NO];
            });
            if (![self.request.URL isFileURL] && (self.options & YYWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
        }
        [_lock unlock];
    }
}

// learn: 4.1 当请求失败的回调
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @autoreleasepool {
        [_lock lock];
        if (![self isCancelled]) {
            if (_completion) {
                _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
            }
            _connection = nil;
            _data = nil;
            if (![_request.URL isFileURL] && (_options & YYWebImageOptionShowNetworkActivity)) {
                [[UIApplication sharedExtensionApplication] decrementNetworkActivityCount];
            }
            [self _finish];
            
            if (_options & YYWebImageOptionIgnoreFailedURL) {
                if (error.code != NSURLErrorNotConnectedToInternet &&
                    error.code != NSURLErrorCancelled &&
                    error.code != NSURLErrorTimedOut &&
                    error.code != NSURLErrorUserCancelledAuthentication &&
                    error.code != NSURLErrorNetworkConnectionLost) {
                    URLInBlackListAdd(_request.URL);
                }
            }
        }
        [_lock unlock];
    }
}

#pragma mark - Override NSOperation

/// learn: 并发task，需要实现 start。并且还需要实现asynchronous、executing、finished
/// 不要在此方法调用 super，可以同自定义实现同步任务的对比：_YYAnimatedImageViewFetchOperation
- (void)start {
    @autoreleasepool {
        [_lock lock];
        self.started = YES;
        if ([self isCancelled]) {
            // 被取消
            [self performSelector:@selector(_cancelOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
            self.finished = YES;
        } else if ([self isReady] && ![self isFinished] && ![self isExecuting]) {
            // ready but not executing
            if (!_request) {    // if input request is nil,finish the request
                self.finished = YES;
                if (_completion) {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:@{NSLocalizedDescriptionKey:@"request in nil"}];
                    _completion(nil, _request.URL, YYWebImageFromNone, YYWebImageStageFinished, error);
                }
            } else {    // otherwise requesting for image
                self.executing = YES;
                [self performSelector:@selector(_startOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
                if ((_options & YYWebImageOptionAllowBackgroundTask) && ![UIApplication isAppExtension]) {
                    __weak __typeof__ (self) _self = self;
                    if (_taskID == UIBackgroundTaskInvalid) {
                        _taskID = [[UIApplication sharedExtensionApplication] beginBackgroundTaskWithExpirationHandler:^{
                            // 在开启后台任务后，如果任务未完成，则会走到这里，在这里需要清理相关资源，并结束后台任务
                            __strong __typeof (_self) self = _self;
                            if (self) {
                                [self cancel];  // 结束后台任务
                                self.finished = YES;
                            }
                        }];
                    }
                }
            }
        }
        [_lock unlock];
    }
}

- (void)cancel {
    [_lock lock];
    if (![self isCancelled]) {
        [super cancel];
        self.cancelled = YES;
        if ([self isExecuting]) {
            self.executing = NO;
            [self performSelector:@selector(_cancelOperation) onThread:[[self class] _networkThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
        }
        if (self.started) {
            self.finished = YES;
        }
    }
    [_lock unlock];
}

#pragma mark - property setter

- (void)setExecuting:(BOOL)executing {
    [_lock lock];
    if (_executing != executing) {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    [_lock unlock];
}

- (BOOL)isExecuting {
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}

- (void)setFinished:(BOOL)finished {
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}

- (BOOL)isFinished {
    [_lock lock];
    BOOL finished = _finished;
    [_lock unlock];
    return finished;
}

- (void)setCancelled:(BOOL)cancelled {
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
}

- (BOOL)isCancelled {
    [_lock lock];
    BOOL cancelled = _cancelled;
    [_lock unlock];
    return cancelled;
}
// 支持并发
- (BOOL)isConcurrent {
    return YES;
}
// 支持异步
- (BOOL)isAsynchronous {
    return YES;
}


/// learn: 是否自动发送通知
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

/// learn: 最好实现该方法，可以在 NSLog 中实现 po 对象
- (NSString *)description {
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p ",self.class, self];
    [string appendFormat:@" executing:%@", [self isExecuting] ? @"YES" : @"NO"];
    [string appendFormat:@" finished:%@", [self isFinished] ? @"YES" : @"NO"];
    [string appendFormat:@" cancelled:%@", [self isCancelled] ? @"YES" : @"NO"];
    [string appendString:@">"];
    return string;
}

@end
