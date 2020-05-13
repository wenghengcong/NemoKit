//
//  NSDate+NMDateTools.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NMDateToolsConstants.h"

#ifndef DateToolsLocalizedStrings
#define DateToolsLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"DateTools", [NSBundle bundleWithPath:[[[NSBundle bundleForClass:[NMDateToolsError class]] resourcePath] stringByAppendingPathComponent:@"NMDateTools.bundle"]], nil)
#endif


@interface NSDate (NMDateTools)

#pragma mark - Time Ago
+ (NSString*)timeAgoSinceDate:(NSDate*)date;
+ (NSString*)shortTimeAgoSinceDate:(NSDate*)date;
+ (NSString *)weekTimeAgoSinceDate:(NSDate *)date;

- (NSString*)timeAgoSinceNow;
- (NSString *)shortTimeAgoSinceNow;
- (NSString *)weekTimeAgoSinceNow;

- (NSString *)timeAgoSinceDate:(NSDate *)date;
- (NSString *)timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates;
- (NSString *)timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates numericTimes:(BOOL)useNumericTimes;


- (NSString *)shortTimeAgoSinceDate:(NSDate *)date;
- (NSString *)weekTimeAgoSinceDate:(NSDate *)date;


#pragma mark - Date Components Without Calendar
- (NSInteger)era;
- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)second;
- (NSInteger)weekday;
- (NSInteger)weekdayOrdinal;
- (NSInteger)quarter;
- (NSInteger)weekOfMonth;
- (NSInteger)weekOfYear;
- (NSInteger)yearForWeekOfYear;
- (NSInteger)daysInMonth;
- (NSInteger)dayOfYear;
-(NSInteger)daysInYear;
-(BOOL)isInLeapYear;
- (BOOL)isToday;
- (BOOL)isTomorrow;
-(BOOL)isYesterday;
- (BOOL)isWeekend;
-(BOOL)isSameDay:(NSDate *)date;
+ (BOOL)isSameDay:(NSDate *)date asDate:(NSDate *)compareDate;

#pragma mark - Date Components With Calendar


- (NSInteger)eraWithCalendar:(NSCalendar *)calendar;
- (NSInteger)yearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)monthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)dayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)hourWithCalendar:(NSCalendar *)calendar;
- (NSInteger)minuteWithCalendar:(NSCalendar *)calendar;
- (NSInteger)secondWithCalendar:(NSCalendar *)calendar;
- (NSInteger)weekdayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)weekdayOrdinalWithCalendar:(NSCalendar *)calendar;
- (NSInteger)quarterWithCalendar:(NSCalendar *)calendar;
- (NSInteger)weekOfMonthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)weekOfYearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)yearForWeekOfYearWithCalendar:(NSCalendar *)calendar;


#pragma mark - Date Creating
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDate *)dateWithString:(NSString *)dateString formatString:(NSString *)formatString;
+ (NSDate *)dateWithString:(NSString *)dateString formatString:(NSString *)formatString timeZone:(NSTimeZone *)timeZone;


#pragma mark - Date Editing
#pragma mark Date By Adding
- (NSDate *)dateByAddingYears:(NSInteger)years;
- (NSDate *)dateByAddingMonths:(NSInteger)months;
- (NSDate *)dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)dateByAddingDays:(NSInteger)days;
- (NSDate *)dateByAddingHours:(NSInteger)hours;
- (NSDate *)dateByAddingMinutes:(NSInteger)minutes;
- (NSDate *)dateByAddingSeconds:(NSInteger)seconds;
#pragma mark Date By Subtracting
- (NSDate *)dateBySubtractingYears:(NSInteger)years;
- (NSDate *)dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)dateBySubtractingWeeks:(NSInteger)weeks;
- (NSDate *)dateBySubtractingDays:(NSInteger)days;
- (NSDate *)dateBySubtractingHours:(NSInteger)hours;
- (NSDate *)dateBySubtractingMinutes:(NSInteger)minutes;
- (NSDate *)dateBySubtractingSeconds:(NSInteger)seconds;

#pragma mark - Date Comparison
#pragma mark Time From
-(NSInteger)yearsFrom:(NSDate *)date;
-(NSInteger)monthsFrom:(NSDate *)date;
-(NSInteger)weeksFrom:(NSDate *)date;
-(NSInteger)daysFrom:(NSDate *)date;
-(double)hoursFrom:(NSDate *)date;
-(double)minutesFrom:(NSDate *)date;
-(double)secondsFrom:(NSDate *)date;
#pragma mark Time From With Calendar
-(NSInteger)yearsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)monthsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)weeksFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)daysFrom:(NSDate *)date calendar:(NSCalendar *)calendar;

#pragma mark Time Until
-(NSInteger)yearsUntil;
-(NSInteger)monthsUntil;
-(NSInteger)weeksUntil;
-(NSInteger)daysUntil;
-(double)hoursUntil;
-(double)minutesUntil;
-(double)secondsUntil;
#pragma mark Time Ago
-(NSInteger)yearsAgo;
-(NSInteger)monthsAgo;
-(NSInteger)weeksAgo;
-(NSInteger)daysAgo;
-(double)hoursAgo;
-(double)minutesAgo;
-(double)secondsAgo;
#pragma mark Earlier Than
-(NSInteger)yearsEarlierThan:(NSDate *)date;
-(NSInteger)monthsEarlierThan:(NSDate *)date;
-(NSInteger)weeksEarlierThan:(NSDate *)date;
-(NSInteger)daysEarlierThan:(NSDate *)date;
-(double)hoursEarlierThan:(NSDate *)date;
-(double)minutesEarlierThan:(NSDate *)date;
-(double)secondsEarlierThan:(NSDate *)date;
#pragma mark Later Than
-(NSInteger)yearsLaterThan:(NSDate *)date;
-(NSInteger)monthsLaterThan:(NSDate *)date;
-(NSInteger)weeksLaterThan:(NSDate *)date;
-(NSInteger)daysLaterThan:(NSDate *)date;
-(double)hoursLaterThan:(NSDate *)date;
-(double)minutesLaterThan:(NSDate *)date;
-(double)secondsLaterThan:(NSDate *)date;
#pragma mark Comparators
-(BOOL)isEarlierThan:(NSDate *)date;
-(BOOL)isLaterThan:(NSDate *)date;
-(BOOL)isEarlierThanOrEqualTo:(NSDate *)date;
-(BOOL)isLaterThanOrEqualTo:(NSDate *)date;

#pragma mark - Formatted Dates
#pragma mark Formatted With Style
-(NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style;
-(NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone;
-(NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style locale:(NSLocale *)locale;
-(NSString *)formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;
#pragma mark Formatted With Format
-(NSString *)formattedDateWithFormat:(NSString *)format;
-(NSString *)formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;
-(NSString *)formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale;
-(NSString *)formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;

#pragma mark - Helpers
+(NSString *)defaultCalendarIdentifier;
+ (void)setDefaultCalendarIdentifier:(NSString *)identifier;

@end

