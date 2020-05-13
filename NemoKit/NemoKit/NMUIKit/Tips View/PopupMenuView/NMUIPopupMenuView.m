//
//  NMUIPopupMenuView.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIPopupMenuView.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"
#import "CALayer+NMUI.h"
#import "NSArray+NMBF.h"
#import "NMUIPopupContainerView.h"

@interface NMUIPopupMenuView ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<CALayer *> *itemSeparatorLayers;
@property(nonatomic, strong) NSMutableArray<CALayer *> *sectionSeparatorLayers;
@end

@interface NMUIPopupMenuView (UIAppearance)

- (void)updateAppearanceForPopupMenuView;
@end

@implementation NMUIPopupMenuView

- (void)setItems:(NSArray<__kindof NMUIPopupMenuBaseItem *> *)items {
    [_items enumerateObjectsUsingBlock:^(__kindof NMUIPopupMenuBaseItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.menuView = nil;
    }];
    _items = items;
    if (!items) {
        self.itemSections = nil;
    } else {
        self.itemSections = @[_items];
    }
}

- (void)setItemSections:(NSArray<NSArray<__kindof NMUIPopupMenuBaseItem *> *> *)itemSections {
    [_itemSections nmbf_enumerateNestedArrayWithBlock:^(__kindof NMUIPopupMenuBaseItem * item, BOOL *stop) {
        item.menuView = nil;
    }];
    _itemSections = itemSections;
    [self configureItems];
}

- (void)setItemConfigurationHandler:(void (^)(NMUIPopupMenuView *, __kindof NMUIPopupMenuBaseItem *, NSInteger, NSInteger))itemConfigurationHandler {
    _itemConfigurationHandler = [itemConfigurationHandler copy];
    if (_itemConfigurationHandler && self.itemSections.count) {
        for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
            NSArray<NMUIPopupMenuBaseItem *> *items = self.itemSections[section];
            for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
                NMUIPopupMenuBaseItem *item = items[row];
                _itemConfigurationHandler(self, item, section, row);
            }
        }
    }
}

- (void)configureItems {
    NSInteger globalItemIndex = 0;
    NSInteger separatorIndex = 0;
    
    // 移除所有 item
    [self.scrollView nmui_removeAllSubviews];
    [self.itemSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.hidden = YES;
    }];
    [self.sectionSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.hidden = YES;
    }];
    
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<NMUIPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            NMUIPopupMenuBaseItem *item = items[row];
            item.menuView = self;
            [item updateAppearance];
            if (self.itemConfigurationHandler) {
                self.itemConfigurationHandler(self, item, section, row);
            }
            [self.scrollView addSubview:item];
            
            // 配置分隔线，注意每一个 section 里的最后一行是不显示分隔线的
            BOOL shouldShowItemSeparator = self.shouldShowItemSeparator && row < rowCount - 1;
            if (shouldShowItemSeparator) {
                CALayer *separatorLayer = nil;
                if (separatorIndex < self.itemSeparatorLayers.count) {
                    separatorLayer = self.itemSeparatorLayers[separatorIndex];
                } else {
                    separatorLayer = [CALayer nmui_separatorLayer];
                    [self.scrollView.layer addSublayer:separatorLayer];
                    [self.itemSeparatorLayers addObject:separatorLayer];
                }
                separatorLayer.hidden = NO;
                separatorLayer.backgroundColor = self.itemSeparatorColor.CGColor;
                separatorIndex++;
            }
            
            globalItemIndex++;
        }
        
        BOOL shouldShowSectionSeparator = self.shouldShowSectionSeparator && section < sectionCount - 1;
        if (shouldShowSectionSeparator) {
            CALayer *separatorLayer = nil;
            if (section < self.sectionSeparatorLayers.count) {
                separatorLayer = self.sectionSeparatorLayers[section];
            } else {
                separatorLayer = [CALayer nmui_separatorLayer];
                [self.scrollView.layer addSublayer:separatorLayer];
                [self.sectionSeparatorLayers addObject:separatorLayer];
            }
            separatorLayer.hidden = NO;
            separatorLayer.backgroundColor = self.sectionSeparatorColor.CGColor;
        }
    }
}

- (void)setItemSeparatorInset:(UIEdgeInsets)itemSeparatorInset {
    _itemSeparatorInset = itemSeparatorInset;
    [self setNeedsLayout];
}

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor {
    _itemSeparatorColor = itemSeparatorColor;
    [self.itemSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.backgroundColor = itemSeparatorColor.CGColor;
    }];
}

