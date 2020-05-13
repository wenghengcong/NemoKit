//
//  UINavigationController+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UINavigationController+NMUI.h"
#import "NMBCore.h"
#import "NMBFWeakObjectContainer.h"
#import "NMBFAssociationMacro.h"

@interface UINavigationController (BackButtonHandlerProtocol)

// `UINavigationControllerBackButtonHandlerProtocol` 的 `shouldPopViewControllerByBackButtonOrPopGesture` 功能里面，当 A canPop = NO，B canPop = YES，那么从 B 手势返回到 A，也会触发 A 的 `shouldPopViewControllerByBackButtonOrPopGesture` 方法，这是因为手势返回会去询问`gestureRecognizerShouldBegin:`和`nmuinav_navigationBar:shouldPopItem:`，而这两个方法里面的 self.topViewController 是不同的对象，所以导致这个问题。所以通过 tmp_topViewController 来记录 self.topViewController 从而保证两个地方的值是相等的。
// 手势从 B 返回 A，如果 A 没有 navBar，那么`nmuinav_navigationBar:shouldPopItem:`是不会被调用的，所以导致 tmp_topViewController 没有被释放，所以 tmp_topViewController 需要使用 weak 来修饰（https://github.com/Tencent/QMUI_iOS/issues/251）
@property(nonatomic, weak) UIViewController *tmp_topViewController;

// 是否通过手势返回
@property(nonatomic, assign) BOOL nmui_isPoppingByGesture;

@end


@implementation UINavigationController (BackButtonHandlerProtocol)

NMBFSynthesizeIdWeakProperty(tmp_topViewController, setTmp_topViewController)
NMBFSynthesizeBOOLProperty(nmui_isPoppingByGesture, setNmui_isPoppingByGesture)

@end



@interface UINavigationController (NMUI_Private)
@property(nullable, nonatomic, readwrite) UIViewController *nmui_endedTransitionTopViewController;
@end


@implementation UINavigationController (NMUI)

NMBFSynthesizeIdWeakProperty(nmui_endedTransitionTopViewController, setNmui_endedTransitionTopViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            objc_setAssociatedObject(selfObject, &originGestureDelegateKey, selfObject.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
            selfObject.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)selfObject;
        });
        
        NMBFOverrideImplementation([UINavigationController class], @selector(navigationBar:shouldPopItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UINavigationController *selfObject, UINavigationBar *navigationBar, UINavigationItem *item) {
                
                // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这时second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这时我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
                BOOL isPopedByCoding = item != [selfObject topViewController].navigationItem;
                
                // !isPopedByCoding 要放在前面，这样当 !isPopedByCoding 不满足的时候就不会去询问 canPopViewController 了，可以避免额外调用 canPopViewController 里面的逻辑
                BOOL canPopViewController = !isPopedByCoding && [selfObject canPopViewController:selfObject.tmp_topViewController ?: [selfObject topViewController]];
                
                if (canPopViewController || isPopedByCoding) {
                    selfObject.tmp_topViewController = nil;
                    selfObject.nmui_isPoppingByGesture = NO;
                    
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, UINavigationBar *, UINavigationItem *);
                    originSelectorIMP = (BOOL (*)(id, SEL, UINavigationBar *, UINavigationItem *))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, navigationBar, item);
                    return result;
                } else {
                    selfObject.tmp_topViewController = nil;
                    selfObject.nmui_isPoppingByGesture = NO;
                    [selfObject resetSubviewsInNavBar:navigationBar];
                }
                
                return NO;
            };
        });
        
        NMBFOverrideImplementation([UINavigationController class], NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UINavigationController *selfObject, UIView *transitionView, NSInteger transition, UIView *fromView, UIView *toView) {
                
                BOOL (*originSelectorIMP)(id, SEL, UIView *, NSInteger , UIView *, UIView *);
                originSelectorIMP = (BOOL (*)(id, SEL, UIView *, NSInteger , UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transitionView, transition, fromView, toView);
                selfObject.nmui_endedTransitionTopViewController = selfObject.topViewController;
            };
        });
    });
}

