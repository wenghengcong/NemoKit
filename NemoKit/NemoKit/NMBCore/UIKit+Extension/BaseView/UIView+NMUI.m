//
//  UIView+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIView+NMUI.h"
#import <objc/runtime.h>
#import "NMBCore.h"
#import "UIViewController+NMUI.h"
#import "CALayer+NMUI.h"
#import "NSNumber+NMBF.h"
#import "UIImage+NMUI.h"
#import "UIColor+NMUI.h"
#import "NMBFLog.h"

@interface UIView()

/// NMUI_Debug
@property(nonatomic, assign, readwrite) BOOL nmui_hasDebugColor;

/// NMUI_Border
@property(nonatomic, strong, readwrite) CAShapeLayer *nmui_borderLayer;

@end

@implementation UIView (NMUI)

NMBFSynthesizeBOOLProperty(nmui_tintColorCustomized, setNmui_tintColorCustomized)
NMBFSynthesizeIdCopyProperty(nmui_frameWillChangeBlock, setNmui_frameWillChangeBlock)
NMBFSynthesizeIdCopyProperty(nmui_frameDidChangeBlock, setNmui_frameDidChangeBlock)
NMBFSynthesizeIdCopyProperty(nmui_tintColorDidChangeBlock, setNmui_tintColorDidChangeBlock)
NMBFSynthesizeIdCopyProperty(nmui_hitTestBlock, setNmui_hitTestBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setTintColor:), UIColor *, ^(UIView *selfObject, UIColor *tintColor) {
            selfObject.nmui_tintColorCustomized = !!tintColor;
        });
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(tintColorDidChange), ^(UIView *selfObject) {
            if (selfObject.nmui_tintColorDidChangeBlock) {
                selfObject.nmui_tintColorDidChangeBlock(selfObject);
            }
        });
        
        NMBFExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.nmui_hitTestBlock) {
                UIView *view = selfObject.nmui_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
        
        // 这个私有方法在 view 被调用 becomeFirstResponder 并且处于 window 上时，才会被调用，所以比 becomeFirstResponder 更适合用来检测
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIView class], NSSelectorFromString(@"_didChangeToFirstResponder:"), id, ^(UIView *selfObject, id firstArgv) {
            if (selfObject == firstArgv && [selfObject conformsToProtocol:@protocol(UITextInput)]) {
                // 像 NMUIModalPresentationViewController 那种以 window 的形式展示浮层，浮层里的输入框 becomeFirstResponder 的场景，[window makeKeyAndVisible] 被调用后，就会立即走到这里，但此时该 window 尚不是 keyWindow，所以这里延迟到下一个 runloop 里再去判断
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (IS_DEBUG && ![selfObject isKindOfClass:[UIWindow class]] && selfObject.window && !selfObject.window.keyWindow) {
                        [selfObject NMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
                    }
                });
            }
        });
        
        NMBFOverrideImplementation([UIView class], @selector(addSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view) {
                if (view == selfObject) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view);
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(insertSubview:atIndex:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, NSInteger index) {
                if (view == selfObject) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, NSInteger);
                originSelectorIMP = (void (*)(id, SEL, UIView *, NSInteger))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, index);
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(insertSubview:aboveSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, UIView *siblingSubview) {
                if (view == self) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, siblingSubview);
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(insertSubview:belowSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *view, UIView *siblingSubview) {
                if (view == self) {
                    [selfObject printLogForAddSubviewToSelf];
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, view, siblingSubview);
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(convertPoint:toView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGPoint(UIView *selfObject, CGPoint point, UIView *view) {
                
                [selfObject alertConvertValueWithView:view];
                
                // call super
                CGPoint (*originSelectorIMP)(id, SEL, CGPoint, UIView *);
                originSelectorIMP = (CGPoint (*)(id, SEL, CGPoint, UIView *))originalIMPProvider();
                CGPoint result = originSelectorIMP(selfObject, originCMD, point, view);
                
                return result;
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(convertPoint:fromView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGPoint(UIView *selfObject, CGPoint point, UIView *view) {
                
                [selfObject alertConvertValueWithView:view];
                
                // call super
                CGPoint (*originSelectorIMP)(id, SEL, CGPoint, UIView *);
                originSelectorIMP = (CGPoint (*)(id, SEL, CGPoint, UIView *))originalIMPProvider();
                CGPoint result = originSelectorIMP(selfObject, originCMD, point, view);
                
                return result;
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(convertRect:toView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UIView *selfObject, CGRect rect, UIView *view) {
                
                [selfObject alertConvertValueWithView:view];
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect, UIView *);
                originSelectorIMP = (CGRect (*)(id, SEL, CGRect, UIView *))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, rect, view);
                
                return result;
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(convertRect:fromView:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UIView *selfObject, CGRect rect, UIView *view) {
                
                [selfObject alertConvertValueWithView:view];
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect, UIView *);
                originSelectorIMP = (CGRect (*)(id, SEL, CGRect, UIView *))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, rect, view);
                
                return result;
            };
        });
        
    });
}

