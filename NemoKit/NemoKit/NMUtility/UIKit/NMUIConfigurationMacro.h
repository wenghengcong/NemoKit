//
//  NMUIConfigurationMacro.h
//  Nemo
//
//  Created by Hunt on 2019/10/15.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMUIConfigurationMacro_h
#define NMUIConfigurationMacro_h

#import "NMUIConfiguration.h"

/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 NMUIConfigurationTemplate 或 NMUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 NMUIConfiguration 属性。
 */


// 单例的宏

#define NMUICMI ({[[NMUIConfiguration sharedInstance] applyInitialTemplate];[NMUIConfiguration sharedInstance];})

/// 标志当前项目是否正使用配置表功能
#define NMUICMIActivated            [NMUICMI active]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [NMUICMI clearColor]
#define UIColorWhite                [NMUICMI whiteColor]
#define UIColorBlack                [NMUICMI blackColor]
#define UIColorGray                 [NMUICMI grayColor]
#define UIColorGrayDarken           [NMUICMI grayDarkenColor]
#define UIColorGrayLighten          [NMUICMI grayLightenColor]
#define UIColorRed                  [NMUICMI redColor]
#define UIColorGreen                [NMUICMI greenColor]
#define UIColorBlue                 [NMUICMI blueColor]
#define UIColorYellow               [NMUICMI yellowColor]

// 功能颜色
#define UIColorLink                 [NMUICMI linkColor]                       // 全局统一文字链接颜色
#define UIColorDisabled             [NMUICMI disabledColor]                   // 全局统一文字disabled颜色
#define UIColorForBackground        [NMUICMI backgroundColor]                 // 全局统一的背景色
#define UIColorMask                 [NMUICMI maskDarkColor]                   // 全局统一的mask背景色
#define UIColorMaskWhite            [NMUICMI maskLightColor]                  // 全局统一的mask背景色，白色
#define UIColorSeparator            [NMUICMI separatorColor]                  // 全局分隔线颜色
#define UIColorSeparatorDashed      [NMUICMI separatorDashedColor]            // 全局分隔线颜色（虚线）
#define UIColorPlaceholder          [NMUICMI placeholderColor]                // 全局的输入框的placeholder颜色

// 测试用的颜色
#define UIColorTestRed              [NMUICMI testColorRed]
#define UIColorTestGreen            [NMUICMI testColorGreen]
#define UIColorTestBlue             [NMUICMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha       [NMUICMI controlHighlightedAlpha]          // 一般control的Highlighted透明值
#define UIControlDisabledAlpha          [NMUICMI controlDisabledAlpha]             // 一般control的Disable透明值

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [NMUICMI buttonHighlightedAlpha]           // 按钮Highlighted状态的透明度
#define ButtonDisabledAlpha             [NMUICMI buttonDisabledAlpha]              // 按钮Disabled状态的透明度
#define ButtonTintColor                 [NMUICMI buttonTintColor]                  // 普通按钮的颜色

#define GhostButtonColorBlue            [NMUICMI ghostButtonColorBlue]              // NMUIGhostButtonColorBlue的颜色
#define GhostButtonColorRed             [NMUICMI ghostButtonColorRed]               // NMUIGhostButtonColorRed的颜色
#define GhostButtonColorGreen           [NMUICMI ghostButtonColorGreen]             // NMUIGhostButtonColorGreen的颜色
#define GhostButtonColorGray            [NMUICMI ghostButtonColorGray]              // NMUIGhostButtonColorGray的颜色
#define GhostButtonColorWhite           [NMUICMI ghostButtonColorWhite]             // NMUIGhostButtonColorWhite的颜色

#define FillButtonColorBlue             [NMUICMI fillButtonColorBlue]              // NMUIFillButtonColorBlue的颜色
#define FillButtonColorRed              [NMUICMI fillButtonColorRed]               // NMUIFillButtonColorRed的颜色
#define FillButtonColorGreen            [NMUICMI fillButtonColorGreen]             // NMUIFillButtonColorGreen的颜色
#define FillButtonColorGray             [NMUICMI fillButtonColorGray]              // NMUIFillButtonColorGray的颜色
#define FillButtonColorWhite            [NMUICMI fillButtonColorWhite]             // NMUIFillButtonColorWhite的颜色

#pragma mark - TextField & TextView
#define TextFieldTintColor              [NMUICMI textFieldTintColor]               // 全局UITextField、UITextView的tintColor
#define TextFieldTextInsets             [NMUICMI textFieldTextInsets]              // NMUITextField的内边距
#define KeyboardAppearance              [NMUICMI keyboardAppearance]

#pragma mark - UISwitch
#define SwitchOnTintColor               [NMUICMI switchOnTintColor]                 // UISwitch 打开时的背景色（除了圆点外的其他颜色）
#define SwitchOffTintColor              [NMUICMI switchOffTintColor]                // UISwitch 关闭时的背景色（除了圆点外的其他颜色）
#define SwitchTintColor                 [NMUICMI switchTintColor]                   // UISwitch 关闭时的周围边框颜色
#define SwitchThumbTintColor            [NMUICMI switchThumbTintColor]              // UISwitch 中间的操控圆点的颜色