- (void)setSectionSeparatorInset:(UIEdgeInsets)sectionSeparatorInset {
    _sectionSeparatorInset = sectionSeparatorInset;
    [self setNeedsLayout];
}

- (void)setSectionSeparatorColor:(UIColor *)sectionSeparatorColor {
    _sectionSeparatorColor = sectionSeparatorColor;
    [self.sectionSeparatorLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        layer.backgroundColor = sectionSeparatorColor.CGColor;
    }];
}

#pragma mark - (UISubclassingHooks)

- (void)didInitialize {
    [super didInitialize];
    self.contentEdgeInsets = UIEdgeInsetsZero;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:self.scrollView];
    
    self.itemSeparatorLayers = [[NSMutableArray alloc] init];
    self.sectionSeparatorLayers = [[NSMutableArray alloc] init];
    
    [self updateAppearanceForPopupMenuView];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    __block CGFloat width = 0;
    __block CGFloat height = UIEdgeInsetsGetVerticalValue(self.padding);
    [self.itemSections nmbf_enumerateNestedArrayWithBlock:^(__kindof NMUIPopupMenuBaseItem *item, BOOL *stop) {
        height += item.height >= 0 ? item.height : self.itemHeight;
        CGSize itemSize = [item sizeThatFits:CGSizeMake(size.width, height)];
        width = MAX(width, MIN(itemSize.width, size.width));
    }];
    size.width = width;
    size.height = MIN(height, size.height);
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    
    CGFloat minY = self.padding.top;
    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    NSInteger separatorIndex = 0;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<NMUIPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            NMUIPopupMenuBaseItem *item = items[row];
            item.frame = CGRectMake(0, minY, contentWidth, item.height >= 0 ? item.height : self.itemHeight);
            minY = CGRectGetMaxY(item.frame);
            
            if (self.shouldShowItemSeparator && row < rowCount - 1) {
                CALayer *layer = self.itemSeparatorLayers[separatorIndex];
                if (!layer.hidden) {
                    layer.frame = CGRectMake(self.padding.left + self.itemSeparatorInset.left, minY - PixelOne + self.itemSeparatorInset.top - self.itemSeparatorInset.bottom, contentWidth - UIEdgeInsetsGetHorizontalValue(self.padding) - UIEdgeInsetsGetHorizontalValue(self.itemSeparatorInset), PixelOne);
                    separatorIndex++;
                }
            }
        }
        
        if (self.shouldShowSectionSeparator && section < sectionCount - 1) {
            self.sectionSeparatorLayers[section].frame = CGRectMake(0, minY - PixelOne + self.sectionSeparatorInset.top - self.sectionSeparatorInset.bottom, contentWidth - UIEdgeInsetsGetHorizontalValue(self.sectionSeparatorInset), PixelOne);
        }
    }
    minY += self.padding.bottom;
    self.scrollView.contentSize = CGSizeMake(contentWidth, minY);
}

@end

@implementation NMUIPopupMenuView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    NMUIPopupMenuView *appearance = [NMUIPopupMenuView appearance];
    appearance.shouldShowItemSeparator = NO;
    appearance.itemSeparatorColor = UIColorSeparator;
    appearance.itemSeparatorInset = UIEdgeInsetsZero;
    appearance.shouldShowSectionSeparator = NO;
    appearance.sectionSeparatorColor = UIColorSeparator;
    appearance.sectionSeparatorInset = UIEdgeInsetsZero;
    appearance.itemTitleFont = UIFontMake(16);
    appearance.itemTitleColor = UIColorBlue;
    appearance.padding = UIEdgeInsetsMake([NMUIPopupContainerView appearance].cornerRadius / 2.0, 16, [NMUIPopupContainerView appearance].cornerRadius / 2.0, 16);
    appearance.itemHeight = 44;
}

- (void)updateAppearanceForPopupMenuView {
    NMUIPopupMenuView *appearance = [NMUIPopupMenuView appearance];
    self.shouldShowItemSeparator = appearance.shouldShowItemSeparator;
    self.itemSeparatorColor = appearance.itemSeparatorColor;
    self.itemSeparatorInset = appearance.itemSeparatorInset;
    self.shouldShowSectionSeparator = appearance.shouldShowSectionSeparator;
    self.sectionSeparatorColor = appearance.sectionSeparatorColor;
    self.sectionSeparatorInset = appearance.sectionSeparatorInset;
    self.itemTitleFont = appearance.itemTitleFont;
    self.itemTitleColor = appearance.itemTitleColor;
    self.padding = appearance.padding;
    self.itemHeight = appearance.itemHeight;
}

@end