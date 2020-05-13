//
//  UITableView+NMUICellHeightKeyCache.h
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUICellHeightKeyCache;

/**
 *  自动缓存 self-sizing cell 的高度，避免重复计算。使用方法：
 *  1. 将 tableView.nmui_cacheCellHeightByKeyAutomatically = YES
 *  2. 实现 tableView 的 delegate 方法 nmui_tableView:cacheKeyForRowAtIndexPath: 返回一个 key。建议 key 由所有可能影响高度的字段拼起来，这样当数据发生变化时不需要手动更新缓存。
 *
 *  @note 注意这里的高度缓存仅适合于使用 self-sizing 机制的 tableView（也即 tableView.rowHeight = UITableViewAutomaticDimension），NMUICellHeightKeyCache 会自动在 willDisplayCell 里将 cell 的当前高度缓存起来，然后在 heightForRow 里从缓存中读取高度后使用。
 *  @note 如果 tableView 开启了 nmui_cacheCellHeightByKeyAutomatically 并且 tableView.delegate 实现了 tableView:heightForRowAtIndexPath:，如果返回值 >= 0则使用这个返回值当成最终的高度，如果 < 0 则交给 NMUICellHeightKeyCache 自己处理。
 *  @note 如果 tableView 开启了 nmui_cacheCellHeightByKeyAutomatically 并且 tableView.delegate 实现了 tableView:estimatedHeightForRowAtIndexPath:，则当该 indexPath 所在的 cell 的高度已经被计算过的情况下，业务自己的 tableView:estimatedHeightForRowAtIndexPath: 不会被调用，只有当高度缓存里找不到该 indexPath 对应的 key 的缓存时，才会调用业务的这个方法。
 *
 *  @note 在 UITableView 的宽度和 contentInset、safeAreaInsets 发生变化时（例如横竖屏旋转、iPad 分屏），高度缓存会自动刷新，所以无需为这种情况做保护。
 */
@interface UITableView (NMUICellHeightKeyCache)

/// 控制是否要自动缓存 cell 的高度，默认为 NO
@property(nonatomic, assign) BOOL nmui_cacheCellHeightByKeyAutomatically;

/// 获取当前的缓存容器。tableView 的宽度和 contentInset 发生变化时，这个数组也会跟着变，但当 tableView 宽度小于 0 时会返回 nil。
@property(nonatomic, weak, readonly, nullable) NMUICellHeightKeyCache *nmui_currentCellHeightKeyCache;

/// 搭配 NMUICellHeightKeyCache，清除某个指定 key 的缓存，注意不要直接调用 self.nmui_currentCellHeightKeyCache.invalidateHeightForKey，因为一个 UITableView 里会包含多个 NMUICellHeightKeyCache，那样写只能刷新当前的 NMUICellHeightKeyCache，其他宽度下的 NMUICellHeightKeyCache 无法刷新。
- (void)nmui_invalidateCellHeightCachedForKey:(id<NSCopying>)key;

/// 搭配 NMUICellHeightKeyCache，清除所有状态下的缓存
- (void)nmui_invalidateAllCellHeightKeyCache;

@end

NS_ASSUME_NONNULL_END
