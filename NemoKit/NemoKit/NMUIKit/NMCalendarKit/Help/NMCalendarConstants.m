//
//  NMCalendarConstants.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarConstants.h"

CGFloat const NMCalendarStandardHeaderHeight = 40;
CGFloat const NMCalendarStandardWeekdayHeight = 25;
CGFloat const NMCalendarStandardMonthlyPageHeight = 300.0;
CGFloat const NMCalendarStandardWeeklyPageHeight = 108+1/3.0;
CGFloat const NMCalendarStandardCellDiameter = 100/3.0;
CGFloat const NMCalendarStandardSeparatorThickness = 0.5;
CGFloat const NMCalendarAutomaticDimension = -1;
CGFloat const NMCalendarDefaultBounceAnimationDuration = 0.15;
CGFloat const NMCalendarStandardRowHeight = 38;
CGFloat const NMCalendarStandardTitleTextSize = 13.5;
CGFloat const NMCalendarStandardSubtitleTextSize = 10;
CGFloat const NMCalendarStandardWeekdayTextSize = 14;
CGFloat const NMCalendarStandardHeaderTextSize = 16.5;
CGFloat const NMCalendarMaximumEventDotDiameter = 4.8;

NSInteger const NMCalendarDefaultHourComponent = 0;

NSString * const NMCalendarDefaultCellReuseIdentifier = @"_FSCalendarDefaultCellReuseIdentifier";
NSString * const NMCalendarBlankCellReuseIdentifier = @"_FSCalendarBlankCellReuseIdentifier";
NSString * const NMCalendarInvalidArgumentsExceptionName = @"Invalid argument exception";

CGPoint const CGPointInfinity = {
    .x =  CGFLOAT_MAX,
    .y =  CGFLOAT_MAX
};

CGSize const CGSizeAutomatic = {
    .width =  NMCalendarAutomaticDimension,
    .height =  NMCalendarAutomaticDimension
};




