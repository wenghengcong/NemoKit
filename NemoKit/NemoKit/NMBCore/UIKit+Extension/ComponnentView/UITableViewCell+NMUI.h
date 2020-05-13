//
//  UITableViewCell+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (NMUI)
/// 获取当前 cell 所在的 tableView，iOS 13 下在 init 时就可以获取到值，而 iOS 12 及以下只能在 cell 被塞给 tableView 后才能获取到值
@property(nonatomic, weak, readonly, nullable) UITableView *nmui_tableView;

/// 设置 cell 点击时的背景色，如果没有 selectedBackgroundView 会创建一个。
/// @warning 请勿再使用 self.selectedBackgroundView.backgroundColor 修改，因为 NMUITheme 里会重新应用 nmui_selectedBackgroundColor，会覆盖 self.selectedBackgroundView.backgroundColor 的效果。
@property(nonatomic, strong, nullable) UIColor *nmui_selectedBackgroundColor;

/// setHighlighted:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^nmui_setHighlightedBlock)(BOOL highlighted, BOOL animated);

/// setSelected:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^nmui_setSelectedBlock)(BOOL selected, BOOL animated);

/// 获取当前 cell 的 accessoryView，优先级分别是：编辑状态下的 editingAccessoryView -> 编辑状态下的系统自己的 accessoryView -> 普通状态下的自定义 accessoryView -> 普通状态下系统自己的 accessoryView
@property(nonatomic, strong, readonly, nullable) __kindof UIView *nmui_accessoryView;

@end

@interface UITableViewCell (NMUI_Styled)

/// 按照 NMUI 配置表的值来将 cell 设置为全局统一的样式
- (void)nmui_styledAsNMUITableViewCell;

@property(nonatomic, strong, readonly, nullable) UIColor *nmui_styledTextLabelColor;
@property(nonatomic, strong, readonly, nullable) UIColor *nmui_styledDetailTextLabelColor;
@property(nonatomic, strong, readonly, nullable) UIColor *nmui_styledBackgroundColor;
@property(nonatomic, strong, readonly, nullable) UIColor *nmui_styledSelectedBackgroundColor;
@property(nonatomic, strong, readonly, nullable) UIColor *nmui_styledWarningBackgroundColor;

@end

NS_ASSUME_NONNULL_END
