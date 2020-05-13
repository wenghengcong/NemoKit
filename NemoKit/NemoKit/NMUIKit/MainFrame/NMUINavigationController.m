//
//  NMUINavigationController.m
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUINavigationController.h"
#import "NMBCore.h"
#import "UIViewController+NMUI.h"
#import "NMBFWeakObjectContainer.h"
#import "UINavigationController+NMUI.h"
#import "NSObject+NMBFMultipleDelegates.h"

@protocol NMUI_viewWillAppearNotifyDelegate <NSObject>

- (void)nmui_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController;

@end

@interface _NMUINavigationControllerDelegator : NSObject <NMUINavigationControllerDelegate>

@property(nonatomic, weak) NMUINavigationController *navigationController;
@end

@interface NMUINavigationController () <UIGestureRecognizerDelegate, NMUI_viewWillAppearNotifyDelegate>

@property(nonatomic, strong) _NMUINavigationControllerDelegator *delegator;

/// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面。
/// 在 getter 方法里会根据配置表开关 PreventConcurrentNavigationControllerTransitions 的值来控制这个属性是否生效。
@property(nonatomic, assign) BOOL isViewControllerTransiting;

/// 即将要被pop的controller
@property(nonatomic, weak) UIViewController *viewControllerPopping;

@end

@interface UIViewController (NMUINavigationControllerTransition)

@property(nonatomic, weak) id<NMUI_viewWillAppearNotifyDelegate> nmui_viewWillAppearNotifyDelegate;

@end

@implementation UIViewController (NMUINavigationControllerTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if ([selfObject.nmui_viewWillAppearNotifyDelegate respondsToSelector:@selector(nmui_viewControllerDidInvokeViewWillAppear:)]) {
                [selfObject.nmui_viewWillAppearNotifyDelegate nmui_viewControllerDidInvokeViewWillAppear:selfObject];
            }
        });
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if ([selfObject.navigationController.viewControllers containsObject:selfObject] && [selfObject.navigationController isKindOfClass:[NMUINavigationController class]]) {
                ((NMUINavigationController *)selfObject.navigationController).isViewControllerTransiting = NO;
            }
            selfObject.nmui_poppingByInteractivePopGestureRecognizer = NO;
            selfObject.nmui_willAppearByInteractivePopGestureRecognizer = NO;
        });
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidDisappear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            selfObject.nmui_poppingByInteractivePopGestureRecognizer = NO;
            selfObject.nmui_willAppearByInteractivePopGestureRecognizer = NO;
        });
    });
}

static char kAssociatedObjectKey_nmui_viewWillAppearNotifyDelegate;
-(void)setNmui_viewWillAppearNotifyDelegate:
(id<NMUI_viewWillAppearNotifyDelegate>)nmui_viewWillAppearNotifyDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmui_viewWillAppearNotifyDelegate, [[NMBFWeakObjectContainer alloc] initWithObject:nmui_viewWillAppearNotifyDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<NMUI_viewWillAppearNotifyDelegate>)nmui_viewWillAppearNotifyDelegate {
    id weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_nmui_viewWillAppearNotifyDelegate);
    if ([weakContainer isKindOfClass:[NMBFWeakObjectContainer class]]) {
        id notifyDelegate = [weakContainer object];
        return notifyDelegate;
    }
    return nil;
}

@end


@interface NMUINavigationController ()

@end

@implementation NMUINavigationController

