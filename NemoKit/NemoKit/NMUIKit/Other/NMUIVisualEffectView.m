//
//  NMUIVisualEffectView.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIVisualEffectView.h"
#import "NMBCore.h"
#import "CALayer+NMUI.h"

@interface NMUIVisualEffectView ()

@property(nonatomic, strong) CALayer *foregroundLayer;

@end

@implementation NMUIVisualEffectView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect {
    if (self = [super initWithEffect:effect]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.foregroundLayer = [CALayer layer];
    [self.foregroundLayer nmui_removeDefaultAnimations];
    [self.contentView.layer addSublayer:self.foregroundLayer];
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    self.foregroundLayer.backgroundColor = foregroundColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.foregroundLayer.frame = self.contentView.bounds;
}

@end
