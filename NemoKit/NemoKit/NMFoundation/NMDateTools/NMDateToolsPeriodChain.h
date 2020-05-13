//
//  NMDateToolsPeriodChain.h
//  Nemo
//
//  Created by Hunt on 2019/8/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMDateToolsPeriodGroup.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMDateToolsPeriodChain : NMDateToolsPeriodGroup {
    NMDateToolsTimePeriod *First;
    NMDateToolsTimePeriod *Last;
}

@property (nonatomic, readonly) NMDateToolsTimePeriod *First;
@property (nonatomic, readonly) NMDateToolsTimePeriod *Last;

#pragma mark - Custom Init / Factory Chain
+(NMDateToolsPeriodChain *)chain;

#pragma mark - Chain Existence Manipulation
-(void)addTimePeriod:(NMDateToolsTimePeriod *)period;
-(void)insertTimePeriod:(NMDateToolsTimePeriod *)period atInedx:(NSInteger)index;
-(void)removeTimePeriodAtIndex:(NSInteger)index;
-(void)removeLatestTimePeriod;
-(void)removeEarliestTimePeriod;

#pragma mark - Chain Relationship
-(BOOL)isEqualToChain:(NMDateToolsPeriodChain *)chain;

#pragma mark - Updates
-(void)updateVariables;

@end

NS_ASSUME_NONNULL_END
