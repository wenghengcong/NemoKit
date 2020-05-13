//
//  NMUISearchController.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUISearchController.h"
#import "NMBCore.h"
#import "NMUIEmptyView.h"


BeginIgnoreDeprecatedWarning

@class NMUISearchResultsTableViewController;

@protocol NMUISearchResultsTableViewControllerDelegate <NSObject>

- (void)didLoadTableViewInSearchResultsTableViewController:(NMUISearchResultsTableViewController *)viewController;
@end

@interface NMUISearchResultsTableViewController : NMUICommonTableViewController

@property(nonatomic,weak) id<NMUISearchResultsTableViewControllerDelegate> delegate;
@end

@implementation NMUISearchResultsTableViewController

- (void)initTableView {
    [super initTableView];
    if (@available(iOS 11, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if ([self.delegate respondsToSelector:@selector(didLoadTableViewInSearchResultsTableViewController:)]) {
        [self.delegate didLoadTableViewInSearchResultsTableViewController:self];
    }
}

@end

@interface NMUICustomSearchController : UISearchController

@property(nonatomic, strong) UIView *customDimmingView;
@end

@implementation NMUICustomSearchController

- (void)setCustomDimmingView:(UIView *)customDimmingView {
    if (_customDimmingView != customDimmingView) {
        [_customDimmingView removeFromSuperview];
    }
    _customDimmingView = customDimmingView;
    
    self.dimsBackgroundDuringPresentation = !_customDimmingView;
    if ([self isViewLoaded]) {
        [self addCustomDimmingView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addCustomDimmingView];
}

- (void)addCustomDimmingView {
    UIView *superviewOfDimmingView = self.searchResultsController.view.superview;
    if (self.customDimmingView && self.customDimmingView.superview != superviewOfDimmingView) {
        [superviewOfDimmingView insertSubview:self.customDimmingView atIndex:0];
        [self layoutCustomDimmingView];
    }
}

- (void)layoutCustomDimmingView {
    UIView *searchBarContainerView = nil;
    for (UIView *subview in self.view.subviews) {
        if ([NSStringFromClass(subview.class) isEqualToString:@"_UISearchBarContainerView"]) {
            searchBarContainerView = subview;
            break;
        }
    }
    
    self.customDimmingView.frame = CGRectInsetEdges(self.customDimmingView.superview.bounds, UIEdgeInsetsMake(searchBarContainerView ? CGRectGetMaxY(searchBarContainerView.frame) : 0, 0, 0, 0));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.customDimmingView) {
        [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
            [self layoutCustomDimmingView];
        }];
    }
}

@end

@interface NMUISearchController () <UISearchResultsUpdating, UISearchControllerDelegate, NMUISearchResultsTableViewControllerDelegate>

@property(nonatomic,strong) NMUICustomSearchController *searchController;
@end

@implementation NMUISearchController

- (instancetype)initWithContentsViewController:(UIViewController *)viewController {
    if (self = [self initWithNibName:nil bundle:nil]) {
        // 将 definesPresentationContext 置为 YES 有两个作用：
        // 1、保证从搜索结果界面进入子界面后，顶部的searchBar不会依然停留在navigationBar上
        // 2、使搜索结果界面的tableView的contentInset.top正确适配searchBar
        viewController.definesPresentationContext = YES;
        
        NMUISearchResultsTableViewController *searchResultsViewController = [[NMUISearchResultsTableViewController alloc] init];
        searchResultsViewController.delegate = self;
        self.searchController = [[NMUICustomSearchController alloc] initWithSearchResultsController:searchResultsViewController];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        _searchBar = self.searchController.searchBar;
        if (CGRectIsEmpty(self.searchBar.frame)) {
            // iOS8 下 searchBar.frame 默认是 CGRectZero，不 sizeToFit 就看不到了
            [self.searchBar sizeToFit];
        }
        [self.searchBar nmui_styledAsNMUISearchBar];
        
        self.hidesNavigationBarDuringPresentation = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 主动触发 loadView，如果不这么做，那么有可能直到 NMUISearchController 被销毁，这期间 self.searchController 都没有被触发 loadView，然后在 dealloc 时就会报错，提示尝试在释放 self.searchController 时触发了 self.searchController 的 loadView
    [self.searchController loadViewIfNeeded];
}

- (void)setSearchResultsDelegate:(id<NMUISearchControllerDelegate>)searchResultsDelegate {
    _searchResultsDelegate = searchResultsDelegate;
    self.tableView.dataSource = _searchResultsDelegate;
    self.tableView.delegate = _searchResultsDelegate;
}

- (BOOL)isActive {
    return self.searchController.active;
}

- (void)setActive:(BOOL)active {
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated {
    self.searchController.active = active;
}

- (UITableView *)tableView {
    return ((NMUICommonTableViewController *)self.searchController.searchResultsController).tableView;
}

- (void)setLaunchView:(UIView *)dimmingView {
    _launchView = dimmingView;
    self.searchController.customDimmingView = _launchView;
}

- (BOOL)hidesNavigationBarDuringPresentation {
    return self.searchController.hidesNavigationBarDuringPresentation;
}

- (void)setHidesNavigationBarDuringPresentation:(BOOL)hidesNavigationBarDuringPresentation {
    self.searchController.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation;
}

#pragma mark - NMUIEmptyView

- (void)showEmptyView {
    // 搜索框文字为空时，界面会显示遮罩，此时不需要显示emptyView了
    // 为什么加这个是因为当搜索框被点击时（进入搜索状态）会触发searchController:updateResultsForSearchString:，里面如果直接根据搜索结果为空来showEmptyView的话，就会导致在遮罩层上有emptyView出现，要么在那边showEmptyView之前判断一下searchBar.text.length，要么在showEmptyView里判断，为了方便，这里选择后者。
    if (self.searchBar.text.length <= 0) {
        return;
    }
    
    [super showEmptyView];
    
    // 格式化样式，以适应当前项目的需求
    self.emptyView.backgroundColor = TableViewBackgroundColor ?: UIColorWhite;
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:willShowEmptyView:)]) {
        [self.searchResultsDelegate searchController:self willShowEmptyView:self.emptyView];
    }
    
    if (self.searchController) {
        UIView *superview = self.searchController.searchResultsController.view;
        [superview addSubview:self.emptyView];
    } else {
        NSAssert(NO, @"NMUISearchController无法为emptyView找到合适的superview");
    }
    
    [self layoutEmptyView];
}

