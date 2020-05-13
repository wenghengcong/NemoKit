//
//  NMDateToolsPeriodChain.m
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMDateToolsPeriodChain.h"
#import "NMDateToolsError.h"

@implementation NMDateToolsPeriodChain


#pragma mark - Custom Init / Factory Chain
+(NMDateToolsPeriodChain *)chain{
    return [[NMDateToolsPeriodChain alloc] init];
}

#pragma mark - Chain Existence Manipulation
-(void)addTimePeriod:(NMDateToolsTimePeriod *)period{
    if ([period class] != [NMDateToolsTimePeriod class]) {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
        return;
    }
    
    if (periods) {
        if (periods.count > 0) {
            //Create a modified period to be added based on size of passed in period
            NMDateToolsTimePeriod *modifiedPeriod = [NMDateToolsTimePeriod timePeriodWithSize:NMTimePeriodSizeSecond amount:period.durationInSeconds startingAt:[periods[periods.count - 1] EndDate]];
            
            //Add object to periods array
            [periods addObject:modifiedPeriod];
        }
        else {
            //Add object to periods array
            [periods addObject:period];
        }
    }
    else {
        //Create new periods array
        periods = [NSMutableArray array];
        
        //Add object to periods array
        [periods addObject:period];
    }
    
    //Set object's variables with updated array values
    [self updateVariables];
}

-(void)insertTimePeriod:(NMDateToolsTimePeriod *)period atInedx:(NSInteger)index{
    if ([period class] != [NMDateToolsTimePeriod class]) {
        [NMDateToolsError throwBadTypeException:period expectedClass:[NMDateToolsTimePeriod class]];
        return;
    }
    
    //Make sure the index is within the operable bounds of the periods array
    if (index == 0) {
        //Update bounds of period to make it fit in chain
        NMDateToolsTimePeriod *modifiedPeriod = [NMDateToolsTimePeriod timePeriodWithSize:NMTimePeriodSizeSecond amount:period.durationInSeconds endingAt:[periods[0] EndDate]];
        
        //Insert the updated object at the beginning of the periods array
        [periods insertObject:modifiedPeriod atIndex:0];
    }
    else if (index > 0 && index < periods.count) {
        
        //Shift time periods later if they fall after new period
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //Shift later
            if (idx >= index) {
                [((NMDateToolsTimePeriod *) obj) shiftLaterWithSize:NMTimePeriodSizeSecond amount:period.durationInSeconds];
            }
        }];
        
        //Update bounds of period to make it fit in chain
        NMDateToolsTimePeriod *modifiedPeriod = [NMDateToolsTimePeriod timePeriodWithSize:NMTimePeriodSizeSecond amount:period.durationInSeconds startingAt:[periods[index - 1] EndDate]];
        
        //Insert the updated object at the beginning of the periods array
        [periods insertObject:modifiedPeriod atIndex:index];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [NMDateToolsError throwInsertOutOfBoundsException:index array:periods];
    }
}

-(void)removeTimePeriodAtIndex:(NSInteger)index{
    //Make sure the index is within the operable bounds of the periods array
    if (index >= 0 && index < periods.count) {
        NMDateToolsTimePeriod *period = periods[index];
        
        //Shift time periods later if they fall after new period
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //Shift earlier
            if (idx > index) {
                [((NMDateToolsTimePeriod *) obj) shiftEarlierWithSize:NMTimePeriodSizeSecond amount:period.durationInSeconds];
            }
        }];
        
        //Remove object
        [periods removeObjectAtIndex:index];
        
        //Set object's variables with updated array values
        [self updateVariables];
    }
    else {
        [NMDateToolsError throwRemoveOutOfBoundsException:index array:periods];
    }
}
-(void)removeLatestTimePeriod{
    if (periods.count > 0) {
        [periods removeLastObject];
        
        //Update the object variables
        if (periods.count > 0) {
            //Set object's variables with updated array values
            [self updateVariables];
        }
        else {
            [self setVariablesNil];
        }
    }
}
-(void)removeEarliestTimePeriod{
    if (periods > 0) {
        //Shift time periods earlier
        [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //Shift earlier to account for removal of first element in periods array
            [((NMDateToolsTimePeriod *) obj) shiftEarlierWithSize:NMTimePeriodSizeSecond amount:[periods[0] durationInSeconds]];
        }];
        
        //Remove first period
        [periods removeObjectAtIndex:0];
        
        //Update the object variables
        if (periods.count > 0) {
            //Set object's variables with updated array values
            [self updateVariables];
        }
        else {
            [self setVariablesNil];
        }
    }
}

#pragma mark - Chain Relationship
-(BOOL)isEqualToChain:(NMDateToolsPeriodChain *)chain{
    //Check class
    if ([chain class] != [NMDateToolsPeriodChain class]) {
        [NMDateToolsError throwBadTypeException:chain expectedClass:[NMDateToolsPeriodChain class]];
        return NO;
    }
    
    //Check group level characteristics for speed
    if (![self hasSameCharacteristicsAs:chain]) {
        return NO;
    }
    
    //Check whole chain
    __block BOOL isEqual = YES;
    [periods enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![chain[idx] isEqualToPeriod:obj]) {
            isEqual = NO;
            *stop = YES;
        }
    }];
    return isEqual;
}

#pragma mark - Getters

-(NMDateToolsTimePeriod *)First{
    return First;
}

-(NMDateToolsTimePeriod *)Last{
    return Last;
}

#pragma mark - Helper Methods

-(void)updateVariables{
    //Set helper variables
    StartDate = [periods[0] StartDate];
    EndDate = [periods[periods.count - 1] EndDate];
    First = periods[0];
    Last = periods[periods.count -1];
}

-(void)setVariablesNil{
    //Set helper variables
    StartDate = nil;
    EndDate = nil;
    First = nil;
    Last = nil;
}

@end
