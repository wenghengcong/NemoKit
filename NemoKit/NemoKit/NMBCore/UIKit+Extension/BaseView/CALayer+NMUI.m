//
//  CALayer+Nemo.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "CALayer+NMUI.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"
#import "UIColor+NMUI.h"

@interface CALayer ()

@property(nonatomic, assign) float nmui_speedBeforePause;

@end


@implementation CALayer (NMUI)

NMBFSynthesizeFloatProperty(nmui_speedBeforePause, setNmui_speedBeforePause)
NMBFSynthesizeCGFloatProperty(nmui_originCornerRadius, setNmui_originCornerRadius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 由于其他方法需要通过调用 nmuilayer_setCornerRadius: 来执行 swizzle 前的实现，所以这里暂时用 NMBFExchangeImplementations
        NMBFExchangeImplementations([CALayer class], @selector(setCornerRadius:), @selector(nmuilayer_setCornerRadius:));
        
        NMBFExtendImplementationOfNonVoidMethodWithoutArguments([CALayer class], @selector(init), CALayer *, ^CALayer *(CALayer *selfObject, CALayer *originReturnValue) {
            selfObject.nmui_speedBeforePause = selfObject.speed;
            selfObject.nmui_maskedCorners = NMUILayerMinXMinYCorner|NMUILayerMaxXMinYCorner|NMUILayerMinXMaxYCorner|NMUILayerMaxXMaxYCorner;
            return originReturnValue;
        });
        
        NMBFOverrideImplementation([CALayer class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGRect bounds) {
                
                // 对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(bounds)) {
                    NMBFLogWarn(@"CALayer (NMUI)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
                    if (NMUICMIActivated && !ShouldPrintNMUIWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setBounds: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        bounds = CGRectSafeValue(bounds);
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
            };
        });
        
        NMBFOverrideImplementation([CALayer class], @selector(setPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CGPoint position) {
                
                // 对非法的 position，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (isnan(position.x) || isnan(position.y)) {
                    NMBFLogWarn(@"CALayer (NMUI)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
                    if (NMUICMIActivated && !ShouldPrintNMUIWarnLogToConsole) {
                        NSAssert(NO, @"CALayer setPosition: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, position);
            };
        });
    });
}

- (BOOL)nmui_isRootLayerOfView {
    return [self.delegate isKindOfClass:[UIView class]] && ((UIView *)self.delegate).layer == self;
}

- (void)nmuilayer_setCornerRadius:(CGFloat)cornerRadius {
    BOOL cornerRadiusChanged = flat(self.nmui_originCornerRadius) != flat(cornerRadius);// flat 处理，避免浮点精度问题
    self.nmui_originCornerRadius = cornerRadius;
    if (@available(iOS 11, *)) {
        [self nmuilayer_setCornerRadius:cornerRadius];
    } else {
        if (self.nmui_maskedCorners && ![self hasFourCornerRadius]) {
            [self nmuilayer_setCornerRadius:0];
        } else {
            [self nmuilayer_setCornerRadius:cornerRadius];
        }
        if (cornerRadiusChanged) {
            // 需要刷新mask
            [self setNeedsLayout];
        }
    }
    if (cornerRadiusChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.nmui_borderPosition > 0 && view.nmui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

static char kAssociatedObjectKey_pause;
- (void)setNmui_pause:(BOOL)nmui_pause {
    if (nmui_pause == self.nmui_pause) {
        return;
    }
    if (nmui_pause) {
        self.nmui_speedBeforePause = self.speed;
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0;
        self.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = self.nmui_speedBeforePause;
        self.timeOffset = 0;
        self.beginTime = 0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(nmui_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)nmui_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

static char kAssociatedObjectKey_maskedCorners;
- (void)setNmui_maskedCorners:(NMUICornerMask)nmui_maskedCorners {
    BOOL maskedCornersChanged = nmui_maskedCorners != self.nmui_maskedCorners;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maskedCorners, @(nmui_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11, *)) {
        self.maskedCorners = (CACornerMask)nmui_maskedCorners;
    } else {
        if (nmui_maskedCorners && ![self hasFourCornerRadius]) {
            [self nmuilayer_setCornerRadius:0];
        }
        if (maskedCornersChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.nmui_borderPosition > 0 && view.nmui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

- (NMUICornerMask)nmui_maskedCorners {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maskedCorners) unsignedIntegerValue];
}

- (void)nmui_sendSublayerToBack:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:0];
    }
}

- (void)nmui_bringSublayerToFront:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
    }
}

