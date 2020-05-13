//
//  NMCalendarCell.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarCell.h"
#import "NMCalendar.h"
#import "NMCalendarExtensions.h"
#import "NMCalendarDynamicHeader.h"
#import "NMCalendarConstants.h"

@interface NMCalendarCell ()

@property (readonly, nonatomic) UIColor *colorForCellFill;
@property (readonly, nonatomic) UIColor *colorForTitleLabel;
@property (readonly, nonatomic) UIColor *colorForSubtitleLabel;
@property (readonly, nonatomic) UIColor *colorForCellBorder;
@property (readonly, nonatomic) NSArray<UIColor *> *colorsForEvents;
@property (readonly, nonatomic) CGFloat borderRadius;

@end

@implementation NMCalendarCell

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

/// 初始化
- (void)commonInit
{
    // 全部视图都在self.contentView下面
    UILabel *label;
    CAShapeLayer *shapeLayer;
    UIImageView *imageView;
    NMCalendarEventIndicator *eventIndicator;
    
    // title
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    [self.contentView addSubview:label];
    self.titleLabel = label;
    
    //  subtitle
    label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:label];
    self.subtitleLabel = label;
    
    // 选中的背景
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.borderWidth = 1.0;
    shapeLayer.borderColor = [UIColor clearColor].CGColor;
    shapeLayer.opacity = 0;
    [self.contentView.layer insertSublayer:shapeLayer below:_titleLabel.layer];
    self.shapeLayer = shapeLayer;
    
    // 事件标识符
    eventIndicator = [[NMCalendarEventIndicator alloc] initWithFrame:CGRectZero];
    eventIndicator.backgroundColor = [UIColor clearColor];
    eventIndicator.hidden = YES;
    [self.contentView addSubview:eventIndicator];
    self.eventIndicator = eventIndicator;
    
    //
    imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeBottom|UIViewContentModeCenter;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    // 对超出的视图都不进行裁剪
    self.clipsToBounds = NO;
    self.contentView.clipsToBounds = NO;
    
}


/// 重新布局
/*
 You should not call this method directly.
 If you want to force a layout update, call the setNeedsLayout method instead to do so prior to the next drawing update.
 If you want to update the layout of your views immediately, call the layoutIfNeeded method.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_subtitle) {
        _subtitleLabel.text = _subtitle;
        if (_subtitleLabel.hidden) {
            _subtitleLabel.hidden = NO;
        }
    } else {
        if (!_subtitleLabel.hidden) {
            _subtitleLabel.hidden = YES;
        }
    }
    
    if (_subtitle) {
        CGFloat titleHeight = self.titleLabel.font.lineHeight;
        CGFloat subtitleHeight = self.subtitleLabel.font.lineHeight;
        
        CGFloat height = titleHeight + subtitleHeight;
        _titleLabel.frame = CGRectMake(
                                       self.preferredTitleOffset.x,
                                       (self.contentView.nmui_height*5.0/6.0-height)*0.5+self.preferredTitleOffset.y,
                                       self.contentView.nmui_width,
                                       titleHeight
                                       );
        _subtitleLabel.frame = CGRectMake(
                                          self.preferredSubtitleOffset.x,
                                          (_titleLabel.nmui_bottom-self.preferredTitleOffset.y) - (_titleLabel.nmui_height-_titleLabel.font.pointSize)+self.preferredSubtitleOffset.y,
                                          self.contentView.nmui_width,
                                          subtitleHeight
                                          );
    } else {
        _titleLabel.frame = CGRectMake(
                                       self.preferredTitleOffset.x,
                                       self.preferredTitleOffset.y,
                                       self.contentView.nmui_width,
                                       floor(self.contentView.nmui_height*5.0/6.0)
                                       );
    }
    
    _imageView.frame = CGRectMake(self.preferredImageOffset.x, self.preferredImageOffset.y, self.contentView.nmui_width, self.contentView.nmui_height);
    
    CGFloat titleHeight = self.bounds.size.height*5.0/6.0;
    CGFloat diameter = MIN(self.bounds.size.height*5.0/6.0,self.bounds.size.width);
    diameter = diameter > NMCalendarStandardCellDiameter ? (diameter - (diameter-NMCalendarStandardCellDiameter)*0.5) : diameter;
    _shapeLayer.frame = CGRectMake((self.bounds.size.width-diameter)/2,
                                   (titleHeight-diameter)/2,
                                   diameter,
                                   diameter);
    
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
    if (!CGPathEqualToPath(_shapeLayer.path, path)) {
        _shapeLayer.path = path;
    }
    
    CGFloat eventSize = _shapeLayer.frame.size.height/6.0;
    _eventIndicator.frame = CGRectMake(
                                       self.preferredEventOffset.x,
                                       CGRectGetMaxY(_shapeLayer.frame)+eventSize*0.17+self.preferredEventOffset.y,
                                       self.nmui_width,
                                       eventSize*0.83
                                      );
    
}
/*
 用法：在出队列前会调用该方法。
 在该方法里面处理需要重用前的的准备工作，但是不要对cell的内容进行赋值，应该在cellFor方法里赋值
 When a view is dequeued for use, this method is called before the corresponding dequeue method returns the view to your code. Subclasses can override this method and use it to reset properties to their default values and generally make the view ready to use again. You should not use this method to assign any new data to the view. That is the responsibility of your data source object.
 */
- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.window) { // Avoid interrupt of navigation transition somehow
        [CATransaction setDisableActions:YES]; // Avoid blink of shape layer.
    }
    // 完全透明
    self.shapeLayer.opacity = 0;
    [self.contentView.layer removeAnimationForKey:@"opacity"];
}

#pragma mark - Public

/// 选中
- (void)performSelecting
{
    _shapeLayer.opacity = 1;
    // 动画组动画
    CAAnimationGroup *group = [CAAnimationGroup animation];
    
    NSNumber *middleValue = @1.2;     // bounce动画的中间值
    // 放大动画
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomOut.fromValue = @0.3;
    zoomOut.toValue = middleValue;
    zoomOut.duration = NMCalendarDefaultBounceAnimationDuration/4*3;
    
    // 缩小动画
    CABasicAnimation *zoomIn = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomIn.fromValue = middleValue;
    zoomIn.toValue = @1.0;
    zoomIn.beginTime = NMCalendarDefaultBounceAnimationDuration/4*3;
    zoomIn.duration = NMCalendarDefaultBounceAnimationDuration/4;
    group.duration = NMCalendarDefaultBounceAnimationDuration;
    group.animations = @[zoomOut, zoomIn];
    [_shapeLayer addAnimation:group forKey:@"bounce"];
    [self configureAppearance];
    
}

#pragma mark - Private

- (void)configureAppearance
{
    UIColor *textColor = self.colorForTitleLabel;
    if (![textColor isEqual:_titleLabel.textColor]) {
        _titleLabel.textColor = textColor;
    }
    
    UIFont *titleFont = self.calendar.appearance.titleFont;
    if (![titleFont isEqual:_titleLabel.font]) {
        _titleLabel.font = titleFont;
    }
    if (_subtitle) {
        textColor = self.colorForSubtitleLabel;
        if (![textColor isEqual:_subtitleLabel.textColor]) {
            _subtitleLabel.textColor = textColor;
        }
        titleFont = self.calendar.appearance.subtitleFont;
        if (![titleFont isEqual:_subtitleLabel.font]) {
            _subtitleLabel.font = titleFont;
        }
    }
    
    UIColor *borderColor = self.colorForCellBorder;
    UIColor *fillColor = self.colorForCellFill;
    
    // 是否要隐藏背景色
    // 未选中 且 不是今天 且 没有边框色 且 没有填充色，就隐藏
    BOOL shouldHideShapeLayer = !self.selected && !self.dateIsToday && !borderColor && !fillColor;
    
    if (_shapeLayer.opacity == shouldHideShapeLayer) {
        _shapeLayer.opacity = !shouldHideShapeLayer;
    }
    if (!shouldHideShapeLayer) {
        
        CGColorRef cellFillColor = self.colorForCellFill.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.fillColor, cellFillColor)) {
            _shapeLayer.fillColor = cellFillColor;
        }
        
        CGColorRef cellBorderColor = self.colorForCellBorder.CGColor;
        if (!CGColorEqualToColor(_shapeLayer.strokeColor, cellBorderColor)) {
            _shapeLayer.strokeColor = cellBorderColor;
        }
        
        CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:_shapeLayer.bounds
                                                    cornerRadius:CGRectGetWidth(_shapeLayer.bounds)*0.5*self.borderRadius].CGPath;
        if (!CGPathEqualToPath(_shapeLayer.path, path)) {
            _shapeLayer.path = path;
        }
        
    }
    
    if (![_image isEqual:_imageView.image]) {
        _imageView.image = _image;
        _imageView.hidden = !_image;
    }
    
    if (_eventIndicator.hidden == (_numberOfEvents > 0)) {
        _eventIndicator.hidden = !_numberOfEvents;
    }
    
    _eventIndicator.numberOfEvents = self.numberOfEvents;
    _eventIndicator.color = self.colorsForEvents;

}


