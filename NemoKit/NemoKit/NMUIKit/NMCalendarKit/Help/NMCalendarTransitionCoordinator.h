//
//  NMCalendarTransitionCoordinator.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NMCalendarCollectionView.h"
#import "NMCalendarCollectionViewLayout.h"
#import "NMCalendar.h"


typedef NS_ENUM(NSUInteger, NMCalendarTransitionState) {
    NMCalendarTransitionStateIdle,
    NMCalendarTransitionStateChanging,
    NMCalendarTransitionStateFinishing,
};


@interface NMCalendarTransitionCoordinator : NSObject <UIGestureRecognizerDelegate>

@property (assign, nonatomic) NMCalendarTransitionState state;

@property (assign, nonatomic) CGSize cachedMonthSize;

@property (readonly, nonatomic) NMCalendarScope representingScope;

- (instancetype)initWithCalendar:(NMCalendar *)calendar;

- (void)performScopeTransitionFromScope:(NMCalendarScope)fromScope toScope:(NMCalendarScope)toScope animated:(BOOL)animated;
- (void)performBoundingRectTransitionFromMonth:(NSDate *)fromMonth toMonth:(NSDate *)toMonth duration:(CGFloat)duration;
- (CGRect)boundingRectForScope:(NMCalendarScope)scope page:(NSDate *)page;

- (void)handleScopeGesture:(id)sender;

@end


@interface NMCalendarTransitionAttributes : NSObject

@property (assign, nonatomic) CGRect sourceBounds;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) NSDate *sourcePage;
@property (strong, nonatomic) NSDate *targetPage;
@property (assign, nonatomic) NSInteger focusedRow;
@property (strong, nonatomic) NSDate *focusedDate;
@property (assign, nonatomic) NMCalendarScope targetScope;

- (void)revert;

@end
