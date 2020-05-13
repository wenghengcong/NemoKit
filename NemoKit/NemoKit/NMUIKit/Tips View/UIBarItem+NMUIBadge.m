//
//  UIBarItem+NMUIBadge.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIBarItem+NMUIBadge.h"
#import "NMBCore.h"
#import "NMBFLog.h"
#import "NMUILabel.h"
#import "UIView+NMUI.h"
#import "UIBarItem+NMUI.h"
#import "UITabBarItem+NMUI.h"
#import "UIViewController+NMUI.h"

@interface _NMUIBadgeLabel : NMUILabel

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;
@end

@interface _NMUIUpdatesIndicatorView : UIView

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;
@end

@interface UIBarItem ()

@property(nonatomic, strong, readwrite) _NMUIBadgeLabel *nmui_badgeLabel;
@property(nonatomic, strong, readwrite) _NMUIUpdatesIndicatorView *nmui_updatesIndicatorView;
@end

@implementation UIBarItem (NMUIBadge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证配置表里的默认值正确被设置
        NMBFExtendImplementationOfNonVoidMethodWithoutArguments([UIBarItem class], @selector(init), __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, __kindof UIBarItem *originReturnValue) {
            [selfObject nmuibaritem_didInitialize];
            return originReturnValue;
        });
        
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UIBarItem class], @selector(initWithCoder:), NSCoder *, __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, NSCoder *firstArgv, __kindof UIBarItem *originReturnValue) {
            [selfObject nmuibaritem_didInitialize];
            return originReturnValue;
        });
        
        // UITabBarButton 在 layoutSubviews 时每次都重新让 imageView 和 label addSubview:，这会导致我们用 nmui_layoutSubviewsBlock 时产生持续的重复调用（但又不死循环，因为每次都在下一次 runloop 执行，而且奇怪的是如果不放到下一次 runloop，反而不会重复调用），所以这里 hack 地屏蔽 addSubview: 操作
        NMBFOverrideImplementation(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UITab", @"BarButton"]), @selector(addSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *firstArgv) {
                
                if (firstArgv.superview == selfObject) {
                    return;
                }
                
                if (selfObject == firstArgv) {
                    UIViewController *visibleViewController = [NMUIHelper visibleViewController];
                    NSString *log = [NSString stringWithFormat:@"UIBarItem (NMUIBadge) addSubview:, 把自己作为 subview 添加到自己身上，self = %@, visibleViewController = %@, visibleState = %@, viewControllers = %@\n%@", selfObject, visibleViewController, @(visibleViewController.nmui_visibleState), visibleViewController.navigationController.viewControllers, [NSThread callStackSymbols]];
                    NSAssert(NO, log);
                    NMBFLogWarn(@"UIBarItem (NMUIBadge)", @"%@", log);
                }
                
                // call super
                IMP originalIMP = originalIMPProvider();
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMP;
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)nmuibaritem_didInitialize {
    self.nmui_badgeBackgroundColor = BadgeBackgroundColor;
    self.nmui_badgeTextColor = BadgeTextColor;
    self.nmui_badgeFont = BadgeFont;
    self.nmui_badgeContentEdgeInsets = BadgeContentEdgeInsets;
    self.nmui_badgeCenterOffset = BadgeCenterOffset;
    self.nmui_badgeCenterOffsetLandscape = BadgeCenterOffsetLandscape;
    
    self.nmui_updatesIndicatorColor = UpdatesIndicatorColor;
    self.nmui_updatesIndicatorSize = UpdatesIndicatorSize;
    self.nmui_updatesIndicatorCenterOffset = UpdatesIndicatorCenterOffset;
    self.nmui_updatesIndicatorCenterOffsetLandscape = UpdatesIndicatorCenterOffsetLandscape;
}

#pragma mark - Badge

static char kAssociatedObjectKey_badgeInteger;
- (void)setNmui_badgeInteger:(NSUInteger)nmui_badgeInteger {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeInteger, @(nmui_badgeInteger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.nmui_badgeString = nmui_badgeInteger > 0 ? [NSString stringWithFormat:@"%@", @(nmui_badgeInteger)] : nil;
}

- (NSUInteger)nmui_badgeInteger {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeInteger)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_badgeString;
- (void)setNmui_badgeString:(NSString *)nmui_badgeString {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeString, nmui_badgeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (nmui_badgeString.length) {
        if (!self.nmui_badgeLabel) {
            self.nmui_badgeLabel = [[_NMUIBadgeLabel alloc] init];
            self.nmui_badgeLabel.clipsToBounds = YES;
            self.nmui_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.nmui_badgeLabel.backgroundColor = self.nmui_badgeBackgroundColor;
            self.nmui_badgeLabel.textColor = self.nmui_badgeTextColor;
            self.nmui_badgeLabel.font = self.nmui_badgeFont;
            self.nmui_badgeLabel.contentEdgeInsets = self.nmui_badgeContentEdgeInsets;
            self.nmui_badgeLabel.centerOffset = self.nmui_badgeCenterOffset;
            self.nmui_badgeLabel.centerOffsetLandscape = self.nmui_badgeCenterOffsetLandscape;
            if (!self.nmui_viewDidSetBlock) {
                self.nmui_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [view addSubview:item.nmui_updatesIndicatorView];
                    [view addSubview:item.nmui_badgeLabel];
                    [view setNeedsLayout];
                    [view layoutIfNeeded];
                };
            }
            // 之前 item 已经 set 完 view，则手动触发一次
            if (self.nmui_view) {
                self.nmui_viewDidSetBlock(self, self.nmui_view);
            }
            if (!self.nmui_viewDidLayoutSubviewsBlock) {
                self.nmui_viewDidLayoutSubviewsBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [item layoutSubviews];
                };
            }
        }
        self.nmui_badgeLabel.text = nmui_badgeString;
        self.nmui_badgeLabel.hidden = NO;
        [self setNeedsUpdateBadgeLabelLayout];
    } else {
        self.nmui_badgeLabel.hidden = YES;
    }
}