#pragma mark - NavigationBar

#define NavBarHighlightedAlpha                          [NMUICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [NMUICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [NMUICMI navBarButtonFont]
#define NavBarButtonFontBold                            [NMUICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [NMUICMI navBarBackgroundImage]
#define NavBarShadowImage                               [NMUICMI navBarShadowImage]
#define NavBarShadowImageColor                          [NMUICMI navBarShadowImageColor]
#define NavBarBarTintColor                              [NMUICMI navBarBarTintColor]
#define NavBarStyle                                     [NMUICMI navBarStyle]
#define NavBarTintColor                                 [NMUICMI navBarTintColor]
#define NavBarTitleColor                                [NMUICMI navBarTitleColor]
#define NavBarTitleFont                                 [NMUICMI navBarTitleFont]
#define NavBarLargeTitleColor                           [NMUICMI navBarLargeTitleColor]
#define NavBarLargeTitleFont                            [NMUICMI navBarLargeTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [NMUICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [NMUICMI navBarBackIndicatorImage]
#define SizeNavBarBackIndicatorImageAutomatically       [NMUICMI sizeNavBarBackIndicatorImageAutomatically]
#define NavBarCloseButtonImage                          [NMUICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [NMUICMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [NMUICMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [NMUICMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [NMUICMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片


#pragma mark - TabBar

#define TabBarBackgroundImage                           [NMUICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [NMUICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [NMUICMI tabBarShadowImageColor]
#define TabBarStyle                                     [NMUICMI tabBarStyle]
#define TabBarItemTitleFont                             [NMUICMI tabBarItemTitleFont]
#define TabBarItemTitleColor                            [NMUICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [NMUICMI tabBarItemTitleColorSelected]
#define TabBarItemImageColor                            [NMUICMI tabBarItemImageColor]
#define TabBarItemImageColorSelected                    [NMUICMI tabBarItemImageColorSelected]

#pragma mark - Toolbar

#define ToolBarHighlightedAlpha                         [NMUICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [NMUICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [NMUICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [NMUICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [NMUICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [NMUICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [NMUICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [NMUICMI toolBarShadowImageColor]
#define ToolBarStyle                                    [NMUICMI toolBarStyle]
#define ToolBarButtonFont                               [NMUICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBorderColor                   [NMUICMI searchBarTextFieldBorderColor]
#define SearchBarTextFieldBackgroundImage               [NMUICMI searchBarTextFieldBackgroundImage]
#define SearchBarBackgroundImage                        [NMUICMI searchBarBackgroundImage]
#define SearchBarTintColor                              [NMUICMI searchBarTintColor]
#define SearchBarTextColor                              [NMUICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [NMUICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [NMUICMI searchBarFont]
#define SearchBarSearchIconImage                        [NMUICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [NMUICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [NMUICMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewEstimatedHeightEnabled                 [NMUICMI tableViewEstimatedHeightEnabled]            // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

#define TableViewBackgroundColor                        [NMUICMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableSectionIndexColor                          [NMUICMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色
#define TableSectionIndexBackgroundColor                [NMUICMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色
#define TableSectionIndexTrackingBackgroundColor        [NMUICMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色
#define TableViewSeparatorColor                         [NMUICMI tableViewSeparatorColor]                    // 列表分隔线颜色
#define TableViewCellBackgroundColor                    [NMUICMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor            [NMUICMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor             [NMUICMI tableViewCellWarningBackgroundColor]        // 列表 cell 在提醒状态下的背景色
#define TableViewCellNormalHeight                       [NMUICMI tableViewCellNormalHeight]                  // NMUITableView 的默认 cell 高度

#define TableViewCellDisclosureIndicatorImage           [NMUICMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                     [NMUICMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage                  [NMUICMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [NMUICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor           [NMUICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor           [NMUICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                      [NMUICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                      [NMUICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor                 [NMUICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor                 [NMUICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderAccessoryMargins          [NMUICMI tableViewSectionHeaderAccessoryMargins]
#define TableViewSectionFooterAccessoryMargins          [NMUICMI tableViewSectionFooterAccessoryMargins]
#define TableViewSectionHeaderContentInset              [NMUICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset              [NMUICMI tableViewSectionFooterContentInset]

