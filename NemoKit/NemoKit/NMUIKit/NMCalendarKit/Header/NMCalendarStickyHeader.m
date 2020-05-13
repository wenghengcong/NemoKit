//
//  NMCalendarStickyHeader.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarStickyHeader.h"
#import "NMCalendar.h"
#import "NMCalendarWeekdayView.h"
#import "NMCalendarExtensions.h"
#import "NMCalendarConstants.h"
#import "NMCalendarDynamicHeader.h"

@interface NMCalendarStickyHeader()

@property (weak  , nonatomic) UIView  *contentView;
@property (weak  , nonatomic) UIView  *bottomBorder;
@property (weak  , nonatomic) NMCalendarWeekdayView *weekdayView;

@end

@implementation NMCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view;
        UILabel *label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        self.contentView = view;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.titleLabel = label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = NMCalendarStandardLineColor;
        [_contentView addSubview:view];
        self.bottomBorder = view;
        
        NMCalendarWeekdayView *weekdayView = [[NMCalendarWeekdayView alloc] init];
        [self.contentView addSubview:weekdayView];
        self.weekdayView = weekdayView;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
    CGFloat weekdayMargin = weekdayHeight * 0.1;
    CGFloat titleWidth = _contentView.nmui_width;
    
    self.weekdayView.frame = CGRectMake(0, _contentView.nmui_height-weekdayHeight-weekdayMargin, self.contentView.nmui_width, weekdayHeight);
    
    CGFloat titleHeight = [@"1" sizeWithAttributes:@{NSFontAttributeName:self.calendar.appearance.headerTitleFont}].height*1.5 + weekdayMargin*3;
    
    _bottomBorder.frame = CGRectMake(0, _contentView.nmui_height-weekdayHeight-weekdayMargin*2, _contentView.nmui_width, 1.0);
    _titleLabel.frame = CGRectMake(0, _bottomBorder.nmui_bottom-titleHeight-weekdayMargin, titleWidth,titleHeight);
    
}

#pragma mark - Properties

- (void)setCalendar:(NMCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _weekdayView.calendar = calendar;
        [self configureAppearance];
    }
}

#pragma mark - Private methods

- (void)configureAppearance
{
    _titleLabel.font = self.calendar.appearance.headerTitleFont;
    _titleLabel.textColor = self.calendar.appearance.headerTitleColor;
    [self.weekdayView configureAppearance];
}

- (void)setMonth:(NSDate *)month
{
    _month = month;
    _calendar.formatter.dateFormat = self.calendar.appearance.headerDateFormat;
    BOOL usesUpperCase = (self.calendar.appearance.caseOptions & 15) == NMCalendarCaseOptionsHeaderUsesUpperCase;
    NSString *text = [_calendar.formatter stringFromDate:_month];
    text = usesUpperCase ? text.uppercaseString : text;
    self.titleLabel.text = text;
}


@end
