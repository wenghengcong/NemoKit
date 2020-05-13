//
//  NMDateToolsPeriodGroup.m
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMDateToolsPeriodGroup.h"
#import "NSDate+NMDateTools.h"

@implementation NMDateToolsPeriodGroup

-(id) init
{
    if (self = [super init]) {
        periods = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return periods[index];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index {
    periods[index] = obj;
}

#pragma mark - Group Info
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

/**
 *  Returns the NSDate representing the earliest date in the NMDateToolsPeriodGroup (or subclass)
 *
 *  @return NSDate
 */
-(NSDate *)StartDate{
    return StartDate;
}

/**
 *  Returns the NSDate representing the latest date in the NMDateToolsPeriodGroup (or subclass)
 *
 *  @return NSDate
 */
-(NSDate *)EndDate{
    return EndDate;
}

/**
 *  The total number of NMTimePeriods in the group
 *
 *  @return NSInteger
 */
-(NSInteger)count{
    return periods.count;
}

/**
 *  Returns a BOOL if the receiver and the comparison group have the same metadata (i.e. number of periods, start & end date, etc.)
 *  Returns YES if they share the same characteristics, otherwise NO
 *
 *  @param group The group to compare with the receiver
 *
 *  @return BOOL
 */
-(BOOL)hasSameCharacteristicsAs:(NMDateToolsPeriodGroup *)group{
    //Check characteristics first for speed
    if (group.count != self.count) {
        return NO;
    }
    else if (!group.StartDate && !group.EndDate && !self.StartDate && !self.EndDate){
        return YES;
    }
    else if (![group.StartDate isEqualToDate:self.StartDate] || ![group.EndDate isEqualToDate:self.EndDate]){
        return NO;
    }
    
    return YES;
}

#pragma mark - Chain Time Manipulation
/**
 *  Shifts all the time periods in the collection to an earlier date by the given size
 *
 *  @param size NMTimePeriodSize - The desired size of the shift
 */
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size{
    [self shiftEarlierWithSize:size amount:1];
}

/**
 *  Shifts all the time periods in the collection to an earlier date by the given size and amount.
 *  The amount acts as a multiplier to the size (i.e. "2 weeks" or "4 years")
 *
 *  @param size   NMTimePeriodSize - The desired size of the shift
 *  @param amount NSInteger - Multiplier for the size
 */
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount{
    if (periods) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((NMDateToolsTimePeriod *)obj) shiftEarlierWithSize:size amount:amount];
        }];
        
        [self updateVariables];
    }
}

/**
 *  Shifts all the time periods in the collection to a later date by the given size
 *
 *  @param size NMTimePeriodSize - The desired size of the shift
 */
-(void)shiftLaterWithSize:(NMTimePeriodSize)size{
    [self shiftLaterWithSize:size amount:1];
}

/**
 *  Shifts all the time periods in the collection to an later date by the given size and amount.
 *  The amount acts as a multiplier to the size (i.e. "2 weeks" or "4 years")
 *
 *  @param size   NMTimePeriodSize - The desired size of the shift
 *  @param amount NSInteger - Multiplier for the size
 */
-(void)shiftLaterWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount{
    if (periods) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [((NMDateToolsTimePeriod *)obj) shiftLaterWithSize:size amount:amount];
        }];
        
        [self updateVariables];
    }
}

#pragma mark - Updates
-(void)updateVariables{}
@end
