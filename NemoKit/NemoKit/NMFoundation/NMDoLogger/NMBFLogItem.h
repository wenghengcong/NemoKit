//
//  NMBFLogItem.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NMBFLogLevel) {
    NMBFLogLevelDefault,    // 当使用 NMBFLog() 时使用的等级
    NMBFLogLevelInfo,       // 当使用 NMBFLogInfo() 时使用的等级，比 NMBFLogLevelDefault 要轻量，适用于一些无关紧要的信息
    NMBFLogLevelWarn        // 当使用 NMBFLogWarn() 时使用的等级，最重，适用于一些异常或者严重错误的场景
};

/// 每一条 NMBFLog 日志都以 NMBFLogItem 的形式包装起来
@interface NMBFLogItem : NSObject

/// 日志的等级，可通过 NMBFConfigurationTemplate 配置表控制全局每个 level 是否可用
@property(nonatomic, assign) NMBFLogLevel level;
@property(nonatomic, copy, readonly) NSString *levelDisplayString;

/// 可利用 name 字段为日志分类，NMBFLogNameManager 可全局控制某一个 name 是否可用
@property(nullable, nonatomic, copy) NSString *name;

/// 日志的内容
@property(nonatomic, copy) NSString *logString;

/// 当前 logItem 对应的 name 是否可用，可通过 NMBFLogNameManager 控制，默认为 YES
@property(nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)logItemWithLevel:(NMBFLogLevel)level name:(nullable NSString *)name logString:(nonnull NSString *)logString, ... NS_FORMAT_FUNCTION(3, 4);
@end


NS_ASSUME_NONNULL_END
