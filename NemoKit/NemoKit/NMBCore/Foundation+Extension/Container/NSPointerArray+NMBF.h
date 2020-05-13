//
//  NSPointerArray+NMBF.h
//  Nemo
//
//  Created by Hunt on 2019/10/29.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPointerArray (NMBF)

- (NSUInteger)nmbf_indexOfPointer:(nullable void *)pointer;
- (BOOL)nmbf_containsPointer:(nullable void *)pointer;

@end

NS_ASSUME_NONNULL_END
