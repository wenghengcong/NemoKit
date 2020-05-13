//
//  NMUIStaticTableViewCellData.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NMUITableViewCell;

typedef NS_ENUM(NSInteger, NMUIStaticTableViewCellAccessoryType) {
    NMUIStaticTableViewCellAccessoryTypeNone,
    NMUIStaticTableViewCellAccessoryTypeDisclosureIndicator,
    NMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton,
    NMUIStaticTableViewCellAccessoryTypeCheckmark,
    NMUIStaticTableViewCellAccessoryTypeDetailButton,
    NMUIStaticTableViewCellAccessoryTypeSwitch,
    NMUIStaticTableViewCellAccessoryTypeTextField,
};

/**
 *  一个 cellData 对象用于存储 static tableView（例如设置界面那种列表） 列表里的一行 cell 的基本信息，包括这个 cell 的 class、text、detailText、accessoryView 等。
 *  @see NMUIStaticTableViewCellDataSource
 */
@interface NMUIStaticTableViewCellData : NSObject

/// 当前 cellData 的标志，一般同个 tableView 里的每个 cellData 都会拥有不相同的 identifier
@property(nonatomic, assign) NSInteger identifier;

/// 当前 cellData 所对应的 indexPath
@property(nonatomic, strong, readonly) NSIndexPath *indexPath;

/// cell 要使用的 class，默认为 NMUITableViewCell，若要改为自定义 class，必须是 NMUITableViewCell 的子类
@property(nonatomic, assign) Class cellClass;

/// init cell 时要使用的 style
@property(nonatomic, assign) UITableViewCellStyle style;

/// cell 的高度，默认为 TableViewCellNormalHeight
@property(nonatomic, assign) CGFloat height;

/// cell 左边要显示的图片，将会被设置到 cell.imageView.image
@property(nonatomic, strong) UIImage *image;

/// cell 的文字，将会被设置到 cell.textLabel.text
@property(nonatomic, copy) NSString *text;

/// cell 的详细文字，将会被设置到 cell.detailTextLabel.text，所以要求 cellData.style 的值必须是带 detailTextLabel 类型的 style
@property(nonatomic, copy) NSString *detailText;

/// 会自动在 tableView:cellForRowAtIndexPath: 里调用，这样就不需要实现 cellForRow
@property(nonatomic, copy) void (^cellForRowBlock)(UITableView *tableView, __kindof NMUITableViewCell *cell, NMUIStaticTableViewCellData *cellData);

/// 当 cell 的点击事件被触发时，要由哪个对象来接收
@property(nonatomic, assign) id didSelectTarget;

/// 当 cell 的点击事件被触发时，要向 didSelectTarget 指针发送什么消息以响应事件
/// @warning 这个 selector 接收一个参数，这个参数也即当前的 NMUIStaticTableViewCellData 对象
@property(nonatomic, assign) SEL didSelectAction;


#pragma mark - accessoryView
/// accessoryView
@property(nonatomic, strong) id accessoryView;

/// cell 右边的 accessoryView 的类型
@property(nonatomic, assign) NMUIStaticTableViewCellAccessoryType accessoryType;

/// 配合 accessoryType 使用，不同的 accessoryType 需要配合不同 class 的 accessoryValueObject 使用。例如 NMUIStaticTableViewCellAccessoryTypeSwitch 要求传 @YES 或 @NO 用于控制 UISwitch.on 属性。
/// @warning 目前也仅支持与 NMUIStaticTableViewCellAccessoryTypeSwitch 搭配使用。
@property(nonatomic, strong) NSObject *accessoryValueObject;

/// 当 accessoryType 是某些带 UIControl 的控件时，可通过这两个属性来为 accessoryView 添加操作事件。
/// 目前支持的类型包括：NMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton、NMUIStaticTableViewCellAccessoryTypeDetailButton、NMUIStaticTableViewCellAccessoryTypeSwitch
/// @warning 这个 selector 接收一个参数，与 didSelectAction 一样，这个参数一般情况下也是当前的 NMUIStaticTableViewCellData 对象，仅在 Switch 时会传 UISwitch 控件的实例
@property(nonatomic, assign) id accessoryTarget;
@property(nonatomic, assign) SEL accessoryAction;

/// 当 accessoryType 是某些带 UIControl 的控件时，可通过这个属性来为 accessoryView 添加代理，目前支持 NMUIStaticTableViewCellAccessoryTypeTextField 类型，即对应UITextFieldDelegate。
@property(nonatomic, weak)   id accessoryDelegate;

#pragma mark - Init

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(NMUIStaticTableViewCellAccessoryType)accessoryType;

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
                                      accessoryAction:(SEL)accessoryAction;

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(NMUIStaticTableViewCellAccessoryType)type;
@end

