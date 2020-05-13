//
//  UINavigationBar+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UINavigationBar+NMUI.h"
#import "NMBCore.h"

@implementation UINavigationBar (NMUI)

- (UIView *)nmui_backgroundView {
    return [self nmbf_valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)nmui_backgroundContentView {
    if (@available(iOS 13, *)) {
        return [self.nmui_backgroundView nmbf_valueForKey:@"_colorAndImageView1"];
    } else if (@available(iOS 10, *)) {
        UIImageView *imageView = [self.nmui_backgroundView nmbf_valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.nmui_backgroundView nmbf_valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.nmui_backgroundView nmbf_valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    } else {
        UIView *backdrop = [self.nmui_backgroundView nmbf_valueForKey:@"_adaptiveBackdrop"];
        UIView *result = backdrop && backdrop.superview ? backdrop : self.nmui_backgroundView;
        return result;
    }
}

- (UIImageView *)nmui_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    if (@available(iOS 13, *)) {
        return [self.nmui_backgroundView nmbf_valueForKey:@"_shadowView1"];
    }
    return [self.nmui_backgroundView nmbf_valueForKey:@"_shadowView"];
}

@end
