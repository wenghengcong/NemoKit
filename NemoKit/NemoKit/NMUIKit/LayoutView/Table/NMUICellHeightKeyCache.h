//
//  NMUICellHeightKeyCache.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 使用，一般不用你自己去 init。
 *  具体使用方式请看 UITableView (NMUICellHeightKeyCache) 的注释。
 */
@interface NMUICellHeightKeyCache : NSObject

/// 检查是否存在某个 key 的高度
- (BOOL)existsHeightForKey:(id<NSCopying>)key;

/// 将某个高度缓存到指定的 key
- (void)cacheHeight:(CGFloat)height forKey:(id<NSCopying>)key;

/// 获取指定 key 对应的高度，如果该 key 不存在，则返回 0
- (CGFloat)heightForKey:(id<NSCopying>)key;

/// 令指定 key 的缓存失效。注意如果在业务里，应该调用 [UITableView -nmui_invalidateCellHeightCachedForKey:]，而不应该直接调用这个方法。
- (void)invalidateHeightForKey:(id<NSCopying>)key;

/// 令所有的缓存失效。注意如果在业务里，应该调用 [UITableView -nmui_invalidateAllCellHeightKeyCache]，而不应该直接调用这个方法。
- (void)invalidateAllHeightCache;

@end

NS_ASSUME_NONNULL_END
