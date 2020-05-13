//
//  NMUIStaticTableViewCellDataSource.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIStaticTableViewCellDataSource.h"
#import "NMBFLog.h"
#import "NMBCore.h"
#import "NMUITableViewCell.h"
#import "NMUIStaticTableViewCellData.h"

@interface NMUIStaticTableViewCellDataSource ()
@end

@implementation NMUIStaticTableViewCellDataSource

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithCellDataSections:(NSArray<NSArray<NMUIStaticTableViewCellData *> *> *)cellDataSections {
    if (self = [super init]) {
        self.cellDataSections = cellDataSections;
    }
    return self;
}

- (void)setCellDataSections:(NSArray<NSArray<NMUIStaticTableViewCellData *> *> *)cellDataSections {
    _cellDataSections = cellDataSections;
    [self.tableView reloadData];
}

// 在 UITableView (NMUI_StaticCell) 那边会把 tableView 的 property 改为 readwrite，所以这里补上 setter
- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    // 触发 UITableView (NMUI_StaticCell) 里重写的 setter 里的逻辑
    tableView.delegate = tableView.delegate;
    tableView.dataSource = tableView.dataSource;
}

@end

@interface NMUIStaticTableViewCellData (Manual)

@property(nonatomic, strong, readwrite) NSIndexPath *indexPath;
@end

@implementation NMUIStaticTableViewCellDataSource (Manual)

- (NMUIStaticTableViewCellData *)cellDataAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.cellDataSections.count) {
        NMBFLog(NSStringFromClass(self.class), @"cellDataWithIndexPath:%@, data not exist in section!", indexPath);
        return nil;
    }
    
    NSArray<NMUIStaticTableViewCellData *> *rowDatas = [self.cellDataSections objectAtIndex:indexPath.section];
    if (indexPath.row >= rowDatas.count) {
        NMBFLog(NSStringFromClass(self.class), @"cellDataWithIndexPath:%@, data not exist in row!", indexPath);
        return nil;
    }
    
    NMUIStaticTableViewCellData *cellData = [rowDatas objectAtIndex:indexPath.row];
    [cellData setIndexPath:indexPath];// 在这里才为 cellData.indexPath 赋值
    return cellData;
}

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    NMUIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
    return [NSString stringWithFormat:@"cell_%@", @(data.identifier)];
}

- (NMUITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NMUIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
    if (!data) {
        return nil;
    }
    
    NSString *identifier = [self reuseIdentifierForCellAtIndexPath:indexPath];
    
    NMUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[data.cellClass alloc] initForTableView:self.tableView withStyle:data.style reuseIdentifier:identifier];
    }
    cell.imageView.image = data.image;
    cell.textLabel.text = data.text;
    cell.detailTextLabel.text = data.detailText;
    cell.accessoryType = [NMUIStaticTableViewCellData tableViewCellAccessoryTypeWithStaticAccessoryType:data.accessoryType];
    
    // 为某些控件类型的accessory添加控件及相应的事件绑定
    if (data.accessoryType == NMUIStaticTableViewCellAccessoryTypeSwitch) {
        UISwitch *switcher;
        BOOL switcherOn = NO;
        if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
            switcher = (UISwitch *)cell.accessoryView;
        } else {
            switcher = [[UISwitch alloc] init];
        }
        if ([data.accessoryValueObject isKindOfClass:[NSNumber class]]) {
            switcherOn = [((NSNumber *)data.accessoryValueObject) boolValue];
        }
        switcher.on = switcherOn;
        [switcher removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [switcher addTarget:data.accessoryTarget action:data.accessoryAction forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
    }
    
    // HCTODO: 增加TextField
    if (data.accessoryType == NMUIStaticTableViewCellAccessoryTypeTextField) {
        UITextField *textField;
        if ([cell.accessoryView isKindOfClass:[UITextField class]]) {
            textField = (UITextField *)cell.accessoryView;
        } else {
            textField = [[UITextField alloc] init];
        }
    }
    
    // 统一设置selectionStyle
    if (data.accessoryType == NMUIStaticTableViewCellAccessoryTypeSwitch || (!data.didSelectTarget || !data.didSelectAction)) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    [cell updateCellAppearanceWithIndexPath:indexPath];
    
    if (data.cellForRowBlock) {
        data.cellForRowBlock(self.tableView, cell, data);
    }
    
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    return cellData.height;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    if (!cellData || !cellData.didSelectTarget || !cellData.didSelectAction) {
        NMUITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return;
    }
    
    // 1、分发选中事件（UISwitch 类型不支持 didSelect）
    if ([cellData.didSelectTarget respondsToSelector:cellData.didSelectAction] && cellData.accessoryType != NMUIStaticTableViewCellAccessoryTypeSwitch) {
        BeginIgnorePerformSelectorLeaksWarning
        [cellData.didSelectTarget performSelector:cellData.didSelectAction withObject:cellData];
        EndIgnorePerformSelectorLeaksWarning
    }
    
    // 2、处理点击状态（对checkmark类型的cell，选中后自动反选）
    if (cellData.accessoryType == NMUIStaticTableViewCellAccessoryTypeCheckmark) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    if ([cellData.accessoryTarget respondsToSelector:cellData.accessoryAction]) {
        BeginIgnorePerformSelectorLeaksWarning
        [cellData.accessoryTarget performSelector:cellData.accessoryAction withObject:cellData];
        EndIgnorePerformSelectorLeaksWarning
    }
}

@end
