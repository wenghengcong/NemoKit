//
//  NMCalendarAppearance.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarAppearance.h"
#import "NMCalendarExtensions.h"
#import "NMCalendarDynamicHeader.h"

@interface NMCalendarAppearance ()

@property (weak  , nonatomic) NMCalendar *calendar;

@property (strong, nonatomic) NSMutableDictionary *backgroundColors;
@property (strong, nonatomic) NSMutableDictionary *titleColors;
@property (strong, nonatomic) NSMutableDictionary *subtitleColors;
@property (strong, nonatomic) NSMutableDictionary *borderColors;

@end

@implementation NMCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _titleFont = [UIFont systemFontOfSize:NMCalendarStandardTitleTextSize];
        _subtitleFont = [UIFont systemFontOfSize:NMCalendarStandardSubtitleTextSize];
        _weekdayFont = [UIFont systemFontOfSize:NMCalendarStandardWeekdayTextSize];
        _headerTitleFont = [UIFont systemFontOfSize:NMCalendarStandardHeaderTextSize];
        
        _headerTitleColor = NMCalendarStandardTitleTextColor;
        _headerDateFormat = @"MMMM yyyy";
        _headerMinimumDissolvedAlpha = 0.2;
        _weekdayTextColor = NMCalendarStandardTitleTextColor;
        _caseOptions = NMCalendarCaseOptionsHeaderUsesDefaultCase|NMCalendarCaseOptionsWeekdayUsesDefaultCase;
        
        _backgroundColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _backgroundColors[@(NMCalendarCellStateNormal)]      = [UIColor clearColor];
        _backgroundColors[@(NMCalendarCellStateSelected)]    = NMCalendarStandardSelectionColor;
        _backgroundColors[@(NMCalendarCellStateDisabled)]    = [UIColor clearColor];
        _backgroundColors[@(NMCalendarCellStatePlaceholder)] = [UIColor clearColor];
        _backgroundColors[@(NMCalendarCellStateToday)]       = NMCalendarStandardTodayColor;
        
        _titleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _titleColors[@(NMCalendarCellStateNormal)]      = [UIColor blackColor];
        _titleColors[@(NMCalendarCellStateSelected)]    = [UIColor whiteColor];
        _titleColors[@(NMCalendarCellStateDisabled)]    = [UIColor grayColor];
        _titleColors[@(NMCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _titleColors[@(NMCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _subtitleColors = [NSMutableDictionary dictionaryWithCapacity:5];
        _subtitleColors[@(NMCalendarCellStateNormal)]      = [UIColor darkGrayColor];
        _subtitleColors[@(NMCalendarCellStateSelected)]    = [UIColor whiteColor];
        _subtitleColors[@(NMCalendarCellStateDisabled)]    = [UIColor lightGrayColor];
        _subtitleColors[@(NMCalendarCellStatePlaceholder)] = [UIColor lightGrayColor];
        _subtitleColors[@(NMCalendarCellStateToday)]       = [UIColor whiteColor];
        
        _borderColors[@(NMCalendarCellStateSelected)] = [UIColor clearColor];
        _borderColors[@(NMCalendarCellStateNormal)] = [UIColor clearColor];
        
        _borderRadius = 1.0;
        _eventDefaultColor = NMCalendarStandardEventDotColor;
        _eventSelectionColor = NMCalendarStandardEventDotColor;
        
        _borderColors = [NSMutableDictionary dictionaryWithCapacity:2];
        
#if TARGET_INTERFACE_BUILDER
        _fakeEventDots = YES;
#endif
        
    }
    return self;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    if (![_titleFont isEqual:titleFont]) {
        _titleFont = titleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setSubtitleFont:(UIFont *)subtitleFont
{
    if (![_subtitleFont isEqual:subtitleFont]) {
        _subtitleFont = subtitleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setWeekdayFont:(UIFont *)weekdayFont
{
    if (![_weekdayFont isEqual:weekdayFont]) {
        _weekdayFont = weekdayFont;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderTitleFont:(UIFont *)headerTitleFont
{
    if (![_headerTitleFont isEqual:headerTitleFont]) {
        _headerTitleFont = headerTitleFont;
        [self.calendar configureAppearance];
    }
}

- (void)setTitleOffset:(CGPoint)titleOffset
{
    if (!CGPointEqualToPoint(_titleOffset, titleOffset)) {
        _titleOffset = titleOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setSubtitleOffset:(CGPoint)subtitleOffset
{
    if (!CGPointEqualToPoint(_subtitleOffset, subtitleOffset)) {
        _subtitleOffset = subtitleOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    if (!CGPointEqualToPoint(_imageOffset, imageOffset)) {
        _imageOffset = imageOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setEventOffset:(CGPoint)eventOffset
{
    if (!CGPointEqualToPoint(_eventOffset, eventOffset)) {
        _eventOffset = eventOffset;
        [_calendar.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

- (void)setTitleDefaultColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(NMCalendarCellStateNormal)] = color;
    } else {
        [_titleColors removeObjectForKey:@(NMCalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleDefaultColor
{
    return _titleColors[@(NMCalendarCellStateNormal)];
}

- (void)setTitleSelectionColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(NMCalendarCellStateSelected)] = color;
    } else {
        [_titleColors removeObjectForKey:@(NMCalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleSelectionColor
{
    return _titleColors[@(NMCalendarCellStateSelected)];
}

- (void)setTitleTodayColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(NMCalendarCellStateToday)] = color;
    } else {
        [_titleColors removeObjectForKey:@(NMCalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleTodayColor
{
    return _titleColors[@(NMCalendarCellStateToday)];
}

- (void)setTitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(NMCalendarCellStatePlaceholder)] = color;
    } else {
        [_titleColors removeObjectForKey:@(NMCalendarCellStatePlaceholder)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titlePlaceholderColor
{
    return _titleColors[@(NMCalendarCellStatePlaceholder)];
}

- (void)setTitleWeekendColor:(UIColor *)color
{
    if (color) {
        _titleColors[@(NMCalendarCellStateWeekend)] = color;
    } else {
        [_titleColors removeObjectForKey:@(NMCalendarCellStateWeekend)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)titleWeekendColor
{
    return _titleColors[@(NMCalendarCellStateWeekend)];
}

- (void)setSubtitleDefaultColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(NMCalendarCellStateNormal)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(NMCalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

-(UIColor *)subtitleDefaultColor
{
    return _subtitleColors[@(NMCalendarCellStateNormal)];
}

- (void)setSubtitleSelectionColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(NMCalendarCellStateSelected)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(NMCalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleSelectionColor
{
    return _subtitleColors[@(NMCalendarCellStateSelected)];
}

- (void)setSubtitleTodayColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(NMCalendarCellStateToday)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(NMCalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleTodayColor
{
    return _subtitleColors[@(NMCalendarCellStateToday)];
}

- (void)setSubtitlePlaceholderColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(NMCalendarCellStatePlaceholder)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(NMCalendarCellStatePlaceholder)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitlePlaceholderColor
{
    return _subtitleColors[@(NMCalendarCellStatePlaceholder)];
}

- (void)setSubtitleWeekendColor:(UIColor *)color
{
    if (color) {
        _subtitleColors[@(NMCalendarCellStateWeekend)] = color;
    } else {
        [_subtitleColors removeObjectForKey:@(NMCalendarCellStateWeekend)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)subtitleWeekendColor
{
    return _subtitleColors[@(NMCalendarCellStateWeekend)];
}

- (void)setSelectionColor:(UIColor *)color
{
    if (color) {
        _backgroundColors[@(NMCalendarCellStateSelected)] = color;
    } else {
        [_backgroundColors removeObjectForKey:@(NMCalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)selectionColor
{
    return _backgroundColors[@(NMCalendarCellStateSelected)];
}

- (void)setTodayColor:(UIColor *)todayColor
{
    if (todayColor) {
        _backgroundColors[@(NMCalendarCellStateToday)] = todayColor;
    } else {
        [_backgroundColors removeObjectForKey:@(NMCalendarCellStateToday)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)todayColor
{
    return _backgroundColors[@(NMCalendarCellStateToday)];
}

- (void)setTodaySelectionColor:(UIColor *)todaySelectionColor
{
    if (todaySelectionColor) {
        _backgroundColors[@(NMCalendarCellStateToday|NMCalendarCellStateSelected)] = todaySelectionColor;
    } else {
        [_backgroundColors removeObjectForKey:@(NMCalendarCellStateToday|NMCalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)todaySelectionColor
{
    return _backgroundColors[@(NMCalendarCellStateToday|NMCalendarCellStateSelected)];
}

- (void)setEventDefaultColor:(UIColor *)eventDefaultColor
{
    if (![_eventDefaultColor isEqual:eventDefaultColor]) {
        _eventDefaultColor = eventDefaultColor;
        [self.calendar configureAppearance];
    }
}

- (void)setBorderDefaultColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(NMCalendarCellStateNormal)] = color;
    } else {
        [_borderColors removeObjectForKey:@(NMCalendarCellStateNormal)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)borderDefaultColor
{
    return _borderColors[@(NMCalendarCellStateNormal)];
}

- (void)setBorderSelectionColor:(UIColor *)color
{
    if (color) {
        _borderColors[@(NMCalendarCellStateSelected)] = color;
    } else {
        [_borderColors removeObjectForKey:@(NMCalendarCellStateSelected)];
    }
    [self.calendar configureAppearance];
}

- (UIColor *)borderSelectionColor
{
    return _borderColors[@(NMCalendarCellStateSelected)];
}

- (void)setBorderRadius:(CGFloat)borderRadius
{
    borderRadius = MAX(0.0, borderRadius);
    borderRadius = MIN(1.0, borderRadius);
    if (_borderRadius != borderRadius) {
        _borderRadius = borderRadius;
        [self.calendar configureAppearance];
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    if (![_weekdayTextColor isEqual:weekdayTextColor]) {
        _weekdayTextColor = weekdayTextColor;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderTitleColor:(UIColor *)color
{
    if (![_headerTitleColor isEqual:color]) {
        _headerTitleColor = color;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderMinimumDissolvedAlpha:(CGFloat)headerMinimumDissolvedAlpha
{
    if (_headerMinimumDissolvedAlpha != headerMinimumDissolvedAlpha) {
        _headerMinimumDissolvedAlpha = headerMinimumDissolvedAlpha;
        [self.calendar configureAppearance];
    }
}

- (void)setHeaderDateFormat:(NSString *)headerDateFormat
{
    if (![_headerDateFormat isEqual:headerDateFormat]) {
        _headerDateFormat = headerDateFormat;
        [self.calendar configureAppearance];
    }
}

- (void)setCaseOptions:(NMCalendarCaseOptions)caseOptions
{
    if (_caseOptions != caseOptions) {
        _caseOptions = caseOptions;
        [self.calendar configureAppearance];
    }
}

- (void)setSeparators:(NMCalendarSeparators)separators
{
    if (_separators != separators) {
        _separators = separators;
        [_calendar.collectionView.collectionViewLayout invalidateLayout];
    }
}

@end


@implementation NMCalendarAppearance (Deprecated)

- (void)setUseVeryShortWeekdaySymbols:(BOOL)useVeryShortWeekdaySymbols
{
    _caseOptions &= 15;
    self.caseOptions |= (useVeryShortWeekdaySymbols*NMCalendarCaseOptionsWeekdayUsesSingleUpperCase);
}

- (BOOL)useVeryShortWeekdaySymbols
{
    return (_caseOptions & (15<<4) ) == NMCalendarCaseOptionsWeekdayUsesSingleUpperCase;
}

- (void)setTitleVerticalOffset:(CGFloat)titleVerticalOffset
{
    self.titleOffset = CGPointMake(0, titleVerticalOffset);
}

- (CGFloat)titleVerticalOffset
{
    return self.titleOffset.y;
}

- (void)setSubtitleVerticalOffset:(CGFloat)subtitleVerticalOffset
{
    self.subtitleOffset = CGPointMake(0, subtitleVerticalOffset);
}

- (CGFloat)subtitleVerticalOffset
{
    return self.subtitleOffset.y;
}

- (void)setEventColor:(UIColor *)eventColor
{
    self.eventDefaultColor = eventColor;
}

- (UIColor *)eventColor
{
    return self.eventDefaultColor;
}

- (void)setTitleTextSize:(CGFloat)titleTextSize
{
    self.titleFont = [UIFont fontWithName:self.titleFont.fontName size:titleTextSize];
}

- (void)setSubtitleTextSize:(CGFloat)subtitleTextSize
{
    self.subtitleFont = [UIFont fontWithName:self.subtitleFont.fontName size:subtitleTextSize];
}

- (void)setWeekdayTextSize:(CGFloat)weekdayTextSize
{
    self.weekdayFont = [UIFont fontWithName:self.weekdayFont.fontName size:weekdayTextSize];
}

- (void)setHeaderTitleTextSize:(CGFloat)headerTitleTextSize
{
    self.headerTitleFont = [UIFont fontWithName:self.headerTitleFont.fontName size:headerTitleTextSize];
}

- (void)invalidateAppearance
{
    [self.calendar configureAppearance];
}

@end
