//
//  NMUIPopupMenuButtonItem.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIPopupMenuButtonItem.h"
#import "NMUIButton.h"
#import "UIControl+NMUI.h"
#import "NMUIPopupMenuView.h"
#import "NMBCore.h"

@interface NMUIPopupMenuButtonItem (UIAppearance)

- (void)updateAppearanceForMenuButtonItem;
@end

@implementation NMUIPopupMenuButtonItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(nullable void (^)(NMUIPopupMenuButtonItem *))handler {
    NMUIPopupMenuButtonItem *item = [[NMUIPopupMenuButtonItem alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
        
        _button = [[NMUIButton alloc] init];
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.button.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        [self updateAppearanceForMenuButtonItem];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.button sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
    [self updateButtonImageEdgeInsets];
}

- (void)setImageMarginRight:(CGFloat)imageMarginRight {
    _imageMarginRight = imageMarginRight;
    [self updateButtonImageEdgeInsets];
}

- (void)updateButtonImageEdgeInsets {
    if (self.button.currentImage) {
        self.button.imageEdgeInsets = UIEdgeInsetsSetRight(self.button.imageEdgeInsets, self.imageMarginRight);
    }
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    self.button.highlightedBackgroundColor = highlightedBackgroundColor;
}

- (void)handleButtonEvent:(id)sender {
    if (self.handler) {
        self.handler(self);
    }
}

- (void)updateAppearance {
    self.button.titleLabel.font = self.menuView.itemTitleFont;
    [self.button setTitleColor:self.menuView.itemTitleColor forState:UIControlStateNormal];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.menuView.padding.left, 0, self.menuView.padding.right);
}

@end

@implementation NMUIPopupMenuButtonItem (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    NMUIPopupMenuButtonItem *appearance = [NMUIPopupMenuButtonItem appearance];
    appearance.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
    appearance.imageMarginRight = 6;
}

- (void)updateAppearanceForMenuButtonItem {
    NMUIPopupMenuButtonItem *appearance = [NMUIPopupMenuButtonItem appearance];
    self.highlightedBackgroundColor = appearance.highlightedBackgroundColor;
    self.imageMarginRight = appearance.imageMarginRight;
}

@end