- (instancetype)nmui_initWithSize:(CGSize)size {
    return [self initWithFrame: CGRectMakeWithSize(size)];
}

- (void)setNmui_frameApplyTransform:(CGRect)nmui_frameApplyTransform {
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(nmui_frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (CGRect)nmui_frameApplyTransform {
    return self.frame;
}

- (UIEdgeInsets)nmui_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)nmui_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

/*
 将像素point由point所在视图转换到目标视图view中，返回在目标视图view中的像素值
 调用者应为covertPoint的父视图，即调用者应为point的父控件。toView即为需要转换到的视图坐标系，以此视图的左上角为（0，0）点。
 - (CGPoint)convertPoint:(CGPoint)point toView:(UIView *)view;
 
 将像素point从view中转换到当前视图中，返回在当前视图中的像素值
 调用者为需要转换到的视图坐标系。fromView为point所在的父控件。
 - (CGPoint)convertPoint:(CGPoint)point fromView:(UIView *)view;
*/
- (CGPoint)nmui_convertPoint:(CGPoint)point toView:(UIView *)view {
    if (view) {
        return [view nmui_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)nmui_convertPoint:(CGPoint)point fromView:(UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        // convertPoint: toView: toView为nil时，将会转换为依赖该window的坐标系
        // 先以当前window作为中介者，进行转换
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)nmui_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view nmui_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)nmui_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                      animations:(void (^)(void))animations {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                      animations:(void (^)(void))animations
                      completion:(void (^)(BOOL))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                         options:(UIViewAnimationOptions)options
                      animations:(void (^)(void))animations
                      completion:(void (^)(BOOL))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
          usingSpringWithDamping:(CGFloat)dampingRatio
           initialSpringVelocity:(CGFloat)velocity
                         options:(UIViewAnimationOptions)options
                      animations:(void (^)(void))animations
                      completion:(void (^)(BOOL))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}



- (void)printLogForAddSubviewToSelf {
    UIViewController *visibleViewController = [NMUIHelper visibleViewController];
    NSString *log = [NSString stringWithFormat:@"UIView (NMUI) addSubview:, 把自己作为 subview 添加到自己身上，self = %@, visibleViewController = %@, visibleState = %@, viewControllers = %@\n%@", self, visibleViewController, @(visibleViewController.nmui_visibleState), visibleViewController.navigationController.viewControllers, [NSThread callStackSymbols]];
    NSAssert(NO, log);
    NMBFLogWarn(@"UIView (NMUI)", @"%@", log);
}

- (void)NMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
    NMBFLogWarn(@"UIView (NMUI)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

- (BOOL)hasSharedAncestorViewWithView:(UIView *)view {
    UIView *sharedAncestorView = self;
    if (!view) {
        return YES;
    }
    while (sharedAncestorView && ![view isDescendantOfView:sharedAncestorView]) {
        sharedAncestorView = sharedAncestorView.superview;
    }
    return !!sharedAncestorView;
}

- (BOOL)isUIKitPrivateView {
    // 系统有些东西本身也存在不合理，但我们不关心这种，所以过滤掉
    if ([self isKindOfClass:[UIWindow class]]) return YES;
    
    __block BOOL isPrivate = NO;
    NSString *classString = NSStringFromClass(self.class);
    [@[@"LayoutContainer", @"NavigationItemButton", @"NavigationItemView", @"SelectionGrabber", @"InputViewContent", @"InputSetContainer", @"TextFieldContentView", @"KeyboardImpl"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (([classString hasPrefix:@"UI"] || [classString hasPrefix:@"_UI"]) && [classString containsString:obj]) {
            isPrivate = YES;
            *stop = YES;
        }
    }];
    return isPrivate;
}

/// 转换提示
- (void)alertConvertValueWithView:(UIView *)view {
    if (IS_DEBUG && ![self isUIKitPrivateView] && ![self hasSharedAncestorViewWithView:view]) {
//        NMBFLog(@"UIView (NMUI)", @"进行坐标系转换运算的 %@ 和 %@ 不存在共同的父 view，可能导致运算结果不准确（特别是在横竖屏旋转时，如果两个 view 处于不同的 window，由于 window 旋转有先后顺序，可能转换时两个 window 的方向不一致，坐标就会错乱）", self, view);
    }
}

@end

@implementation UIView (NMUI_ViewController)

NMBFSynthesizeBOOLProperty(nmui_isControllerRootView, setNmui_isControllerRootView)

- (BOOL)nmui_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    UIViewController *viewController = self.nmui_viewController;
    return (viewController.nmui_visibleState >= NMUIViewControllerWillAppear)
    && (viewController.nmui_visibleState < NMUIViewControllerWillDisappear);
}

static char kAssociatedObjectKey_viewController;
- (void)setNmui_viewController:(__kindof UIViewController * _Nullable)nmui_viewController {
    NMBFWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
    if (!weakContainer) {
        weakContainer = [NMBFWeakObjectContainer new];
    }
    weakContainer.object = nmui_viewController;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.nmui_isControllerRootView = !!nmui_viewController;
}

- (__kindof UIViewController *)nmui_viewController {
    if (self.nmui_isControllerRootView) {
        return (__kindof UIViewController *)((NMBFWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController)).object;
    }
    return self.superview.nmui_viewController;
}

@end


@interface UIViewController (NMUI_View)

@end

@implementation UIViewController (NMUI_View)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            if (@available(iOS 11.0, *)) {
                selfObject.view.nmui_viewController = selfObject;
            } else {
                // 临时修复 iOS 10.0.2 上在输入框内切换输入法可能引发死循环的 bug，待查
                // https://github.com/Tencent/QMUI_iOS/issues/471
                ((UIView *)[selfObject nmbf_valueForKey:@"_view"]).nmui_viewController = selfObject;
            }
        });
    });
}