- (NSString *)nmui_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setNmui_badgeBackgroundColor:(UIColor *)nmui_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, nmui_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.backgroundColor = nmui_badgeBackgroundColor;
    }
}

- (UIColor *)nmui_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setNmui_badgeTextColor:(UIColor *)nmui_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, nmui_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.textColor = nmui_badgeTextColor;
    }
}

- (UIColor *)nmui_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setNmui_badgeFont:(UIFont *)nmui_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, nmui_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.font = nmui_badgeFont;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIFont *)nmui_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setNmui_badgeContentEdgeInsets:(UIEdgeInsets)nmui_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:nmui_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.contentEdgeInsets = nmui_badgeContentEdgeInsets;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIEdgeInsets)nmui_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setNmui_badgeCenterOffset:(CGPoint)nmui_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:nmui_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.centerOffset = nmui_badgeCenterOffset;
    }
}

- (CGPoint)nmui_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setNmui_badgeCenterOffsetLandscape:(CGPoint)nmui_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:nmui_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_badgeLabel) {
        self.nmui_badgeLabel.centerOffsetLandscape = nmui_badgeCenterOffsetLandscape;
    }
}

- (CGPoint)nmui_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_badgeLabel;
- (void)setNmui_badgeLabel:(UILabel *)nmui_badgeLabel {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeLabel, nmui_badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_NMUIBadgeLabel *)nmui_badgeLabel {
    return (_NMUIBadgeLabel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeLabel);
}

- (void)setNeedsUpdateBadgeLabelLayout {
    if (self.nmui_badgeString.length) {
        [self.nmui_view setNeedsLayout];
    }
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setNmui_shouldShowUpdatesIndicator:(BOOL)nmui_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(nmui_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (nmui_shouldShowUpdatesIndicator) {
        if (!self.nmui_updatesIndicatorView) {
            self.nmui_updatesIndicatorView = [[_NMUIUpdatesIndicatorView alloc] nmui_initWithSize:self.nmui_updatesIndicatorSize];
            self.nmui_updatesIndicatorView.layer.cornerRadius = CGRectGetHeight(self.nmui_updatesIndicatorView.bounds) / 2;
            self.nmui_updatesIndicatorView.backgroundColor = self.nmui_updatesIndicatorColor;
            self.nmui_updatesIndicatorView.centerOffset = self.nmui_updatesIndicatorCenterOffset;
            self.nmui_updatesIndicatorView.centerOffsetLandscape = self.nmui_updatesIndicatorCenterOffsetLandscape;
            if (!self.nmui_viewDidLayoutSubviewsBlock) {
                self.nmui_viewDidLayoutSubviewsBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [item layoutSubviews];
                };
            }
            if (!self.nmui_viewDidSetBlock) {
                self.nmui_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [view addSubview:item.nmui_updatesIndicatorView];
                    [view addSubview:item.nmui_badgeLabel];
                    [view setNeedsLayout];
                    [view layoutIfNeeded];
                };
            }
            // 之前 item 已经 set 完 view，则手动触发一次
            if (self.nmui_view) {
                self.nmui_viewDidSetBlock(self, self.nmui_view);
            }
        }
        [self setNeedsUpdateIndicatorLayout];
        self.nmui_updatesIndicatorView.hidden = NO;
    } else {
        self.nmui_updatesIndicatorView.hidden = YES;
    }
}

- (BOOL)nmui_shouldShowUpdatesIndicator {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator)) boolValue];
}

static char kAssociatedObjectKey_updatesIndicatorColor;
- (void)setNmui_updatesIndicatorColor:(UIColor *)nmui_updatesIndicatorColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor, nmui_updatesIndicatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_updatesIndicatorView) {
        self.nmui_updatesIndicatorView.backgroundColor = nmui_updatesIndicatorColor;
    }
}

- (UIColor *)nmui_updatesIndicatorColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor);
}

