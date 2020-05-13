//
//  UIViewController+NMUITheme.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIViewController+NMUITheme.h"
#import "NMUIModalPresentationViewController.h"

@implementation UIViewController (NMUITheme)

- (void)nmui_themeDidChangeByManager:(NMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull childViewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [childViewController nmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }];
    if (self.presentedViewController && self.presentedViewController.presentingViewController == self) {
        [self.presentedViewController nmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }
}

@end


@implementation NMUIModalPresentationViewController (NMUITheme)

- (void)nmui_themeDidChangeByManager:(NMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    [super nmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    if (self.contentViewController) {
        [self.contentViewController nmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }
}

@end

