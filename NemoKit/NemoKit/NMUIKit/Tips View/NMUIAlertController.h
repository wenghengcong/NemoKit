//
//  NMUIAlertController.h
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUIModalPresentationViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class NMUIButton;
@class NMUITextField;
@class NMUIAlertController;


typedef NS_ENUM(NSInteger, NMUIAlertActionStyle) {
    NMUIAlertActionStyleDefault = 0,
    NMUIAlertActionStyleCancel,
    NMUIAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, NMUIAlertControllerStyle) {
    NMUIAlertControllerStyleActionSheet = 0,
    NMUIAlertControllerStyleAlert
};


@protocol NMUIAlertControllerDelegate <NSObject>

@optional

- (void)willShowAlertController:(NMUIAlertController *)alertController;
- (void)willHideAlertController:(NMUIAlertController *)alertController;
- (void)didShowAlertController:(NMUIAlertController *)alertController;
- (void)didHideAlertController:(NMUIAlertController *)alertController;
- (BOOL)shouldHideAlertController:(NMUIAlertController *)alertController;

@end


/**
 *  NMUIAlertController的按钮，初始化完通过`NMUIAlertController`的`addAction:`方法添加到 AlertController 上即可。
 */
@interface NMUIAlertAction : NSObject

/**
 *  初始化`NMUIAlertController`的按钮
 *
 *  @param title   按钮标题
 *  @param style   按钮style，跟系统一样，有 Default、Cancel、Destructive 三种类型
 *  @param handler 处理点击事件的block，注意 NMUIAlertAction 点击后必定会隐藏 alertController，不需要手动在 handler 里 hide
 *
 *  @return NMUIAlertController按钮的实例
 */
+ (instancetype)actionWithTitle:(nullable NSString *)title style:(NMUIAlertActionStyle)style handler:(nullable void (^)(__kindof NMUIAlertController *aAlertController, NMUIAlertAction *action))handler;

/// `NMUIAlertAction`对应的 button 对象
@property(nonatomic, strong, readonly) NMUIButton *button;

/// `NMUIAlertAction`对应的标题
@property(nullable, nonatomic, copy, readonly) NSString *title;

/// `NMUIAlertAction`对应的样式
@property(nonatomic, assign, readonly) NMUIAlertActionStyle style;

/// `NMUIAlertAction`是否允许操作
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;

/// `NMUIAlertAction`按钮样式，默认nil。当此值为nil的时候，则使用`NMUIAlertController`的`alertButtonAttributes`或者`sheetButtonAttributes`的值。
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonAttributes;

/// 原理同上`buttonAttributes`
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *buttonDisabledAttributes;

@end


/**
 *  `NMUIAlertController`是模仿系统`UIAlertController`的控件，所以系统有的功能在NMUIAlertController里面基本都有。同时`NMUIAlertController`还提供了一些扩展功能，例如：它的每个 button 都是开放出来的，可以对默认的按钮进行二次处理（比如加一个图片）；可以通过 appearance 在 app 启动的时候修改整个`NMUIAlertController`的主题样式。
 */
@interface NMUIAlertController : UIViewController<NMUIModalPresentationComponentProtocol> {
    UIView          *_containerView;    // 弹窗的主体容器
    UIView          *_scrollWrapView;   // 包含上下两个 scrollView 的容器
    UIScrollView    *_headerScrollView; // 上半部分的内容的 scrollView，例如 title、message
    UIScrollView    *_buttonScrollView; // 所有按钮的容器，特别的，actionSheet 下的取消按钮不放在这里面，因为它不参与滚动
    UIControl       *_maskView;         // 背后占满整个屏幕的半透明黑色遮罩
}

/// alert距离屏幕四边的间距，默认UIEdgeInsetsMake(0, 0, 0, 0)。alert的宽度最终是通过屏幕宽度减去水平的 alertContentMargin 和 alertContentMaximumWidth 决定的。
@property(nonatomic, assign) UIEdgeInsets alertContentMargin UI_APPEARANCE_SELECTOR;