static char kAssociatedObjectKey_updatesIndicatorSize;
- (void)setNmui_updatesIndicatorSize:(CGSize)nmui_updatesIndicatorSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize, [NSValue valueWithCGSize:nmui_updatesIndicatorSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_updatesIndicatorView) {
        self.nmui_updatesIndicatorView.frame = CGRectSetSize(self.nmui_updatesIndicatorView.frame, nmui_updatesIndicatorSize);
        self.nmui_updatesIndicatorView.layer.cornerRadius = nmui_updatesIndicatorSize.height / 2;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGSize)nmui_updatesIndicatorSize {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize)) CGSizeValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffset;
- (void)setNmui_updatesIndicatorCenterOffset:(CGPoint)nmui_updatesIndicatorCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset, [NSValue valueWithCGPoint:nmui_updatesIndicatorCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_updatesIndicatorView) {
        self.nmui_updatesIndicatorView.centerOffset = nmui_updatesIndicatorCenterOffset;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)nmui_updatesIndicatorCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape;
- (void)setNmui_updatesIndicatorCenterOffsetLandscape:(CGPoint)nmui_updatesIndicatorCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape, [NSValue valueWithCGPoint:nmui_updatesIndicatorCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.nmui_updatesIndicatorView) {
        self.nmui_updatesIndicatorView.centerOffsetLandscape = nmui_updatesIndicatorCenterOffsetLandscape;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)nmui_updatesIndicatorCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorView;
- (void)setNmui_updatesIndicatorView:(UIView *)nmui_updatesIndicatorView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView, nmui_updatesIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_NMUIUpdatesIndicatorView *)nmui_updatesIndicatorView {
    return (_NMUIUpdatesIndicatorView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView);
}

- (void)setNeedsUpdateIndicatorLayout {
    if (self.nmui_shouldShowUpdatesIndicator) {
        [self.nmui_view setNeedsLayout];
    }
}

#pragma mark - Common

BeginIgnoreDeprecatedWarning
- (void)layoutSubviews {
    
    if (self.nmui_updatesIndicatorView && !self.nmui_updatesIndicatorView.hidden) {
        CGPoint centerOffset = IS_LANDSCAPE ? self.nmui_updatesIndicatorView.centerOffsetLandscape : self.nmui_updatesIndicatorView.centerOffset;
        
        UIView *superview = self.nmui_updatesIndicatorView.superview;
        if ([self isKindOfClass:[UITabBarItem class]]) {
            // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
            UIView *imageView = ((UITabBarItem *)self).nmui_imageView;
            if (!imageView) return;
            
            self.nmui_updatesIndicatorView.frame = CGRectSetXY(self.nmui_updatesIndicatorView.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.nmui_updatesIndicatorView.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.nmui_updatesIndicatorView.frame) + centerOffset.y);
        } else {
            self.nmui_updatesIndicatorView.frame = CGRectSetXY(self.nmui_updatesIndicatorView.frame, CGFloatGetCenter(superview.nmui_width, self.nmui_updatesIndicatorView.nmui_width) + centerOffset.x, CGFloatGetCenter(superview.nmui_height, self.nmui_updatesIndicatorView.nmui_height) + centerOffset.y);
        }
        
        [superview bringSubviewToFront:self.nmui_updatesIndicatorView];
    }
    
    if (self.nmui_badgeLabel && !self.nmui_badgeLabel.hidden) {
        [self.nmui_badgeLabel sizeToFit];
        self.nmui_badgeLabel.layer.cornerRadius = MIN(self.nmui_badgeLabel.nmui_height / 2, self.nmui_badgeLabel.nmui_width / 2);
        
        CGPoint centerOffset = IS_LANDSCAPE ? self.nmui_badgeLabel.centerOffsetLandscape : self.nmui_badgeLabel.centerOffset;
        
        UIView *superview = self.nmui_badgeLabel.superview;
        if ([self isKindOfClass:[UITabBarItem class]]) {
            // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
            UIView *imageView = ((UITabBarItem *)self).nmui_imageView;
            if (!imageView) return;
            
            self.nmui_badgeLabel.frame = CGRectSetXY(self.nmui_badgeLabel.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.nmui_badgeLabel.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.nmui_badgeLabel.frame) + centerOffset.y);
        } else {
            self.nmui_badgeLabel.frame = CGRectSetXY(self.nmui_badgeLabel.frame, CGFloatGetCenter(superview.nmui_width, self.nmui_badgeLabel.nmui_width) + centerOffset.x, CGFloatGetCenter(superview.nmui_height, self.nmui_badgeLabel.nmui_height) + centerOffset.y);
        }
        
        [superview bringSubviewToFront:self.nmui_badgeLabel];
    }
}
EndIgnoreDeprecatedWarning

@end

@implementation _NMUIUpdatesIndicatorView
BeginIgnoreDeprecatedWarning
- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}
EndIgnoreDeprecatedWarning
@end

@implementation _NMUIBadgeLabel
BeginIgnoreDeprecatedWarning
- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}
EndIgnoreDeprecatedWarning
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    
    // 只有一个字的时候保证它是一个正方形
    if (self.text.length <= 1) {
        CGFloat finalSize = MAX(result.width, result.height);
        result = CGSizeMake(finalSize, finalSize);
    }
    
    return result;
}

@end