@end

@implementation UIView (NMUI_Runtime)


- (BOOL)nmui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIStackView class],
                                               [UILabel class],
                                               [UIButton class],
                                               [UISegmentedControl class],
                                               [UITextField class],
                                               [UISlider class],
                                               [UISwitch class],
                                               [UIActivityIndicatorView class],
                                               [UIProgressView class],
                                               [UIPageControl class],
                                               [UIStepper class],
                                               [UITableView class],
                                               [UITableViewCell class],
                                               [UIImageView class],
                                               [UICollectionView class],
                                               [UICollectionViewCell class],
                                               [UICollectionReusableView class],
                                               [UITextView class],
                                               [UIScrollView class],
                                               [UIDatePicker class],
                                               [UIPickerView class],
                                               [UIVisualEffectView class],
                                               // Apple 不再接受使用了 UIWebView 的 App 提交，所以这里去掉 UIWebView
                                               // https://github.com/Tencent/QMUI_iOS/issues/741
                                               // [UIWebView class],
                                               [UIWindow class],
                                               [UINavigationBar class],
                                               [UIToolbar class],
                                               [UITabBar class],
                                               [UISearchBar class],
                                               [UIControl class],
                                               [UIView class],
                                               nil];
    
    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self nmbf_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation UIView (NMUI_Border)

