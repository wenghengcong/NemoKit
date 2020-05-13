//
//  NSPointerArray+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/29.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSPointerArray+NMBF.h"
#import "NMBCore.h"

@implementation NSPointerArray (NMBF)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithoutArguments([NSPointerArray class], @selector(description), NSString *, ^NSString *(NSPointerArray *selfObject, NSString *originReturnValue) {
            NSMutableString *result = [[NSMutableString alloc] initWithString:originReturnValue];
            NSPointerArray *array = [selfObject copy];
            for (NSInteger i = 0; i < array.count; i++) {
                ([result appendFormat:@"\npointer[%@] is %@", @(i), [array pointerAtIndex:i]]);
            }
            return result;
        });
    });
}


- (NSUInteger)nmbf_indexOfPointer:(nullable void *)pointer {
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)nmbf_containsPointer:(void *)pointer {
    if (!pointer) {
        return NO;
    }
    if ([self nmbf_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}
@end
