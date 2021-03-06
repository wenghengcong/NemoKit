//
//  NMUIFloatLayoutView.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIFloatLayoutView.h"
#import "NMBCore.h"

#define ValueSwitchAlignLeftOrRight(valueLeft, valueRight) ([self shouldAlignRight] ? valueRight : valueLeft)

const CGSize NMUIFloatLayoutViewAutomaticalMaximumItemSize = {-1, -1};

@implementation NMUIFloatLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
    self.contentMode = UIViewContentModeLeft;
    self.minimumItemSize = CGSizeZero;
    self.maximumItemSize = NMUIFloatLayoutViewAutomaticalMaximumItemSize;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self layoutSubviewsWithSize:size shouldLayout:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutSubviewsWithSize:self.bounds.size shouldLayout:YES];
}

- (CGSize)layoutSubviewsWithSize:(CGSize)size shouldLayout:(BOOL)shouldLayout {
    NSArray<UIView *> *visibleItemViews = [self visibleSubviews];
    
    if (visibleItemViews.count == 0) {
        return CGSizeMake(UIEdgeInsetsGetHorizontalValue(self.padding), UIEdgeInsetsGetVerticalValue(self.padding));
    }
    
    // 如果是左对齐，则代表 item 左上角的坐标，如果是右对齐，则代表 item 右上角的坐标
    CGPoint itemViewOrigin = CGPointMake(ValueSwitchAlignLeftOrRight(self.padding.left, size.width - self.padding.right), self.padding.top);
    CGFloat currentRowMaxY = itemViewOrigin.y;
    CGSize maximumItemSize = CGSizeEqualToSize(self.maximumItemSize, NMUIFloatLayoutViewAutomaticalMaximumItemSize) ? CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.padding), size.height - UIEdgeInsetsGetVerticalValue(self.padding)) : self.maximumItemSize;
    
    for (NSInteger i = 0, l = visibleItemViews.count; i < l; i ++) {
        UIView *itemView = visibleItemViews[i];
        
        CGSize itemViewSize = [itemView sizeThatFits:maximumItemSize];
        itemViewSize.width = fmax(self.minimumItemSize.width, itemViewSize.width);
        itemViewSize.height = fmax(self.minimumItemSize.height, itemViewSize.height);
        itemViewSize.width = fmin(maximumItemSize.width, itemViewSize.width);
        itemViewSize.height = fmin(maximumItemSize.height, itemViewSize.height);
        
        BOOL shouldBreakline = i == 0 ? YES : ValueSwitchAlignLeftOrRight(itemViewOrigin.x + self.itemMargins.left + itemViewSize.width + self.padding.right > size.width,
                                                                          itemViewOrigin.x - self.itemMargins.right - itemViewSize.width - self.padding.left < 0);
        if (shouldBreakline) {
            // 换行，每一行第一个 item 是不考虑 itemMargins 的
            if (shouldLayout) {
                /** 修改原因: 原代码会在第一行的 item 的 y 值计算中考虑 itemMargins.top */
                itemView.frame = CGRectMake(ValueSwitchAlignLeftOrRight(self.padding.left, size.width - self.padding.right - itemViewSize.width), currentRowMaxY, itemViewSize.width, itemViewSize.height);
            }
            
            itemViewOrigin.x = ValueSwitchAlignLeftOrRight(self.padding.left + itemViewSize.width + self.itemMargins.right, size.width - self.padding.right - itemViewSize.width - self.itemMargins.left);
            itemViewOrigin.y = currentRowMaxY;
        } else {
            // 当前行放得下
            if (shouldLayout) {
                /** 修改原因: 原代码会在第一行的 item 的 y 值计算中考虑 itemMargins.top */
                itemView.frame = CGRectMake(ValueSwitchAlignLeftOrRight(itemViewOrigin.x + self.itemMargins.left, itemViewOrigin.x - self.itemMargins.right - itemViewSize.width), itemViewOrigin.y, itemViewSize.width, itemViewSize.height);
            }
            
            itemViewOrigin.x = ValueSwitchAlignLeftOrRight(itemViewOrigin.x + UIEdgeInsetsGetHorizontalValue(self.itemMargins) + itemViewSize.width,
                                                           itemViewOrigin.x - itemViewSize.width - UIEdgeInsetsGetHorizontalValue(self.itemMargins));
        }
        
        currentRowMaxY = fmax(currentRowMaxY, itemViewOrigin.y + UIEdgeInsetsGetVerticalValue(self.itemMargins) + itemViewSize.height);
    }
    
    // 最后一行不需要考虑 itemMarins.bottom，所以这里减掉
    currentRowMaxY -= self.itemMargins.bottom;
    
    CGSize resultSize = CGSizeMake(size.width, currentRowMaxY + self.padding.bottom);
    return resultSize;
}

- (NSArray<UIView *> *)visibleSubviews {
    NSMutableArray<UIView *> *visibleItemViews = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0, l = self.subviews.count; i < l; i++) {
        UIView *itemView = self.subviews[i];
        if (!itemView.hidden) {
            [visibleItemViews addObject:itemView];
        }
    }
    
    return visibleItemViews;
}

- (BOOL)shouldAlignRight {
    return self.contentMode == UIViewContentModeRight;
}

@end
