//
//  UIBarItem+NMUIBadge.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NMUILabel;

/**
 *  用于在 UIBarButtonItem（通常用于 UINavigationBar 和 UIToolbar）和 UITabBarItem 上显示未读红点或者未读数。对设置的时机没有要求。所有属性在 NMUIConfigurationTemplate 配置表里均提供对应的默认值设置，如果你不使用配置表，则所有属性的默认值均为 0。
 *
 *  @note 系统对 UIBarButtonItem 和 UITabBarItem 在横竖屏下均会有不同的布局，当你使用本控件时建议分别检查横竖屏下的表现是否正确。
 */
@interface UIBarItem (NMUIBadge)


#pragma mark - Badge

/// 用数字设置未读数，0表示不显示未读数
@property(nonatomic, assign) NSUInteger nmui_badgeInteger;

/// 用字符串设置未读数，nil 表示不显示未读数
@property(nonatomic, copy, nullable) NSString *nmui_badgeString;

@property(nonatomic, strong, nullable) UIColor *nmui_badgeBackgroundColor;
@property(nonatomic, strong, nullable) UIColor *nmui_badgeTextColor;
@property(nonatomic, strong, nullable) UIFont *nmui_badgeFont;

/// 未读数字与圆圈之间的 padding，会影响最终 badge 的大小。当只有一位数字时，会取宽/高中最大的值作为最终的宽高，以保证整个 badge 是正圆。
@property(nonatomic, assign) UIEdgeInsets nmui_badgeContentEdgeInsets;

/// 默认 badge 的布局处于 item 正中心，而通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，badge 布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint nmui_badgeCenterOffset;

/// 默认 badge 的布局处于 item 正中心，而通过这个属性可以调整横屏模式下 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，badge 布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint nmui_badgeCenterOffsetLandscape;

@property(nonatomic, strong, readonly, nullable) NMUILabel *nmui_badgeLabel;


#pragma mark - UpdatesIndicator

/// 控制红点的显隐
@property(nonatomic, assign) BOOL nmui_shouldShowUpdatesIndicator;
@property(nonatomic, strong, nullable) UIColor *nmui_updatesIndicatorColor;
@property(nonatomic, assign) CGSize nmui_updatesIndicatorSize;

/// 默认红点的布局处于 item 正中心，而通过这个属性可以调整红点相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，红点布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint nmui_updatesIndicatorCenterOffset;

/// 默认红点的布局处于 item 正中心，而通过这个属性可以调整横屏模式下红点相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，红点布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint nmui_updatesIndicatorCenterOffsetLandscape;

@property(nonatomic, strong, readonly, nullable) UIView *nmui_updatesIndicatorView;

@end


NS_ASSUME_NONNULL_END
