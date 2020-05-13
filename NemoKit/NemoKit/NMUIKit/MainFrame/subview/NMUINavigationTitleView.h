//
//  NMUINavigationTitleView.h
//  Nemo
//
//  Created by Hunt on 2019/11/2.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUINavigationTitleView;

@protocol NMUINavigationTitleViewDelegate <NSObject>

@optional

/**
 点击 titleView 后的回调，只需设置 titleView.userInteractionEnabled = YES 后即可使用。不过一般都用于配合 NMUINavigationTitleViewAccessoryTypeDisclosureIndicator。
 
 @param titleView 被点击的 titleView
 @param isActive titleView 是否处于活跃状态（所谓的活跃，对应右边的箭头而言，就是点击后箭头向上的状态）
 */
- (void)didTouchTitleView:(NMUINavigationTitleView *)titleView isActive:(BOOL)isActive;

/**
 titleView 的活跃状态发生变化时会被调用，也即 [titleView setActive:] 被调用时。
 
 @param active 是否处于活跃状态
 @param titleView 变换状态的 titleView
 */
- (void)didChangedActive:(BOOL)active forTitleView:(NMUINavigationTitleView *)titleView;

@end

/// 设置title和subTitle的布局方式，默认是水平布局。
typedef NS_ENUM(NSInteger, NMUINavigationTitleViewStyle) {
    NMUINavigationTitleViewStyleDefault,                // 水平
    NMUINavigationTitleViewStyleSubTitleVertical        // 垂直
};

/// 设置titleView的样式，默认没有任何修饰
typedef NS_ENUM(NSInteger, NMUINavigationTitleViewAccessoryType) {
    NMUINavigationTitleViewAccessoryTypeNone,                   // 默认
    NMUINavigationTitleViewAccessoryTypeDisclosureIndicator     // 有下拉箭头
};


/**
 *  可作为navgationItem.titleView 的标题控件。
 *
 *  支持主副标题，且可控制主副标题的布局方式（水平或垂直）；支持在左边显示loading，在右边显示accessoryView（如箭头）。
 *
 *  默认情况下 titleView 是不支持点击的，需要支持点击的情况下，请把 `userInteractionEnabled` 设为 `YES`。
 *
 *  若要监听 titleView 的点击事件，有两种方法：
 *
 *  1. 使用 UIControl 默认的 addTarget:action:forControlEvents: 方式。这种适用于单纯的点击，不需要涉及到状态切换等。
 *  2. 使用 NMUINavigationTitleViewDelegate 提供的接口。这种一般配合 titleView.accessoryType 来使用，这样就不用自己去做 accessoryView 的旋转、active 状态的维护等。
 */
@interface NMUINavigationTitleView : UIControl

@property(nonatomic, weak) id<NMUINavigationTitleViewDelegate> delegate;
@property(nonatomic, assign) NMUINavigationTitleViewStyle style;
@property(nonatomic, assign, getter=isActive) BOOL active;
@property(nonatomic, assign) CGFloat maximumWidth UI_APPEARANCE_SELECTOR;

#pragma mark - Titles

@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong, readonly) UILabel *subtitleLabel;
@property(nonatomic, copy) NSString *subtitle;

/// 当 tintColor 发生变化时是否要自动把 titleLabel、subtitleLabel、loadingView 的颜色也更新为 tintColor 的色值，默认为 YES，如果你自己修改了 titleLabel、subtitleLabel、loadingView 的颜色，需要把这个值置为 NO
@property(nonatomic, assign) BOOL adjustsSubviewsTintColorAutomatically UI_APPEARANCE_SELECTOR;

/// 水平布局下的标题字体，默认为 NavBarTitleFont
@property(nonatomic, strong) UIFont *horizontalTitleFont UI_APPEARANCE_SELECTOR;

/// 水平布局下的副标题的字体，默认为 NavBarTitleFont
@property(nonatomic, strong) UIFont *horizontalSubtitleFont UI_APPEARANCE_SELECTOR;

/// 垂直布局下的标题字体，默认为 UIFontMake(15)
@property(nonatomic, strong) UIFont *verticalTitleFont UI_APPEARANCE_SELECTOR;

/// 垂直布局下的副标题字体，默认为 UIFontLightMake(12)
@property(nonatomic, strong) UIFont *verticalSubtitleFont UI_APPEARANCE_SELECTOR;

/// 标题的上下左右间距，当标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
@property(nonatomic, assign) UIEdgeInsets titleEdgeInsets UI_APPEARANCE_SELECTOR;

/// 副标题的上下左右间距，当副标题不显示时，计算大小及布局时也不考虑这个间距，默认为 UIEdgeInsetsZero
@property(nonatomic, assign) UIEdgeInsets subtitleEdgeInsets UI_APPEARANCE_SELECTOR;

#pragma mark - Loading

@property(nonatomic, strong, readonly) UIActivityIndicatorView *loadingView;

/*
 *  设置是否需要loading，只有开启了这个属性，loading才有可能显示出来。默认值为NO。
 */
@property(nonatomic, assign) BOOL needsLoadingView;

/*
 *  `needsLoadingView`开启之后，通过这个属性来控制loading的显示和隐藏，默认值为YES
 *
 *  @see needsLoadingView
 */
@property(nonatomic, assign) BOOL loadingViewHidden;

/*
 *  如果为YES则title居中，loading放在title的左边，title右边有一个跟左边loading一样大的占位空间；如果为NO，loading和title整体居中。默认值为YES。
 */
@property(nonatomic, assign) BOOL needsLoadingPlaceholderSpace;

@property(nonatomic, assign) CGSize loadingViewSize UI_APPEARANCE_SELECTOR;

/*
 *  控制loading距离右边的距离
 */
@property(nonatomic, assign) CGFloat loadingViewMarginRight UI_APPEARANCE_SELECTOR;

#pragma mark - Accessory

/*
 *  当accessoryView不为空时，NMUINavigationTitleViewAccessoryType设置无效，一直都是None
 */
@property(nonatomic, strong) UIView *accessoryView;

/*
 *  只有当accessoryView为空时才有效
 */
@property(nonatomic, assign) NMUINavigationTitleViewAccessoryType accessoryType;

/*
 *  用于微调accessoryView的位置
 */
@property(nonatomic, assign) CGPoint accessoryViewOffset UI_APPEARANCE_SELECTOR;

/*
 *  如果为YES则title居中，`accessoryView`放在title的左边或右边；如果为NO，`accessoryView`和title整体居中。默认值为NO。
 */
@property(nonatomic, assign) BOOL needsAccessoryPlaceholderSpace;

/*
 *  同 accessoryView，用于 subtitle 的 AccessoryView
 *  @warn 为了美观考虑，该属性只对 NMUINavigationTitleViewStyleSubTitleVertical 有效
 */
@property(nonatomic, strong) UIView *subAccessoryView;

/*
 *  用于微调 subAccessoryView 的位置
 */
@property(nonatomic, assign) CGPoint subAccessoryViewOffset UI_APPEARANCE_SELECTOR;

/*
 *  同 needsAccessoryPlaceholderSpace，用于 subtitle
 */
@property(nonatomic, assign) BOOL needsSubAccessoryPlaceholderSpace;

/*
 *  初始化方法
 */
- (instancetype)initWithStyle:(NMUINavigationTitleViewStyle)style;

@end


NS_ASSUME_NONNULL_END
