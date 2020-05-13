//
//  NMBFLogger+NMUIConfigurationTemplate.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFLogger+NMUIConfigurationTemplate.h"
#import "NMBCore.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NMBFLogger (NMUIConfigurationTemplate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([NMBFLogger class], @selector(printLogWithFile:line:func:logItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(NMBFLogger *selfObject, const char *file, int line, const char *func, NMBFLogItem *logItem) {
                // 不同级别的 log 可通过配置表的开关来控制是否要输出
                if (logItem.level == NMBFLogLevelDefault && !ShouldPrintDefaultLog) return;
                if (logItem.level == NMBFLogLevelInfo && !ShouldPrintInfoLog) return;
                if (logItem.level == NMBFLogLevelWarn && !ShouldPrintWarnLog) return;
                
                // call super
                void (*originSelectorIMP)(id, SEL, const char *, int, const char *, NMBFLogItem *);
                originSelectorIMP = (void (*)(id, SEL, const char *, int, const char *, NMBFLogItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, file, line, func, logItem);
            };
        });
    });
}

@end

NS_ASSUME_NONNULL_END
