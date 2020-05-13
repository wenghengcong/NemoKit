//
//  NMUIToastBackgroundView.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIToastBackgroundView.h"
#import "NMBCore.h"
#import "NMUIVisualEffectView.h"

@interface NMUIToastBackgroundView ()

@end

@implementation NMUIToastBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.allowsGroupOpacity = NO;
        self.backgroundColor = self.styleColor;
        self.layer.cornerRadius = self.cornerRadius;
        
    }
    return self;
}

- (void)setShouldBlurBackgroundView:(BOOL)shouldBlurBackgroundView {
    _shouldBlurBackgroundView = shouldBlurBackgroundView;
    if (shouldBlurBackgroundView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[NMUIVisualEffectView alloc] initWithEffect:effect];
        self.effectView.layer.cornerRadius = self.cornerRadius;
        self.effectView.layer.masksToBounds = YES;
        self.effectView.foregroundColor = nil;
        [self addSubview:self.effectView];
    } else {
        if (self.effectView) {
            [self.effectView removeFromSuperview];
            _effectView = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.effectView) {
        self.effectView.frame = self.bounds;
    }
}

#pragma mark - UIAppearance

- (void)setStyleColor:(UIColor *)styleColor {
    _styleColor = styleColor;
    self.backgroundColor = styleColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    if (self.effectView) {
        self.effectView.layer.cornerRadius = cornerRadius;
    }
}

@end


@interface NMUIToastBackgroundView (UIAppearance)

@end

@implementation NMUIToastBackgroundView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    NMUIToastBackgroundView *appearance = [NMUIToastBackgroundView appearance];
    appearance.styleColor = UIColorMakeWithRGBA(0, 0, 0, 0.8);
    appearance.cornerRadius = 10.0;
}

@end
