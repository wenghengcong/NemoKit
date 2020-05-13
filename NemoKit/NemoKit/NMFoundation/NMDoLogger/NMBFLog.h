//
//  NMBFLog.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBFLog_h
#define NMBFLog_h

#import "NMBFLogger.h"

/// 以下是 NMBF 提供的用于代替 NSLog() 的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log。

#define NMBFLog(_name, ...) [[NMBFLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[NMBFLogItem logItemWithLevel:NMBFLogLevelDefault name:_name logString:__VA_ARGS__]]
#define NMBFLogInfo(_name, ...) [[NMBFLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[NMBFLogItem logItemWithLevel:NMBFLogLevelInfo name:_name logString:__VA_ARGS__]]
#define NMBFLogWarn(_name, ...) [[NMBFLogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[NMBFLogItem logItemWithLevel:NMBFLogLevelWarn name:_name logString:__VA_ARGS__]]

//#ifdef DEBUG
//
//// iOS 11 之前用真正的方法替换去实现拦截 NSLog 的功能，iOS 11 之后这种方法失效了，所以只能用宏定义的方式覆盖 NSLog。这也就意味着在 iOS 11 下一些如果某些代码编译时机比 NMBF 早，则这些代码里的 NSLog 是无法被替换为 NMBFLog 的
//extern void _NSSetLogCStringFunction(void (*)(const char *string, unsigned length, BOOL withSyslogBanner));
//static void PrintNSLogMessage(const char *string, unsigned length, BOOL withSyslogBanner) {
//    NMBFLog(@"NSLog", @"%s", string);
//}
//
//static void HackNSLog(void) __attribute__((constructor));
//static void HackNSLog(void) {
//    _NSSetLogCStringFunction(PrintNSLogMessage);
//}
//
//#define NSLog(...) NMBFLog(@"NSLog", __VA_ARGS__)// iOS 11 以后真正生效的是这一句
//#endif

#endif /* NMBFLog_h */
