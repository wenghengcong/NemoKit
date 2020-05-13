//
//  UITextField+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (NMUI)

/// UITextField只有selectedTextRange属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将UITextRange类型的selectedTextRange转换为NSRange类型的selectedRange
@property(nonatomic, assign, readonly) NSRange nmui_selectedRange;

/// 输入框右边的 clearButton，在 UITextField 初始化后就存在
@property(nullable, nonatomic, weak, readonly) UIButton *nmui_clearButton;

/// 自定义 clearButton 的图片，设置成nil，恢复到系统默认的图片
@property(nullable, nonatomic, strong) UIImage *nmui_clearButtonImage UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
