//
//  UIImage+NMUITheme.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIImage+NMUITheme.h"
#import "NMUIThemePrivate.h"
#import "NMUIThemeManagerCenter.h"
#import "NSMethodSignature+NMBF.h"
#import "NMBFRuntimeMacro.h"
#import "NSObject+NMBF.h"
#import <objc/message.h>
#import "NSMethodSignature+NMBF.h"

@interface NMUIThemeImageCache : NSCache

@end

@implementation NMUIThemeImageCache

- (instancetype)init {
    if (self = [super init]) {
        // NSCache 在 app 进入后台时会删除所有缓存，它的实现方式是在 init 的时候去监听 UIApplicationDidEnterBackgroundNotification ，一旦进入后台则调用 removeAllObjects，通过 removeObserver 可以禁用掉这个策略
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

@end

@interface NMUIThemeImage()

@property(nonatomic, strong) NMUIThemeImageCache *cachedRawImages;

@end

@implementation NMUIThemeImage


static IMP nmui_getMsgForwardIMP(NSObject *self, SEL selector) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    Class cls = self.class;
    Method method = class_getInstanceMethod(cls, selector);
    const char *typeDescription = method_getTypeEncoding(method);
    if (typeDescription[0] == '{') {
        // 以下代码参考 JSPatch 的实现：
        //In some cases that returns struct, we should use the '_stret' API:
        //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
        //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    return msgForwardIMP;
}


+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = [NMUIThemeImage class];
        UIImage *instance =  UIImage.new;
        // QMUIThemeImage 覆盖重写了大部分 UIImage 的方法，在这些方法调用时，会交给 nmui_rawImage 处理
        // 除此之外 UIImage 内部还有很多私有方法，无法全部在 QMUIThemeImage 重写一遍，这些方法将通过消息转发的形式交给 nmui_rawImage 调用。
        [NSObject nmbf_enumrateInstanceMethodsOfClass:instance.class includingInherited:NO usingBlock:^(Method  _Nonnull method, SEL  _Nonnull selector) {
            // 如果 QMUIThemeImage 已经实现了该方法，则不需要消息转发
            if (class_getInstanceMethod(selfClass, selector) != method) return;
            const char * typeDescription = (char *)method_getTypeEncoding(method);
            class_addMethod(selfClass, selector, nmui_getMsgForwardIMP(instance, selector), typeDescription);
        }];
        
        // dealloc 时，不应该转发给 nmui_rawImage 处理，因为 nmui_rawImage 可能会有其他对象引用，不一定在 QMUIThemeImage 释放后就随之释放

        // 这里不能在 NMUIThemeImage 直接写 '- (void)dealloc { _themeProvider = nil; }' ，因为这样写会先调用 super dealloc，而 UIImage 的 dealloc 方法里会调用其他方法，从而再次触发消息转发、访问 nmui_rawImage，这可能会导致一些野指针问题，通过下面的方式，保持在执行 super dealloc 之前，先清空 _themeProvider
        NMBFOverrideImplementation([NMUIThemeImage class], NSSelectorFromString(@"dealloc"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(__unsafe_unretained NMUIThemeImage *selfObject) {
                selfObject->_themeProvider = nil;
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });

    });
}

- (instancetype)init {
    return ((id (*)(id, SEL))[NSObject instanceMethodForSelector:_cmd])(self, _cmd);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.nmui_rawImage methodSignatureForSelector:aSelector];
    if (result && [self.nmui_rawImage respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature nmbf_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.nmui_rawImage respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.nmui_rawImage];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.nmui_rawImage respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == NMUIThemeImage.class) return YES;
    return [self.nmui_rawImage isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == NMUIThemeImage.class) return YES;
    return [self.nmui_rawImage isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.nmui_rawImage conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}


- (CGSize)size {
    return self.nmui_rawImage.size;
}

- (CGImageRef)CGImage {
    return self.nmui_rawImage.CGImage;
}

- (CIImage *)CIImage {
    return self.nmui_rawImage.CIImage;
}

- (UIImageOrientation)imageOrientation {
    return self.nmui_rawImage.imageOrientation;
}

- (CGFloat)scale {
    return self.nmui_rawImage.scale;
}

- (NSArray<UIImage *> *)images {
    return self.nmui_rawImage.images;
}

- (NSTimeInterval)duration {
    return self.nmui_rawImage.duration;
}

- (UIEdgeInsets)alignmentRectInsets {
    return self.nmui_rawImage.alignmentRectInsets;
}

- (void)drawAtPoint:(CGPoint)point {
    [self.nmui_rawImage drawAtPoint:point];
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.nmui_rawImage drawAtPoint:point blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect {
    [self.nmui_rawImage drawInRect:rect];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.nmui_rawImage drawInRect:rect blendMode:blendMode alpha:alpha];
}

