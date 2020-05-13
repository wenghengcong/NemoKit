//
//  UIScrollView+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (NMUI)


/// 判断UIScrollView是否已经处于顶部（当UIScrollView内容不够多不可滚动时，也认为是在顶部）
@property(nonatomic, assign, readonly) BOOL nmui_alreadyAtTop;

/// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
@property(nonatomic, assign, readonly) BOOL nmui_alreadyAtBottom;

/// UIScrollView 的真正 inset，在 iOS11 以后需要用到 adjustedContentInset 而在 iOS11 以前只需要用 contentInset
@property(nonatomic, assign, readonly) UIEdgeInsets nmui_contentInset;

/**
 UIScrollView 默认的 contentInset，会自动将 contentInset 和 scrollIndicatorInsets 都设置为这个值并且调用一次 nmui_scrollToTopUponContentInsetTopChange 设置默认的 contentOffset，一般用于 UIScrollViewContentInsetAdjustmentNever 的列表。
  @warning 如果 scrollView 被添加到某个 viewController 上，则只有在 viewController viewDidAppear 之前（不包含 viewDidAppear）设置这个属性才会自动滚到顶部，如果在 viewDidAppear 之后才添加到 viewController 上，则只有第一次设置 nmui_initialContentInset 时才会滚动到顶部。这样做的目的是为了避免在 scrollView 已经显示出来并滚动到列表中间后，由于某些原因，contentInset 发生了中间值的变动（也即一开始是正确的值，中间变成错误的值，再变回正确的值），此时列表会突然跳到顶部的问题。
 */
@property(nonatomic, assign) UIEdgeInsets nmui_initialContentInset;

/**
 * 判断当前的scrollView内容是否足够滚动
 * @warning 避免与<i>scrollEnabled</i>混淆
 */
- (BOOL)nmui_canScroll;

/**
 * 不管当前scrollView是否可滚动，直接将其滚动到最顶部
 * @param force 是否无视[self nmui_canScroll]而强制滚动
 * @param animated 是否用动画表现
 */
- (void)nmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated;

/**
 * 等同于[self nmui_scrollToTopForce:NO animated:animated]
 */
- (void)nmui_scrollToTopAnimated:(BOOL)animated;

/// 等同于[self nmui_scrollToTopAnimated:NO]
- (void)nmui_scrollToTop;

/**
 滚到列表顶部，但如果 contentInset.top 与上一次相同则不会执行滚动操作，通常用于 UIScrollViewContentInsetAdjustmentNever 的 scrollView 设置完业务的 contentInset 后将列表滚到顶部。
 */
- (void)nmui_scrollToTopUponContentInsetTopChange;

/**
 * 如果当前的scrollView可滚动，则将其滚动到最底部
 * @param animated 是否用动画表现
 * @see [UIScrollView nmui_canScroll]
 */
- (void)nmui_scrollToBottomAnimated:(BOOL)animated;

/// 等同于[self nmui_scrollToBottomAnimated:NO]
- (void)nmui_scrollToBottom;

// 立即停止滚动，用于那种手指已经离开屏幕但列表还在滚动的情况。
- (void)nmui_stopDeceleratingIfNeeded;

/**
 以动画的形式修改 contentInset
 
 @param contentInset 要修改为的 contentInset
 @param animated 是否要使用动画修改
 */
- (void)nmui_setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
