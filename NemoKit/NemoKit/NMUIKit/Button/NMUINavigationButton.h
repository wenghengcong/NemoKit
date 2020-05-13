//
//  NMUINavigationButton.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NMUINavigationButtonType) {
    NMUINavigationButtonTypeNormal,         // 普通导航栏文字按钮
    NMUINavigationButtonTypeBold,           // 导航栏加粗按钮
    NMUINavigationButtonTypeImage,          // 图标按钮
    NMUINavigationButtonTypeBack            // 自定义返回按钮(可以同时带有title)
};

/**
 *  NMUINavigationButton 有两部分组成：
 *  一部分是 UIBarButtonItem (NMUINavigationButton)，提供比系统更便捷的类方法来快速初始化一个 UIBarButtonItem，推荐首选这种方式（原则是能用系统的尽量用系统的，不满足才用自定义的）。
 *  另一部分就是 NMUINavigationButton，会提供一个按钮，作为 customView 给 UIBarButtonItem 使用，这种常用于自定义的返回按钮。
 *  对于第二种按钮，会尽量保证样式、布局看起来都和系统的 UIBarButtonItem 一致，所以内部做了许多 iOS 版本兼容的微调。
 */
@interface NMUINavigationButton : UIButton

/**
 *  获取当前按钮的`NMUINavigationButtonType`
 */
@property(nonatomic, assign, readonly) NMUINavigationButtonType type;

/**
 * UIBarButtonItem 默认都是跟随 tintColor 的，所以这里声明是否让图片也是用 AlwaysTemplate 模式
 * 默认为 YES
 */
@property(nonatomic, assign) BOOL adjustsImageTintColorAutomatically;

/**
 *  导航栏按钮的初始化函数，指定的初始化方法
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(NMUINavigationButtonType)type title:(nullable NSString *)title;

/**
 *  导航栏按钮的初始化函数
 *  @param type 按钮类型
 */
- (instancetype)initWithType:(NMUINavigationButtonType)type;

/**
 *  导航栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(nullable UIImage *)image;

@end

@interface UIBarButtonItem (NMUINavigationButton)

+ (instancetype)nmui_itemWithButton:(nullable NMUINavigationButton *)button target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_itemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_itemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_itemWithBoldTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_backItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_backItemWithTarget:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_closeItemWithTarget:(nullable id)target action:(nullable SEL)action;
+ (instancetype)nmui_fixedSpaceItemWithWidth:(CGFloat)width;
+ (instancetype)nmui_flexibleSpaceItem;
@end

NS_ASSUME_NONNULL_END