- (void)nmui_removeDefaultAnimations {
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(position)): [NSNull null],
                                                               NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                               NSStringFromSelector(@selector(transform)): [NSNull null],
                                                               BeginIgnoreClangWarning(-Wundeclared-selector)
                                                               NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                               NSStringFromSelector(@selector(doubleSided)): [NSNull null],
                                                               EndIgnoreClangWarning
                                                               NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                               NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(contents)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                               NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                               NSStringFromSelector(@selector(filters)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                               NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                               NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(path)): [NSNull null],
                                            NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                            NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                            NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                            NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(colors)): [NSNull null],
                                            NSStringFromSelector(@selector(locations)): [NSNull null],
                                            NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                            NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
    }
    
    self.actions = actions;
}

+ (void)nmui_performWithoutAnimation:(void (NS_NOESCAPE ^)(void))actionsWithoutAnimation {
    if (!actionsWithoutAnimation) return;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    actionsWithoutAnimation();
    [CATransaction commit];
}

+ (CAShapeLayer *)nmui_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColorClear.CGColor;
    layer.strokeColor = lineColor;
    layer.lineWidth = lineWidth;
    layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
    layer.masksToBounds = YES;
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (isHorizontal) {
        CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
        CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH, lineWidth / 2);
    } else {
        CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
        CGPathAddLineToPoint(path, NULL, lineWidth / 2, SCREEN_HEIGHT);
    }
    layer.path = path;
    CGPathRelease(path);
    
    return layer;
}

+ (CAShapeLayer *)nmui_separatorDashLayerInHorizontal {
    CAShapeLayer *layer = [CAShapeLayer nmui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:YES];
    return layer;
}

+ (CAShapeLayer *)nmui_separatorDashLayerInVertical {
    CAShapeLayer *layer = [CAShapeLayer nmui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:NO];
    return layer;
}

+ (CALayer *)nmui_separatorLayer {
    CALayer *layer = [CALayer layer];
    [layer nmui_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    layer.frame = CGRectMake(0, 0, 0, PixelOne);
    return layer;
}

+ (CALayer *)nmui_separatorLayerForTableView {
    CALayer *layer = [self nmui_separatorLayer];
    layer.backgroundColor = TableViewSeparatorColor.CGColor;
    return layer;
}

- (BOOL)hasFourCornerRadius {
    return (self.nmui_maskedCorners & NMUILayerMinXMinYCorner) == NMUILayerMinXMinYCorner &&
    (self.nmui_maskedCorners & NMUILayerMaxXMinYCorner) == NMUILayerMaxXMinYCorner &&
    (self.nmui_maskedCorners & NMUILayerMinXMaxYCorner) == NMUILayerMinXMaxYCorner &&
    (self.nmui_maskedCorners & NMUILayerMaxXMaxYCorner) == NMUILayerMaxXMaxYCorner;
}

@end

@implementation UIView (NMUI_CornerRadius)

static NSString *kMaskName = @"NMUI_CornerRadius_Mask";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer) {
            if (@available(iOS 11, *)) {
            } else {
                if (selfObject.layer.mask && ![selfObject.layer.mask.name isEqualToString:kMaskName]) {
                    return;
                }
                if (selfObject.layer.nmui_maskedCorners) {
                    if (selfObject.layer.nmui_originCornerRadius <= 0 || [selfObject hasFourCornerRadius]) {
                        if (selfObject.layer.mask) {
                            selfObject.layer.mask = nil;
                        }
                    } else {
                        CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                        cornerMaskLayer.name = kMaskName;
                        UIRectCorner rectCorner = 0;
                        if ((selfObject.layer.nmui_maskedCorners & NMUILayerMinXMinYCorner) == NMUILayerMinXMinYCorner) {
                            rectCorner |= UIRectCornerTopLeft;
                        }
                        if ((selfObject.layer.nmui_maskedCorners & NMUILayerMaxXMinYCorner) == NMUILayerMaxXMinYCorner) {
                            rectCorner |= UIRectCornerTopRight;
                        }
                        if ((selfObject.layer.nmui_maskedCorners & NMUILayerMinXMaxYCorner) == NMUILayerMinXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomLeft;
                        }
                        if ((selfObject.layer.nmui_maskedCorners & NMUILayerMaxXMaxYCorner) == NMUILayerMaxXMaxYCorner) {
                            rectCorner |= UIRectCornerBottomRight;
                        }
                        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:selfObject.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(selfObject.layer.nmui_originCornerRadius, selfObject.layer.nmui_originCornerRadius)];
                        cornerMaskLayer.frame = CGRectMakeWithSize(selfObject.bounds.size);
                        cornerMaskLayer.path = path.CGPath;
                        selfObject.layer.mask = cornerMaskLayer;
                    }
                }
            }
        });
    });
}

