//
//  NMUICommonTableViewController.h
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICommonViewController.h"
#import "NMUINavigationController.h"
#import "NMUITableView.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const NMUICommonTableViewControllerSectionHeaderIdentifier;
extern NSString *const NMUICommonTableViewControllerSectionFooterIdentifier;

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `NMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `NMUISearchController`，可通过属性 `shouldShowSearchBar` 来快速为列表生成一个 searchBar 及 searchController，具体请查看 NMUICommonTableViewController (Search)。
 *  2. 支持仅设置 tableView:titleForHeaderInSection: 就能自动生成 sectionHeader，无需编写 viewForHeaderInSection:、heightForHeaderInSection: 等方法。
 *  3. 自带一个 NMUIEmptyView，作为 tableView 的 subview，可用于显示 loading、空或错误提示语等。
 *
 *  @note emptyView 会从 tableHeaderView 的下方开始布局到 tableView 最底部，因此它会遮挡 tableHeaderView 之外的部分（比如 tableFooterView 和 cells ），你可以重写 layoutEmptyView 来改变这个布局方式
 *
 *  @see NMUISearchController
 */
@interface NMUICommonTableViewController : NMUICommonViewController<NMUITableViewDelegate, NMUITableViewDataSource>

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitializeWithStyle:(UITableViewStyle)style NS_REQUIRES_SUPER;

/// 获取当前的 `UITableViewStyle`
@property(nonatomic, assign, readonly) UITableViewStyle style;

/// 获取当前的 tableView
@property(nonatomic, strong, readonly, null_resettable) IBOutlet NMUITableView *tableView;

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;

@end

@interface NMUICommonTableViewController (NMUISubclassingHooks)

/**
 *  初始化tableView，在initSubViews的时候被自动调用。
 *
 *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
 */
- (void)initTableView NS_REQUIRES_SUPER;

/**
 *  布局 tableView 的方法独立抽取出来，方便子类在需要自定义 tableView.frame 时能重写并且屏蔽掉 super 的代码。如果不独立一个方法而是放在 viewDidLayoutSubviews 里，子类就很难屏蔽 super 里对 tableView.frame 的修改。
 *  默认的实现是撑满 self.view，如果要自定义，可以写在这里而不调用 super，或者干脆重写这个方法但留空
 */
- (void)layoutTableView;

/**
 *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
 *
 *  默认为NO
 *
 *  @see NMUITableViewDelegate
 */
- (BOOL)shouldHideTableHeaderViewInitial;

@end

NS_ASSUME_NONNULL_END
