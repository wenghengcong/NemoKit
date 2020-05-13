//
//  UISwitch+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UISwitch+NMUI.h"
#import "NMBCore.h"

@implementation UISwitch (NMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UISwitch class], @selector(initWithFrame:), CGRect, UISwitch *, ^UISwitch *(UISwitch *selfObject, CGRect firstArgv, UISwitch *originReturnValue) {
            if (NMUICMIActivated) {
                if (SwitchTintColor) {
                    selfObject.tintColor = SwitchTintColor;
                }
                if (SwitchOffTintColor) {
                    selfObject.nmui_offTintColor = SwitchOffTintColor;
                }
            }
            return originReturnValue;
        });
        // 设置 nmui_offTintColor 的原理是找到 UISwitch 内部的 switchWellView 并改变它的 backgroundColor，而 switchWellView 在某些时机会重新创建 ，因此需要在这些时机之后对 switchWellView 重新设置一次背景颜色：
        if (@available(iOS 13.0, *)) {
            NMBFExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(traitCollectionDidChange:), UITraitCollection *, ^(UISwitch *selfObject, UITraitCollection *previousTraitCollection) {
                BOOL interfaceStyleChanged = [previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:selfObject.traitCollection];
                if (interfaceStyleChanged) {
                    // 在 iOS 13 切换 Dark/Light Mode 之后，会在重新创建 switchWellView，之所以延迟一个 runloop 是因为这个时机是在晚于 traitCollectionDidChange 的 _traitCollectionDidChangeInternal中进行
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [selfObject nmui_applyOffTintColorIfNeeded];
                    });
                }
            });
        } else {
            // iOS 9 - 12 上调用 setOnTintColor: 或 setTintColor: 之后，会在重新创建 switchWellView
            NMBFExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject nmui_applyOffTintColorIfNeeded];
            });
            NMBFExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setOnTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject nmui_applyOffTintColorIfNeeded];
            });

        }

    });
}

static char kAssociatedObjectKey_offTintColor;
static NSString * const kDefaultOffTintColorKey = @"defaultOffTintColorKey";

- (void)setNmui_offTintColor:(UIColor *)nmui_offTintColor {
    UIView *switchWellView = nil;
    if (@available(iOS 10.0, *)) {
        switchWellView = [self valueForKeyPath:@"_visualElement._switchWellView"];
    } else {
        switchWellView = [self valueForKeyPath:@"_control._switchWellView"];
    }
    UIColor *defaultOffTintColor = [switchWellView nmbf_getBoundObjectForKey:kDefaultOffTintColorKey];
    if (!defaultOffTintColor) {
        defaultOffTintColor = switchWellView.backgroundColor;
        [switchWellView nmbf_bindObject:defaultOffTintColor forKey:kDefaultOffTintColorKey];
    }
    // 当 offTintColor 为 nil 时，恢复默认颜色（和 setOnTintColor 行为保持一致）
    switchWellView.backgroundColor = nmui_offTintColor ? : defaultOffTintColor;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_offTintColor, nmui_offTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)nmui_offTintColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_offTintColor);
}

- (void)nmui_applyOffTintColorIfNeeded {
    if (self.nmui_offTintColor) {
        self.nmui_offTintColor = self.nmui_offTintColor;
    }
}

@end
