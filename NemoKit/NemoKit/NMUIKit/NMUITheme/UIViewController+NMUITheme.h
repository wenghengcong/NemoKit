//
//  UIViewController+NMUITheme.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NMUIThemeManager;
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (NMUITheme)

/// 当主题变化时这个方法会被调用
/// @param manager 当前的主题管理对象
/// @param identifier 当前主题的标志，可自行修改参数类型为目标类型
/// @param theme 当前主题对象，可自行修改参数类型为目标类型
- (void)nmui_themeDidChangeByManager:(NMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