#pragma mark - <NMUISearchResultsTableViewControllerDelegate>

- (void)didLoadTableViewInSearchResultsTableViewController:(NMUISearchResultsTableViewController *)viewController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:didLoadSearchResultsTableView:)]) {
        [self.searchResultsDelegate searchController:self didLoadSearchResultsTableView:viewController.tableView];
    }
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:updateResultsForSearchString:)]) {
        [self.searchResultsDelegate searchController:self updateResultsForSearchString:searchController.searchBar.text];
    }
}

#pragma mark - <UISearchControllerDelegate>

- (void)willPresentSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(willPresentSearchController:)]) {
        [self.searchResultsDelegate willPresentSearchController:self];
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(didPresentSearchController:)]) {
        [self.searchResultsDelegate didPresentSearchController:self];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(willDismissSearchController:)]) {
        [self.searchResultsDelegate willDismissSearchController:self];
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // 退出搜索必定先隐藏emptyView
    [self hideEmptyView];
    
    if ([self.searchResultsDelegate respondsToSelector:@selector(didDismissSearchController:)]) {
        [self.searchResultsDelegate didDismissSearchController:self];
    }
}

@end

EndIgnoreDeprecatedWarning

@implementation NMUICommonTableViewController (Search)

NMBFSynthesizeIdStrongProperty(searchController, setSearchController)
NMBFSynthesizeIdStrongProperty(searchBar, setSearchBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([NMUICommonTableViewController class], @selector(initSubviews), ^(NMUICommonTableViewController *selfObject) {
            [selfObject initSearchController];
        });
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([NMUICommonTableViewController class], @selector(viewWillAppear:), BOOL, ^(NMUICommonTableViewController *selfObject, BOOL firstArgv) {
            if (!selfObject.searchController.tableView.allowsMultipleSelection) {
                [selfObject.searchController.tableView nmui_clearsSelection];
            }
        });
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([NMUICommonTableViewController class], @selector(showEmptyView), ^(NMUICommonTableViewController *selfObject) {
            if ([selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == selfObject.searchBar) {
                selfObject.tableView.tableHeaderView = nil;
            }
        });
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([NMUICommonTableViewController class], @selector(hideEmptyView), ^(NMUICommonTableViewController *selfObject) {
            if (selfObject.shouldShowSearchBar && [selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == nil) {
                [selfObject initSearchController];
                // 隐藏 emptyView 后重新设置 tableHeaderView，会导致原先 shouldHideTableHeaderViewInitial 隐藏头部的操作被重置，所以下面的 force 参数要传 YES
                // https://github.com/Tencent/QMUI_iOS/issues/128
                selfObject.tableView.tableHeaderView = selfObject.searchBar;
                [selfObject hideTableHeaderViewInitialIfCanWithAnimated:NO force:YES];
            }
        });
    });
}

static char kAssociatedObjectKey_shouldShowSearchBar;
- (void)setShouldShowSearchBar:(BOOL)shouldShowSearchBar {
    BOOL isValueChanged = self.shouldShowSearchBar != shouldShowSearchBar;
    if (!isValueChanged) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar, @(shouldShowSearchBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (shouldShowSearchBar) {
        [self initSearchController];
    } else {
        if (self.searchBar) {
            if (self.tableView.tableHeaderView == self.searchBar) {
                self.tableView.tableHeaderView = nil;
            }
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
        }
        if (self.searchController) {
            self.searchController.searchResultsDelegate = nil;
            self.searchController = nil;
        }
    }
}

- (BOOL)shouldShowSearchBar {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar)) boolValue];
}

- (void)initSearchController {
    if ([self isViewLoaded] && self.shouldShowSearchBar && !self.searchController) {
        self.searchController = [[NMUISearchController alloc] initWithContentsViewController:self];
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchBar.placeholder = @"搜索";
        self.searchController.searchBar.nmui_usedAsTableHeaderView = YES;// 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchBar = self.searchController.searchBar;
    }
}

- (BOOL)shouldHideSearchBarWhenEmptyViewShowing {
    return NO;
}

#pragma mark - <NMUISearchControllerDelegate>

- (void)searchController:(NMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    
}

@end
