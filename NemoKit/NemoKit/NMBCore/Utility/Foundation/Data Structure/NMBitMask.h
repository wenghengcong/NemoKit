//
//  NMBitMask.h
//  NemoMoney
//
//  Created by Hunt on 2020/4/14.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 二进制位操作
@interface NMBitMask : NSObject

// 某一位是否设置 ( 1到64 之间)
+(BOOL) is_set:(NSNumber *) value AtBit:(NSNumber *) bit;

// 设置某一位
+(NSNumber *) set:(NSNumber *) value AtBit:(NSNumber *) bit;

// 重置某一位
+(NSNumber *) un_set:(NSNumber *) value AtBit:(NSNumber *) bit;

// 设置一系列位
+(NSNumber *) setFromBitArray:(NSNumber *) value FromArray:(NSArray *) array;

// 提取出哪些位是设置的
+(NSArray *) extractToArray:(NSNumber *) value StartBit:(NSNumber *) start_bit EndBit:(NSNumber *) end_bit;

@end

NS_ASSUME_NONNULL_END
