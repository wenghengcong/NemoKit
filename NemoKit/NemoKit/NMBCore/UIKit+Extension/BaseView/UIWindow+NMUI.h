//
//  UIWindow+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//




#import <UIKit/UIKit.h>


@interface UIWindow (NMUI)

/**
 允许当前 window 接管 statusBar 的样式设置，默认为 YES。
 
 @note 经测试，- [UIViewController prefersStatusBarHidden]、- [UIViewController preferredStatusBarStyle]、- [UIViewController preferredStatusBarUpdateAnimation] 系列方法仅当该 viewController 所在的 UIWindow 符合以下条件时才能生效：
 1. window 处于最顶层，没有其他 window 遮挡
 2. iOS 10 及以后，window.frame 与 mainScreen.bounds 相等（origin、size 都应一模一样）
 因此当我们在某些情况下利用 UIWindow 去实现遮罩、浮层等效果时，会错误地导致原来的 window 内的 viewController 丢失了对 statusBar 的控制权（因为你新加的 window 满足了上文所有条件），为了避免这种情况，可以将你自己的 window.nmui_capturesStatusBarAppearance = NO，这样你的 window 就不会影响原 window 对 statusBar 的控制权。同理，如果你的 window 本身就不需要盖住整个屏幕，那就算你不设置 nmui_capturesStatusBarAppearance 也不会影响原 window 的表现。
 
 @warning 如果你自己创建的 window 不满足以上2点，那么就算 nmui_capturesStatusBarAppearance 为 YES，也无法得到 statusBar 的控制权。
 */
@property(nonatomic, assign) BOOL nmui_capturesStatusBarAppearance;

/// 获取keywindow，一定是系统指定的keywindow
+ (nullable UIWindow *)nmui_keyWindow;
/// 主app 根控制器所在的window，不管是否处于前台激活状态
+ (nullable UIWindow *)nmui_rootViewControllerWindow;

@end