/// cell 在当前状态下的颜色
/// @param dictionary <#dictionary description#>
- (UIColor *)colorForCurrentStateInDictionary:(NSDictionary *)dictionary
{
    if (self.isSelected) {
        if (self.dateIsToday) {
            return dictionary[@(NMCalendarCellStateSelected|NMCalendarCellStateToday)] ?: dictionary[@(NMCalendarCellStateSelected)];
        }
        return dictionary[@(NMCalendarCellStateSelected)];
    }
    if (self.dateIsToday && [[dictionary allKeys] containsObject:@(NMCalendarCellStateToday)]) {
        return dictionary[@(NMCalendarCellStateToday)];
    }
    if (self.placeholder && [[dictionary allKeys] containsObject:@(NMCalendarCellStatePlaceholder)]) {
        return dictionary[@(NMCalendarCellStatePlaceholder)];
    }
    if (self.weekend && [[dictionary allKeys] containsObject:@(NMCalendarCellStateWeekend)]) {
        return dictionary[@(NMCalendarCellStateWeekend)];
    }
    return dictionary[@(NMCalendarCellStateNormal)];
}

#pragma mark - Properties

/// cell填充色
- (UIColor *)colorForCellFill
{
    if (self.selected) {
        return self.preferredFillSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
    }
    return self.preferredFillDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.backgroundColors];
}

// 标题文字颜色
- (UIColor *)colorForTitleLabel
{
    if (self.selected) {
        return self.preferredTitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
    }
    return self.preferredTitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.titleColors];
}

- (UIColor *)colorForSubtitleLabel
{
    if (self.selected) {
        return self.preferredSubtitleSelectionColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
    }
    return self.preferredSubtitleDefaultColor ?: [self colorForCurrentStateInDictionary:_appearance.subtitleColors];
}

- (UIColor *)colorForCellBorder
{
    if (self.selected) {
        return _preferredBorderSelectionColor ?: _appearance.borderSelectionColor;
    }
    return _preferredBorderDefaultColor ?: _appearance.borderDefaultColor;
}

- (NSArray<UIColor *> *)colorsForEvents
{
    if (self.selected) {
        return _preferredEventSelectionColors ?: @[_appearance.eventSelectionColor];
    }
    return _preferredEventDefaultColors ?: @[_appearance.eventDefaultColor];
}

- (CGFloat)borderRadius
{
    return _preferredBorderRadius >= 0 ? _preferredBorderRadius : _appearance.borderRadius;
}

#define OFFSET_PROPERTY(NAME,CAPITAL,ALTERNATIVE) \
\
@synthesize NAME = _##NAME; \
\
- (void)set##CAPITAL:(CGPoint)NAME \
{ \
    BOOL diff = !CGPointEqualToPoint(NAME, self.NAME); \
    _##NAME = NAME; \
    if (diff) { \
        [self setNeedsLayout]; \
    } \
} \
\
- (CGPoint)NAME \
{ \
    return CGPointEqualToPoint(_##NAME, CGPointInfinity) ? ALTERNATIVE : _##NAME; \
}

OFFSET_PROPERTY(preferredTitleOffset, PreferredTitleOffset, _appearance.titleOffset);
OFFSET_PROPERTY(preferredSubtitleOffset, PreferredSubtitleOffset, _appearance.subtitleOffset);
OFFSET_PROPERTY(preferredImageOffset, PreferredImageOffset, _appearance.imageOffset);
OFFSET_PROPERTY(preferredEventOffset, PreferredEventOffset, _appearance.eventOffset);

#undef OFFSET_PROPERTY

- (void)setCalendar:(NMCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _appearance = calendar.appearance;
        [self configureAppearance];
    }
}

