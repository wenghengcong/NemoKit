//
//  NMUITableViewHeaderFooterView.m
//  Nemo
//
//  Created by Hunt on 2019/11/2.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITableViewHeaderFooterView.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"

@implementation NMUITableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        
        // remove system subviews
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.backgroundView = [[UIView alloc] init];// 去掉默认的背景，以使 self.backgroundColor 生效
    }
    return self;
}

- (void)updateAppearance {
    if (!self.parentTableView) return;
    if (self.type == NMUITableViewHeaderFooterViewTypeUnknow) return;
    
    BOOL isPlainStyleTableView = self.parentTableView.style == UITableViewStylePlain;
    
    if (self.type == NMUITableViewHeaderFooterViewTypeHeader) {
        self.titleLabel.font = isPlainStyleTableView ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont;
        self.titleLabel.textColor = isPlainStyleTableView ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor;
        self.contentEdgeInsets = isPlainStyleTableView ? TableViewSectionHeaderContentInset : TableViewGroupedSectionHeaderContentInset;
        self.accessoryViewMargins = isPlainStyleTableView ? TableViewSectionHeaderAccessoryMargins : TableViewGroupedSectionHeaderAccessoryMargins;
        self.backgroundView.backgroundColor = isPlainStyleTableView ? TableViewSectionHeaderBackgroundColor : UIColorClear;
    } else {
        self.titleLabel.font = isPlainStyleTableView ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont;
        self.titleLabel.textColor = isPlainStyleTableView ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor;
        self.contentEdgeInsets = isPlainStyleTableView ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;
        self.accessoryViewMargins = isPlainStyleTableView ? TableViewSectionFooterAccessoryMargins : TableViewGroupedSectionFooterAccessoryMargins;
        self.backgroundView.backgroundColor = isPlainStyleTableView ? TableViewSectionFooterBackgroundColor : UIColorClear;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.accessoryView) {
        [self.accessoryView sizeToFit];
        self.accessoryView.nmui_right = self.contentView.nmui_width - self.contentEdgeInsets.right - self.accessoryViewMargins.right;
        self.accessoryView.nmui_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.nmui_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), self.accessoryView.nmui_height) + self.accessoryViewMargins.top - self.accessoryViewMargins.bottom;
    }
    
    self.titleLabel.nmui_left = self.contentEdgeInsets.left;
    self.titleLabel.nmui_extendToRight = self.accessoryView ? self.accessoryView.nmui_left - self.accessoryViewMargins.left : self.contentView.nmui_width - self.contentEdgeInsets.right;
    self.titleLabel.nmui_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.nmui_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), self.titleLabel.nmui_height);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.nmui_width, CGFLOAT_MAX)];
    self.titleLabel.nmui_height = titleLabelSize.height;

}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = size;
    
    CGSize accessoryViewSize = self.accessoryView ? self.accessoryView.frame.size : CGSizeZero;
    if (self.accessoryView) {
        accessoryViewSize.width = accessoryViewSize.width + UIEdgeInsetsGetHorizontalValue(self.accessoryViewMargins);
        accessoryViewSize.height = accessoryViewSize.height + UIEdgeInsetsGetVerticalValue(self.accessoryViewMargins);
    }
    
    CGFloat titleLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - accessoryViewSize.width;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, CGFLOAT_MAX)];
    
    resultSize.height = fmax(titleLabelSize.height, accessoryViewSize.height) + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return resultSize;
}

#pragma mark - getter / setter

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView && _accessoryView != accessoryView) {
        [_accessoryView removeFromSuperview];
    }
    _accessoryView = accessoryView;
    [self.contentView addSubview:accessoryView];
}

- (void)setParentTableView:(UITableView *)parentTableView {
    _parentTableView = parentTableView;
    [self updateAppearance];
}

- (void)setType:(NMUITableViewHeaderFooterViewType)type {
    _type = type;
    [self updateAppearance];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsLayout];
}

- (void)setAccessoryViewMargins:(UIEdgeInsets)accessoryViewMargins {
    _accessoryViewMargins = accessoryViewMargins;
    [self setNeedsLayout];
}

@end
