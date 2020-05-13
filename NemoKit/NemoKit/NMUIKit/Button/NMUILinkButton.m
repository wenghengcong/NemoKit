//
//  NMUILinkButton.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUILinkButton.h"
#import "NMBCore.h"
#import "CALayer+NMUI.h"

@interface NMUILinkButton ()

@property(nonatomic, strong) CALayer *underlineLayer;
@end

@implementation NMUILinkButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [super didInitialize];
    
    self.underlineLayer = [CALayer layer];
    [self.underlineLayer nmui_removeDefaultAnimations];
    [self.layer addSublayer:self.underlineLayer];
    
    self.underlineHidden = NO;
    self.underlineWidth = 1;
    self.underlineColor = nil;
    self.underlineInsets = UIEdgeInsetsZero;
}

- (void)setUnderlineHidden:(BOOL)underlineHidden {
    _underlineHidden = underlineHidden;
    self.underlineLayer.hidden = underlineHidden;
}

- (void)setUnderlineWidth:(CGFloat)underlineWidth {
    _underlineWidth = underlineWidth;
    [self setNeedsLayout];
}

- (void)setUnderlineColor:(UIColor *)underlineColor {
    _underlineColor = underlineColor;
    [self updateUnderlineColor];
}

- (void)setUnderlineInsets:(UIEdgeInsets)underlineInsets {
    _underlineInsets = underlineInsets;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.underlineLayer.hidden) {
        self.underlineLayer.frame = CGRectMake(self.underlineInsets.left, CGRectGetMaxY(self.titleLabel.frame) + self.underlineInsets.top - self.underlineInsets.bottom, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.underlineInsets), self.underlineWidth);
    }
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    [self updateUnderlineColor];
}

- (void)updateUnderlineColor {
    UIColor *color = self.underlineColor ? : [self titleColorForState:UIControlStateNormal];
    self.underlineLayer.backgroundColor = color.CGColor;
}

@end
