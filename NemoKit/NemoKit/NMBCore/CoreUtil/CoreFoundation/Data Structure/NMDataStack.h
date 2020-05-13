//
//  NMDataStack.h
//  NemoMoney
//
//  Created by Hunt on 2020/1/4.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMDataStack : NSObject <NSFastEnumeration> {
    NSMutableArray* array;
}


// Removes and returns the element at the top of the stack
-(id)pop;
// Adds the element to the top of the stack
-(void)push:(id)element;
// Removes all elements
-(void)pushElementsFromArray:(NSArray*)arr;
-(void)clear;

// Returns the object at the top of the stack
-(id)peek;
// Returns the size of the stack
-(NSInteger)size;
// Returns YES if the stack is empty
-(BOOL)isEmpty;
@end

NS_ASSUME_NONNULL_END
