//
//  NMDateToolsTimePeriod.m
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMDateToolsTimePeriod.h"
#import "NMDateToolsError.h"
#import "NSDate+NMDateTools.h"

@implementation NMDateToolsTimePeriod

#pragma mark - Custom Init / Factory Methods
/**
 *  Initializes an instance of NMDateToolsTimePeriod from a given start and end date
 *
 *  @param startDate NSDate - Desired start date
 *  @param endDate   NSDate - Desired end date
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
-(instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if (self = [super init]) {
        self.StartDate = startDate;
        self.EndDate = endDate;
    }
    
    return self;
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod from a given start and end date
 *
 *  @param startDate NSDate - Desired start date
 *  @param endDate   NSDate - Desired end date
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    return [[self.class alloc] initWithStartDate:startDate endDate:endDate];
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod that starts on the provided start date
 *  and is of the size provided
 *
 *  @param size NMTimePeriodSize - Desired size of the new time period
 *  @param date NSDate - Desired start date of the new time period
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size startingAt:(NSDate *)date{
    return [[self.class alloc] initWithStartDate:date endDate:[NMDateToolsTimePeriod dateWithAddedTime:size amount:1 baseDate:date]];
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod that starts on the provided start date
 *  and is of the size provided. The amount represents a multipler to the size (e.g. "2 weeks" or "4 years")
 *
 *  @param size NMTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date NSDate - Desired start date of the new time period
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount startingAt:(NSDate *)date{
    return [[self.class alloc] initWithStartDate:date endDate:[NMDateToolsTimePeriod dateWithAddedTime:size amount:amount baseDate:date]];
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod that ends on the provided end date
 *  and is of the size provided
 *
 *  @param size NMTimePeriodSize - Desired size of the new time period
 *  @param date NSDate - Desired end date of the new time period
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size endingAt:(NSDate *)date{
    return [[self.class alloc] initWithStartDate:[NMDateToolsTimePeriod dateWithSubtractedTime:size amount:1 baseDate:date] endDate:date];
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod that ends on the provided end date
 *  and is of the size provided. The amount represents a multipler to the size (e.g. "2 weeks" or "4 years")
 *
 *  @param size   NMTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount endingAt:(NSDate *)date{
    return [[self.class alloc] initWithStartDate:[NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount baseDate:date] endDate:date];
}

/**
 *  Returns a new instance of NMDateToolsTimePeriod that represents the largest time period available.
 *  The start date is in the distant past and the end date is in the distant future.
 *
 *  @return NMDateToolsTimePeriod - new instance
 */
+(instancetype)timePeriodWithAllTime{
    return [[self.class alloc] initWithStartDate:[NSDate distantPast] endDate:[NSDate distantFuture]];
}

/**
 *  Method serving the various factory methods as well as a few others.
 *  Returns a date with time added to a given base date. Includes multiplier amount.
 *
 *  @param size   NMTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return NSDate - new instance
 */
+(NSDate *)dateWithAddedTime:(NMTimePeriodSize)size amount:(NSInteger)amount baseDate:(NSDate *)date{
    switch (size) {
        case NMTimePeriodSizeSecond:
            return [date dateByAddingSeconds:amount];
            break;
        case NMTimePeriodSizeMinute:
            return [date dateByAddingMinutes:amount];
            break;
        case NMTimePeriodSizeHour:
            return [date dateByAddingHours:amount];
            break;
        case NMTimePeriodSizeDay:
            return [date dateByAddingDays:amount];
            break;
        case NMTimePeriodSizeWeek:
            return [date dateByAddingWeeks:amount];
            break;
        case NMTimePeriodSizeMonth:
            return [date dateByAddingMonths:amount];
            break;
        case NMTimePeriodSizeYear:
            return [date dateByAddingYears:amount];
            break;
        default:
            break;
    }
    
    return date;
}

/**
 *  Method serving the various factory methods as well as a few others.
 *  Returns a date with time subtracted from a given base date. Includes multiplier amount.
 *
 *  @param size   NMTimePeriodSize - Desired size of the new time period
 *  @param amount NSInteger - Desired multiplier of the size provided
 *  @param date   NSDate - Desired end date of the new time period
 *
 *  @return NSDate - new instance
 */
