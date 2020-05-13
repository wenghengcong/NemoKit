//
//  NMBFLogManagerViewController.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFLogManagerViewController.h"
#import "NMBCore.h"
#import "NMBFLogger.h"
#import "NMUIStaticTableViewCellData.h"
#import "NMUIStaticTableViewCellDataSource.h"
#import "NMUISearchController.h"
#import "UITableView+NMUI.h"
#import "NMUITableView.h"
#import "UITableView+NMUIStaticCell.h"
#import "NMUIPopupMenuView.h"
#import "NMUITableViewCell.h"

@interface NMBFLogManagerViewController ()

@property(nonatomic, copy) NSDictionary<NSString *, NSNumber *> *allNames;
@property(nonatomic, copy) NSArray<NSString *> *sortedLogNames;
@property(nonatomic, copy) NSArray<NSString *> *sectionIndexTitles;
@property(nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@implementation NMBFLogManagerViewController

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    [super didInitializeWithStyle:style];
    self.rowCountWhenShowSearchBar = 10;
    self.statusBarStyle = NMUICMIActivated ? (StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) : UIStatusBarStyleDefault;
}

- (void)initTableView {
    [super initTableView];
    [self setupDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkEmptyView];
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    if (self.allNames.count) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleMenuItemEvent)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)setupDataSource {
    self.allNames = [NMBFLogger sharedInstance].logNameManager.allNames;
    
    NSArray<NSString *> *logNames = self.allNames.allKeys;
    
    self.sortedLogNames = [logNames sortedArrayUsingComparator:^NSComparisonResult(NSString *logName1, NSString *logName2) {
        logName1 = [self formatLogNameForSorting:logName1];
        logName2 = [self formatLogNameForSorting:logName2];
        return [logName1 caseInsensitiveCompare:logName2];
    }];
    self.sectionIndexTitles = ({
        NSMutableArray<NSString *> *titles = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.sortedLogNames.count; i++) {
            NSString *logName = self.sortedLogNames[i];
            NSString *sectionIndexTitle = [[self formatLogNameForSorting:logName] substringToIndex:1];
            if (![titles containsObject:sectionIndexTitle]) {
                [titles addObject:sectionIndexTitle];
            }
        }
        [titles copy];
    });
    
    NSMutableArray<NSArray<NMUIStaticTableViewCellData *> *> *cellDataSections = [[NSMutableArray alloc] init];
    NSMutableArray<NMUIStaticTableViewCellData *> *currentSection = nil;
    for (NSInteger i = 0; i < self.sortedLogNames.count; i++) {
        NSString *logName = self.sortedLogNames[i];
        NSString *formatedLogName = [self formatLogNameForSorting:logName];
        NSString *sectionIndexTitle = [formatedLogName substringToIndex:1];
        NSUInteger section = [self.sectionIndexTitles indexOfObject:sectionIndexTitle];
        if (section != NSNotFound) {
            if (cellDataSections.count <= section) {
                // 说明这个 section 还没被创建过
                currentSection = [[NSMutableArray alloc] init];
                [cellDataSections addObject:currentSection];
            }
            [currentSection addObject:({
                NMUIStaticTableViewCellData *d = [[NMUIStaticTableViewCellData alloc] init];
                d.text = logName;
                d.accessoryType = NMUIStaticTableViewCellAccessoryTypeSwitch;
                d.accessoryValueObject = self.allNames[logName];
                d.accessoryTarget = self;
                d.accessoryAction = @selector(handleSwitchEvent:);
                d;
            })];
        }
    }
    
    // 超过一定数量则出搜索框，先设置好搜索框的显隐，以便其他东西可以依赖搜索框的显隐状态来做判断
    NSInteger rowCount = logNames.count;
    self.shouldShowSearchBar = rowCount >= self.rowCountWhenShowSearchBar;
    
    NMUIStaticTableViewCellDataSource *dataSource = [[NMUIStaticTableViewCellDataSource alloc] initWithCellDataSections:cellDataSections];
    self.tableView.nmui_staticCellDataSource = dataSource;
}

- (void)reloadData {
    [self setupDataSource];
    [self checkEmptyView];
    [self.tableView reloadData];
}

- (void)checkEmptyView {
    if (self.allNames.count <= 0) {
        [self showEmptyViewWithText:@"暂无 NMBFLog 产生" detailText:nil buttonTitle:nil buttonAction:NULL];
    } else {
        [self hideEmptyView];
    }
    [self setupNavigationItems];
}

- (NSArray<NSString *> *)sortedLogNameArray {
    NSArray<NSString *> *logNames = self.allNames.allKeys;
    NSArray<NSString *> *sortedArray = [logNames sortedArrayUsingComparator:^NSComparisonResult(NSString *logName1, NSString *logName2) {
        
        return NSOrderedAscending;
    }];
    return sortedArray;
}

- (NSString *)formatLogNameForSorting:(NSString *)logName {
    if (self.formatLogNameForSortingBlock) {
        return self.formatLogNameForSortingBlock(logName);
    }
    return logName;
}

