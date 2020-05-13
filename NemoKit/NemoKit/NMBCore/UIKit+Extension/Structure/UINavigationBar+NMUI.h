//
//  UINavigationBar+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (NMUI)

/**
 UINavigationBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UINavigationBar 外。
 
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 
 在 iOS 9 及以前是私有的 _UINavigationBarBackground 类。
 */
@property(nonatomic, strong, readonly) UIView *nmui_backgroundView;

/**
 nmui_backgroundView 内显示实际背景的 view，可能是磨砂或者背景图片。
 
 在 iOS 10 及以后，该 view 为 nmui_backgroundView 的 subview，当显示磨砂时是一个 UIVisualEffectView，当显示背景图时是一个 UIImageView。
 
 在 iOS 9 及以前，如果显示磨砂，该 view 为 nmui_backgroundView 的 subview，是一个 _UIBackdropView，如果显示背景图，则返回 nmui_backgroundView 自身，因为 _UINavigationBarBackground 本身就是一个 UIImageView。
 
 @warning 如果要以 view 的方式去修改 UINavigationBar 的背景，由于不同的 iOS 版本，nmui_shadowImageView 和 nmui_backgroundContentView 的层级关系不同，所以为了效果的统一，建议这种情况下操作 nmui_backgroundView 会好过于操作 nmui_backgroundContentView。
 */
@property(nonatomic, strong, readonly) __kindof UIView *nmui_backgroundContentView;

/**
 nmui_backgroundView 内的 subview，用于显示底部分隔线 shadowImage，注意这个 view 是溢出到 nmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nonatomic, strong, readonly) UIImageView *nmui_shadowImageView;

@end

NS_ASSUME_NONNULL_END
