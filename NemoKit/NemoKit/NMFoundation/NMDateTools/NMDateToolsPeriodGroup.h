//
//  NMDateToolsPeriodGroup.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMDateToolsTimePeriod.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMDateToolsPeriodGroup : NSObject {
@protected
    NSMutableArray *periods;
    NSDate *StartDate;
    NSDate *EndDate;
}

@property (nonatomic, readonly) NSDate *StartDate;
@property (nonatomic, readonly) NSDate *EndDate;

//Here we will use object subscripting to help create the illusion of an array
- (id)objectAtIndexedSubscript:(NSUInteger)index; //getter
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)index; //setter

#pragma mark - Group Info
-(double)durationInYears;
-(double)durationInWeeks;
-(double)durationInDays;
-(double)durationInHours;
-(double)durationInMinutes;
-(double)durationInSeconds;
-(NSDate *)StartDate;
-(NSDate *)EndDate;
-(NSInteger)count;

#pragma mark - Chain Time Manipulation
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size;
-(void)shiftEarlierWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount;
-(void)shiftLaterWithSize:(NMTimePeriodSize)size;
-(void)shiftLaterWithSize:(NMTimePeriodSize)size amount:(NSInteger)amount;

#pragma mark - Comparison
-(BOOL)hasSameCharacteristicsAs:(NMDateToolsPeriodGroup *)group;

#pragma mark - Updates
-(void)updateVariables;

@end

NS_ASSUME_NONNULL_END
