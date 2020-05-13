//
//  UISearchController+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UISearchController+NMUI.h"
#import "NMBCore.h"
#import "UIViewController+NMUI.h"
#import "UINavigationController+NMUI.h"
#import "UIView+NMUI.h"

@implementation UISearchController (NMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation(NSClassFromString(@"_UISearchControllerView"), @selector(didMoveToWindow), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject) {
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                // 修复 https://github.com/Tencent/QMUI_iOS/issues/680 中提到的问题二：当有一个 TableViewController A，A 的 seachBar 被激活且 searchResultsController 正在显示的情况下，A.navigationController push 一个新的 viewController B，B 用 pop 手势返回到一半松手放弃返回，此时 B 再 push 一个新的 viewController 时，在转场过程中会看到 searchResultsController 的内容。
                if (selfObject.window && [selfObject.superview isKindOfClass:NSClassFromString(@"UITransitionView")]) {
                    UIView *transitionView = selfObject.superview;
                    UISearchController *searchController = [selfObject nmui_viewController];
                    UIViewController *sourceViewController = [searchController valueForKey:@"_modalSourceViewController"];
                    UINavigationController *navigationController = sourceViewController.navigationController;
                    if (navigationController.nmui_isPushing && navigationController.topViewController.nmui_previousViewController != sourceViewController) {
                        // 系统内部错误地添加了这个 view，这里直接 remove 掉，系统内部在真正要显示的时候再次添加回来。
                        [transitionView removeFromSuperview];
                    }
                }
                
            };
        });
    });
}

@end
