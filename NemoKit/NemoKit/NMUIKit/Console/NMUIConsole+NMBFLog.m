//
//  NMUIConsole+NMBFLog.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIConsole+NMBFLog.h"
#import "NMUIConsole.h"
#import "NMBCore.h"
#import "NMBFLogger.h"

@implementation NMBFLogger (NMUIConsole)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([NMBFLogger class], @selector(printLogWithFile:line:func:logItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(NMBFLogger *selfObject, const char *file, int line, const char *func, NMBFLogItem *logItem) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, const char *, int, const char *, NMBFLogItem *);
                originSelectorIMP = (void (*)(id, SEL, const char *, int, const char *, NMBFLogItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, file, line, func, logItem);
                
                if (!NMUICMIActivated || !ShouldPrintNMUIWarnLogToConsole) return;
                if (!logItem.enabled) return;
                if (logItem.level != NMBFLogLevelWarn) return;
                
                NSString *funcString = [NSString stringWithFormat:@"%s", func];
                NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
                [NMUIConsole logWithLevel:logItem.levelDisplayString name:logItem.name logString:defaultString];
            };
        });
    });
}

@end
