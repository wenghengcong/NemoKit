//
//  NMDataQueue.m
//  NemoMoney
//
//  Created by Hunt on 2020/1/4.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import "NMDataQueue.h"

@interface NMDataQueue()  {
    NSMutableArray *_array;
}

@end

@implementation NMDataQueue 

-(id)init
{
    if ( (self = [super init]) ) {
        _array = [[NSMutableArray alloc] init];
        _limit = INT_MAX;
    }
    
    return self;
}

-(id)dequeue {
    if ([self size] > 0) {
        id object = [self peek];
        if (object) {
            [_array removeObjectAtIndex:0];
        }
        return object;
    }
    
    return nil;
}

-(void)enqueue:(id)element {
    if ([self size] <= self.limit) {
        [_array addObject:element];
    }
}

-(void)enqueueElementsFromArray:(NSArray*)arr {
    [_array addObjectsFromArray:arr];
}

-(void)enqueueElementsFromQueue:(NMDataQueue*)queue {
    while (![queue isEmpty]) {
        [self enqueue:[queue dequeue]];
    }
}

-(id)peek {
    if ([self size] > 0)
        return [_array objectAtIndex:0];
    
    return nil;
}

-(NSInteger)size {
    return [_array count];
}

-(BOOL)isEmpty {
    return [_array count] == 0;
}

-(void)clear {
    [_array removeAllObjects];
}

- (void)setLimit:(NSInteger)limit {
    _limit = limit;
    if ([self size] > limit) {
        //TODO: remove beyonde index object
    }
}

@end
