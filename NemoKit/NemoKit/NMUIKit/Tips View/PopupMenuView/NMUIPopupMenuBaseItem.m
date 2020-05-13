//
//  NMUIPopupMenuBaseItem.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIPopupMenuBaseItem.h"

@implementation NMUIPopupMenuBaseItem

@synthesize title = _title;
@synthesize height = _height;
@synthesize handler = _handler;
@synthesize menuView = _menuView;

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
    }
    return self;
}

- (void)updateAppearance {
    
}

@end