NMBFSynthesizeIdStrongProperty(nmui_borderLayer, setNmui_borderLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject setDefaultStyle];
            return originReturnValue;
        });
        
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject,  NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject setDefaultStyle];
            return originReturnValue;
        });
        
        // 给视图添加边框
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(layoutSublayersOfLayer:), CALayer *, ^(UIView *selfObject, CALayer *layer) {
            if ((!selfObject.nmui_borderLayer && selfObject.nmui_borderPosition == NMUIViewBorderPositionNone) || (!selfObject.nmui_borderLayer && selfObject.nmui_borderWidth == 0)) {
                return;
            }
            
            if (selfObject.nmui_borderLayer && selfObject.nmui_borderPosition == NMUIViewBorderPositionNone && !selfObject.nmui_borderLayer.path) {
                return;
            }
            
            if (selfObject.nmui_borderLayer && selfObject.nmui_borderWidth == 0 && selfObject.nmui_borderLayer.lineWidth == 0) {
                return;
            }
            
            // 添加一个边框的layer
            if (!selfObject.nmui_borderLayer) {
                selfObject.nmui_borderLayer = [CAShapeLayer layer];
                selfObject.nmui_borderLayer.fillColor = UIColorClear.CGColor;
                [selfObject.nmui_borderLayer nmui_removeDefaultAnimations];
                [selfObject.layer addSublayer:selfObject.nmui_borderLayer];
            }
            
            selfObject.nmui_borderLayer.frame = selfObject.bounds;
        
            CGFloat borderWidth = selfObject.nmui_borderWidth;
            selfObject.nmui_borderLayer.lineWidth = borderWidth;
            selfObject.nmui_borderLayer.strokeColor = selfObject.nmui_borderColor.CGColor;
            selfObject.nmui_borderLayer.lineDashPhase = selfObject.nmui_dashPhase;
            selfObject.nmui_borderLayer.lineDashPattern = selfObject.nmui_dashPattern;
            
            UIBezierPath *path = nil;
            if (selfObject.nmui_borderPosition != NMUIViewBorderPositionNone) {
                path = [UIBezierPath bezierPath];
            }
            
            CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                return selfObject.nmui_borderLocation == NMUIViewBorderLocationInside ? inside :
                (selfObject.nmui_borderLocation == NMUIViewBorderLocationCenter ? center : outside);
            };
            
            BOOL shouldShowTopBorder = (selfObject.nmui_borderPosition & NMUIViewBorderPositionTop) == NMUIViewBorderPositionTop;
            BOOL shouldShowBottomBorder = (selfObject.nmui_borderPosition & NMUIViewBorderPositionBottom) == NMUIViewBorderPositionBottom;
            BOOL shouldShowLeftBorder = (selfObject.nmui_borderPosition & NMUIViewBorderPositionLeft) == NMUIViewBorderPositionLeft;
            BOOL shouldShowRightBorder = (selfObject.nmui_borderPosition & NMUIViewBorderPositionRight) == NMUIViewBorderPositionRight;

            CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
            CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth);     // 两条相邻的边框连接的位置
            
            UIBezierPath *topPath = [UIBezierPath bezierPath];
            UIBezierPath *leftPath = [UIBezierPath bezierPath];
            UIBezierPath *bottomPath = [UIBezierPath bezierPath];
            UIBezierPath *rightPath = [UIBezierPath bezierPath];
            
            if (selfObject.layer.nmui_originCornerRadius > 0) {
                
                CGFloat cornerRadius = selfObject.layer.nmui_originCornerRadius;
                
                if (selfObject.layer.nmui_maskedCorners) {
                    if ((selfObject.layer.nmui_maskedCorners & NMUILayerMinXMinYCorner) == NMUILayerMinXMinYCorner) {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    } else {
                        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    }
                    if ((selfObject.layer.nmui_maskedCorners & NMUILayerMinXMaxYCorner) == NMUILayerMinXMaxYCorner) {
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    } else {
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                    }
                    if ((selfObject.layer.nmui_maskedCorners & NMUILayerMaxXMaxYCorner) == NMUILayerMaxXMaxYCorner) {
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    } else {
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                    }
                    if ((selfObject.layer.nmui_maskedCorners & NMUILayerMaxXMinYCorner) == NMUILayerMaxXMinYCorner) {
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    } else {
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    }
                } else {
                    [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                    [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                    
                    [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                    
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                    [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                }
                
            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                
                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                
                CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                
                CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
            }
            
            if (shouldShowTopBorder && ![topPath isEmpty]) {
                [path appendPath:topPath];
            }
            if (shouldShowLeftBorder && ![leftPath isEmpty]) {
                [path appendPath:leftPath];
            }
            if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
                [path appendPath:bottomPath];
            }
            if (shouldShowRightBorder && ![rightPath isEmpty]) {
                [path appendPath:rightPath];
            }
            
            selfObject.nmui_borderLayer.path = path.CGPath;
        });

        
    });

}

