//
//  NMDateToolsError.m
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMDateToolsError.h"

#pragma mark - Domain
NSString *const NMErrorDomain = @"com.luci.nemo.dateTools";

@implementation NMDateToolsError

+(void)throwInsertOutOfBoundsException:(NSInteger)index array:(NSArray *)array{
    //Handle possible zero bounds
    NSInteger arrayUpperBound = (array.count == 0)? 0:array.count;
    
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to insert NMDateToolsTimePeriod at index %ld but the group is of size [0...%ld].", (long)index, (long)arrayUpperBound],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try an index within the bounds or the group.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:NMErrorDomain code:NMInsertOutOfBoundsException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)throwRemoveOutOfBoundsException:(NSInteger)index array:(NSArray *)array{
    //Handle possible zero bounds
    NSInteger arrayUpperBound = (array.count == 0)? 0:array.count;
    
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to remove NMDateToolsTimePeriod at index %ld but the group is of size [0...%ld].", (long)index, (long)arrayUpperBound],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try an index within the bounds of the group.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:NMErrorDomain code:NMRemoveOutOfBoundsException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)throwBadTypeException:(id)obj expectedClass:(Class)classType{
    //Create info for error
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil), NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Attempted to insert object of class %@ when expecting object of class %@.", NSStringFromClass([obj class]), NSStringFromClass(classType)],NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try again by inserting a NMDateToolsTimePeriod object.", nil)};
    
    //Handle Error
    NSError *error = [NSError errorWithDomain:NMErrorDomain code:NMBadTypeException userInfo:userInfo];
    [self printErrorWithCallStack:error];
}

+(void)printErrorWithCallStack:(NSError *)error{
    //Print error
    NSLog(@"%@", error);
    
    //Print call stack
    for (NSString *symbol in [NSThread callStackSymbols]) {
        NSLog(@"\n\n %@", symbol);
    }
}

@end
