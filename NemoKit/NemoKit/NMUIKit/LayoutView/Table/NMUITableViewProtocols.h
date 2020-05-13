//
//  NMUITableViewProtocols.h
//  Nemo
//
//  Created by Hunt on 2019/10/31.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NMUITableView;

@protocol NMUICellHeightCache_UITableViewDataSource

@optional
/// 搭配 NMUICellHeightCache 使用，对于 UITableView 而言如果要用 NMUICellHeightCache 那套高度计算方式，则必须实现这个方法
- (nullable __kindof UITableViewCell *)nmui_tableView:(nullable UITableView *)tableView cellWithIdentifier:(nonnull NSString *)identifier;

@end

@protocol NMUICellHeightKeyCache_UITableViewDelegate <NSObject>

@optional

- (nonnull id<NSCopying>)nmui_tableView:(nonnull UITableView *)tableView cacheKeyForRowAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

@protocol NMUITableViewDelegate <UITableViewDelegate, NMUICellHeightKeyCache_UITableViewDelegate>

@optional

/**
 * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
 * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
 */
- (BOOL)tableView:(nonnull NMUITableView *)tableView touchesShouldCancelInContentView:(nonnull UIView *)view;

@end


@protocol NMUITableViewDataSource <UITableViewDataSource, NMUICellHeightCache_UITableViewDataSource>

@end
