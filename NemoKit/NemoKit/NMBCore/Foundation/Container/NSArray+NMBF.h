//
//  NSArray+NMBF.h
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (NMBF)

/// 将多个对象合并成一个数组，如果参数类型是数组则会将数组内的元素拆解出来加到 return 内（只会拆解一层，所以多维数组不处理）
/// @param object object 要合并的多个数组
/// @return 合并完的结果
+ (instancetype)nmbf_arrayWithObjects:(id)object, ...;


/// 将多维数组打平成一维数组再遍历所有子元素
/// @param block  遍历回调block
- (void)nmbf_enumerateNestedArrayWithBlock:(void (^)(id obj, BOOL *stop))block;

/// 将多维数组递归转换成 mutable 多维数组
- (NSMutableArray *)nmbf_mutableCopyNestedArray;

/// 过滤数组元素，将 block 返回 YES 的 item 重新组装成一个数组返回
/// @param block  过滤block
- (NSArray<ObjectType> *)nmbf_filterWithBlock:(BOOL (^)(ObjectType item))block;


/**
*  转换数组元素，将每个 item 都经过 block 转换成一遍 返回转换后的新数组
*/
- (NSArray *)nmbf_mapWithBlock:(id (^)(ObjectType item))block;

@end

NS_ASSUME_NONNULL_END