- (BOOL)hasFourCornerRadius {
    return (self.layer.nmui_maskedCorners & NMUILayerMinXMinYCorner) == NMUILayerMinXMinYCorner &&
    (self.layer.nmui_maskedCorners & NMUILayerMaxXMinYCorner) == NMUILayerMaxXMinYCorner &&
    (self.layer.nmui_maskedCorners & NMUILayerMinXMaxYCorner) == NMUILayerMinXMaxYCorner &&
    (self.layer.nmui_maskedCorners & NMUILayerMaxXMaxYCorner) == NMUILayerMaxXMaxYCorner;
}

@end

@interface CAShapeLayer (NMUI_DynamicColor)

@property(nonatomic, strong) UIColor *qcl_originalFillColor;
@property(nonatomic, strong) UIColor *qcl_originalStrokeColor;

@end

@implementation CAShapeLayer (NMUI_DynamicColor)

NMBFSynthesizeIdStrongProperty(qcl_originalFillColor, setQcl_originalFillColor)
NMBFSynthesizeIdStrongProperty(qcl_originalStrokeColor, setQcl_originalStrokeColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([CAShapeLayer class], @selector(setFillColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) nmbf_getBoundObjectForKey:NMUICGColorOriginalColorBindKey];
                selfObject.qcl_originalFillColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
        
        NMBFOverrideImplementation([CAShapeLayer class], @selector(setStrokeColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAShapeLayer *selfObject, CGColorRef color) {
                
                UIColor *originalColor = [(__bridge id)(color) nmbf_getBoundObjectForKey:NMUICGColorOriginalColorBindKey];
                selfObject.qcl_originalStrokeColor = originalColor;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGColorRef);
                originSelectorIMP = (void (*)(id, SEL, CGColorRef))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, color);
            };
        });
    });
}

- (void)nmui_setNeedsUpdateDynamicStyle {
    [super nmui_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalFillColor) {
        self.fillColor = self.qcl_originalFillColor.CGColor;
    }
    
    if (self.qcl_originalStrokeColor) {
        self.strokeColor = self.qcl_originalStrokeColor.CGColor;
    }
}

@end

@interface CAGradientLayer (NMUI_DynamicColor)

@property(nonatomic, strong) NSArray <UIColor *>* qcl_originalColors;

@end

@implementation CAGradientLayer (NMUI_DynamicColor)

