//
//  NMUIFillButton.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIFillButton.h"
#import "NMBCore.h"

const CGFloat NMUIFillButtonCornerRadiusAdjustsBounds = -1;

@implementation NMUIFillButton

- (instancetype)init {
    return [self initWithFillType:NMUIFillButtonColorBlue];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFillType:NMUIFillButtonColorBlue frame:frame];
}

- (instancetype)initWithFillType:(NMUIFillButtonColor)fillType {
    return [self initWithFillType:fillType frame:CGRectZero];
}

- (instancetype)initWithFillType:(NMUIFillButtonColor)fillType frame:(CGRect)frame {
    UIColor *fillColor = nil;
    UIColor *textColor = UIColorWhite;
    switch (fillType) {
        case NMUIFillButtonColorBlue:
            fillColor = FillButtonColorBlue;
            break;
        case NMUIFillButtonColorRed:
            fillColor = FillButtonColorRed;
            break;
        case NMUIFillButtonColorGreen:
            fillColor = FillButtonColorGreen;
            break;
        case NMUIFillButtonColorGray:
            fillColor = FillButtonColorGray;
            break;
        case NMUIFillButtonColorWhite:
            fillColor = FillButtonColorWhite;
            textColor = UIColorBlue;
        default:
            break;
    }
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:frame];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor {
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:CGRectZero];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = fillColor;
        self.titleTextColor = textColor;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.fillColor = FillButtonColorBlue;
        self.titleTextColor = UIColorWhite;
    }
    return self;
}

- (void)setAdjustsImageWithTitleTextColor:(BOOL)adjustsImageWithTitleTextColor {
    _adjustsImageWithTitleTextColor = adjustsImageWithTitleTextColor;
    if (adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundColor = fillColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    [self setTitleColor:titleTextColor forState:UIControlStateNormal];
    if (self.adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithTitleTextColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithTitleTextColor ? self.titleTextColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithTitleTextColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != NMUIFillButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = self.cornerRadius;
    } else {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

@end

@interface NMUIFillButton (UIAppearance)

@end

@implementation NMUIFillButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    NMUIFillButton *appearance = [NMUIFillButton appearance];
    appearance.cornerRadius = NMUIFillButtonCornerRadiusAdjustsBounds;
    appearance.adjustsImageWithTitleTextColor = NO;
}

@end
