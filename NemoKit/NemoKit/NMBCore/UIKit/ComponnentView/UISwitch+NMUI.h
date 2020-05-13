//
//  UISwitch+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//




#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UISwitch (NMUI)
/// 用于设置 UISwitch 关闭时的背景色（除了圆点外的其他颜色）
@property(nonatomic, strong) UIColor *nmui_offTintColor;

@end

NS_ASSUME_NONNULL_END
