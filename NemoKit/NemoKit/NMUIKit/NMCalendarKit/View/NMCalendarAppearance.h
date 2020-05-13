//
//  NMCalendarAppearance.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NMCalendar;
/// cell状态
typedef NS_ENUM(NSInteger, NMCalendarCellState) {
    NMCalendarCellStateNormal      = 0,
    NMCalendarCellStateSelected    = 1,
    NMCalendarCellStatePlaceholder = 1 << 1,
    NMCalendarCellStateDisabled    = 1 << 2,
    NMCalendarCellStateToday       = 1 << 3,
    NMCalendarCellStateWeekend     = 1 << 4,
    NMCalendarCellStateTodaySelected = NMCalendarCellStateToday|NMCalendarCellStateSelected
};

///
typedef NS_ENUM(NSUInteger, NMCalendarSeparators) {
    NMCalendarSeparatorNone          = 0,
    NMCalendarSeparatorInterRows     = 1
};

typedef NS_OPTIONS(NSUInteger, NMCalendarCaseOptions) {
    NMCalendarCaseOptionsHeaderUsesDefaultCase      = 0,
    NMCalendarCaseOptionsHeaderUsesUpperCase        = 1,
    
    NMCalendarCaseOptionsWeekdayUsesDefaultCase     = 0 << 4,
    NMCalendarCaseOptionsWeekdayUsesUpperCase       = 1 << 4,
    NMCalendarCaseOptionsWeekdayUsesSingleUpperCase = 2 << 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface NMCalendarAppearance : NSObject

/**
 * The font of the day text.
 */
@property (strong, nonatomic) UIFont   *titleFont;

/**
 * The font of the subtitle text.
 */
@property (strong, nonatomic) UIFont   *subtitleFont;

/**
 * The font of the weekday text.
 */
@property (strong, nonatomic) UIFont   *weekdayFont;

/**
 * The font of the month text.
 */
@property (strong, nonatomic) UIFont   *headerTitleFont;

/**
 * The offset of the day text from default position.
 */
@property (assign, nonatomic) CGPoint  titleOffset;

/**
 * The offset of the day text from default position.
 */
@property (assign, nonatomic) CGPoint  subtitleOffset;

/**
 * The offset of the event dots from default position.
 */
@property (assign, nonatomic) CGPoint eventOffset;

/**
 * The offset of the image from default position.
 */
@property (assign, nonatomic) CGPoint imageOffset;

/**
 * The color of event dots.
 */
@property (strong, nonatomic) UIColor  *eventDefaultColor;

/**
 * The color of event dots.
 */
@property (strong, nonatomic) UIColor  *eventSelectionColor;

/**
 * The color of weekday text.
 */
@property (strong, nonatomic) UIColor  *weekdayTextColor;

/**
 * The color of month header text.
 */
@property (strong, nonatomic) UIColor  *headerTitleColor;

/**
 * The date format of the month header.
 */
@property (strong, nonatomic) NSString *headerDateFormat;

/**
 * The alpha value of month label staying on the fringes.
 * 设置上下月的透明度
 */
@property (assign, nonatomic) CGFloat  headerMinimumDissolvedAlpha;

/**
 * The day text color for unselected state.
 */
@property (strong, nonatomic) UIColor  *titleDefaultColor;

/**
 * The day text color for selected state.
 */
@property (strong, nonatomic) UIColor  *titleSelectionColor;

/**
 * The day text color for today in the calendar.
 */
@property (strong, nonatomic) UIColor  *titleTodayColor;

/**
 * The day text color for days out of current month.
 */
@property (strong, nonatomic) UIColor  *titlePlaceholderColor;

/**
 * The day text color for weekend.
 */
@property (strong, nonatomic) UIColor  *titleWeekendColor;

/**
 * The subtitle text color for unselected state.
 */
@property (strong, nonatomic) UIColor  *subtitleDefaultColor;

/**
 * The subtitle text color for selected state.
 */
@property (strong, nonatomic) UIColor  *subtitleSelectionColor;

/**
 * The subtitle text color for today in the calendar.
 */
@property (strong, nonatomic) UIColor  *subtitleTodayColor;

/**
 * The subtitle text color for days out of current month.
 */
@property (strong, nonatomic) UIColor  *subtitlePlaceholderColor;

/**
 * The subtitle text color for weekend.
 */
@property (strong, nonatomic) UIColor  *subtitleWeekendColor;

/**
 * The fill color of the shape for selected state.
 */
@property (strong, nonatomic) UIColor  *selectionColor;

/**
 * The fill color of the shape for today.
 */
@property (strong, nonatomic) UIColor  *todayColor;

/**
 * The fill color of the shape for today and selected state.
 */
@property (strong, nonatomic) UIColor  *todaySelectionColor;

/**
 * The border color of the shape for unselected state.
 */
@property (strong, nonatomic) UIColor  *borderDefaultColor;

/**
 * The border color of the shape for selected state.
 */
@property (strong, nonatomic) UIColor  *borderSelectionColor;

/**
 * The border radius, while 1 means a circle, 0 means a rectangle, and the middle value will give it a corner radius.
 *  0 表示正方形单元格
 */
@property (assign, nonatomic) CGFloat borderRadius;

/**
 * The case options manage the case of month label and weekday symbols.
 *
 * @see NMCalendarCaseOptions
 */
@property (assign, nonatomic) NMCalendarCaseOptions caseOptions;

/**
 * The line integrations for calendar.
 *
 */
@property (assign, nonatomic) NMCalendarSeparators separators;

#if TARGET_INTERFACE_BUILDER

// For preview only
@property (assign, nonatomic) BOOL      fakeSubtitles;
@property (assign, nonatomic) BOOL      fakeEventDots;
@property (assign, nonatomic) NSInteger fakedSelectedDay;

#endif

@end

NS_ASSUME_NONNULL_END