#pragma mark - 生命周期函数 && 基类方法重写

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        if (@available(iOS 13.0, *)) {
            // -[UINavigationController initWithRootViewController:] 在 iOS 13 以下的版本内部会调用 [self initWithNibName:bundle] 而在 iOS 13 上则是直接调用 [super initWithNibName:bundle] 所以这里需要手动调用一次 [self didInitialize]
            [self didInitialize];
        }
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    self.nmbf_multipleDelegatesEnabled = YES;
    self.delegator = [[_NMUINavigationControllerDelegator alloc] init];
    self.delegator.navigationController = self;
    self.delegate = self.delegator;
    
    // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
    if (NMUICMIActivated) {
        self.navigationBar.tintColor = NavBarTintColor;
        self.toolbar.tintColor = ToolBarTintColor;
    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 手势允许多次addTarget
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePopGestureRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willShowViewController:self.topViewController animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didShowViewController:self.topViewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
        return [super popViewControllerAnimated:animated];
    }
    
    UIViewController *viewController = [self topViewController];
    self.viewControllerPopping = viewController;
    
    if (animated) {
        self.viewControllerPopping.nmui_viewWillAppearNotifyDelegate = self;
        
        self.isViewControllerTransiting = YES;
    }
    
    if ([viewController respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewController) willPopInNavigationControllerWithAnimated:animated];
    }
    
    //    NMBFLog(@"NavigationItem", @"call popViewControllerAnimated:%@, current viewControllers = %@", StringFromBOOL(animated), self.viewControllers);
    
    viewController = [super popViewControllerAnimated:animated];
    
    //    NMBFLog(@"NavigationItem", @"pop viewController: %@", viewController);
    
    if ([viewController respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewController) didPopInNavigationControllerWithAnimated:animated];
    }
    return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController || self.topViewController == viewController) {
        // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
        return [super popToViewController:viewController animated:animated];
    }
    
    self.viewControllerPopping = self.topViewController;
    
    if (animated) {
        self.viewControllerPopping.nmui_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if (viewControllerPopping == viewController) {
            break;
        }
        
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> *poppedViewControllers = [super popToViewController:viewController animated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
    if (self.topViewController == self.nmui_rootViewController) {
        return nil;
    }
    
    self.viewControllerPopping = self.topViewController;
    
    if (animated) {
        self.viewControllerPopping.nmui_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> * poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    return poppedViewControllers;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController *topViewController = self.topViewController;
    
    // will pop
    NSMutableArray<UIViewController *> *viewControllersPopping = self.viewControllers.mutableCopy;
    [viewControllersPopping removeObjectsInArray:viewControllers];
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)obj) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // setViewControllers 不会触发 pushViewController，所以这里也要更新一下返回按钮的文字
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull viewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [self updateBackItemTitleWithCurrentViewController:viewController nextViewController:idx + 1 < viewControllers.count ? viewControllers[idx + 1] : nil];
    }];
    
    [super setViewControllers:viewControllers animated:animated];
    
    // did pop
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)obj) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
    if (topViewController == viewControllers.lastObject) {
        if ([topViewController respondsToSelector:@selector(viewControllerKeepingAppearWhenSetViewControllersWithAnimated:)]) {
            [((UIViewController<NMUINavigationControllerTransitionDelegate> *)topViewController) viewControllerKeepingAppearWhenSetViewControllersWithAnimated:animated];
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isViewControllerTransiting || !viewController) {
        NMBFLogWarn(NSStringFromClass(self.class), @"%@, 上一次界面切换的动画尚未结束就试图进行新的 push 操作，为了避免产生 bug，拦截了这次 push。\n%s, isViewControllerTransiting = %@, viewController = %@, self.viewControllers = %@", NSStringFromClass(self.class),  __func__, StringFromBOOL(self.isViewControllerTransiting), viewController, self.viewControllers);
        return;
    }
    
    // 增加一个 presentedViewController 作为判断条件是因为这个 issue：https://github.com/Tencent/QMUI_iOS/issues/261
    if (!self.presentedViewController && animated) {
        self.isViewControllerTransiting = YES;
    }
    
    if (self.presentedViewController) {
        NMBFLogWarn(NSStringFromClass(self.class), @"push 的时候 navigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
    }
    
    // 在 push 前先设置好返回按钮的文字
    [self updateBackItemTitleWithCurrentViewController:self.topViewController nextViewController:viewController];
    
    [super pushViewController:viewController animated:animated];
    
    // 某些情况下 push 操作可能会被系统拦截，实际上该 push 并不生效，这种情况下应当恢复相关标志位，否则会影响后续的 push 操作
    // https://github.com/Tencent/QMUI_iOS/issues/426
    if (![self.viewControllers containsObject:viewController]) {
        self.isViewControllerTransiting = NO;
    }
}

- (void)updateBackItemTitleWithCurrentViewController:(UIViewController *)currentViewController nextViewController:(UIViewController *)nextViewController {
    if (currentViewController) {
        // 全局屏蔽返回按钮的文字
        if (NMUICMIActivated && !NeedsBackBarButtonItemTitle) {
            currentViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        }
        
        // 如果某个 viewController 显式声明了返回按钮的文字，则无视配置表 NeedsBackBarButtonItemTitle 的值，且该 viewController 的前一个 viewController 会负责设置该 viewController 的返回按钮文字
        UIViewController<NMUINavigationControllerAppearanceDelegate> *vc = (UIViewController<NMUINavigationControllerAppearanceDelegate> *)nextViewController;
        if ([vc respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
            NSString *title = [vc backBarButtonItemTitleWithPreviousViewController:currentViewController];
            currentViewController.navigationItem.backBarButtonItem = title ? [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:NULL] : nil;
        }
    }
}


#pragma mark - 自定义方法

- (BOOL)isViewControllerTransiting {
    // 如果配置表里这个开关关闭，则为了使 isViewControllerTransiting 功能失效，强制返回 NO
    if (!PreventConcurrentNavigationControllerTransitions) {
        return NO;
    }
    return _isViewControllerTransiting;
}

// 接管系统手势返回的回调
- (void)handleInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    UIViewController *viewControllerWillDisappear = self.viewControllerPopping;
    UIViewController *viewControllerWillAppear = self.topViewController;
    
    viewControllerWillDisappear.nmui_poppingByInteractivePopGestureRecognizer = YES;
    viewControllerWillDisappear.nmui_willAppearByInteractivePopGestureRecognizer = NO;
    
    viewControllerWillAppear.nmui_poppingByInteractivePopGestureRecognizer = NO;
    viewControllerWillAppear.nmui_willAppearByInteractivePopGestureRecognizer = YES;
    
    if (state == UIGestureRecognizerStateBegan) {
        // UIGestureRecognizerStateBegan 对应 viewWillAppear:，只要在 viewWillAppear: 里的修改都是安全的，但只要过了 viewWillAppear:，后续的修改都是不安全的，所以这里用 dispatch 的方式将标志位的赋值放到 viewWillAppear: 的下一个 Runloop 里
        dispatch_async(dispatch_get_main_queue(), ^{
            viewControllerWillDisappear.nmui_navigationControllerPopGestureRecognizerChanging = YES;
            viewControllerWillAppear.nmui_navigationControllerPopGestureRecognizerChanging = YES;
        });
    } else if (state > UIGestureRecognizerStateChanged) {
        viewControllerWillDisappear.nmui_navigationControllerPopGestureRecognizerChanging = NO;
        viewControllerWillAppear.nmui_navigationControllerPopGestureRecognizerChanging = NO;
    }
    
    if (state == UIGestureRecognizerStateEnded) {
        if (CGRectGetMinX(self.topViewController.view.superview.frame) < 0) {
            // by molice:只是碰巧发现如果是手势返回取消时，不管在哪个位置取消，self.topViewController.view.superview.frame.orgin.x必定是-112，所以用这个<0的条件来判断
            NMBFLog(NSStringFromClass(self.class), @"手势返回放弃了");
            viewControllerWillDisappear = self.topViewController;
            viewControllerWillAppear = self.viewControllerPopping;
        } else {
            NMBFLog(NSStringFromClass(self.class), @"执行手势返回");
        }
    }
    
    if ([viewControllerWillDisappear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerWillDisappear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    
    if ([viewControllerWillAppear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<NMUINavigationControllerTransitionDelegate> *)viewControllerWillAppear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
}

- (void)nmui_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController {
    viewController.nmui_viewWillAppearNotifyDelegate = nil;
    [self.delegator navigationController:self willShowViewController:self.viewControllerPopping animated:YES];
    self.viewControllerPopping = nil;
    self.isViewControllerTransiting = NO;
}

#pragma mark - StatusBar

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [self.visibleViewController nmui_hasOverrideUIKitMethod:_cmd] ? [self.visibleViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // fix UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // crash in iOS 9 and show log in iOS 10 and later
    // https://github.com/Tencent/QMUI_iOS/issues/502
    // https://github.com/Tencent/QMUI_iOS/issues/632
    UIViewController *visibleViewController = self.visibleViewController;
    if (!visibleViewController || visibleViewController.isBeingDismissed || [visibleViewController isKindOfClass:UIAlertController.class]) {
        visibleViewController = self.topViewController;
    }
    return [visibleViewController nmui_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.topViewController;
}



@end



@implementation NMUINavigationController (UISubclassingHooks)

- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

@end

@implementation _NMUINavigationControllerDelegator

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(NMUINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController willShowViewController:viewController animated:animated];
}

- (void)navigationController:(NMUINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.viewControllerPopping = nil;
    [navigationController didShowViewController:viewController animated:animated];
}

@end
