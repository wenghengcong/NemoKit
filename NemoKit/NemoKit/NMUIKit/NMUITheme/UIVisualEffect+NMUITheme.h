//
//  UIVisualEffect+NMUITheme.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUIThemeManager;

@protocol NMUIDynamicEffectProtocol <NSObject>
@required

/// 获取当前 UIVisualEffect 的实际 effect（返回的 effect 必定不是 dynamic image）
@property(nonatomic, strong, readonly) __kindof UIVisualEffect *nmui_rawEffect;

/// 标志当前 UIVisualEffect 对象是否为动态 effect（由 [UIVisualEffect nmui_effectWithThemeProvider:] 创建的 effect
@property(nonatomic, assign, readonly) BOOL nmui_isDynamicEffect;
@end

@interface UIVisualEffect (NMUITheme) <NMUIDynamicEffectProtocol>


/// 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 NMUIThemeManager 主题返回对应的 effect。
/// @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
/// @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
+ (UIVisualEffect *)nmui_effectWithThemeProvider:(UIVisualEffect *(^)(__kindof NMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;


/// 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 NMUIThemeManager  name 和主题返回对应的 effect。
/// @param name themeManager 的 name，用于区分不同维度的主题管理器
/// @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
/// @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
+ (UIVisualEffect *)nmui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect *(^)(__kindof NMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;
@end

NS_ASSUME_NONNULL_END