static char originGestureDelegateKey;

- (BOOL)nmui_isPushing {
    if (self.viewControllers.count >= 2) {
        UIViewController *previousViewController = self.childViewControllers[self.childViewControllers.count - 2];
        if (previousViewController == self.nmui_endedTransitionTopViewController) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)nmui_isPopping {
    return self.nmui_topViewController != self.topViewController;
}

- (UIViewController *)nmui_topViewController {
    if (self.nmui_isPushing) {
        return self.topViewController;
    }
    return self.nmui_endedTransitionTopViewController ? self.nmui_endedTransitionTopViewController : self.topViewController;
}

- (nullable UIViewController *)nmui_rootViewController {
    return self.viewControllers.firstObject;
}

- (void)nmui_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    [NMUIHelper executeAnimationBlock:^{
        [self pushViewController:viewController animated:animated];
    } completionBlock:completion];
}

- (UIViewController *)nmui_popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __block UIViewController *result = nil;
    [NMUIHelper executeAnimationBlock:^{
        result = [self popViewControllerAnimated:animated];
    } completionBlock:completion];
    return result;
}

- (NSArray<UIViewController *> *)nmui_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    __block NSArray<UIViewController *> *result = nil;
    [NMUIHelper executeAnimationBlock:^{
        result = [self popToViewController:viewController animated:animated];
    } completionBlock:completion];
    return result;
}

- (NSArray<UIViewController *> *)nmui_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __block NSArray<UIViewController *> *result = nil;
    [NMUIHelper executeAnimationBlock:^{
        result = [self popToRootViewControllerAnimated:animated];
    } completionBlock:completion];
    return result;
}

- (BOOL)canPopViewController:(UIViewController *)viewController {
    BOOL canPopViewController = YES;
    
    BeginIgnoreDeprecatedWarning
    if ([viewController respondsToSelector:@selector(shouldHoldBackButtonEvent)] &&
        [viewController shouldHoldBackButtonEvent] &&
        [viewController respondsToSelector:@selector(canPopViewController)] &&
        [viewController canPopViewController] == NO) {
        canPopViewController = NO;
    }
    EndIgnoreDeprecatedWarning
    
    if ([viewController respondsToSelector:@selector(shouldPopViewControllerByBackButtonOrPopGesture:)] &&
        [viewController shouldPopViewControllerByBackButtonOrPopGesture:self.nmui_isPoppingByGesture] == NO) {
        canPopViewController = NO;
    }
    
    return canPopViewController;
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        self.tmp_topViewController = self.topViewController;
        self.nmui_isPoppingByGesture = YES;
        BOOL canPopViewController = [self canPopViewController:self.tmp_topViewController];
        if ([self shouldForceEnableInteractivePopGestureRecognizer]) {
            // 如果是强制手势返回，则不会调用 navigationBar:shouldPopItem:（原因未知，不过好像也没什么影响），导致 pop 回去的上一层界面点击系统返回按钮时调用 [self canPopViewController:self.tmp_topViewController] 时里面的 self.tmp_topViewController 是上一个界面的值，所以提前把它设置为 nil
            self.tmp_topViewController = nil;
            self.nmui_isPoppingByGesture = NO;
        }
        if (canPopViewController) {
            id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
            if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
                return [originGestureDelegate gestureRecognizerShouldBegin:gestureRecognizer];
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldForceEnableInteractivePopGestureRecognizer {
    UIViewController *viewController = [self topViewController];
    return self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.enabled && [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] && [viewController forceEnableInteractivePopGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
        if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
            BOOL originalValue = [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
            if (!originalValue && [self shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
        if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
            return [originGestureDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
        }
    }
    return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
        // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
        return YES;
    }
    return NO;
}

@end


@implementation UIViewController (BackBarButtonSupport)

@end
