//
//  NSDate+NMBF.h
//  AFNetworking
//
//  Created by Hunt on 2020/5/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



/*
 * time zero https://www.timeanddate.com/time/zones/
 */
@interface NSDate (NMBF)


-(NSString *)getNSDateDay;
-(NSString *)getNSDateTime;
-(NSString *)getNSDate;

/**
 *  从字符串构造日期；格式为：yyyy-MM-dd HH:mm
 */
+ (NSDate*)DateFromString:(NSString *)string;


///-----------------------------------------
/// @name Calculating Beginning / End of Day
///-----------------------------------------

/**
 Returns a new date with first second of the day of the receiver.
 */
- (NSDate *)beginningOfDay;

/**
 Returns a new date with the last second of the day of the receiver.
 */
- (NSDate *)endOfDay;

///------------------------------------------
/// @name Calculating Beginning / End of Week
///------------------------------------------

/**
 Returns a new date with first second of the first weekday of the receiver, taking into account the current calendar's `firstWeekday` property.
 */
- (NSDate *)beginningOfWeek;

/**
 Returns a new date with last second of the last weekday of the receiver, taking into account the current calendar's `firstWeekday` property.
 */
- (NSDate *)endOfWeek;

///-------------------------------------------
/// @name Calculating Beginning / End of Month
///-------------------------------------------

/**
 Returns a new date with the first second of the first day of the month of the receiver.
 */
- (NSDate *)beginningOfMonth;

/**
 Returns a new date with the last second of the last day of the month of the receiver.
 */
- (NSDate *)endOfMonth;

///------------------------------------------
/// @name Calculating Beginning / End of Year
///------------------------------------------

/**
 Returns a new date with the first second of the first day of the year of the receiver.
 */
- (NSDate *)beginningOfYear;

/**
 Returns a new date with the last second of the last day of the year of the receiver.
 */
- (NSDate *)endOfYear;


/**
 *  判断当前时间是否在某一天
 */
- (BOOL)isInDate:(NSDate *)date;


@end

NS_ASSUME_NONNULL_END
