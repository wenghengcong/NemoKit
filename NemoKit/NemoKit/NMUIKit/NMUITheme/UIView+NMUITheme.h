//
//  UIView+NMUITheme.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>

@class NMUIThemeManager;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NMUITheme)

/// 注册当前 view 里需要在主题变化时被重新设置的 property，当主题变化时，会通过 nmui_themeDidChangeByManager:identifier:theme: 来重新调用一次 self.xxx = xxx，以达到刷新界面的目的。
/// @param getters getters 属性的 getter， 内部会根据命名规则自动转换得到 setter，再通过 performSelector 的形式调用 getter 和 setter
- (void)nmui_registerThemeColorProperties:(NSArray<NSString *> *)getters;

/// 注销通过 nmui_registerThemeColorProperties: 注册的 property
/// @param getters getters 属性的 getter， 内部会根据命名规则自动转换得到 setter，再通过 performSelector 的形式调用 getter 和 setter
- (void)nmui_unregisterThemeColorProperties:(NSArray<NSString *> *)getters;


/// 当主题变化时这个方法会被调用，通过 registerThemeColorProperties: 方法注册的属性也会在这里被更新（所以记得要调用 super）。registerThemeColorProperties: 无法满足的需求可以重写这个方法自行实现。
/// @param manager 当前的主题管理对象
/// @param identifier 当前主题的标志，可自行修改参数类型为目标类型
/// @param theme 当前主题对象，可自行修改参数类型为目标类型
- (void)nmui_themeDidChangeByManager:(nullable NMUIThemeManager *)manager identifier:(nullable __kindof NSObject<NSCopying> *)identifier theme:(nullable __kindof NSObject *)theme NS_REQUIRES_SUPER;

@property(nonatomic, copy, nullable) void (^nmui_themeDidChangeBlock)(void);

@end

NS_ASSUME_NONNULL_END