#define TableViewGroupedBackgroundColor                 [NMUICMI tableViewGroupedBackgroundColor]               // Grouped 类型的 NMUITableView 的背景色
#define TableViewGroupedCellTitleLabelColor             [NMUICMI tableViewGroupedCellTitleLabelColor]           // Grouped 类型的列表的 NMUITableViewCell 的标题颜色
#define TableViewGroupedCellDetailLabelColor            [NMUICMI tableViewGroupedCellDetailLabelColor]          // Grouped 类型的列表的 NMUITableViewCell 的副标题颜色
#define TableViewGroupedCellBackgroundColor             [NMUICMI tableViewGroupedCellBackgroundColor]           // Grouped 类型的列表的 NMUITableViewCell 的背景色
#define TableViewGroupedCellSelectedBackgroundColor     [NMUICMI tableViewGroupedCellSelectedBackgroundColor]   // Grouped 类型的列表的 NMUITableViewCell 点击时的背景色
#define TableViewGroupedCellWarningBackgroundColor      [NMUICMI tableViewGroupedCellWarningBackgroundColor]    // Grouped 类型的列表的 NMUITableViewCell 在提醒状态下的背景色
#define TableViewGroupedSectionHeaderFont               [NMUICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont               [NMUICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor          [NMUICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor          [NMUICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderAccessoryMargins   [NMUICMI tableViewGroupedSectionHeaderAccessoryMargins]
#define TableViewGroupedSectionFooterAccessoryMargins   [NMUICMI tableViewGroupedSectionFooterAccessoryMargins]
#define TableViewGroupedSectionHeaderDefaultHeight      [NMUICMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight      [NMUICMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset       [NMUICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset       [NMUICMI tableViewGroupedSectionFooterContentInset]

#define TableViewCellTitleLabelColor                    [NMUICMI tableViewCellTitleLabelColor]               // cell的title颜色
#define TableViewCellDetailLabelColor                   [NMUICMI tableViewCellDetailLabelColor]              // cell的detailTitle颜色

#pragma mark - UIWindowLevel
#define UIWindowLevelNMUIAlertView                      [NMUICMI windowLevelNMUIAlertView]

#pragma mark - NMBFLog
#define ShouldPrintDefaultLog                           [NMUICMI shouldPrintDefaultLog]
#define ShouldPrintInfoLog                              [NMUICMI shouldPrintInfoLog]
#define ShouldPrintWarnLog                              [NMUICMI shouldPrintWarnLog]

#pragma mark - NMUIBadge
#define BadgeBackgroundColor                            [NMUICMI badgeBackgroundColor]
#define BadgeTextColor                                  [NMUICMI badgeTextColor]
#define BadgeFont                                       [NMUICMI badgeFont]
#define BadgeContentEdgeInsets                          [NMUICMI badgeContentEdgeInsets]
#define BadgeCenterOffset                               [NMUICMI badgeCenterOffset]
#define BadgeCenterOffsetLandscape                      [NMUICMI badgeCenterOffsetLandscape]

#define UpdatesIndicatorColor                           [NMUICMI updatesIndicatorColor]
#define UpdatesIndicatorSize                            [NMUICMI updatesIndicatorSize]
#define UpdatesIndicatorCenterOffset                    [NMUICMI updatesIndicatorCenterOffset]
#define UpdatesIndicatorCenterOffsetLandscape           [NMUICMI updatesIndicatorCenterOffsetLandscape]

#pragma mark - Others

#define AutomaticCustomNavigationBarTransitionStyle [NMUICMI automaticCustomNavigationBarTransitionStyle] // 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
#define SupportedOrientationMask                        [NMUICMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [NMUICMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [NMUICMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为NO，也即黑色
#define NeedsBackBarButtonItemTitle                     [NMUICMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [NMUICMI hidesBottomBarWhenPushedInitially] // NMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define PreventConcurrentNavigationControllerTransitions [NMUICMI preventConcurrentNavigationControllerTransitions] // PreventConcurrentNavigationControllerTransitions : 自动保护 NMUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
#define NavigationBarHiddenInitially                    [NMUICMI navigationBarHiddenInitially]      // preferredNavigationBarHidden 的初始值，默认为NO
#define ShouldFixTabBarTransitionBugInIPhoneX           [NMUICMI shouldFixTabBarTransitionBugInIPhoneX] // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
#define ShouldFixTabBarButtonBugForAll                  [NMUICMI shouldFixTabBarButtonBugForAll] // 是否要对 iOS 12.1.2 及以后的版本也修复手势返回时 tabBarButton 布局错误的 bug(issue #410)，默认为 NO
#define ShouldPrintNMUIWarnLogToConsole                 [NMUICMI shouldPrintNMUIWarnLogToConsole] // 是否在出现 NMBFLogWarn 时自动把这些 log 以 NMUIConsole 的方式显示到设备屏幕上
#define SendAnalyticsToNMUITeam                         [NMUICMI sendAnalyticsToNMUITeam] // 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 NMUI 统计用
#define DynamicPreferredValueForIPad                    [NMUICMI dynamicPreferredValueForIPad] // 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
#define IgnoreKVCAccessProhibited                       [NMUICMI ignoreKVCAccessProhibited] // 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
#define AdjustScrollIndicatorInsetsByContentInsetAdjustment [NMUICMI adjustScrollIndicatorInsetsByContentInsetAdjustment] // 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。

#endif /* NMUIConfigurationMacro_h */
