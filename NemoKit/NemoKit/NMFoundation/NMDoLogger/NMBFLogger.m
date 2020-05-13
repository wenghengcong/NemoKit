//
//  NMBFLogger.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFLogger.h"

@implementation NMBFLogger

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NMBFLogger *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.logNameManager = [[NMBFLogNameManager alloc] init];
    }
    return self;
}

- (void)printLogWithFile:(const char *)file line:(int)line func:(const char *)func logItem:(NMBFLogItem *)logItem {
    // 禁用了某个 name 则直接退出
    if (!logItem.enabled) return;
    
    NSString *fileString = [NSString stringWithFormat:@"%s", file];
    NSString *funcString = [NSString stringWithFormat:@"%s", func];
    NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
    
    if ([self.delegate respondsToSelector:@selector(printNMBFLogWithFile:line:func:logItem:defaultString:)]) {
        [self.delegate printNMBFLogWithFile:fileString line:line func:funcString logItem:logItem defaultString:defaultString];
    } else {
        //        // iOS 11 之前用替换方法的方式替换了 NSLog，所以这里就不能继续使用 NSLog 了
        //        if (IS_DEBUG && IOS_VERSION_NUMBER < 110000) {
        //            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
        //            puts([defaultString cStringUsingEncoding:enc]);
        //        } else {
        NSLog(@"%@", defaultString);
        //        }
    }
}

@end

