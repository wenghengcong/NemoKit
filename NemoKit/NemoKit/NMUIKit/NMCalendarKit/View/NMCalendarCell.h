//
//  NMCalendarCell.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMCalendar, NMCalendarAppearance, NMCalendarEventIndicator;

typedef NS_ENUM(NSUInteger, NMCalendarMonthPosition);

@interface NMCalendarCell : UICollectionViewCell

#pragma mark - Public properties

/**
 The day text label of the cell
  标题label
 */
@property (weak, nonatomic) UILabel  *titleLabel;


/**
 The subtitle label of the cell
 子标题label
 */
@property (weak, nonatomic) UILabel  *subtitleLabel;


/**
 The shape layer of the cell
  选中shape layer
 */
@property (weak, nonatomic) CAShapeLayer *shapeLayer;

/**
 The imageView below shape layer of the cell
 
 */
@property (weak, nonatomic) UIImageView *imageView;


/**
 The collection of event dots of the cell
 */
@property (weak, nonatomic) NMCalendarEventIndicator *eventIndicator;

/**
 A boolean value indicates that whether the cell is "placeholder". Default is NO.
 */
@property (assign, nonatomic, getter=isPlaceholder) BOOL placeholder;

#pragma mark - Private properties

@property (weak, nonatomic) NMCalendar *calendar;
@property (weak, nonatomic) NMCalendarAppearance *appearance;

@property (strong, nonatomic) NSString *subtitle;
@property (strong, nonatomic) UIImage  *image;
@property (assign, nonatomic) NMCalendarMonthPosition monthPosition;

@property (assign, nonatomic) NSInteger numberOfEvents;
@property (assign, nonatomic) BOOL dateIsToday;
@property (assign, nonatomic) BOOL weekend;

@property (strong, nonatomic) UIColor *preferredFillDefaultColor;
@property (strong, nonatomic) UIColor *preferredFillSelectionColor;
@property (strong, nonatomic) UIColor *preferredTitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredTitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredSubtitleDefaultColor;
@property (strong, nonatomic) UIColor *preferredSubtitleSelectionColor;
@property (strong, nonatomic) UIColor *preferredBorderDefaultColor;
@property (strong, nonatomic) UIColor *preferredBorderSelectionColor;
@property (assign, nonatomic) CGPoint preferredTitleOffset;
@property (assign, nonatomic) CGPoint preferredSubtitleOffset;
@property (assign, nonatomic) CGPoint preferredImageOffset;
@property (assign, nonatomic) CGPoint preferredEventOffset;

@property (strong, nonatomic) NSArray<UIColor *> *preferredEventDefaultColors;
@property (strong, nonatomic) NSArray<UIColor *> *preferredEventSelectionColors;
@property (assign, nonatomic) CGFloat preferredBorderRadius;

// Add subviews to self.contentView and set up constraints
- (instancetype)initWithFrame:(CGRect)frame NS_REQUIRES_SUPER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_REQUIRES_SUPER;

// For DIY overridden
- (void)layoutSubviews NS_REQUIRES_SUPER; // Configure frames of subviews
- (void)configureAppearance NS_REQUIRES_SUPER; // Configure appearance for cell


/// 获取颜色配置表中的颜色
/// @param dictionary 颜色配置表
- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary;

/// 选中动作
- (void)performSelecting;

@end


/// 事件指示点
@interface NMCalendarEventIndicator : UIView

@property (assign, nonatomic) NSInteger numberOfEvents;
@property (strong, nonatomic) id color;

@end

/// 空白Cell
@interface NMCalendarBlankCell : UICollectionViewCell

- (void)configureAppearance;

@end

NS_ASSUME_NONNULL_END
