//
//  UICollectionView+NMUICellSizeKeyCache.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//



#import <UIKit/UIKit.h>

@class NMUICellSizeKeyCache;

@protocol NMUICellSizeKeyCache_UICollectionViewDelegate <NSObject>

@optional
- (nonnull id<NSCopying>)nmui_collectionView:(nonnull UICollectionView *)collectionView cacheKeyForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

/// 注意，这个类的功能暂无法使用
@interface UICollectionView (NMUICellSizeKeyCache)

/// 控制是否要自动缓存 cell 的高度，默认为 NO
@property(nonatomic, assign) BOOL nmui_cacheCellSizeByKeyAutomatically;

/// 获取当前的缓存容器。tableView 的宽度和 contentInset 发生变化时，这个数组也会跟着变，但当 tableView 宽度小于 0 时会返回 nil。
@property(nonatomic, weak, readonly, nullable) NMUICellSizeKeyCache *nmui_currentCellSizeKeyCache;

@end
