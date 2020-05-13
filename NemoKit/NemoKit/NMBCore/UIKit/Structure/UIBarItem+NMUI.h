//
//  UIBarItem+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarItem (NMUI)

/**
 获取 UIBarItem（UIBarButtonItem、UITabBarItem） 内部的 view，通常对于 navigationItem 而言，需要在设置了 navigationItem 后并且在 navigationBar 可见时（例如 viewDidAppear: 及之后）获取 UIBarButtonItem.nmui_view 才有值。
 
 @return 当 UIBarButtonItem 作为 navigationItem 使用时，iOS 10 及以前返回 UINavigationButton，iOS 11 及以后返回 _UIButtonBarButton；当作为 toolbarItem 使用时，iOS 10 及以前返回 UIToolbarButton，iOS 11 及以后返回 _UIButtonBarButton。对于 UITabBarItem，不管任何 iOS 版本均返回 UITabBarButton。
 
 @note 可以通过 nmui_viewDidSetBlock 监听 nmui_view 值的变化，从而无需等待 viewDidAppear: 之类的时机。
 
 @warning 仅对 UIBarButtonItem、UITabBarItem 有效
 */
@property(nullable, nonatomic, weak, readonly) UIView *nmui_view;

/**
 当 item 内的 view 生成后就会调用这个 block。
 
 @note 该方法的本质是系统的 setView:/setCustomView: 被调用时就会调用，但系统在横竖屏旋转时也会再次走到 setView:（即便此时 view 的实例并没有发生变化），所以 NMUI 对这种情况做了屏蔽，以保证这个 block 对于同一个 view 实例只会被调用一次。
 
 @warning 仅对 UIBarButtonItem、UITabBarItem 有效
 */
@property(nullable, nonatomic, copy) void (^nmui_viewDidSetBlock)(__kindof UIBarItem *item,  UIView * _Nullable view);

/**
 当 item 内的 view 的 layoutSubviews 被调用后就会调用这个 block，如果某些需求需要依赖于 subviews 的位置，则使用这个 block。如果只是依赖于 item 的 view 的 frame 变化，则可以使用 nmui_viewLayoutDidChangeBlock。
 
 @warning 仅对 UIBarButtonItem、UITabBarItem 有效
 */
@property(nullable, nonatomic, copy) void (^nmui_viewDidLayoutSubviewsBlock)(__kindof UIBarItem *item, UIView * _Nullable view);

/**
 当 item 内的 view 的 frame 发生变化时就会调用这个 block。
 
 @warning 仅对 UIBarButtonItem、UITabBarItem 有效
 */
@property(nullable, nonatomic, copy) void (^nmui_viewLayoutDidChangeBlock)(__kindof UIBarItem *item, UIView * _Nullable view);


@end

NS_ASSUME_NONNULL_END
