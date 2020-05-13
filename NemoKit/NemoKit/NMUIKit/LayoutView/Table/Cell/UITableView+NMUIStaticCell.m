//
//  UITableView+NMUIStaticCell.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITableView+NMUIStaticCell.h"
#import "NMBCore.h"
#import "NMUIStaticTableViewCellDataSource.h"
#import <objc/runtime.h>
#import "NMBFLog.h"
#import "NMBFMultipleDelegates.h"

@interface NMUIStaticTableViewCellDataSource ()

@property(nonatomic, weak, readwrite) UITableView *tableView;
@end

@implementation UITableView (NMUI_StaticCell)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFOverrideImplementation([UITableView class], @selector(setDataSource:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, id<UITableViewDataSource> dataSource) {
                if (dataSource && selfObject.nmui_staticCellDataSource) {
                    void (^addSelectorBlock)(id<UITableViewDataSource>) = ^void(id<UITableViewDataSource> aDataSource) {
                        // 这些 addMethod 的操作必须要在系统的 setDataSource 执行前就执行，否则 tableView 可能会认为不存在这些 method
                        // 并且 addMethod 操作执行一次之后，直到 App 进程被杀死前都会生效，所以多次进入这段代码可能就会提示添加方法失败，请不用在意
                        [selfObject addSelector:@selector(numberOfSectionsInTableView:) withImplementation:(IMP)staticCell_numberOfSections types:"l@:@" forObject:aDataSource];
                        [selfObject addSelector:@selector(tableView:numberOfRowsInSection:) withImplementation:(IMP)staticCell_numberOfRows types:"l@:@l" forObject:aDataSource];
                        [selfObject addSelector:@selector(tableView:cellForRowAtIndexPath:) withImplementation:(IMP)staticCell_cellForRow types:"@@:@@" forObject:aDataSource];
                    };
                    if ([dataSource isKindOfClass:[NMBFMultipleDelegates class]]) {
                        NSPointerArray *delegates = [((NMBFMultipleDelegates *)dataSource).delegates copy];
                        for (id delegate in delegates) {
                            if ([delegate conformsToProtocol:@protocol(UITableViewDataSource)]) {
                                addSelectorBlock((id<UITableViewDataSource>)delegate);
                            }
                        }
                    } else {
                        addSelectorBlock((id<UITableViewDataSource>)dataSource);
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<UITableViewDataSource>);
                originSelectorIMP = (void (*)(id, SEL, id<UITableViewDataSource>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, dataSource);
            };
        });
        
        NMBFOverrideImplementation([UITableView class], @selector(setDelegate:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, id<UITableViewDelegate> delegate) {
                
                if (delegate && selfObject.nmui_staticCellDataSource) {
                    void (^addSelectorBlock)(id<UITableViewDelegate>) = ^void(id<UITableViewDelegate> aDelegate) {
                        // 这些 addMethod 的操作必须要在系统的 setDelegate 执行前就执行，否则 tableView 可能会认为不存在这些 method
                        // 并且 addMethod 操作执行一次之后，直到 App 进程被杀死前都会生效，所以多次进入这段代码可能就会提示添加方法失败，请不用在意
                        [selfObject addSelector:@selector(tableView:heightForRowAtIndexPath:) withImplementation:(IMP)staticCell_heightForRow types:"d@:@@" forObject:aDelegate];
                        [selfObject addSelector:@selector(tableView:didSelectRowAtIndexPath:) withImplementation:(IMP)staticCell_didSelectRow types:"v@:@@" forObject:aDelegate];
                        [selfObject addSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:) withImplementation:(IMP)staticCell_accessoryButtonTapped types:"v@:@@" forObject:aDelegate];
                    };
                    if ([delegate isKindOfClass:[NMBFMultipleDelegates class]]) {
                        NSPointerArray *delegates = [((NMBFMultipleDelegates *)delegate).delegates copy];
                        for (id d in delegates) {
                            if ([d conformsToProtocol:@protocol(UITableViewDelegate)]) {
                                addSelectorBlock((id<UITableViewDelegate>)d);
                            }
                        }
                    } else {
                        addSelectorBlock((id<UITableViewDelegate>)delegate);
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<UITableViewDelegate>);
                originSelectorIMP = (void (*)(id, SEL, id<UITableViewDelegate>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, delegate);
            };
        });
    });
}

static char kAssociatedObjectKey_staticCellDataSource;
- (void)setNmui_staticCellDataSource:(NMUIStaticTableViewCellDataSource *)nmui_staticCellDataSource {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_staticCellDataSource, nmui_staticCellDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    nmui_staticCellDataSource.tableView = self;
    [self reloadData];
}

- (NMUIStaticTableViewCellDataSource *)nmui_staticCellDataSource {
    return (NMUIStaticTableViewCellDataSource *)objc_getAssociatedObject(self, &kAssociatedObjectKey_staticCellDataSource);
}

// 把那些已经手动 addMethod 过的 class 存起来，避免每次都触发 log，打了一堆重复的信息
static NSMutableSet<NSString *> *NMUI_staticTableViewAddedClass;

- (void)addSelector:(SEL)selector withImplementation:(IMP)implementation types:(const char *)types forObject:(NSObject *)object {
    if (!class_addMethod(object.class, selector, implementation, types)) {
        if (!NMUI_staticTableViewAddedClass) {
            NMUI_staticTableViewAddedClass = [[NSMutableSet alloc] init];
        }
        NSString *identifier = [NSString stringWithFormat:@"%@%@", NSStringFromClass(object.class), NSStringFromSelector(selector)];
        if (![NMUI_staticTableViewAddedClass containsObject:identifier]) {
            NMBFLog(NSStringFromClass(self.class), @"尝试为 %@ 添加方法 %@ 失败，可能该类里已经实现了这个方法", NSStringFromClass(object.class), NSStringFromSelector(selector));
            [NMUI_staticTableViewAddedClass addObject:identifier];
        }
    }
}

#pragma mark - DataSource

NSInteger staticCell_numberOfSections (id current_self, SEL current_cmd, UITableView *tableView) {
    return tableView.nmui_staticCellDataSource.cellDataSections.count;
}

NSInteger staticCell_numberOfRows (id current_self, SEL current_cmd, UITableView *tableView, NSInteger section) {
    return tableView.nmui_staticCellDataSource.cellDataSections[section].count;
}

id staticCell_cellForRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
    NMUITableViewCell *cell = [tableView.nmui_staticCellDataSource cellForRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Delegate

CGFloat staticCell_heightForRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
    return [tableView.nmui_staticCellDataSource heightForRowAtIndexPath:indexPath];
}

void staticCell_didSelectRow (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
    [tableView.nmui_staticCellDataSource didSelectRowAtIndexPath:indexPath];
}

void staticCell_accessoryButtonTapped (id current_self, SEL current_cmd, UITableView *tableView, NSIndexPath *indexPath) {
    [tableView.nmui_staticCellDataSource accessoryButtonTappedForRowWithIndexPath:indexPath];
}

@end