+(NSDate *)dateWithSubtractedTime:(NMTimePeriodSize)size amount:(NSInteger)amount baseDate:(NSDate *)date{
    switch (size) {
        case NMTimePeriodSizeSecond:
            return [date dateBySubtractingSeconds:amount];
            break;
        case NMTimePeriodSizeMinute:
            return [date dateBySubtractingMinutes:amount];
            break;
        case NMTimePeriodSizeHour:
            return [date dateBySubtractingHours:amount];
            break;
        case NMTimePeriodSizeDay:
            return [date dateBySubtractingDays:amount];
            break;
        case NMTimePeriodSizeWeek:
            return [date dateBySubtractingWeeks:amount];
            break;
        case NMTimePeriodSizeMonth:
            return [date dateBySubtractingMonths:amount];
            break;
        case NMTimePeriodSizeYear:
            return [date dateBySubtractingYears:amount];
            break;
        default:
            break;
    }
    
    return date;
}

#pragma mark - Time Period Information
/**
 *  Returns a boolean representing whether the receiver's StartDate exists
 *  Returns YES if StartDate is not nil, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)hasStartDate {
    return (self.StartDate)? YES:NO;
}

/**
 *  Returns a boolean representing whether the receiver's EndDate exists
 *  Returns YES if EndDate is not nil, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)hasEndDate {
    return (self.EndDate)? YES:NO;
}

/**
 *  Returns a boolean representing whether the receiver is a "moment", that is the start and end dates are the same.
 *  Returns YES if receiver is a moment, otherwise NO
 *
 *  @return BOOL
 */
-(BOOL)isMoment{
    if (self.StartDate && self.EndDate) {
        if ([self.StartDate isEqualToDate:self.EndDate]) {
            return YES;
        }
    }
    
    return NO;
}

/**
 *  Returns the duration of the receiver in years
 *
 *  @return NSInteger
 */