- (void)handleSwitchEvent:(UISwitch *)switchControl {
    UITableView *tableView = self.searchController.active ? self.searchController.tableView : self.tableView;
    NSIndexPath *indexPath = [tableView nmui_indexPathForRowAtView:switchControl];
    NMUIStaticTableViewCellData *cellData = [tableView.nmui_staticCellDataSource cellDataAtIndexPath:indexPath];
    cellData.accessoryValueObject = @(switchControl.on);
    [[NMBFLogger sharedInstance].logNameManager setEnabled:switchControl.on forLogName:cellData.text];
}

- (void)handleMenuItemEvent {
    NMUIPopupMenuView *menuView = [[NMUIPopupMenuView alloc] init];
    menuView.automaticallyHidesWhenUserTap = YES;
    menuView.preferLayoutDirection = NMUIPopupContainerViewLayoutDirectionBelow;
    menuView.maximumWidth = 124;
    menuView.safetyMarginsOfSuperview = UIEdgeInsetsSetRight(menuView.safetyMarginsOfSuperview, 6);
    menuView.items = @[
        [NMUIPopupMenuButtonItem itemWithImage:nil title:@"开启全部" handler:^(NMUIPopupMenuButtonItem *aItem) {
            for (NSString *logName in self.allNames) {
                [[NMBFLogger sharedInstance].logNameManager setEnabled:YES forLogName:logName];
            }
            [self reloadData];
            [aItem.menuView hideWithAnimated:YES];
        }],
        [NMUIPopupMenuButtonItem itemWithImage:nil title:@"禁用全部" handler:^(NMUIPopupMenuButtonItem *aItem) {
            for (NSString *logName in self.allNames) {
                [[NMBFLogger sharedInstance].logNameManager setEnabled:NO forLogName:logName];
            }
            [self reloadData];
            [aItem.menuView hideWithAnimated:YES];
        }],
        [NMUIPopupMenuButtonItem itemWithImage:nil title:@"清空全部" handler:^(NMUIPopupMenuButtonItem *aItem) {
            [[NMBFLogger sharedInstance].logNameManager removeAllNames];
            [self reloadData];
            [aItem.menuView hideWithAnimated:YES];
        }]];
    menuView.sourceBarItem = self.navigationItem.rightBarButtonItem;
    [menuView showWithAnimated:YES];
}

#pragma mark - <NMUITableViewDataSource, NMUITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NMUITableViewCell *cell = [tableView.nmui_staticCellDataSource cellForRowAtIndexPath:indexPath];
    NMUIStaticTableViewCellData *cellData = [tableView.nmui_staticCellDataSource cellDataAtIndexPath:indexPath];
    NSString *logName = cellData.text;
    
    NSAttributedString *string = nil;
    if (self.formatCellTextBlock) {
        string = self.formatCellTextBlock(logName);
    } else {
        NSString *formatedLogName = [self formatLogNameForSorting:logName];
        NSRange range = [logName rangeOfString:formatedLogName];
        NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:logName attributes:@{NSFontAttributeName: UIFontMake(16), NSForegroundColorAttributeName: UIColorGray}];
        [mutableString setAttributes:@{NSForegroundColorAttributeName: UIColorBlack} range:range];
        string = [mutableString copy];
    }
    cell.textLabel.attributedText = string;
    
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        BOOL enabled = self.allNames[logName].boolValue;
        UISwitch *switchControl = (UISwitch *)cell.accessoryView;
        switchControl.on = enabled;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return tableView == self.tableView ? self.sectionIndexTitles[section] : nil;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return tableView == self.tableView && self.shouldShowSearchBar ? self.sectionIndexTitles : nil;
}

#pragma mark - <NMUISearchControllerDelegate>

- (void)searchController:(NMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    NSArray<NSArray<NMUIStaticTableViewCellData *> *> *dataSource = self.tableView.nmui_staticCellDataSource.cellDataSections;
    NSMutableArray<NMUIStaticTableViewCellData *> *resultDataSource = [[NSMutableArray alloc] init];// 搜索结果就不需要分 section 了
    for (NSInteger section = 0; section < dataSource.count; section ++) {
        for (NSInteger row = 0; row < dataSource[section].count; row ++) {
            NMUIStaticTableViewCellData *cellData = dataSource[section][row];
            NSString *text = cellData.text;
            if ([text.lowercaseString containsString:searchString.lowercaseString]) {
                [resultDataSource addObject:cellData];
            }
        }
    }
    searchController.tableView.nmui_staticCellDataSource = [[NMUIStaticTableViewCellDataSource alloc] initWithCellDataSections:@[resultDataSource.copy]];
    
    if (resultDataSource.count > 0) {
        [searchController hideEmptyView];
    } else {
        [searchController showEmptyViewWithText:@"无结果" detailText:nil buttonTitle:nil buttonAction:NULL];
    }
}

- (void)willPresentSearchController:(NMUISearchController *)searchController {
    self.statusBarStyle = UIStatusBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)willDismissSearchController:(NMUISearchController *)searchController {
    
    // 在搜索状态里可能修改了 switch 的值，则退出时强制刷新一下默认状态的列表
    [self reloadData];
    self.statusBarStyle = NMUICMIActivated ? (StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault) : UIStatusBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