/// alert的最大宽度，默认270。
@property(nonatomic, assign) CGFloat alertContentMaximumWidth UI_APPEARANCE_SELECTOR;

/// alert上分隔线颜色，默认UIColorMake(211, 211, 219)。
@property(nullable, nonatomic, strong) UIColor *alertSeparatorColor UI_APPEARANCE_SELECTOR;

/// alert标题样式，默认@{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontBoldMake(17),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertTitleAttributes UI_APPEARANCE_SELECTOR;

/// alert信息样式，默认@{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertMessageAttributes UI_APPEARANCE_SELECTOR;

/// alert按钮样式，默认@{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonAttributes UI_APPEARANCE_SELECTOR;

/// alert按钮disabled时的样式，默认@{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertButtonDisabledAttributes UI_APPEARANCE_SELECTOR;

/// alert cancel 按钮样式，默认@{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(17),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertCancelButtonAttributes UI_APPEARANCE_SELECTOR;

/// alert destructive 按钮样式，默认@{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *alertDestructiveButtonAttributes UI_APPEARANCE_SELECTOR;

/// alert圆角大小，默认值是 13，以保持与系统默认样式一致
@property(nonatomic, assign) CGFloat alertContentCornerRadius UI_APPEARANCE_SELECTOR;

/// alert按钮高度，默认44pt
@property(nonatomic, assign) CGFloat alertButtonHeight UI_APPEARANCE_SELECTOR;

/// alert头部（非按钮部分）背景色，默认值是：UIColorMakeWithRGBA(247, 247, 247, 1)
@property(nullable, nonatomic, strong) UIColor *alertHeaderBackgroundColor UI_APPEARANCE_SELECTOR;

/// alert按钮背景色，默认值同`alertHeaderBackgroundColor`
@property(nullable, nonatomic, strong) UIColor *alertButtonBackgroundColor UI_APPEARANCE_SELECTOR;

/// alert按钮高亮背景色，默认UIColorMake(232, 232, 232)
@property(nullable, nonatomic, strong) UIColor *alertButtonHighlightBackgroundColor UI_APPEARANCE_SELECTOR;

/// alert头部四边insets间距
@property(nonatomic, assign) UIEdgeInsets alertHeaderInsets UI_APPEARANCE_SELECTOR;

/// alert头部title和message之间的间距，默认3pt
@property(nonatomic, assign) CGFloat alertTitleMessageSpacing UI_APPEARANCE_SELECTOR;

/// alert 内部 textField 的字体
@property(nullable, nonatomic, strong) UIFont *alertTextFieldFont UI_APPEARANCE_SELECTOR;

/// alert 内部 textField 的文字颜色
@property(nullable, nonatomic, strong) UIColor *alertTextFieldTextColor UI_APPEARANCE_SELECTOR;

/// alert 内部 textField 的边框颜色，如果不需要边框，可设置为 nil
@property(nullable, nonatomic, strong) UIColor *alertTextFieldBorderColor UI_APPEARANCE_SELECTOR;


/// sheet距离屏幕四边的间距，默认UIEdgeInsetsMake(10, 10, 10, 10)。
@property(nonatomic, assign) UIEdgeInsets sheetContentMargin UI_APPEARANCE_SELECTOR;

/// sheet的最大宽度，默认值是5.5英寸的屏幕的宽度减去水平的 sheetContentMargin
@property(nonatomic, assign) CGFloat sheetContentMaximumWidth UI_APPEARANCE_SELECTOR;

/// sheet分隔线颜色，默认UIColorMake(211, 211, 219)
@property(nullable, nonatomic, strong) UIColor *sheetSeparatorColor UI_APPEARANCE_SELECTOR;

