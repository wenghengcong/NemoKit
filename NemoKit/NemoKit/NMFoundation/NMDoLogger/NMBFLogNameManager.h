//
//  NMBFLogNameManager.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 所有 NMBFLog 的 name 都会以这个 key 存储到 NSUserDefaults 里（类型为 NSDictionary<NSString *, NSNumber *> *），可通过 dictionaryForKey: 获取到所有的 name 及对应的 enabled 状态。
extern NSString * _Nonnull const NMBFLoggerAllNamesKeyInUserDefaults;

/// log.name 的管理器，由它来管理每一个 name 是否可用、以及清理不需要的 name
@interface NMBFLogNameManager : NSObject

/// 获取当前所有 logName，key 为 logName 名，value 为 name 的 enabled 状态，可通过 value.boolValue 读取它的值
@property(nullable, nonatomic, copy, readonly) NSDictionary<NSString *, NSNumber *> *allNames;
- (BOOL)containsLogName:(nullable NSString *)logName;
- (void)setEnabled:(BOOL)enabled forLogName:(nullable NSString *)logName;
- (BOOL)enabledForLogName:(nullable NSString *)logName;
- (void)removeLogName:(nullable NSString *)logName;
- (void)removeAllNames;
@end

NS_ASSUME_NONNULL_END
