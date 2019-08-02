//
//  HOPreciseTimer.h
//  NemoKit
//
//  Created by Hunt on 2019/8/2.
//  Copyright © 2019 WengHengcong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HOPreciseTimer : NSObject {
    double timebase_ratio;
    
    NSMutableArray *events;
    NSCondition *condition;
    pthread_t thread;
}

+ (void)scheduleAction:(SEL)action target:(id)target inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)scheduleAction:(SEL)action target:(id)target context:(id)context inTimeInterval:(NSTimeInterval)timeInterval;
+ (void)cancelAction:(SEL)action target:(id)target;
+ (void)cancelAction:(SEL)action target:(id)target context:(id)context;


#if NS_BLOCKS_AVAILABLE
+ (void)scheduleBlock:(void (^)(void))block inTimeInterval:(NSTimeInterval)timeInterval;
#endif

@end

NS_ASSUME_NONNULL_END