/// sheet标题样式，默认@{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontBoldMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetTitleAttributes UI_APPEARANCE_SELECTOR;

/// sheet信息样式，默认@{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail]}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetMessageAttributes UI_APPEARANCE_SELECTOR;

/// sheet按钮样式，默认@{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetButtonAttributes UI_APPEARANCE_SELECTOR;

/// sheet按钮disabled时的样式，默认@{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetButtonDisabledAttributes UI_APPEARANCE_SELECTOR;

/// sheet cancel 按钮样式，默认@{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(20),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetCancelButtonAttributes UI_APPEARANCE_SELECTOR;

/// sheet destructive 按钮样式，默认@{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)}
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *sheetDestructiveButtonAttributes UI_APPEARANCE_SELECTOR;

/// sheet cancel 按钮距离其上面元素（按钮或者header）的间距，默认8pt
@property(nonatomic, assign) CGFloat sheetCancelButtonMarginTop UI_APPEARANCE_SELECTOR;

/// sheet内容的圆角，默认值是 13，以保持与系统默认样式一致
@property(nonatomic, assign) CGFloat sheetContentCornerRadius UI_APPEARANCE_SELECTOR;

/// sheet按钮高度，默认值是 57，以保持与系统默认样式一致
@property(nonatomic, assign) CGFloat sheetButtonHeight UI_APPEARANCE_SELECTOR;

/// sheet头部（非按钮部分）背景色，默认值是：UIColorMakeWithRGBA(247, 247, 247, 1)
@property(nullable, nonatomic, strong) UIColor *sheetHeaderBackgroundColor UI_APPEARANCE_SELECTOR;

/// sheet按钮背景色，默认值同`sheetHeaderBackgroundColor`
@property(nullable, nonatomic, strong) UIColor *sheetButtonBackgroundColor UI_APPEARANCE_SELECTOR;

/// sheet按钮高亮背景色，默认UIColorMake(232, 232, 232)
@property(nullable, nonatomic, strong) UIColor *sheetButtonHighlightBackgroundColor UI_APPEARANCE_SELECTOR;

/// sheet头部四边insets间距
@property(nonatomic, assign) UIEdgeInsets sheetHeaderInsets UI_APPEARANCE_SELECTOR;

/// sheet头部title和message之间的间距，默认8pt
@property(nonatomic, assign) CGFloat sheetTitleMessageSpacing UI_APPEARANCE_SELECTOR;


/// 默认初始化方法
- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(NMUIAlertControllerStyle)preferredStyle;

/// 通过类方法初始化实例
+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(NMUIAlertControllerStyle)preferredStyle;

/// @see `NMUIAlertControllerDelegate`
@property(nullable, nonatomic,weak) id<NMUIAlertControllerDelegate>delegate;

/// 增加一个按钮
- (void)addAction:(nonnull NMUIAlertAction *)action;

// 增加一个“取消”按钮，点击后 alertController 会被 hide
- (void)addCancelAction;

/// 增加一个输入框
- (void)addTextFieldWithConfigurationHandler:(void (^_Nullable)(NMUITextField *textField))configurationHandler;

/// 是否应该自动管理输入框的键盘 Return 事件（切换多个输入框的焦点、自动响应某个按钮等），默认为 YES。你也可以通过 UITextFieldDelegate 自己管理，此时请将此属性置为 NO。
@property(nonatomic, assign) BOOL shouldManageTextFieldsReturnEventAutomatically;

/// 增加一个自定义的view作为`NMUIAlertController`的customView
- (void)addCustomView:(UIView *_Nullable)view;

/// 显示`NMUIAlertController`
- (void)showWithAnimated:(BOOL)animated;

/// 隐藏`NMUIAlertController`
- (void)hideWithAnimated:(BOOL)animated;

/// 所有`NMUIAlertAction`对象
@property(nullable, nonatomic, copy, readonly) NSArray <NMUIAlertAction *> *actions;

