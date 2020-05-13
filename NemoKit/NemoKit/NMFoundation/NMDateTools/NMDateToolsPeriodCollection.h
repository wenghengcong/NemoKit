//
//  NMDateToolsCollection.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMDateToolsPeriodGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMDateToolsPeriodCollection : NMDateToolsPeriodGroup

#pragma mark - Custom Init / Factory Methods
+(NMDateToolsPeriodCollection *)collection;

#pragma mark - Collection Manipulation
-(void)addTimePeriod:(NMDateToolsTimePeriod *)period;
-(void)insertTimePeriod:(NMDateToolsTimePeriod *)period atIndex:(NSInteger)index;
-(void)removeTimePeriodAtIndex:(NSInteger)index;

#pragma mark - Sorting
-(void)sortByStartAscending;
-(void)sortByStartDescending;
-(void)sortByEndAscending;
-(void)sortByEndDescending;
-(void)sortByDurationAscending;
-(void)sortByDurationDescending;

#pragma mark - Collection Relationship
-(NMDateToolsPeriodCollection *)periodsInside:(NMDateToolsTimePeriod *)period;
-(NMDateToolsPeriodCollection *)periodsIntersectedByDate:(NSDate *)date;
-(NMDateToolsPeriodCollection *)periodsIntersectedByPeriod:(NMDateToolsTimePeriod *)period;
-(NMDateToolsPeriodCollection *)periodsOverlappedByPeriod:(NMDateToolsTimePeriod *)period;
-(BOOL)isEqualToCollection:(NMDateToolsPeriodCollection *)collection
             considerOrder:(BOOL)considerOrder;

#pragma mark - Helper Methods
-(NMDateToolsPeriodCollection *)copy;

#pragma mark - Updates
-(void)updateVariables;

@end

NS_ASSUME_NONNULL_END
