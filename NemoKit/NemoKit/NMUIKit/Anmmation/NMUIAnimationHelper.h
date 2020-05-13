//
//  NMUIAnimationHelper.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMUIEasings.h"

@interface NMUIAnimationHelper : NSObject

typedef NS_ENUM(NSInteger, NMUIAnimationEasings) {
    NMUIAnimationEasingsLinear,
    NMUIAnimationEasingsEaseInSine,
    NMUIAnimationEasingsEaseOutSine,
    NMUIAnimationEasingsEaseInOutSine,
    NMUIAnimationEasingsEaseInQuad,
    NMUIAnimationEasingsEaseOutQuad,
    NMUIAnimationEasingsEaseInOutQuad,
    NMUIAnimationEasingsEaseInCubic,
    NMUIAnimationEasingsEaseOutCubic,
    NMUIAnimationEasingsEaseInOutCubic,
    NMUIAnimationEasingsEaseInQuart,
    NMUIAnimationEasingsEaseOutQuart,
    NMUIAnimationEasingsEaseInOutQuart,
    NMUIAnimationEasingsEaseInQuint,
    NMUIAnimationEasingsEaseOutQuint,
    NMUIAnimationEasingsEaseInOutQuint,
    NMUIAnimationEasingsEaseInExpo,
    NMUIAnimationEasingsEaseOutExpo,
    NMUIAnimationEasingsEaseInOutExpo,
    NMUIAnimationEasingsEaseInCirc,
    NMUIAnimationEasingsEaseOutCirc,
    NMUIAnimationEasingsEaseInOutCirc,
    NMUIAnimationEasingsEaseInBack,
    NMUIAnimationEasingsEaseOutBack,
    NMUIAnimationEasingsEaseInOutBack,
    NMUIAnimationEasingsEaseInElastic,
    NMUIAnimationEasingsEaseOutElastic,
    NMUIAnimationEasingsEaseInOutElastic,
    NMUIAnimationEasingsEaseInBounce,
    NMUIAnimationEasingsEaseOutBounce,
    NMUIAnimationEasingsEaseInOutBounce,
    NMUIAnimationEasingsSpring, // 自定义任意弹簧曲线
    NMUIAnimationEasingsSpringKeyboard // 系统键盘动画曲线
};

/**
 * 动画插值器
 * 根据给定的 easing 曲线，计算出初始值和结束值在当前的时间 time 对应的值。value 目前现在支持 NSNumber、UIColor 以及 NSValue 类型的 CGPoint、CGSize、CGRect、CGAffineTransform、UIEdgeInsets
 * @param fromValue 初始值
 * @param toValue 结束值
 * @param time 当前帧时间
 * @param easing 曲线，见`NMUIAnimationEasings`
 */
+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(NMUIAnimationEasings)easing;
/**
 * 动画插值器，支持弹簧参数
 * mass|damping|stiffness|initialVelocity 仅在 NMUIAnimationEasingsSpring 的时候才生效
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(NMUIAnimationEasings)easing;

@end