-(double)durationInYears {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate yearsEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in weeks
 *
 *  @return double
 */
-(double)durationInWeeks {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate weeksEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in days
 *
 *  @return double
 */
-(double)durationInDays {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate daysEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in hours
 *
 *  @return double
 */
-(double)durationInHours {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate hoursEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in minutes
 *
 *  @return double
 */
-(double)durationInMinutes {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate minutesEarlierThan:self.EndDate];
    }
    
    return 0;
}

/**
 *  Returns the duration of the receiver in seconds
 *
 *  @return double
 */
-(double)durationInSeconds {
    if (self.StartDate && self.EndDate) {
        return [self.StartDate secondsEarlierThan:self.EndDate];
    }
    
    return 0;
}

#pragma mark - Time Period Relationship
/**
 *  Returns a BOOL representing whether the receiver's start and end dates exatcly match a given time period
 *  Returns YES if the two periods are the same, otherwise NO
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)isEqualToPeriod:(NMDateToolsTimePeriod *)period{
    if ([self.StartDate isEqualToDate:period.StartDate] && [self.EndDate isEqualToDate:period.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver's start and end dates exatcly match a given time period or is contained within them
 *  Returns YES if the receiver is inside the given time period, otherwise NO
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)isInside:(NMDateToolsTimePeriod *)period{
    if ([period.StartDate isEarlierThanOrEqualTo:self.StartDate] && [period.EndDate isLaterThanOrEqualTo:self.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the given time period's start and end dates exatcly match the receivers' or is contained within them
 *  Returns YES if the receiver is inside the given time period, otherwise NO
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)contains:(NMDateToolsTimePeriod *)period{
    if ([self.StartDate isEarlierThanOrEqualTo:period.StartDate] && [self.EndDate isLaterThanOrEqualTo:period.EndDate]) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver and the given time period overlap.
 *  This covers all space they share, minus instantaneous space (i.e. one's start date equals another's end date)
 *  Returns YES if they overlap, otherwise NO
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)overlapsWith:(NMDateToolsTimePeriod *)period{
    //Outside -> Inside
    if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThan:self.StartDate]) {
        return YES;
    }
    //Enclosing
    else if ([period.StartDate isLaterThanOrEqualTo:self.StartDate] && [period.EndDate isEarlierThanOrEqualTo:self.EndDate]){
        return YES;
    }
    //Inside -> Out
    else if([period.StartDate isEarlierThan:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
        return YES;
    }
    return NO;
}

/**
 *  Returns a BOOL representing whether the receiver and the given time period overlap.
 *  This covers all space they share, including instantaneous space (i.e. one's start date equals another's end date)
 *  Returns YES if they overlap, otherwise NO
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return BOOL
 */
-(BOOL)intersects:(NMDateToolsTimePeriod *)period{
    //Outside -> Inside
    if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThanOrEqualTo:self.StartDate]) {
        return YES;
    }
    //Enclosing
    else if ([period.StartDate isLaterThanOrEqualTo:self.StartDate] && [period.EndDate isEarlierThanOrEqualTo:self.EndDate]){
        return YES;
    }
    //Inside -> Out
    else if([period.StartDate isEarlierThanOrEqualTo:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
        return YES;
    }
    return NO;
}

/**
 *  Returns the relationship of the receiver to a given time period
 *
 *  @param period NMDateToolsTimePeriod - Time period to compare to receiver
 *
 *  @return NMTimePeriodRelation
 */
-(NMTimePeriodRelation)relationToPeriod:(NMDateToolsTimePeriod *)period{
    
    //Make sure that all start and end points exist for comparison
    if (self.StartDate && self.EndDate && period.StartDate && period.EndDate) {
        //Make sure time periods are of positive durations
        if ([self.StartDate isEarlierThan:self.EndDate] && [period.StartDate isEarlierThan:period.EndDate]) {
            
            //Make comparisons
            if ([period.EndDate isEarlierThan:self.StartDate]) {
                return NMTimePeriodRelationAfter;
            }
            else if ([period.EndDate isEqualToDate:self.StartDate]){
                return NMTimePeriodRelationStartTouching;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return NMTimePeriodRelationStartInside;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isLaterThan:self.EndDate]){
                return NMTimePeriodRelationInsideStartTouching;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return NMTimePeriodRelationEnclosingStartTouching;
            }
            else if ([period.StartDate isLaterThan:self.StartDate] && [period.EndDate isEarlierThan:self.EndDate]){
                return NMTimePeriodRelationEnclosing;
            }
            else if ([period.StartDate isLaterThan:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return NMTimePeriodRelationEnclosingEndTouching;
            }
            else if ([period.StartDate isEqualToDate:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return NMTimePeriodRelationExactMatch;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isLaterThan:self.EndDate]){
                return NMTimePeriodRelationInside;
            }
            else if ([period.StartDate isEarlierThan:self.StartDate] && [period.EndDate isEqualToDate:self.EndDate]){
                return NMTimePeriodRelationInsideEndTouching;
            }
            else if ([period.StartDate isEarlierThan:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
                return NMTimePeriodRelationEndInside;
            }
            else if ([period.StartDate isEqualToDate:self.EndDate] && [period.EndDate isLaterThan:self.EndDate]){
                return NMTimePeriodRelationEndTouching;
            }
            else if ([period.StartDate isLaterThan:self.EndDate]){
                return NMTimePeriodRelationBefore;
            }
        }
    }
    
    return NMTimePeriodRelationNone;
}

/**
 *  Returns the gap in seconds between the receiver and provided time period
 *  Returns 0 if the time periods intersect, otherwise returns the gap between.
 *
 *  @param period period description
 *
 *  @return <#return value description#>
 */
-(NSTimeInterval)gapBetween:(NMDateToolsTimePeriod *)period{
    if ([self.EndDate isEarlierThan:period.StartDate]) {
        return ABS([self.EndDate timeIntervalSinceDate:period.StartDate]);
    }
    else if ([period.EndDate isEarlierThan:self.StartDate]){
        return ABS([period.EndDate timeIntervalSinceDate:self.StartDate]);
    }
    
    return 0;
}

#pragma mark - Date Relationships
/**
 *  Returns a BOOL representing whether the provided date is contained in the receiver.
 *
 *  @param date     NSDate - Date to evaluate
 *  @param interval NMTimePeriodInterval representing evaluation type (Closed includes StartDate and EndDate in evaluation, Open does not)
 *
 *  @return <#return value description#>
 */
-(BOOL)containsDate:(NSDate *)date interval:(NMTimePeriodInterval)interval{
    if (interval == NMTimePeriodIntervalOpen) {
        if ([self.StartDate isEarlierThan:date] && [self.EndDate isLaterThan:date]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else if (interval == NMTimePeriodIntervalClosed){
        if ([self.StartDate isEarlierThanOrEqualTo:date] && [self.EndDate isLaterThanOrEqualTo:date]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - Period Manipulation
/**
 *  Shifts the StartDate and EndDate earlier by a given size amount
 *
 *  @param size NMTimePeriodSize - Desired shift size
 */
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size{
    [self shiftEarlierWithSize:size amount:1];
}

/**
 *  Shifts the StartDate and EndDate earlier by a given size amount. Amount multiplies size.
 *
 *  @param size NMTimePeriodSize - Desired shift size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount{
    self.StartDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.StartDate];
    self.EndDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.EndDate];
}

/**
 *  Shifts the StartDate and EndDate later by a given size amount
 *
 *  @param size NMTimePeriodSize - Desired shift size
 */
-(void)shiftLaterWithSize:(NMTimePeriodSize)size{
    [self shiftLaterWithSize:size amount:1];
}

/**
 *  Shifts the StartDate and EndDate later by a given size amount. Amount multiplies size.
 *
 *  @param size NMTimePeriodSize - Desired shift size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shiftLaterWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount{
    self.StartDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount baseDate:self.StartDate];
    self.EndDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount baseDate:self.EndDate];
}

#pragma mark Lengthen / Shorten
/**
 *  Lengthens the receiver by a given amount, anchored by a provided point
 *
 *  @param anchor NMTimePeriodAnchor - Anchor point for the lengthen (the date that stays the same)
 *  @param size NMTimePeriodSize - Desired lenghtening size
 */
-(void)lengthenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size{
    [self lengthenWithAnchorDate:anchor size:size amount:1];
}
/**
 *  Lengthens the receiver by a given amount, anchored by a provided point. Amount multiplies size.
 *
 *  @param anchor NMTimePeriodAnchor - Anchor point for the lengthen (the date that stays the same)
 *  @param size   NMTimePeriodSize - Desired lenghtening size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)lengthenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size amount:(NSInteger)amount{
    switch (anchor) {
        case NMTimePeriodAnchorStart:
            self.EndDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount baseDate:self.EndDate];
            break;
        case NMTimePeriodAnchorCenter:
            self.StartDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount/2 baseDate:self.StartDate];
            self.EndDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount/2 baseDate:self.EndDate];
            break;
        case NMTimePeriodAnchorEnd:
            self.StartDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.StartDate];
            break;
        default:
            break;
    }
}

/**
 *  Shortens the receiver by a given amount, anchored by a provided point
 *
 *  @param anchor NMTimePeriodAnchor - Anchor point for the shorten (the date that stays the same)
 *  @param size NMTimePeriodSize - Desired shortening size
 */
-(void)shortenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size{
    [self shortenWithAnchorDate:anchor size:size amount:1];
}

/**
 *  Shortens the receiver by a given amount, anchored by a provided point. Amount multiplies size.
 *
 *  @param anchor NMTimePeriodAnchor - Anchor point for the shorten (the date that stays the same)
 *  @param size   NMTimePeriodSize - Desired shortening size
 *  @param amount NSInteger - Multiplier of size (i.e. "2 weeks" or "4 years")
 */
-(void)shortenWithAnchorDate:(NMTimePeriodAnchor)anchor size:(NMTimePeriodSize)size amount:(NSInteger)amount{
    switch (anchor) {
        case NMTimePeriodAnchorStart:
            self.EndDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount baseDate:self.EndDate];
            break;
        case NMTimePeriodAnchorCenter:
            self.StartDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount/2 baseDate:self.StartDate];
            self.EndDate = [NMDateToolsTimePeriod dateWithSubtractedTime:size amount:amount/2 baseDate:self.EndDate];
            break;
        case NMTimePeriodAnchorEnd:
            self.StartDate = [NMDateToolsTimePeriod dateWithAddedTime:size amount:amount baseDate:self.StartDate];
            break;
        default:
            break;
    }
}

#pragma mark - Helper Methods
-(NMDateToolsTimePeriod *)copy{
    NMDateToolsTimePeriod *period = [NMDateToolsTimePeriod timePeriodWithStartDate:[NSDate dateWithTimeIntervalSince1970:self.StartDate.timeIntervalSince1970] endDate:[NSDate dateWithTimeIntervalSince1970:self.EndDate.timeIntervalSince1970]];
    return period;
}
@end
