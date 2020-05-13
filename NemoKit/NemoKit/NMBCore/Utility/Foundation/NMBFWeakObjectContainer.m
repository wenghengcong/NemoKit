//
//  NMBFWeakObjectContainer.m
//  Nemo
//
//  Created by Hunt on 2019/10/19.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFWeakObjectContainer.h"

@implementation NMBFWeakObjectContainer

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

@end
