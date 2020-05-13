//
//  NMDateToolsCollection.m
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMDateToolsPeriodCollection.h"
#import "NMDateToolsError.h"
#import "NSDate+NMDateTools.h"

@implementation NMDateToolsPeriodCollection

#pragma mark - Custom Init / Factory Methods
/**
 *  Initializes a new instance of NMDateToolsPeriodCollection
 *
 *  @return NMDateToolsPeriodCollection
 */
+(NMDateToolsPeriodCollection *)collection{
    return [[NMDateToolsPeriodCollection alloc] init];
}

#pragma mark - Collection Manipulation
/**
 *  Adds a time period to the reciever.
 *
 *  @param period NMDateToolsTimePeriod - The time period to add to the collection
 */
-(void)addTimePeriod:(NMDateToolsTimePeriod *)period{
    if ([period isKindOfClass:[NMDateToolsTimePeriod class]]) {
        [periods addObject:period];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
    }
}

/**
 *  Inserts a time period to the receiver at a given index.
 *
 *  @param period NMDateToolsTimePeriod - The time period to insert into the collection
 *  @param index  NSInteger - The index in the collection the time period is to be added at
 */
-(void)insertTimePeriod:(NMDateToolsTimePeriod *)period atIndex:(NSInteger)index{
    if ([period class] != [NMDateToolsTimePeriod class]) {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
        return;
    }
    
    if (index >= 0 && index < periods.count) {
        [periods insertObject:period atIndex:index];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [NMDateToolsError throwInsertOutOfBoundsException:index array:periods];
    }
}

/**
 *  Removes the time period at a given index from the collection
 *
 *  @param index NSInteger - The index in the collection the time period is to be removed from
 */
-(void)removeTimePeriodAtIndex:(NSInteger)index{
    if (index >= 0 && index < periods.count) {
        [periods removeObjectAtIndex:index];
        
        //Update the object variables
        if (periods.count > 0) {
            //Set object's variables with updated array values
            [self updateVariables];
        }
        else {
            [self setVariablesNil];
        }
    }
    else {
        [NMDateToolsError throwRemoveOutOfBoundsException:index array:periods];
    }
}



#pragma mark - Sorting
/**
 *  Sorts the time periods in the collection by earliest start date to latest start date.
 */
-(void)sortByStartAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NMDateToolsTimePeriod *) obj1).StartDate compare:((NMDateToolsTimePeriod *) obj2).StartDate];
    }];
}

/**
 *  Sorts the time periods in the collection by latest start date to earliest start date.
 */
-(void)sortByStartDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NMDateToolsTimePeriod *) obj2).StartDate compare:((NMDateToolsTimePeriod *) obj1).StartDate];
    }];
}

/**
 *  Sorts the time periods in the collection by earliest end date to latest end date.
 */
-(void)sortByEndAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NMDateToolsTimePeriod *) obj1).EndDate compare:((NMDateToolsTimePeriod *) obj2).EndDate];
    }];
}

/**
 *  Sorts the time periods in the collection by latest end date to earliest end date.
 */
-(void)sortByEndDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((NMDateToolsTimePeriod *) obj2).EndDate compare:((NMDateToolsTimePeriod *) obj1).EndDate];
    }];
}

/**
 *  Sorts the time periods in the collection by how much time they span. Sorts smallest durations to longest.
 */
-(void)sortByDurationAscending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (((NMDateToolsTimePeriod *) obj1).durationInSeconds < ((NMDateToolsTimePeriod *) obj2).durationInSeconds) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

/**
 *  Sorts the time periods in the collection by how much time they span. Sorts longest durations to smallest.
 */
