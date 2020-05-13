//
//  NMUIFillButton.h
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NMUIFillButtonColor) {
    NMUIFillButtonColorBlue,
    NMUIFillButtonColorRed,
    NMUIFillButtonColorGreen,
    NMUIFillButtonColorGray,
    NMUIFillButtonColorWhite,
};

/**
 *  用于 `NMUIFillButton.cornerRadius` 属性，当 `cornerRadius` 为 `NMUIFillButtonCornerRadiusAdjustsBounds` 时，`NMUIFillButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
extern const CGFloat NMUIFillButtonCornerRadiusAdjustsBounds;

/**
 *  NMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 */
@interface NMUIFillButton : NMUIButton

@property(nonatomic, strong, nullable) IBInspectable UIColor *fillColor; // 默认为 FillButtonColorBlue
@property(nonatomic, strong, nullable) IBInspectable UIColor *titleTextColor; // 默认为 UIColorWhite
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;// 默认为 NMUIFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

/**
 *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
 */
@property(nonatomic, assign) BOOL adjustsImageWithTitleTextColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithFillType:(NMUIFillButtonColor)fillType;
- (instancetype)initWithFillType:(NMUIFillButtonColor)fillType frame:(CGRect)frame;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
