//
//  NMBFLogItem.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFLogItem.h"
#import "NMBFLogNameManager.h"
#import "NMBFLogger.h"

@implementation NMBFLogItem

+ (instancetype)logItemWithLevel:(NMBFLogLevel)level name:(NSString *)name logString:(NSString *)logString, ... {
    NMBFLogItem *logItem = [[NMBFLogItem alloc] init];
    logItem.level = level;
    logItem.name = name;
    
    NMBFLogNameManager *logNameManager = [NMBFLogger sharedInstance].logNameManager;
    if ([logNameManager containsLogName:name]) {
        logItem.enabled = [logNameManager enabledForLogName:name];
    } else {
        [logNameManager setEnabled:YES forLogName:name];
        logItem.enabled = YES;
    }
    
    va_list args;
    va_start(args, logString);
    logItem.logString = [[NSString alloc] initWithFormat:logString arguments:args];
    va_end(args);
    
    return logItem;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (NSString *)levelDisplayString {
    switch (self.level) {
        case NMBFLogLevelInfo:
            return @"NMBFLogLevelInfo";
        case NMBFLogLevelWarn:
            return @"NMBFLogLevelWarn";
        default:
            return @"NMBFLogLevelDefault";
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ | %@ | %@", self.levelDisplayString, self.name.length > 0 ? self.name : @"Default", self.logString];
}
@end
