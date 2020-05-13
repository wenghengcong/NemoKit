//
//  NMDateToolsError.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Domain

extern NSString * _Nullable const NMErrorDomain;

#pragma mark - Status Codes
static const NSUInteger NMInsertOutOfBoundsException = 0;
static const NSUInteger NMRemoveOutOfBoundsException = 1;
static const NSUInteger NMBadTypeException = 2;

NS_ASSUME_NONNULL_BEGIN

@interface NMDateToolsError : NSObject

+(void)throwInsertOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+(void)throwRemoveOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+(void)throwBadTypeException:(id)obj expectedClass:(Class)classType;

@end

NS_ASSUME_NONNULL_END
