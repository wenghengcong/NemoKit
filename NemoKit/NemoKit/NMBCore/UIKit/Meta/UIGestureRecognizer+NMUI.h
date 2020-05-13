//
//  UIGestureRecognizer+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (NMUI)

/// 获取当前手势直接作用到的 view（注意与 view 属性区分开：view 属性表示手势被添加到哪个 view 上，nmui_targetView 则是 view 属性里的某个 subview）
@property(nullable, nonatomic, weak, readonly) UIView *nmui_targetView;

@end

NS_ASSUME_NONNULL_END
