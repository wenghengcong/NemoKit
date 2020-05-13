//
//  NMCalendar.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMCalendarAppearance.h"
#import "NMCalendarConstants.h"
#import "NMCalendarWeekdayView.h"
#import "NMCalendarHeaderView.h"
#import "NMCalendarCell.h"

//! Project version number for NMCalendar.
FOUNDATION_EXPORT double NMCalendarVersionNumber;

//! Project version string for NMCalendar.
FOUNDATION_EXPORT const unsigned char NMCalendarVersionString[];

typedef NS_ENUM(NSUInteger, NMCalendarScope) {
    NMCalendarScopeMonth,
    NMCalendarScopeWeek
};

typedef NS_ENUM(NSUInteger, NMCalendarScrollDirection) {
    NMCalendarScrollDirectionVertical,
    NMCalendarScrollDirectionHorizontal
};

typedef NS_ENUM(NSUInteger, NMCalendarPlaceholderType) {
    NMCalendarPlaceholderTypeNone          = 0,
    NMCalendarPlaceholderTypeFillHeadTail  = 1,
    NMCalendarPlaceholderTypeFillSixRows   = 2
};

// 月份位置：上月、当月、下月
typedef NS_ENUM(NSUInteger, NMCalendarMonthPosition) {
    NMCalendarMonthPositionPrevious,
    NMCalendarMonthPositionCurrent,
    NMCalendarMonthPositionNext,
    
    NMCalendarMonthPositionNotFound = NSNotFound
};


@class NMCalendar;

/**
 * NMCalendarDataSource is a source set of NMCalendar. The basic role is to provide event、subtitle and min/max day to display, or customized day cell for the calendar.
 */
@protocol NMCalendarDataSource <NSObject>

@optional

/**
 * Asks the dataSource for a title for the specific date as a replacement of the day text
 */
- (nullable NSString *)calendar:(NMCalendar *_Nullable)calendar titleForDate:(NSDate *_Nullable)date;

/**
 * Asks the dataSource for a subtitle for the specific date under the day text.
 */
- (nullable NSString *)calendar:(NMCalendar *_Nullable)calendar subtitleForDate:(NSDate *_Nullable)date;

/**
 * Asks the dataSource for an image for the specific date.
 */
- (nullable UIImage *)calendar:(NMCalendar *_Nullable)calendar imageForDate:(NSDate *_Nullable)date;

/**
 * Asks the dataSource the minimum date to display.
 */
- (NSDate *_Nullable)minimumDateForCalendar:(NMCalendar *_Nullable)calendar;

/**
 * Asks the dataSource the maximum date to display.
 */
- (NSDate *_Nullable)maximumDateForCalendar:(NMCalendar *_Nullable)calendar;

/**
 * Asks the data source for a cell to insert in a particular data of the calendar.
 */
- (__kindof NMCalendarCell *_Nullable)calendar:(NMCalendar *_Nullable)calendar cellForDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)position;

/**
 * Asks the dataSource the number of event dots for a specific date.
 *
 * @see
 *   - (UIColor *)calendar:(NMCalendar *)calendar appearance:(NMCalendarAppearance *)appearance eventColorForDate:(NSDate *)date;
 *   - (NSArray *)calendar:(NMCalendar *)calendar appearance:(NMCalendarAppearance *)appearance eventColorsForDate:(NSDate *)date;
 */
- (NSInteger)calendar:(NMCalendar *_Nullable)calendar numberOfEventsForDate:(NSDate *_Nullable)date;

@end


/**
 * The delegate of a NMCalendar object must adopt the NMCalendarDelegate protocol. The optional methods of NMCalendarDelegate manage selections、 user events and help to manager the frame of the calendar.
 */
@protocol NMCalendarDelegate <NSObject>

@optional

/**
 Asks the delegate whether the specific date is allowed to be selected by tapping.
 */
- (BOOL)calendar:(NMCalendar *_Nullable)calendar shouldSelectDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)monthPosition;

/**
 Tells the delegate a date in the calendar is selected by tapping.
 */
- (void)calendar:(NMCalendar *_Nullable)calendar didSelectDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)monthPosition;

/**
 Asks the delegate whether the specific date is allowed to be deselected by tapping_Nullable.
 */
- (BOOL)calendar:(NMCalendar *_Nullable)calendar shouldDeselectDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)monthPosition;

