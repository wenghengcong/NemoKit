//
//  NMCoreTimeMacro.h
//  Pods
//
//  Created by Hunt on 2020/7/2.
//

#import "NMCoreMacro.h"
#import <sys/time.h>

#ifndef NMCoreTimeMacro_h
#define NMCoreTimeMacro_h

NM_EXTERN_C_BEGIN

/**
 Profile time cost.
 @param block    code to benchmark
 @param complete code time cost (millisecond)
 
 Usage:
    NMBenchmark(^{
        // code
    }, ^(double ms) {
        NSLog("time cost: %.2f ms",ms);
    });
 
 */
static inline void NMBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
    extern double CACurrentMediaTime (void);
    double begin, end, ms;
    begin = CACurrentMediaTime();
    block();
    end = CACurrentMediaTime();
    ms = (end - begin) * 1000.0;
    complete(ms);
    */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

static inline NSDate *_NMCompileTime(const char *data, const char *time) {
    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
    [formatter setLocale:locale];
    return [formatter dateFromString:timeStr];
}

/**
 Get compile timestamp.
 @return A new date object set to the compile date and time.
 */
#ifndef NMCompileTime
// use macro to avoid compile warning when use pch file
#define NMCompileTime() _NMCompileTime(__DATE__, __TIME__)
#endif

/*
 dispatch_time stops running when your computer goes to sleep. 相对时间
 dispatch_walltime continues running.   绝对时间
 So if you want to do an action in one hour minutes, but after 5 minutes your computer goes to sleep for 50 minutes, dispatch_walltime will execute an hour from now, 5 minutes after the computer wakes up. dispatch_time will execute after the computer is running for an hour, that is 55 minutes after it wakes up.
 
 */
/**
 Returns a dispatch_time delay from now.
 */
static inline dispatch_time_t dispatch_time_delay(NSTimeInterval second) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 Returns a dispatch_wall_time delay from now.
 */
static inline dispatch_time_t dispatch_walltime_delay(NSTimeInterval second) {
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/**
 Returns a dispatch_wall_time from NSDate.
 */
static inline dispatch_time_t dispatch_walltime_date(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    
    interval = [date timeIntervalSince1970];
    /*
     Breaks x into an integral and a fractional part.
     The integer part is stored in the object pointed by intpart, and the fractional part is returned by the function.
     Both parts have the same sign as x.
     */
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}


NM_EXTERN_C_END
#endif /* NMCoreTimeMacro_h */
