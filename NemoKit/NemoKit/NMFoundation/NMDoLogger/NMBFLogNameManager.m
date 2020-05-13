//
//  NMBFLogNameManager.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFLogNameManager.h"
#import "NMBFLogger.h"

NSString *const NMBFLoggerAllNamesKeyInUserDefaults = @"NMBFLoggerAllNamesKeyInUserDefaults";

@interface NMBFLogNameManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *mutableAllNames;
@property(nonatomic, assign) BOOL didInitialize;
@end

@implementation NMBFLogNameManager

- (instancetype)init {
    if (self = [super init]) {
        self.mutableAllNames = [[NSMutableDictionary alloc] init];
        
        NSDictionary<NSString *, NSNumber *> *allNMBFLogNames = [[NSUserDefaults standardUserDefaults] dictionaryForKey:NMBFLoggerAllNamesKeyInUserDefaults];
        for (NSString *logName in allNMBFLogNames) {
            [self setEnabled:allNMBFLogNames[logName].boolValue forLogName:logName];
        }
        
        // 初始化时从 NSUserDefaults 里获取值的过程，不希望触发 delegate，所以加这个标志位
        self.didInitialize = YES;
    }
    return self;
}

- (NSDictionary<NSString *,NSNumber *> *)allNames {
    if (self.mutableAllNames.count) {
        return [self.mutableAllNames copy];
    }
    return nil;
}

- (BOOL)containsLogName:(NSString *)logName {
    if (logName.length > 0) {
        return !!self.mutableAllNames[logName];
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled forLogName:(NSString *)logName {
    if (logName.length > 0) {
        self.mutableAllNames[logName] = @(enabled);
        
        if (!self.didInitialize) return;
        
        [self synchronizeUserDefaults];
        
        if ([[NMBFLogger sharedInstance].delegate respondsToSelector:@selector(NMBFLogName:didChangeEnabled:)]) {
            [[NMBFLogger sharedInstance].delegate NMBFLogName:logName didChangeEnabled:enabled];
        }
    }
}

- (BOOL)enabledForLogName:(NSString *)logName {
    if (logName.length > 0) {
        if ([self containsLogName:logName]) {
            return [self.mutableAllNames[logName] boolValue];
        }
    }
    return YES;
}

- (void)removeLogName:(NSString *)logName {
    if (logName.length > 0) {
        [self.mutableAllNames removeObjectForKey:logName];
        
        if (!self.didInitialize) return;
        
        [self synchronizeUserDefaults];
        
        if ([[NMBFLogger sharedInstance].delegate respondsToSelector:@selector(NMBFLogNameDidRemove:)]) {
            [[NMBFLogger sharedInstance].delegate NMBFLogNameDidRemove:logName];
        }
    }
}

- (void)removeAllNames {
    BOOL shouldCallDelegate = self.didInitialize && [[NMBFLogger sharedInstance].delegate respondsToSelector:@selector(NMBFLogNameDidRemove:)];
    NSDictionary<NSString *, NSNumber *> *allNames = nil;
    if (shouldCallDelegate) {
        allNames = self.allNames;
    }
    
    [self.mutableAllNames removeAllObjects];
    
    [self synchronizeUserDefaults];
    
    if (shouldCallDelegate) {
        for (NSString *logName in allNames.allKeys) {
            [[NMBFLogger sharedInstance].delegate NMBFLogNameDidRemove:logName];
        }
    }
}

- (void)synchronizeUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.allNames forKey:NMBFLoggerAllNamesKeyInUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
