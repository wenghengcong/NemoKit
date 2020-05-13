//
//  NMUIImagePreviewViewController.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICommonViewController.h"
#import "NMUICommonViewController.h"
#import "NMUIImagePreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@class NMUIImagePreviewViewTransitionAnimator;

typedef NS_ENUM(NSUInteger, NMUIImagePreviewViewControllerTransitioningStyle) {
    /// present 时整个界面渐现，dismiss 时整个界面渐隐，默认。
    NMUIImagePreviewViewControllerTransitioningStyleFade,
    
    /// present 时从某个指定的位置缩放到屏幕中央，dismiss 时缩放到指定位置，必须实现 sourceImageView 并返回一个非空的值
    NMUIImagePreviewViewControllerTransitioningStyleZoom
};

extern const CGFloat NMUIImagePreviewViewControllerCornerRadiusAutomaticDimension;

/**
 *  图片预览控件，主要功能由内部自带的 NMUIImagePreviewView 提供，由于以 viewController 的形式存在，所以适用于那种在单独界面里展示图片，或者需要从某张目标图片的位置以动画的形式放大进入预览界面的场景。
 *
 *  使用方式：
 *
 *  1. 使用 init 方法初始化
 *  2. 添加 self.imagePreviewView 的 delegate
 *  3. 以 push 或 present 的方式打开界面。如果是 present，则支持 NMUIImagePreviewViewControllerTransitioningStyle 里定义的动画。特别地，如果使用 zoom 方式，则需要通过 sourceImageView() 返回一个原界面上的 view 以作为 present 动画的起点和 dismiss 动画的终点。
 *
 *  @see NMUIImagePreviewView
 */
@interface NMUIImagePreviewViewController : NMUICommonViewController<UIViewControllerTransitioningDelegate>

/// 图片背后的黑色背景，默认为配置表里的 UIColorBlack
@property(nullable, nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

@property(null_resettable, nonatomic, strong, readonly) NMUIImagePreviewView *imagePreviewView;

/// 以 present 方式进入大图预览的时候使用的转场动画 animator，可通过 NMUIImagePreviewViewTransitionAnimator 提供的若干个 block 属性自定义动画，也可以完全重写一个自己的 animator。
@property(nullable, nonatomic, strong) __kindof NMUIImagePreviewViewTransitionAnimator *transitioningAnimator;

/// present 时的动画，默认为 fade，当修改了 presentingStyle 时会自动把 dismissingStyle 也修改为相同的值。
@property(nonatomic, assign) NMUIImagePreviewViewControllerTransitioningStyle presentingStyle;

/// dismiss 时的动画，默认为 fade，默认与 presentingStyle 的值相同，若需要与之不同，请在设置完 presentingStyle 之后再设置 dismissingStyle。
@property(nonatomic, assign) NMUIImagePreviewViewControllerTransitioningStyle dismissingStyle;

/// 当以 zoom 动画进入/退出大图预览时，会通过这个 block 获取到原本界面上的图片所在的 view，从而进行动画的位置计算，如果返回的值为 nil，则会强制使用 fade 动画。当同时存在 sourceImageView 和 sourceImageRect 时，只有 sourceImageRect 会被调用。
@property(nullable, nonatomic, copy)  UIView * _Nullable (^sourceImageView)(void);

/// 当以 zoom 动画进入/退出大图预览时，会通过这个 block 获取到原本界面上的图片所在的 view，从而进行动画的位置计算，如果返回的值为 CGRectZero，则会强制使用 fade 动画。注意返回值要进行坐标系转换。当同时存在 sourceImageView 和 sourceImageRect 时，只有 sourceImageRect 会被调用。
@property(nullable, nonatomic, copy) CGRect (^sourceImageRect)(void);

/// 当以 zoom 动画进入/退出大图预览时，可以指定一个圆角值，默认为 NMUIImagePreviewViewControllerCornerRadiusAutomaticDimension，也即自动从 sourceImageView.layer.cornerRadius 获取，如果使用的是 sourceImageRect 或希望自定义圆角值，则直接给 sourceImageCornerRadius 赋值即可。
@property(nonatomic, assign) CGFloat sourceImageCornerRadius;

/// 是否支持手势拖拽退出预览模式，默认为 YES。仅对以 present 方式进入大图预览的场景有效。
@property(nonatomic, assign) BOOL dismissingGestureEnabled;

@end

@interface NMUIImagePreviewViewController (UIAppearance)

+ (instancetype)appearance;
@end

NS_ASSUME_NONNULL_END
