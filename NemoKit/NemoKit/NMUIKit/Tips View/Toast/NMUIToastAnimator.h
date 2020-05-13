//
//  NMUIToastAnimator.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NMUIToastView;

/**
 * `NMUIToastAnimatorDelegate`是所有`NMUIToastAnimator`或者其子类必须遵循的协议，是整个动画过程实现的地方。
 */
@protocol NMUIToastAnimatorDelegate <NSObject>

@required

- (void)showWithCompletion:(void (^)(BOOL finished))completion;
- (void)hideWithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;
- (BOOL)isAnimating;
@end


// TODO: 实现多种animation类型

typedef NS_ENUM(NSInteger, NMUIToastAnimationType) {
    NMUIToastAnimationTypeFade      = 0,
    NMUIToastAnimationTypeZoom,
    NMUIToastAnimationTypeSlide
};

/**
 * `NMUIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`NMUIToastAnimator`，然后实现`NMUIToastAnimatorDelegate`中的方法，即可实现自定义的动画。NMUIToastAnimator默认也提供了几种type的动画：1、NMUIToastAnimationTypeFade；2、NMUIToastAnimationTypeZoom；3、NMUIToastAnimationTypeSlide；
 */
@interface NMUIToastAnimator : NSObject <NMUIToastAnimatorDelegate>

/**
 * 初始化方法，请务必使用这个方法来初始化。
 *
 * @param toastView 要使用这个animator的NMUIToastView实例。
 */
- (instancetype)initWithToastView:(NMUIToastView *)toastView NS_DESIGNATED_INITIALIZER;

/**
 * 获取初始化传进来的NMUIToastView。
 */
@property(nonatomic, weak, readonly) NMUIToastView *toastView;

/**
 * 指定NMUIToastAnimator做动画的类型type。此功能暂时未实现，目前所有动画类型都是NMUIToastAnimationTypeFade。
 */
@property(nonatomic, assign) NMUIToastAnimationType animationType;

@end
