//
//  NMUIGhostButton.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIGhostButton.h"
#import "NMBCore.h"

const CGFloat NMUIGhostButtonCornerRadiusAdjustsBounds = -1;

@implementation NMUIGhostButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithGhostType:NMUIGhostButtonColorBlue frame:frame];
}

- (instancetype)initWithGhostType:(NMUIGhostButtonColor)ghostType {
    return [self initWithGhostType:ghostType frame:CGRectZero];
}

- (instancetype)initWithGhostType:(NMUIGhostButtonColor)ghostType frame:(CGRect)frame {
    UIColor *ghostColor = nil;
    switch (ghostType) {
        case NMUIGhostButtonColorBlue:
            ghostColor = GhostButtonColorBlue;
            break;
        case NMUIGhostButtonColorRed:
            ghostColor = GhostButtonColorRed;
            break;
        case NMUIGhostButtonColorGreen:
            ghostColor = GhostButtonColorGreen;
            break;
        case NMUIGhostButtonColorGray:
            ghostColor = GhostButtonColorGray;
            break;
        case NMUIGhostButtonColorWhite:
            ghostColor = GhostButtonColorWhite;
            break;
        default:
            break;
    }
    return [self initWithGhostColor:ghostColor frame:frame];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor {
    return [self initWithGhostColor:ghostColor frame:CGRectZero];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithGhostColor:ghostColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeWithGhostColor:GhostButtonColorBlue];
    }
    return self;
}

- (void)initializeWithGhostColor:(UIColor *)ghostColor {
    self.ghostColor = ghostColor;
}

- (void)setGhostColor:(UIColor *)ghostColor {
    _ghostColor = ghostColor;
    [self setTitleColor:_ghostColor forState:UIControlStateNormal];
    self.layer.borderColor = _ghostColor.CGColor;
    if (self.adjustsImageWithGhostColor) {
        [self updateImageColor];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setAdjustsImageWithGhostColor:(BOOL)adjustsImageWithGhostColor {
    _adjustsImageWithGhostColor = adjustsImageWithGhostColor;
    [self updateImageColor];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithGhostColor ? self.ghostColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithGhostColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithGhostColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != NMUIGhostButtonCornerRadiusAdjustsBounds) {
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

@interface NMUIGhostButton (UIAppearance)

@end

@implementation NMUIGhostButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    NMUIGhostButton *appearance = [NMUIGhostButton appearance];
    appearance.borderWidth = 1;
    appearance.cornerRadius = NMUIGhostButtonCornerRadiusAdjustsBounds;
    appearance.adjustsImageWithGhostColor = NO;
}

@end
