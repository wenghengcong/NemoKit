//
//  NMUIStaticTableViewCellData.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIStaticTableViewCellData.h"
#import "NMBCore.h"
#import "NMUITableViewCell.h"

@implementation NMUIStaticTableViewCellData

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(NMUIStaticTableViewCellAccessoryType)accessoryType {
    return [NMUIStaticTableViewCellData staticTableViewCellDataWithIdentifier:identifier
                                                                    cellClass:[NMUITableViewCell class]
                                                                        style:UITableViewCellStyleDefault
                                                                       height:TableViewCellNormalHeight
                                                                        image:image
                                                                         text:text
                                                                   detailText:detailText
                                                              didSelectTarget:didSelectTarget
                                                              didSelectAction:didSelectAction
                                                                accessoryType:accessoryType
                                                         accessoryValueObject:nil
                                                              accessoryTarget:nil
                                                              accessoryAction:NULL];
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                            cellClass:(Class)cellClass
                                                style:(UITableViewCellStyle)style
                                               height:(CGFloat)height
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(NMUIStaticTableViewCellAccessoryType)accessoryType
                                 accessoryValueObject:(NSObject *)accessoryValueObject
                                      accessoryTarget:(id)accessoryTarget
                                      accessoryAction:(SEL)accessoryAction {
    NMUIStaticTableViewCellData *data = [[NMUIStaticTableViewCellData alloc] init];
    data.identifier = identifier;
    data.cellClass = cellClass;
    data.style = style;
    data.height = height;
    data.image = image;
    data.text = text;
    data.detailText = detailText;
    data.didSelectTarget = didSelectTarget;
    data.didSelectAction = didSelectAction;
    data.accessoryType = accessoryType;
    data.accessoryValueObject = accessoryValueObject;
    data.accessoryTarget = accessoryTarget;
    data.accessoryAction = accessoryAction;
    return data;
}

- (instancetype)init {
    if (self = [super init]) {
        self.cellClass = [NMUITableViewCell class];
        self.height = TableViewCellNormalHeight;
    }
    return self;
}

- (void)setCellClass:(Class)cellClass {
    NSAssert([cellClass isSubclassOfClass:[NMUITableViewCell class]], @"%@.cellClass 必须为 NMUITableViewCell 的子类", NSStringFromClass(self.class));
    _cellClass = cellClass;
}

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(NMUIStaticTableViewCellAccessoryType)type {
    switch (type) {
        case NMUIStaticTableViewCellAccessoryTypeDisclosureIndicator:
            return UITableViewCellAccessoryDisclosureIndicator;
        case NMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton:
            return UITableViewCellAccessoryDetailDisclosureButton;
        case NMUIStaticTableViewCellAccessoryTypeCheckmark:
            return UITableViewCellAccessoryCheckmark;
        case NMUIStaticTableViewCellAccessoryTypeDetailButton:
            return UITableViewCellAccessoryDetailButton;
        case NMUIStaticTableViewCellAccessoryTypeSwitch:
        default:
            return UITableViewCellAccessoryNone;
    }
}

@end