/**
 Tells the delegate a date in the calendar is deselected by tapping.
 */
- (void)calendar:(NMCalendar *_Nullable)calendar didDeselectDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)monthPosition;


/**
 Tells the delegate the calendar is about to change the bounding rect.
 */
- (void)calendar:(NMCalendar *_Nullable)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;

/**
 Tells the delegate that the specified cell is about to be displayed in the calendar.
 */
- (void)calendar:(NMCalendar *_Nullable)calendar willDisplayCell:(NMCalendarCell *_Nullable)cell forDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)monthPosition;

/**
 Tells the delegate the calendar is about to change the current page.
 */
- (void)calendarCurrentPageDidChange:(NMCalendar *_Nullable)calendar;

@end

/**
 * NMCalendarDelegateAppearance determines the fonts and colors of components in the calendar, but more specificly. Basically, if you need to make a global customization of appearance of the calendar, use NMCalendarAppearance. But if you need different appearance for different days, use NMCalendarDelegateAppearance.
 *
 * @see NMCalendarAppearance
 */
@protocol NMCalendarDelegateAppearance <NMCalendarDelegate>

@optional

/**
 * Asks the delegate for a fill color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance fillDefaultColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for a fill color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance fillSelectionColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for day text color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance titleDefaultColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for day text color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance titleSelectionColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for subtitle text color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance subtitleDefaultColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for subtitle text color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance subtitleSelectionColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for event colors for the specific date.
 */
