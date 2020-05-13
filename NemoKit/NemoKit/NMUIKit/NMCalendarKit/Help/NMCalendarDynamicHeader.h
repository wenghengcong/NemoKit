//
//  NMCalendarDynamicHeader.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMCalendar.h"
#import "NMCalendarCell.h"
#import "NMCalendarHeaderView.h"
#import "NMCalendarStickyHeader.h"
#import "NMCalendarCollectionView.h"
#import "NMCalendarCollectionViewLayout.h"
#import "NMCalendarCalculator.h"
#import "NMCalendarTransitionCoordinator.h"
#import "NMCalendarDelegationProxy.h"

@interface NMCalendar (Dynamic)

@property (readonly, nonatomic) NMCalendarCollectionView *collectionView;
@property (readonly, nonatomic) NMCalendarCollectionViewLayout *collectionViewLayout;
@property (readonly, nonatomic) NMCalendarTransitionCoordinator *transitionCoordinator;
@property (readonly, nonatomic) NMCalendarCalculator *calculator;
@property (readonly, nonatomic) BOOL floatingMode;
@property (readonly, nonatomic) NSArray *visibleStickyHeaders;
@property (readonly, nonatomic) CGFloat preferredHeaderHeight;
@property (readonly, nonatomic) CGFloat preferredWeekdayHeight;
@property (readonly, nonatomic) UIView *bottomBorder;

@property (readonly, nonatomic) NSCalendar *gregorian;
@property (readonly, nonatomic) NSDateFormatter *formatter;

@property (readonly, nonatomic) UIView *contentView;
@property (readonly, nonatomic) UIView *daysContainer;

@property (assign, nonatomic) BOOL needsAdjustingViewFrame;

- (void)invalidateHeaders;
- (void)adjustMonthPosition;
- (void)configureAppearance;

- (BOOL)isPageInRange:(NSDate *)page;
- (BOOL)isDateInRange:(NSDate *)date;

- (CGSize)sizeThatFits:(CGSize)size scope:(NMCalendarScope)scope;

@end

@interface NMCalendarAppearance (Dynamic)

@property (readwrite, nonatomic) NMCalendar *calendar;

@property (readonly, nonatomic) NSDictionary *backgroundColors;
@property (readonly, nonatomic) NSDictionary *titleColors;
@property (readonly, nonatomic) NSDictionary *subtitleColors;
@property (readonly, nonatomic) NSDictionary *borderColors;

@end

@interface NMCalendarWeekdayView (Dynamic)

@property (readwrite, nonatomic) NMCalendar *calendar;

@end

@interface NMCalendarCollectionViewLayout (Dynamic)

@property (readonly, nonatomic) CGSize estimatedItemSize;

@end

@interface NMCalendarDelegationProxy()<NMCalendarDataSource,NMCalendarDelegate,NMCalendarDelegateAppearance>
@end