-(void)sortByDurationDescending{
    [periods sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (((NMDateToolsTimePeriod *) obj1).durationInSeconds > ((NMDateToolsTimePeriod *) obj2).durationInSeconds) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

#pragma mark - Collection Relationship
/**
 *  Returns an instance of NMDateToolsPeriodCollection with all the time periods in the receiver that fall inside a given time period.
 *  Time periods of the receiver must have a start date and end date within the closed interval of the period provided to be included.
 *
 *  @param period NMDateToolsTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return NMDateToolsPeriodCollection
 */
-(NMDateToolsPeriodCollection *)periodsInside:(NMDateToolsTimePeriod *)period{
    NMDateToolsPeriodCollection *collection = [[NMDateToolsPeriodCollection alloc] init];
    
    if ([period isKindOfClass:[NMDateToolsTimePeriod class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((NMDateToolsTimePeriod *) obj) isInside:period]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of NMDateToolsPeriodCollection with all the time periods in the receiver that intersect a given date.
 *  Time periods of the receiver must have a start date earlier than or equal to the comparison date and an end date later than or equal to the comparison date to be included
 *
 *  @param date NSDate - The date to check against the receiver's time periods
 *
 *  @return NMDateToolsPeriodCollection
 */
-(NMDateToolsPeriodCollection *)periodsIntersectedByDate:(NSDate *)date{
    NMDateToolsPeriodCollection *collection = [[NMDateToolsPeriodCollection alloc] init];
    
    if ([date isKindOfClass:[NSDate class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((NMDateToolsTimePeriod *) obj) containsDate:date interval:NMTimePeriodIntervalClosed]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [NMDateToolsError throwBadTypeException:date expectedClass:[NSDate class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of NMDateToolsPeriodCollection with all the time periods in the receiver that intersect a given time period.
 *  Intersection with the given time period includes other time periods that simply touch it. (i.e. one's start date is equal to another's end date)
 *
 *  @param period NMDateToolsTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return NMDateToolsPeriodCollection
 */
-(NMDateToolsPeriodCollection *)periodsIntersectedByPeriod:(NMDateToolsTimePeriod *)period{
    NMDateToolsPeriodCollection *collection = [[NMDateToolsPeriodCollection alloc] init];
    
    if ([period isKindOfClass:[NMDateToolsTimePeriod class]]) {
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((NMDateToolsTimePeriod *) obj) intersects:period]) {
                [collection addTimePeriod:obj];
            }
        }];
    }
    else {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
    }
    
    return collection;
}

/**
 *  Returns an instance of NMDateToolsPeriodCollection with all the time periods in the receiver that overlap a given time period.
 *  Overlap with the given time period does NOT include other time periods that simply touch it. (i.e. one's start date is equal to another's end date)
 *
 *  @param period NMDateToolsTimePeriod - The time period to check against the receiver's time periods.
 *
 *  @return NMDateToolsPeriodCollection
 */
-(NMDateToolsPeriodCollection *)periodsOverlappedByPeriod:(NMDateToolsTimePeriod *)period{
    NMDateToolsPeriodCollection *collection = [[NMDateToolsPeriodCollection alloc] init];
    
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((NMDateToolsTimePeriod *) obj) overlapsWith:period]) {
            [collection addTimePeriod:obj];
        }
    }];
    
    return collection;
}

/**
 *  Returns a BOOL representing whether the receiver is equal to a given NMDateToolsPeriodCollection. Equality requires the start and end dates to be the same, and all time periods to be the same.
 *
 *  If you would like to take the order of the time periods in two collections into consideration, you may do so with the considerOrder BOOL
 *
 *  @param collection    NMDateToolsPeriodCollection - The collection to compare with the receiver
 *  @param considerOrder BOOL - Option for whether to account for the time periods order in the test for equality. YES considers order, NO does not.
 *
 *  @return BOOL
 */
-(BOOL)isEqualToCollection:(NMDateToolsPeriodCollection *)collection considerOrder:(BOOL)considerOrder{
    //Check class
    if ([collection class] != [NMDateToolsPeriodCollection class]) {
        [NMDateToolsError throwBadTypeException:collection expectedClass:[NMDateToolsPeriodCollection class]];
        return NO;
    }
    
    //Check group level characteristics for speed
    if (![self hasSameCharacteristicsAs:collection]) {
        return NO;
    }
    
    //Default to equality and look for inequality
    __block BOOL isEqual = YES;
    if (considerOrder) {
        
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![collection[idx] isEqualToPeriod:obj]) {
                isEqual = NO;
                *stop = YES;
            }
        }];
    }
    else {
        __block NMDateToolsPeriodCollection *collectionCopy = [collection copy];
        
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            __block BOOL innerMatch = NO;
            __block NSInteger matchIndex = 0; //We will remove matches to account for duplicates and to help speed
            for (int ii = 0; ii < collectionCopy.count; ii++) {
                if ([obj isEqualToPeriod:collectionCopy[ii]]) {
                    innerMatch = YES;
                    matchIndex = ii;
                    break;
                }
            }
            
            //If there was a match found, stop
            if (!innerMatch) {
                isEqual = NO;
                *stop = YES;
            }
            else {
                [collectionCopy removeTimePeriodAtIndex:matchIndex];
            }
        }];
    }
    
    return isEqual;
}

#pragma mark - Helper Methods

-(void)updateVariables{
    //Set helper variables
    __block NSDate *startDate = [NSDate distantFuture];
    __block NSDate *endDate = [NSDate distantPast];
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((NMDateToolsTimePeriod *) obj).StartDate isEarlierThan:startDate]) {
            startDate = ((NMDateToolsTimePeriod *) obj).StartDate;
        }
        if ([((NMDateToolsTimePeriod *) obj).EndDate isLaterThan:endDate]) {
            endDate = ((NMDateToolsTimePeriod *) obj).EndDate;
        }
    }];
    
    //Make assignments after evaluation
    StartDate = startDate;
    EndDate = endDate;
}

-(void)setVariablesNil{
    //Set helper variables
    StartDate = nil;
    EndDate = nil;
}

/**
 *  Returns a new instance of NMDateToolsPeriodCollection that is an exact copy of the receiver, but with differnt memory references, etc.
 *
 *  @return NMDateToolsPeriodCollection
 */
-(NMDateToolsPeriodCollection *)copy{
    NMDateToolsPeriodCollection *collection = [NMDateToolsPeriodCollection collection];
    
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [collection addTimePeriod:[obj copy]];
    }];
    
    return collection;
}

@end
