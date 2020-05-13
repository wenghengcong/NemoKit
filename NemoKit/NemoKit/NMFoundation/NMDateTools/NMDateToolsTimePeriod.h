//
//  NMDateToolsTimePeriod.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, NMTimePeriodRelation){
    NMTimePeriodRelationAfter,
    NMTimePeriodRelationStartTouching,
    NMTimePeriodRelationStartInside,
    NMTimePeriodRelationInsideStartTouching,
    NMTimePeriodRelationEnclosingStartTouching,
    NMTimePeriodRelationEnclosing,
    NMTimePeriodRelationEnclosingEndTouching,
    NMTimePeriodRelationExactMatch,
    NMTimePeriodRelationInside,
    NMTimePeriodRelationInsideEndTouching,
    NMTimePeriodRelationEndInside,
    NMTimePeriodRelationEndTouching,
    NMTimePeriodRelationBefore,
    NMTimePeriodRelationNone //One or more of the dates does not exist
};

typedef NS_ENUM(NSUInteger, NMTimePeriodSize) {
    NMTimePeriodSizeSecond,
    NMTimePeriodSizeMinute,
    NMTimePeriodSizeHour,
    NMTimePeriodSizeDay,
    NMTimePeriodSizeWeek,
    NMTimePeriodSizeMonth,
    NMTimePeriodSizeYear
};

typedef NS_ENUM(NSUInteger, NMTimePeriodInterval) {
    NMTimePeriodIntervalOpen,
    NMTimePeriodIntervalClosed
};

typedef NS_ENUM(NSUInteger, NMTimePeriodAnchor) {
    NMTimePeriodAnchorStart,
    NMTimePeriodAnchorCenter,
    NMTimePeriodAnchorEnd
};

NS_ASSUME_NONNULL_BEGIN

@interface NMDateToolsTimePeriod : NSObject


/**
 *  The start date for a NMDateToolsTimePeriod representing the starting boundary of the time period
 */
@property (nonatomic,strong) NSDate *StartDate;

/**
 *  The end date for a NMDateToolsTimePeriod representing the ending boundary of the time period
 */
@property (nonatomic,strong) NSDate *EndDate;

#pragma mark - Custom Init / Factory Methods
-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+(instancetype)timePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size startingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount startingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size endingAt:(NSDate *)date;
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount endingAt:(NSDate *)date;
+(instancetype)timePeriodWithAllTime;

#pragma mark - Time Period Information
-(BOOL)hasStartDate;
-(BOOL)hasEndDate;
-(BOOL)isMoment;
-(double)durationInYears;
-(double)durationInWeeks;
-(double)durationInDays;
-(double)durationInHours;
-(double)durationInMinutes;
-(double)durationInSeconds;

#pragma mark - Time Period Relationship
-(BOOL)isEqualToPeriod:(NMDateToolsTimePeriod *)period;
-(BOOL)isInside:(NMDateToolsTimePeriod *)period;
-(BOOL)contains:(NMDateToolsTimePeriod *)period;
-(BOOL)overlapsWith:(NMDateToolsTimePeriod *)period;
-(BOOL)intersects:(NMDateToolsTimePeriod *)period;
-(NMTimePeriodRelation)relationToPeriod:(NMDateToolsTimePeriod *)period;
-(NSTimeInterval)gapBetween:(NMDateToolsTimePeriod *)period;

#pragma mark - Date Relationships
-(BOOL)containsDate:(NSDate *)date interval:(NMTimePeriodInterval)interval;

#pragma mark - Period Manipulation
#pragma mark Shifts
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size;
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount;
-(void)shiftLaterWithSize:(NMTimePeriodSize)size;
-(void)shiftLaterWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark Lengthen / Shorten
-(void)lengthenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size;
-(void)lengthenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size amount:(NSInteger)amount;
-(void)shortenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size;
-(void)shortenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark - Helper Methods
-(NMDateToolsTimePeriod *)copy;

@end

NS_ASSUME_NONNULL_END
