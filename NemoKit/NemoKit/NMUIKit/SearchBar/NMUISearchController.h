//
//  NMUISearchController.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICommonViewController.h"
#import "NMUICommonTableViewController.h"
#import "NMUICommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class NMUIEmptyView;
@class NMUISearchController;

/**
 *  配合 NMUISearchController 使用的 protocol，主要负责两件事情：
 *
 *  1. 响应用户的输入，在搜索框内的文字发生变化后被调用，可在 searchController:updateResultsForSearchString: 方法内更新搜索结果的数据集，在里面请自行调用 [searchController.tableView reloadData]
 *  2. 渲染最终用于显示搜索结果的 UITableView 的数据，该 tableView 的 delegate、dataSource 均包含在这个 protocol 里
 */
@protocol NMUISearchControllerDelegate <NMUITableViewDataSource, NMUITableViewDelegate>

@required
/**
 *  搜索框文字发生变化时的回调，请自行调用 `[tableView reloadData]` 来更新界面。
 *  @warning 搜索框文字为空（例如第一次点击搜索框进入搜索状态时，或者文字全被删掉了，或者点击搜索框的×）也会走进来，此时参数searchString为@""，这是为了和系统的UISearchController保持一致
 */
- (void)searchController:(NMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString;

@optional
- (void)willPresentSearchController:(NMUISearchController *)searchController;
- (void)didPresentSearchController:(NMUISearchController *)searchController;
- (void)willDismissSearchController:(NMUISearchController *)searchController;
- (void)didDismissSearchController:(NMUISearchController *)searchController;
- (void)searchController:(NMUISearchController *)searchController didLoadSearchResultsTableView:(UITableView *)tableView;
- (void)searchController:(NMUISearchController *)searchController willShowEmptyView:(NMUIEmptyView *)emptyView;

@end

/**
 *  支持在搜索文字为空时（注意并非“搜索结果为空”）显示一个界面，例如常见的“最近搜索”功能，具体请查看属性 launchView。
 *  使用方法：
 *  1. 使用 initWithContentsViewController: 初始化
 *  2. 通过 searchBar 属性得到搜索框的引用并直接使用，例如 `tableHeaderView = searchController.searchBar`
 *  3. 指定 searchResultsDelegate 属性并在其中实现 searchController:updateResultsForSearchString: 方法以更新搜索结果数据集
 *
 *  @note NMUICommonTableViewController 内部自带 NMUISearchController，只需将属性 shouldShowSearchBar 置为 YES 即可，无需自行初始化 NMUISearchController。
 */
@interface NMUISearchController : NMUICommonViewController

/**
 *  在某个指定的UIViewController上创建一个与其绑定的searchController
 *  @param viewController 要在哪个viewController上添加搜索功能
 */
- (instancetype)initWithContentsViewController:(UIViewController *)viewController;

@property(nonatomic, weak) id<NMUISearchControllerDelegate> searchResultsDelegate;

/// 搜索框
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

/// 搜索结果列表
@property(nonatomic, strong, readonly) NMUITableView *tableView;

/// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
@property(nonatomic, strong) UIView *launchView;

/// 控制以无动画的形式进入/退出搜索状态
@property(nonatomic, assign, getter=isActive) BOOL active;

/**
 *  控制进入/退出搜索状态
 *  @param active YES 表示进入搜索状态，NO 表示退出搜索状态
 *  @param animated 是否要以动画的形式展示状态切换
 */
- (void)setActive:(BOOL)active animated:(BOOL)animated;

/// 进入搜索状态时是否要把原界面的 navigationBar 推走，默认为 YES
@property(nonatomic, assign) BOOL hidesNavigationBarDuringPresentation;
@end



@interface NMUICommonTableViewController (Search) <NMUISearchControllerDelegate>

/**
 *  控制列表里是否需要搜索框，如果为 YES，则会在 viewDidLoad 之后创建一个 searchBar 作为 tableHeaderView；如果为 NO，则会移除已有的 searchBar 和 searchController。
 *  默认为 NO。
 *  @note 若在 viewDidLoad 之前设置为 YES，也会等到 viewDidLoad 时才去创建搜索框。
 */
@property(nonatomic, assign) BOOL shouldShowSearchBar;

/**
 *  获取当前的 searchController，注意只有当 `shouldShowSearchBar` 为 `YES` 时才有用
 *
 *  默认为 `nil`
 *
 *  @see NMUITableViewDelegate
 */
@property(nonatomic, strong, readonly) NMUISearchController *searchController;

/**
 *  获取当前的 searchBar，注意只有当 `shouldShowSearchBar` 为 `YES` 时才有用
 *
 *  默认为 `nil`
 *
 *  @see NMUITableViewDelegate
 */
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

/**
 *  是否应该在显示空界面时自动隐藏搜索框
 *
 *  默认为 `NO`
 */
- (BOOL)shouldHideSearchBarWhenEmptyViewShowing;

/**
 *  初始化searchController和searchBar，在initSubViews的时候被自动调用。
 *
 *  会询问 `self.shouldShowSearchBar`，若返回 `YES`，则创建 searchBar 并将其以 `tableHeaderView` 的形式呈现在界面里；若返回 `NO`，则将 `tableHeaderView` 置为nil。
 *
 *  @warning `self.shouldShowSearchBar` 默认为 NO，需要 searchBar 的界面必须手动将其置为 `YES`。
 */
- (void)initSearchController;

@end


NS_ASSUME_NONNULL_END
