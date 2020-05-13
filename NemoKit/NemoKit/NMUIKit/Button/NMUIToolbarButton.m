//
//  NMUIToolbarButton.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIToolbarButton.h"
#import "NMBCore.h"
#import "UIImage+NMUI.h"

@implementation NMUIToolbarButton

- (instancetype)init {
    return [self initWithType:NMUIToolbarButtonTypeNormal];
}

- (instancetype)initWithType:(NMUIToolbarButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(NMUIToolbarButtonType)type title:(NSString *)title {
    if (self = [super init]) {
        _type = type;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:NMUIToolbarButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:[image nmui_imageWithAlpha:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
        [self setImage:[image nmui_imageWithAlpha:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
        [self sizeToFit];
    }
    return self;
}

- (void)renderButtonStyle {
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.tintColor = nil; // 重置默认值，nil表示跟随父元素
    self.titleLabel.font = ToolBarButtonFont;
    switch (self.type) {
        case NMUIToolbarButtonTypeNormal:
            [self setTitleColor:ToolBarTintColor forState:UIControlStateNormal];
            [self setTitleColor:ToolBarTintColorHighlighted forState:UIControlStateHighlighted];
            [self setTitleColor:ToolBarTintColorDisabled forState:UIControlStateDisabled];
            break;
        case NMUIToolbarButtonTypeRed:
            [self setTitleColor:UIColorRed forState:UIControlStateNormal];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
            self.imageView.tintColor = UIColorRed; // 修改为红色
            break;
        case NMUIToolbarButtonTypeImage:
            break;
        default:
            break;
    }
}

+ (UIBarButtonItem *)barButtonItemWithToolbarButton:(NMUIToolbarButton *)button target:(id)target action:(SEL)selector {
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithType:(NMUIToolbarButtonType)type title:(NSString *)title target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    if (type == NMUIToolbarButtonTypeRed) {
        // 默认继承toolBar的tintColor，红色需要重置
        buttonItem.tintColor = UIColorRed;
    }
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    return buttonItem;
}

@end
