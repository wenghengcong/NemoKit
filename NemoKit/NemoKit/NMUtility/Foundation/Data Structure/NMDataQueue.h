//
//  NMDataQueue.h
//  NemoMoney
//
//  Created by Hunt on 2020/1/4.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMDataQueue : NSObject

@property (nonatomic, assign)   NSInteger       limit;

// Removes and returns the element at the front of the queue
-(id)dequeue;
// Add the element to the back of the queue
-(void)enqueue:(id)element;
// Remove all elements
-(void)enqueueElementsFromArray:(NSArray*)arr;
-(void)enqueueElementsFromQueue:(NMDataQueue*)queue;
-(void)clear;

// Returns the element at the front of the queue
-(id)peek;
// Returns YES if the queue is empty
-(BOOL)isEmpty;
// Returns the size of the queue
-(NSInteger)size;


@end

NS_ASSUME_NONNULL_END