NMBFSynthesizeIdStrongProperty(qcl_originalColors, setQcl_originalColors)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([CAGradientLayer class], @selector(setColors:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CAGradientLayer *selfObject, NSArray *colors) {
                
                
                void (*originSelectorIMP)(id, SEL, NSArray *);
                originSelectorIMP = (void (*)(id, SEL, NSArray *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, colors);
                
                
                __block BOOL hasDynamicColor = NO;
                NSMutableArray *originalColors = [NSMutableArray array];
                [colors enumerateObjectsUsingBlock:^(id color, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIColor *originalColor = [color nmbf_getBoundObjectForKey:NMUICGColorOriginalColorBindKey];
                    if (originalColor) {
                        hasDynamicColor = YES;
                        [originalColors addObject:originalColor];
                    } else {
                        [originalColors addObject:[UIColor colorWithCGColor:(__bridge CGColorRef _Nonnull)(color)]];
                    }
                }];
                
                if (hasDynamicColor) {
                    selfObject.qcl_originalColors = originalColors;
                } else {
                    selfObject.qcl_originalColors = nil;
                }
                
            };
        });
    });
}

- (void)nmui_setNeedsUpdateDynamicStyle {
    [super nmui_setNeedsUpdateDynamicStyle];
    
    if (self.qcl_originalColors) {
        NSMutableArray *colors = [NSMutableArray array];
        [self.qcl_originalColors enumerateObjectsUsingBlock:^(UIColor * _Nonnull color, NSUInteger idx, BOOL * _Nonnull stop) {
            [colors addObject:(__bridge id _Nonnull)(color.CGColor)];
        }];
        self.colors = colors;
    }
}

@end


@implementation CALayer (NMUI_Layout)

- (CGFloat)nmui_x
{
    return self.frame.origin.x;
}

- (void)setNmui_x:(CGFloat)nmui_x
{
    CGRect frame = self.frame;
    frame.origin.x = nmui_x;
    self.frame = frame;
}

- (CGFloat)nmui_y
{
    return self.frame.origin.y;
}

- (void)setNmui_y:(CGFloat)nmui_y
{
    CGRect frame = self.frame;
    frame.origin.y = nmui_y;
    self.frame = frame;
}

- (CGFloat)nmui_top
{
    return self.frame.origin.y;
}

- (void)setNmui_top:(CGFloat)nmui_top
{
    CGRect frame = self.frame;
    frame.origin.y = nmui_top;
    self.frame = frame;
}

- (CGFloat)nmui_right
{
    return CGRectGetMaxX(self.frame);
}

- (void)setNmui_right:(CGFloat)nmui_right
{
    CGRect frame = self.frame;
    frame.origin.x = nmui_right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)nmui_bottom
{
    return CGRectGetMaxY(self.frame);
}

- (void)setNmui_bottom:(CGFloat)nmui_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = nmui_bottom - self.frame.size.height;
    self.frame = frame;
}

- (CGFloat)nmui_left
{
    return self.frame.origin.x;
}

- (void)setNmui_left:(CGFloat)nmui_left
{
    CGRect frame = self.frame;
    frame.origin.x = nmui_left;
    self.frame = frame;
}

- (CGFloat)nmui_width
{
    return self.frame.size.width;
}

- (void)setNmui_width:(CGFloat)nmui_width
{
    CGRect frame = self.frame;
    frame.size.width = nmui_width;
    self.frame = frame;
}

- (CGFloat)nmui_height
{
    return self.frame.size.height;
}

- (void)setNmui_height:(CGFloat)nmui_height
{
    CGRect frame = self.frame;
    frame.size.height = nmui_height;
    self.frame = frame;
}

- (CGSize)nmui_size
{
    return self.frame.size;
}

- (void)setNmui_size:(CGSize)nmui_size
{
    CGRect frame = self.frame;
    frame.size = nmui_size;
    self.frame = frame;
}

- (CGPoint)nmui_origin
{
    return self.frame.origin;
}

- (void)setNmui_origin:(CGPoint)nmui_origin
{
    CGRect frame = self.frame;
    frame.origin = nmui_origin;
    self.frame = frame;
}

@end
