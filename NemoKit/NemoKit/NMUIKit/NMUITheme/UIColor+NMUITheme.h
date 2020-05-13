//
//  UIColor+NMUITheme.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NMUIThemeManager;

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (NMUITheme)

/// 生成一个动态的 color 对象（NMUIThemeColor），每次使用该颜色时都会动态根据当前的 NMUIThemeManager 主题返回对应的颜色
/// @param provider  当 color 被使用时，这个 provider 会被调用，返回对应当前主题的 color 值。请不要在这个 block 里做耗时操作。
/// @return 当前主题下的实际色值，由 provider 返回
+ (UIColor *)nmui_colorWithThemeProvider:(UIColor *(^)(__kindof NMUIThemeManager *manager,
                                                       __kindof NSObject<NSCopying> * _Nullable identifier,
                                                       __kindof NSObject * _Nullable theme))provider;


/// 生成一个动态的 color 对象（NMUIThemeColor），每次使用该颜色时都会动态根据当前的 NMUIThemeManager name 和主题返回对应的颜色。
/// @param name themeManager 的 name，用于区分不同维度的主题管理器
/// @param provider 当 color 被使用时，这个 provider 会被调用，返回对应当前主题的 color 值。请不要在这个 block 里做耗时操作。
/// @return 当前主题下的实际色值，由 provider 返回
+ (UIColor *)nmui_colorWithThemeManagerName:(__kindof NSObject<NSCopying> *)name
                                   provider:(UIColor *(^)(__kindof NMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

@end

NS_ASSUME_NONNULL_END