- (void)drawAsPatternInRect:(CGRect)rect {
    [self.nmui_rawImage drawAsPatternInRect:rect];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self.nmui_rawImage resizableImageWithCapInsets:capInsets];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    return [self.nmui_rawImage resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
}

- (UIEdgeInsets)capInsets {
    return [self.nmui_rawImage capInsets];
}

- (UIImageResizingMode)resizingMode {
    return [self.nmui_rawImage resizingMode];
}

- (UIImage *)imageWithAlignmentRectInsets:(UIEdgeInsets)alignmentInsets {
    return [self.nmui_rawImage imageWithAlignmentRectInsets:alignmentInsets];
}

- (UIImage *)imageWithRenderingMode:(UIImageRenderingMode)renderingMode {
    return [self.nmui_rawImage imageWithRenderingMode:renderingMode];
}

- (UIImageRenderingMode)renderingMode {
    return self.nmui_rawImage.renderingMode;
}

- (UIGraphicsImageRendererFormat *)imageRendererFormat {
    return self.nmui_rawImage.imageRendererFormat;
}

- (UITraitCollection *)traitCollection {
    return self.nmui_rawImage.traitCollection;
}

- (UIImageAsset *)imageAsset {
    return self.nmui_rawImage.imageAsset;
}

- (UIImage *)imageFlippedForRightToLeftLayoutDirection {
    return self.nmui_rawImage.imageFlippedForRightToLeftLayoutDirection;
}

- (BOOL)flipsForRightToLeftLayoutDirection {
    return self.nmui_rawImage.flipsForRightToLeftLayoutDirection;
}

- (UIImage *)imageWithHorizontallyFlippedOrientation {
    return self.nmui_rawImage.imageWithHorizontallyFlippedOrientation;
}

#ifdef IOS13_SDK_ALLOWED

- (BOOL)isSymbolImage {
    return self.nmui_rawImage.isSymbolImage;
}

- (CGFloat)baselineOffsetFromBottom {
    return self.nmui_rawImage.baselineOffsetFromBottom;
}

- (BOOL)hasBaseline {
    return self.nmui_rawImage.hasBaseline;
}

- (UIImage *)imageWithBaselineOffsetFromBottom:(CGFloat)baselineOffset {
    return [self.nmui_rawImage imageWithBaselineOffsetFromBottom:baselineOffset];
}

- (UIImage *)imageWithoutBaseline {
    return self.nmui_rawImage.imageWithoutBaseline;
}

- (UIImageConfiguration *)configuration {
    return self.nmui_rawImage.configuration;
}

- (UIImage *)imageWithConfiguration:(UIImageConfiguration *)configuration {
    return [self.nmui_rawImage imageWithConfiguration:configuration];
}

- (UIImageSymbolConfiguration *)symbolConfiguration {
    return self.nmui_rawImage.symbolConfiguration;
}

- (UIImage *)imageByApplyingSymbolConfiguration:(UIImageSymbolConfiguration *)configuration {
    return [self.nmui_rawImage imageByApplyingSymbolConfiguration:configuration];
}

- (UIImage *)imageWithTintColor:(UIColor *)color {
    return [self.nmui_rawImage imageWithTintColor:color];
}

- (UIImage *)imageWithTintColor:(UIColor *)color renderingMode:(UIImageRenderingMode)renderingMode {
    return [self.nmui_rawImage imageWithTintColor:color renderingMode:renderingMode];
}

#endif

#pragma mark - <NMUIDynamicImageProtocol>

- (UIImage *)nmui_rawImage {
    if (!_themeProvider) return nil;
    NMUIThemeManager *manager = [NMUIThemeManagerCenter themeManagerWithName:self.managerName];
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",manager.name, manager.currentThemeIdentifier];
    UIImage *rawImage = [self.cachedRawImages objectForKey:cacheKey];
    if (!rawImage) {
        rawImage = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).nmui_rawImage;
        if (rawImage) [self.cachedRawImages setObject:rawImage forKey:cacheKey];
    }
    return rawImage;
}

- (BOOL)nmui_isDynamicImage {
    return YES;
}

@end

@implementation UIImage (NMUITheme)

+ (UIImage *)nmui_imageWithThemeProvider:(UIImage * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIImage nmui_imageWithThemeManagerName:NMUIThemeManagerNameDefault provider:provider];
}

+ (UIImage *)nmui_imageWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIImage * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    NMUIThemeImage *image = [[NMUIThemeImage alloc] init];
    image.cachedRawImages = [[NMUIThemeImageCache alloc] init];
    image.managerName = name;
    image.themeProvider = provider;
    return (UIImage *)image;    // NMUIThemeImage 可以这样转换时因为NMUIThemeImage 第一个成员变量nmui_rawImage就是UIImage对象
}

#pragma mark - <NMUIDynamicImageProtocol>

- (UIImage *)nmui_rawImage {
    return self;
}

- (BOOL)nmui_isDynamicImage {
    return NO;
}

#pragma mark- orientation
- (UIImage *)nmui_fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

@end