/// 当前所有通过`addTextFieldWithConfigurationHandler:`接口添加的输入框
@property(nullable, nonatomic, copy, readonly) NSArray <NMUITextField *> *textFields;

/// 设置自定义view。通过`addCustomView:`方法添加一个自定义的view，`NMUIAlertController`会在布局的时候去调用这个view的`sizeThatFits:`方法来获取size，至于x和y坐标则由控件自己控制。
@property(nullable, nonatomic, strong, readonly) UIView *customView;

/// 当前标题title
@property(nullable, nonatomic, copy) NSString *title;

/// 当前信息message
@property(nullable, nonatomic, copy) NSString *message;

/// 当前样式style
@property(nonatomic, assign, readonly) NMUIAlertControllerStyle preferredStyle;

/// 将`NMUIAlertController`弹出来的`NMUIModalPresentationViewController`对象
@property(nullable, nonatomic, strong, readonly) NMUIModalPresentationViewController *modalPresentationViewController;

/// 主体内容（alert 下指整个弹窗，actionSheet 下指取消按钮上方的那些 header 和 按钮）背后用来做背景样式的 view，默认为空白的 UIView，当你需要做磨砂效果时可以将一个 UIVisualEffectView 赋值给它（但推荐用 NMUIVisualEffectView）。当赋值为 nil 时，内部会自动创建一个空白的 UIView 代替，以保证这个属性不为空。
@property(null_resettable, nonatomic, strong) UIView *mainVisualEffectView;

/// actionSheet 下的取消按钮背后用来做背景样式的 view，默认为空白的 UIView，当你需要做磨砂效果时可以将一个 UIVisualEffectView 赋值给它（但推荐用 NMUIVisualEffectView）。alert 情况下不会出现。当赋值为 nil 时，内部会自动创建一个空白的 UIView 代替，以保证这个属性不为空。
@property(null_resettable, nonatomic, strong) UIView *cancelButtonVisualEffectView;

/**
 *  设置按钮的排序是否要由用户添加的顺序来决定，默认为NO，也即与系统原生`UIAlertController`一致，NMUIAlertActionStyleDestructive 类型的action必定在最后面。
 *
 *  @warning 注意 NMUIAlertActionStyleCancel 按钮不受这个属性的影响
 */
@property(nonatomic, assign) BOOL orderActionsByAddedOrdered;

/// maskView是否响应点击，alert默认为NO，sheet默认为YES
@property(nonatomic, assign) BOOL shouldRespondMaskViewTouch;

/// 在 iPhoneX 机器上是否延伸底部背景色。因为在 iPhoneX 上我们会把整个面板往上移动 safeArea 的距离，如果你的面板本来就配置成撑满全屏的样式，那么就会露出底部的空隙，isExtendBottomLayout 可以帮助你把空暇填补上。默认为NO。
/// @warning: 只对 sheet 类型有效
@property(nonatomic, assign) BOOL isExtendBottomLayout UI_APPEARANCE_SELECTOR;

/// 在显示 alert 之前先降下键盘，默认为 YES。系统的 UIAlertController 也会在显示时降下键盘，但它能在消失后把键盘自动升起，并且这个过程不会触发 becomeFirstResponder/resignFirstResponder，NMUIAlertController 暂时做不到这样的效果，只负责降下，不负责恢复。
/// iOS 10 及以上，一个 UIWindow 显示出来时默认就会降下键盘，所以这个属性只在 iOS 9 里有效，iOS 10 及以上即便设置为 NO 也没有效果。
@property(nonatomic, assign) BOOL dismissKeyboardAutomatically;

@end


@interface NMUIAlertController (UIAppearance)

+ (instancetype)appearance;

@end


@interface NMUIAlertController (Manager)

/// 可方便地判断是否有 alertController 正在显示，全局生效
+ (BOOL)isAnyAlertControllerVisible;

@end

NS_ASSUME_NONNULL_END
