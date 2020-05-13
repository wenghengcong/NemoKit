//
//  NMUITabBarController.m
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITabBarController.h"
#import "NMBCore.h"
#import "UIViewController+NMUI.h"

@interface NMUITabBarController ()

@end

@implementation NMUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    // subclass hooking
}

#pragma mark- Status bar

/// 将状态栏的控制器交给selectedViewController，而非tabbarcontroller本身
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

#pragma mark - 屏幕旋转

/// 是否支持旋转
/// presentedViewController -> selectedViewController
- (BOOL)shouldAutorotate {
    BOOL shouldAutorotate = self.presentedViewController ? [self.presentedViewController shouldAutorotate] : ([self.selectedViewController nmui_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController shouldAutorotate] : YES);
    return shouldAutorotate;
}


/// 支持的旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // fix UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // crash in iOS 9 and show log in iOS 10 and later
    // https://github.com/Tencent/QMUI_iOS/issues/502
    // https://github.com/Tencent/QMUI_iOS/issues/632
    UIViewController *visibleViewController = self.presentedViewController;
    if (!visibleViewController || visibleViewController.isBeingDismissed || [visibleViewController isKindOfClass:UIAlertController.class]) {
        visibleViewController = self.selectedViewController;
    }
    
    if ([visibleViewController isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]) {
        return visibleViewController.supportedInterfaceOrientations;
    }
    
    return [visibleViewController nmui_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

/// 是否隐藏Home指示条
- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}


@end