- (void)setSubtitle:(NSString *)subtitle
{
    if (![_subtitle isEqualToString:subtitle]) {
        BOOL diff = (subtitle.length && !_subtitle.length) || (_subtitle.length && !subtitle.length);
        _subtitle = subtitle;
        if (diff) {
            [self setNeedsLayout];
        }
    }
}

@end


/// 事件标识符
@interface NMCalendarEventIndicator ()

@property (weak, nonatomic) UIView *contentView;

@property (strong, nonatomic) NSPointerArray *eventLayers;

@end

@implementation NMCalendarEventIndicator

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:view];
        self.contentView = view;
        /*
         类似于数组的集合，但具有更广泛的可用内存语义；继承自NSObject；NSPointerArray具有以下特点：

         与NSMutableArray一样，使用下标有序的插入或移除元素，且可修改数组内容；
         可以插入或删除nil，并且 nil 参与 count 的计算 , 超出后会自动扩容；
         count 可以 set，如果直接 set count，那么会使用 nil 占位；
         可以使用 weak 来修饰成员；
         成员可以是所有指针类型；
         遵循 NSFastEnumeration，可以通过 for...in 来进行遍历。
         */
        self.eventLayers = [NSPointerArray weakObjectsPointerArray];
        for (int i = 0; i < 3; i++) {
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = [UIColor clearColor].CGColor;
            [self.contentView.layer addSublayer:layer];
            [self.eventLayers addPointer:(__bridge void * _Nullable)(layer)];
        }
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat diameter = MIN(MIN(self.nmui_width, self.nmui_height),NMCalendarMaximumEventDotDiameter);
    self.contentView.nmui_height = self.nmui_height;
    self.contentView.nmui_width = (self.numberOfEvents*2-1)*diameter;
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if (layer == self.layer) {
        
        CGFloat diameter = MIN(MIN(self.nmui_width, self.nmui_height),NMCalendarMaximumEventDotDiameter);
        for (int i = 0; i < self.eventLayers.count; i++) {
            CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
            eventLayer.hidden = i >= self.numberOfEvents;
            if (!eventLayer.hidden) {
                eventLayer.frame = CGRectMake(2*i*diameter, (self.nmui_height-diameter)*0.5, diameter, diameter);
                if (eventLayer.cornerRadius != diameter/2) {
                    eventLayer.cornerRadius = diameter/2;
                }
            }
        }
    }
}

- (void)setColor:(id)color
{
    if (![_color isEqual:color]) {
        _color = color;
        
        if ([_color isKindOfClass:[UIColor class]]) {
            for (NSInteger i = 0; i < self.eventLayers.count; i++) {
                CALayer *layer = [self.eventLayers pointerAtIndex:i];
                layer.backgroundColor = [_color CGColor];
            }
        } else if ([_color isKindOfClass:[NSArray class]]) {
            NSArray<UIColor *> *colors = (NSArray *)_color;
            for (int i = 0; i < self.eventLayers.count; i++) {
                CALayer *eventLayer = [self.eventLayers pointerAtIndex:i];
                eventLayer.backgroundColor = colors[MIN(i,colors.count-1)].CGColor;
            }
        }
        
    }
}

- (void)setNumberOfEvents:(NSInteger)numberOfEvents
{
    if (_numberOfEvents != numberOfEvents) {
        _numberOfEvents = MIN(MAX(numberOfEvents,0),3);
        [self setNeedsLayout];
    }
}

@end

@implementation NMCalendarBlankCell

- (void)configureAppearance {}

@end
