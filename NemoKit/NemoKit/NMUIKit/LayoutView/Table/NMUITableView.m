//
//  NMUITableView.m
//  Nemo
//
//  Created by Hunt on 2019/10/31.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITableView.h"
#import "UITableView+NMUI.h"
#import "UIView+NMUI.h"

@implementation NMUITableView

@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self nmui_styledAsNMUITableView];
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

// 保证一直存在tableFooterView，以去掉列表内容不满一屏时尾部的空白分割线
- (void)setTableFooterView:(UIView *)tableFooterView {
    if (!tableFooterView) {
        tableFooterView = [[UIView alloc] init];
    }
    [super setTableFooterView:tableFooterView];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(tableView:touchesShouldCancelInContentView:)]) {
        return [self.delegate tableView:self touchesShouldCancelInContentView:view];
    }
    // 默认情况下只有当view是非UIControl的时候才会返回yes，这里统一对UIButton也返回yes
    // 原因是UITableView上面把事件延迟去掉了，但是这样如果拖动的时候手指是在UIControl上面的话，就拖动不了了
    if ([view isKindOfClass:[UIControl class]]) {
        if ([view isKindOfClass:[UIButton class]]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