- (nullable NSArray<UIColor *> *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance eventDefaultColorsForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for multiple event colors in selected state for the specific date.
 */
- (nullable NSArray<UIColor *> *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance eventSelectionColorsForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for a border color in unselected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance borderDefaultColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for a border color in selected state for the specific date.
 */
- (nullable UIColor *)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance borderSelectionColorForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for an offset for day text for the specific date.
 */
- (CGPoint)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance titleOffsetForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for an offset for subtitle for the specific date.
 */
- (CGPoint)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance subtitleOffsetForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for an offset for image for the specific date.
 */
- (CGPoint)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance imageOffsetForDate:(NSDate *_Nullable)date;

/**
 * Asks the delegate for an offset for event dots for the specific date.
 */
- (CGPoint)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance eventOffsetForDate:(NSDate *_Nullable)date;


/**
 * Asks the delegate for a border radius for the specific date.
 */
- (CGFloat)calendar:(NMCalendar *_Nullable)calendar appearance:(NMCalendarAppearance *_Nullable)appearance borderRadiusForDate:(NSDate *_Nullable)date;

@end

#pragma mark - Primary

IB_DESIGNABLE
@interface NMCalendar : UIView

/**
 * The object that acts as the delegate of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<NMCalendarDelegate> _Nullable delegate;

/**
 * The object that acts as the data source of the calendar.
 */
@property (weak, nonatomic) IBOutlet id<NMCalendarDataSource> _Nullable dataSource;

/**
 * A special mark will be put on 'today' of the calendar.
 */
@property (nullable, strong, nonatomic) NSDate *today;

/**
 * The current page of calendar
 *
 * @desc In week mode, current page represents the current visible week; In month mode, it means current visible month.
 */
@property (strong, nonatomic) NSDate * _Nullable currentPage;

/**
 * The locale of month and weekday symbols. Change it to display them in your own language.
 *
 * e.g. To display them in Chinese:
 *
 *    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
 */
@property (copy, nonatomic) NSLocale * _Nullable locale;

/**
 * The scroll direction of NMCalendar.
 *
 * e.g. To make the calendar scroll vertically
 *
 *    calendar.scrollDirection = NMCalendarScrollDirectionVertical;
 */
@property (assign, nonatomic) NMCalendarScrollDirection scrollDirection;

/**
 * The scope of calendar, change scope will trigger an inner frame change, make sure the frame has been correctly adjusted in
 *
 *    - (void)calendar:(NMCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated;
 */
@property (assign, nonatomic) NMCalendarScope scope;

/**
 A UIPanGestureRecognizer instance which enables the control of scope on the whole day-area. Not available if the scrollDirection is vertical.
 
 @deprecated Use -handleScopeGesture: instead
 
 e.g.
 
    UIPanGestureRecognizer *scopeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:calendar action:@selector(handleScopeGesture:)];
    [calendar addGestureRecognizer:scopeGesture];
 
 @see DIYExample
 @see NMCalendarScopeExample
 */
@property (readonly, nonatomic) UIPanGestureRecognizer * _Nullable scopeGesture NMCalendarDeprecated(handleScopeGesture:);

/**
 * A UILongPressGestureRecognizer instance which enables the swipe-to-choose feature of the calendar.
 *
 * e.g.
 *
 *    calendar.swipeToChooseGesture.enabled = YES;
 */
@property (readonly, nonatomic) UILongPressGestureRecognizer * _Nullable swipeToChooseGesture;

/**
 * The placeholder type of NMCalendar. Default is NMCalendarPlaceholderTypeFillSixRows.
 *
 * e.g. To hide all placeholder of the calendar
 *
 *    calendar.placeholderType = NMCalendarPlaceholderTypeNone;
 */
@property (assign, nonatomic) NMCalendarPlaceholderType placeholderType;

/**
 The index of the first weekday of the calendar. Give a '2' to make Monday in the first column.
 */
@property (assign, nonatomic) IBInspectable NSUInteger firstWeekday;

/**
 The height of month header of the calendar. Give a '0' to remove the header.
 */
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;

/**
 The height of weekday header of the calendar.
 */
@property (assign, nonatomic) IBInspectable CGFloat weekdayHeight;

/**
 The weekday view of the calendar
 */
@property (strong, nonatomic) NMCalendarWeekdayView * _Nullable calendarWeekdayView;

/**
 The header view of the calendar
 */
@property (strong, nonatomic) NMCalendarHeaderView * _Nullable calendarHeaderView;

/**
 A Boolean value that determines whether users can select a date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsSelection;

/**
 A Boolean value that determines whether users can select more than one date.
 */
@property (assign, nonatomic) IBInspectable BOOL allowsMultipleSelection;

/**
 A Boolean value that determines whether the bounding rect changes when the displayed month of the calendar is changed.
 */
@property (assign, nonatomic) IBInspectable BOOL adjustsBoundingRectWhenChangingMonths;

/**
 A Boolean value that determines whether paging is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL pagingEnabled;

/**
 A Boolean value that determines whether scrolling is enabled for the calendar.
 */
@property (assign, nonatomic) IBInspectable BOOL scrollEnabled;

/**
 The row height of the calendar if paging enabled is NO.;
 */
@property (assign, nonatomic) IBInspectable CGFloat rowHeight;

/**
 The calendar appearance used to control the global fonts、colors .etc
 */
@property (readonly, nonatomic) NMCalendarAppearance * _Nullable appearance;

/**
 A date object representing the minimum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate * _Nullable minimumDate;

/**
 A date object representing the maximum day enable、visible and selectable. (read-only)
 */
@property (readonly, nonatomic) NSDate * _Nullable maximumDate;

/**
 A date object identifying the section of the selected date. (read-only)
 */
@property (nullable, readonly, nonatomic) NSDate *selectedDate;

/**
 The dates representing the selected dates. (read-only)
 */
@property (readonly, nonatomic) NSArray<NSDate *> * _Nullable selectedDates;

/**
 Reload the dates and appearance of the calendar.
 */
- (void)reloadData;

/**
 Change the scope of the calendar. Make sure `-calendar:boundingRectWillChange:animated` is correctly adopted.
 
 @param scope The target scope to change.
 @param animated YES if you want to animate the scoping; NO if the change should be immediate.
 */
- (void)setScope:(NMCalendarScope)scope animated:(BOOL)animated;

/**
 Selects a given date in the calendar.
 
 @param date A date in the calendar.
 */
- (void)selectDate:(nullable NSDate *)date;

/**
 Selects a given date in the calendar, optionally scrolling the date to visible area.
 
 @param date A date in the calendar.
 @param scrollToDate A Boolean value that determines whether the calendar should scroll to the selected date to visible area.
 */
- (void)selectDate:(nullable NSDate *)date scrollToDate:(BOOL)scrollToDate;

/**
 Deselects a given date of the calendar.
 
 @param date A date in the calendar.
 */
- (void)deselectDate:(NSDate *_Nullable)date;

/**
 Changes the current page of the calendar.
 
 @param currentPage Representing weekOfYear in week mode, or month in month mode.
 @param animated YES if you want to animate the change in position; NO if it should be immediate.
 */
- (void)setCurrentPage:(NSDate *_Nullable)currentPage animated:(BOOL)animated;

/**
 Register a class for use in creating new calendar cells.

 @param cellClass The class of a cell that you want to use in the calendar.
 @param identifier The reuse iden_Nullabletifier to associate with the specified class. This parameter must not be nil and must not be an empty string.
 */
- (void)registerClass:(Class _Nullable )cellClass forCellReuseIdentifier:(NSString *_Nullable)identifier;

/**
 Returns a reusable calendar cell object located by its identifier.

 @param identifier The reuse identifier for the specified cell. This parameter must not be nil.
 @param date The specific date of the cell.
 @return A valid NMCalendarCell object.
 */
- (__kindof NMCalendarCell *_Nullable)dequeueReusableCellWithIdentifier:(NSString *_Nonnull)identifier forDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)position;

/**
 Returns the calendar cell for the specified date.

 @param date The date of the cell
 @param position The month position for the cell
 @return An object representing a cell of the calendar, or nil if the cell is not visible or date is out of range.
 */
- (nullable NMCalendarCell *)cellForDate:(NSDate *_Nullable)date atMonthPosition:(NMCalendarMonthPosition)position;


/**
 Returns the date of the specified cell.
 
 @param cell The cell object whose date you want.
 @return The date of the cell or nil if the specified cell is not in the calendar.
 */
- (nullable NSDate *)dateForCell:(NMCalendarCell *_Nullable)cell;

/**
 Returns the month position of the specified cell.
 
 @param cell The cell object whose month position you want.
 @return The month position of the cell or NMCalendarMonthPositionNotFound if the specified cell is not in the calendar.
 */
- (NMCalendarMonthPosition)monthPositionForCell:(NMCalendarCell *_Nullable)cell;


/**
 Returns an array of visible cells currently displayed by the calendar.
 
 @return An array of NMCalendarCell objects. If no cells are visible, this method returns an empty array.
 */
- (NSArray<__kindof NMCalendarCell *> *_Nullable)visibleCells;

/**
 Returns the frame for a non-placeholder cell relative to the super view of the calendar.
 
 @param date A date is the calendar.
 */
- (CGRect)frameForDate:(NSDate *_Nullable)date;

/**
 An action selector for UIPanGestureRecognizer instance to control the scope transition
 
 @param sender A UIPanGestureRecognizer instance which controls the scope of the calendar
 */
- (void)handleScopeGesture:(UIPanGestureRecognizer *_Nullable)sender;

@end


IB_DESIGNABLE
@interface NMCalendar (IBExtension)

#if TARGET_INTERFACE_BUILDER

@property (assign, nonatomic) IBInspectable CGFloat  titleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  subtitleTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  weekdayTextSize;
@property (assign, nonatomic) IBInspectable CGFloat  headerTitleTextSize;

@property (strong, nonatomic) IBInspectable UIColor  *eventDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *eventSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *weekdayTextColor;

@property (strong, nonatomic) IBInspectable UIColor  *headerTitleColor;
@property (strong, nonatomic) IBInspectable NSString *headerDateFormat;
@property (assign, nonatomic) IBInspectable CGFloat  headerMinimumDissolvedAlpha;

@property (strong, nonatomic) IBInspectable UIColor  *titleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *titlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *titleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *subtitleDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleSelectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleTodayColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitlePlaceholderColor;
@property (strong, nonatomic) IBInspectable UIColor  *subtitleWeekendColor;

@property (strong, nonatomic) IBInspectable UIColor  *selectionColor;
@property (strong, nonatomic) IBInspectable UIColor  *todayColor;
@property (strong, nonatomic) IBInspectable UIColor  *todaySelectionColor;

@property (strong, nonatomic) IBInspectable UIColor *borderDefaultColor;
@property (strong, nonatomic) IBInspectable UIColor *borderSelectionColor;

@property (assign, nonatomic) IBInspectable CGFloat borderRadius;
@property (assign, nonatomic) IBInspectable BOOL    useVeryShortWeekdaySymbols;

@property (assign, nonatomic) IBInspectable BOOL      fakeSubtitles;
@property (assign, nonatomic) IBInspectable BOOL      fakeEventDots;
@property (assign, nonatomic) IBInspectable NSInteger fakedSelectedDay;

#endif

@end