- (void)setDefaultStyle {
    self.nmui_borderWidth = PixelOne;
    self.nmui_borderColor = UIColorSeparator;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setNmui_borderLocation:(NMUIViewBorderLocation)nmui_borderLocation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(nmui_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NMUIViewBorderLocation)nmui_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setNmui_borderPosition:(NMUIViewBorderPosition)nmui_borderPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(nmui_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NMUIViewBorderPosition)nmui_borderPosition {
    return (NMUIViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setNmui_borderWidth:(CGFloat)nmui_borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(nmui_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)nmui_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) nmbf_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setNmui_borderColor:(UIColor *)nmui_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, nmui_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)nmui_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setNmui_dashPhase:(CGFloat)nmui_dashPhase {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(nmui_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)nmui_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) nmbf_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setNmui_dashPattern:(NSArray<NSNumber *> *)nmui_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, nmui_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NSArray *)nmui_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

const CGFloat NMUIViewSelfSizingHeight = INFINITY;

@implementation UIView (NMUI_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFOverrideImplementation([UIView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect frame) {
                
                // NMUIViewSelfSizingHeight 的功能
                if (CGRectGetWidth(frame) > 0 && isinf(CGRectGetHeight(frame))) {
                    CGFloat height = flat([selfObject sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                    frame = CGRectSetHeight(frame, height);
                }
                
                // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(frame)) {
                    NMBFLogWarn(@"UIView (NMUI)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                    if (NMUICMIActivated && !ShouldPrintNMUIWarnLogToConsole) {
                        NSAssert(NO, @"UIView setFrame: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        frame = CGRectSafeValue(frame);
                    }
                }
                
                CGRect precedingFrame = selfObject.frame;
                BOOL valueChange = !CGRectEqualToRect(frame, precedingFrame);
                if (selfObject.nmui_frameWillChangeBlock && valueChange) {
                    frame = selfObject.nmui_frameWillChangeBlock(selfObject, frame);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
                if (selfObject.nmui_frameDidChangeBlock && valueChange) {
                    selfObject.nmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect bounds) {
                
                CGRect precedingFrame = selfObject.frame;
                CGRect precedingBounds = selfObject.bounds;
                BOOL valueChange = !CGSizeEqualToSize(bounds.size, precedingBounds.size);// bounds 只有 size 发生变化才会影响 frame
                if (selfObject.nmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectMake(CGRectGetMinX(precedingFrame) + CGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(precedingFrame)), CGRectGetMinY(precedingFrame) + CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(precedingFrame)), bounds.size.width, bounds.size.height);
                    followingFrame = selfObject.nmui_frameWillChangeBlock(selfObject, followingFrame);
                    bounds = CGRectSetSize(bounds, followingFrame.size);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
                
                if (selfObject.nmui_frameDidChangeBlock && valueChange) {
                    selfObject.nmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(setCenter:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGPoint center) {
                
                CGRect precedingFrame = selfObject.frame;
                CGPoint precedingCenter = selfObject.center;
                BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
                if (selfObject.nmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectSetXY(precedingFrame, center.x - CGRectGetWidth(selfObject.frame) / 2, center.y - CGRectGetHeight(selfObject.frame) / 2);
                    followingFrame = selfObject.nmui_frameWillChangeBlock(selfObject, followingFrame);
                    center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, center);
                
                if (selfObject.nmui_frameDidChangeBlock && valueChange) {
                    selfObject.nmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(setTransform:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGAffineTransform transform) {
                
                CGRect precedingFrame = selfObject.frame;
                CGAffineTransform precedingTransform = selfObject.transform;
                BOOL valueChange = !CGAffineTransformEqualToTransform(transform, precedingTransform);
                if (selfObject.nmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectApplyAffineTransformWithAnchorPoint(precedingFrame, transform, selfObject.layer.anchorPoint);
                    selfObject.nmui_frameWillChangeBlock(selfObject, followingFrame);// 对于 CGAffineTransform，无法根据修改后的 rect 来算出新的 transform，所以就不修改 transform 的值了
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGAffineTransform);
                originSelectorIMP = (void (*)(id, SEL, CGAffineTransform))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transform);
                
                if (selfObject.nmui_frameDidChangeBlock && valueChange) {
                    selfObject.nmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
    });
}

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

- (CGFloat)nmui_centerX
{
    return self.center.x;
}


- (void)setNmui_centerX:(CGFloat)nmui_centerX
{
    self.center = CGPointMake(nmui_centerX, self.center.y);
}

- (CGFloat)nmui_centerY
{
    return self.center.y;
}

-(void)setNmui_centerY:(CGFloat)nmui_centerY
{
    self.center = CGPointMake(self.center.x, nmui_centerY);
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


- (CGFloat)nmui_extendToTop {
    return self.nmui_top;
}

- (void)setNmui_extendToTop:(CGFloat)nmui_extendToTop {
    self.nmui_height = self.nmui_bottom - nmui_extendToTop;
    self.nmui_top = nmui_extendToTop;
}

- (CGFloat)nmui_extendToLeft {
    return self.nmui_left;
}

- (void)setNmui_extendToLeft:(CGFloat)nmui_extendToLeft {
    self.nmui_width = self.nmui_right - nmui_extendToLeft;
    self.nmui_left = nmui_extendToLeft;
}

- (CGFloat)nmui_extendToBottom {
    return self.nmui_bottom;
}

- (void)setNmui_extendToBottom:(CGFloat)nmui_extendToBottom {
    self.nmui_height = nmui_extendToBottom - self.nmui_top;
    self.nmui_bottom = nmui_extendToBottom;
}

- (CGFloat)nmui_extendToRight {
    return self.nmui_right;
}

- (void)setNmui_extendToRight:(CGFloat)nmui_extendToRight {
    self.nmui_width = nmui_extendToRight - self.nmui_left;
    self.nmui_right = nmui_extendToRight;
}

- (CGFloat)nmui_leftWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)nmui_topWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end

@implementation UIView (CGAffineTransform)

- (CGFloat)nmui_scaleX {
    return self.transform.a;
}

- (CGFloat)nmui_scaleY {
    return self.transform.d;
}

- (CGFloat)nmui_translationX {
    return self.transform.tx;
}

- (CGFloat)nmui_translationY {
    return self.transform.ty;
}

@end

@implementation UIView (NMUI_Snapshotting)

- (UIImage *)nmui_snapshotLayerImage {
    return [UIImage nmui_imageWithView:self];
}

- (UIImage *)nmui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage nmui_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end

@implementation UIView (NMUI_Debug)

NMBFSynthesizeBOOLProperty(nmui_needsDifferentDebugColor, setNmui_needsDifferentDebugColor)
NMBFSynthesizeBOOLProperty(nmui_hasDebugColor, setNmui_hasDebugColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
            if (selfObject.nmui_shouldShowDebugColor) {
                selfObject.nmui_hasDebugColor = YES;
                selfObject.backgroundColor = [selfObject debugColor];
                [selfObject renderColorWithSubviews:selfObject.subviews];
            }
        });
    });
}

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setNmui_shouldShowDebugColor:(BOOL)nmui_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(nmui_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (nmui_shouldShowDebugColor) {
        [self setNeedsLayout];
    }
}
- (BOOL)nmui_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_layoutSubviewsBlock;
static NSMutableSet * nmui_registeredLayoutSubviewsBlockClasses;
- (void)setNmui_layoutSubviewsBlock:(void (^)(__kindof UIView * _Nonnull))nmui_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock, nmui_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (!nmui_registeredLayoutSubviewsBlockClasses) nmui_registeredLayoutSubviewsBlockClasses = [NSMutableSet set];
    if (nmui_layoutSubviewsBlock) {
        Class viewClass = self.class;
        if (![nmui_registeredLayoutSubviewsBlockClasses containsObject:viewClass]) {
            // Extend 每个实例对象的类是为了保证比子类的 layoutSubviews 逻辑要更晚调用
            NMBFExtendImplementationOfVoidMethodWithoutArguments(viewClass, @selector(layoutSubviews), ^(__kindof UIView *selfObject) {
                if (selfObject.nmui_layoutSubviewsBlock && [selfObject isMemberOfClass:viewClass]) {
                    selfObject.nmui_layoutSubviewsBlock(selfObject);
                }
            });
            [nmui_registeredLayoutSubviewsBlockClasses addObject:viewClass];
        }
    }
}

- (void (^)(UIView * _Nonnull))nmui_layoutSubviewsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock);
}



- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self renderColorWithSubviews:stackView.arrangedSubviews];
        }
        view.nmui_hasDebugColor = YES;
        view.nmui_shouldShowDebugColor = self.nmui_shouldShowDebugColor;
        view.nmui_needsDifferentDebugColor = self.nmui_needsDifferentDebugColor;
        view.backgroundColor = [self debugColor];
    }
}

- (UIColor *)debugColor {
    if (!self.nmui_needsDifferentDebugColor) {
        return UIColorTestRed;
    } else {
        return [[UIColor nmui_randomColor] colorWithAlphaComponent:.3];
    }
}


@end
