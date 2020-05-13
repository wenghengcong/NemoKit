//
//  NMUIAnimationHelper.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIAnimationHelper.h"
#import "NMBCore.h"

#define SpringDefaultMass 1.0
#define SpringDefaultDamping 18.0
#define SpringDefaultStiffness 82.0
#define SpringDefaultInitialVelocity 0.0

@implementation NMUIAnimationHelper

+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(NMUIAnimationEasings)easing {
    return [self interpolateSpringFromValue:fromValue toValue:toValue time:time mass:SpringDefaultMass damping:SpringDefaultDamping stiffness:SpringDefaultStiffness initialVelocity:SpringDefaultInitialVelocity easing:easing];
}

/*
 * 插值器，遇到新的类型再添加
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(NMUIAnimationEasings)easing {
    
    if ([fromValue isKindOfClass:[NSNumber class]]) { // NSNumber
        CGFloat from = [fromValue floatValue];
        CGFloat to = [toValue floatValue];
        CGFloat result = interpolateSpring(from, to, time, easing, mass, damping, stiffness, initialVelocity);
        return [NSNumber numberWithFloat:result];
    }
    
    else if ([fromValue isKindOfClass:[UIColor class]]) { // UIColor
        UIColor *from = (UIColor *)fromValue;
        UIColor *to = (UIColor *)toValue;
        CGFloat fromRed, toRed, curRed = 0;
        CGFloat fromGreen, toGreen, curGreen = 0;
        CGFloat fromBlue, toBlue, curBlue = 0;
        CGFloat fromAlpha, toAlpha, curAlpha = 0;
        [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
        [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
        curRed = interpolateSpring(fromRed, toRed, time, easing, mass, damping, stiffness, initialVelocity);
        curGreen = interpolateSpring(fromGreen, toGreen, time, easing, mass, damping, stiffness, initialVelocity);
        curBlue = interpolateSpring(fromBlue, toBlue, time, easing, mass, damping, stiffness, initialVelocity);
        curAlpha = interpolateSpring(fromAlpha, toAlpha, time, easing, mass, damping, stiffness, initialVelocity);
        UIColor *result = [UIColor colorWithRed:curRed green:curGreen blue:curBlue alpha:curAlpha];
        return result;
    }
    
    else if ([fromValue isKindOfClass:[NSValue class]]) { // NSValue
        const char *type = [(NSValue *)fromValue objCType];
        if (strcmp(type, @encode(CGPoint)) == 0) {
            CGPoint from = [fromValue CGPointValue];
            CGPoint to = [toValue CGPointValue];
            CGPoint result = CGPointMake(interpolateSpring(from.x, to.x, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.y, to.y, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGPoint:result];
        }
        else if (strcmp(type, @encode(CGSize)) == 0) {
            CGSize from = [fromValue CGSizeValue];
            CGSize to = [toValue CGSizeValue];
            CGSize result = CGSizeMake(interpolateSpring(from.width, to.width, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.height, to.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGSize:result];
        }
        else if (strcmp(type, @encode(CGRect)) == 0) {
            CGRect from = [fromValue CGRectValue];
            CGRect to = [toValue CGRectValue];
            CGRect result = CGRectMake(interpolateSpring(from.origin.x, to.origin.x, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.origin.y, to.origin.y, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.size.width, to.size.width, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.size.height, to.size.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGRect:result];
        }
        else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
            CGAffineTransform from = [fromValue CGAffineTransformValue];
            CGAffineTransform to = [toValue CGAffineTransformValue];
            CGAffineTransform result = CGAffineTransformIdentity;
            result.a = interpolateSpring(from.a, to.a, time, easing, mass, damping, stiffness, initialVelocity);
            result.b = interpolateSpring(from.b, to.b, time, easing, mass, damping, stiffness, initialVelocity);
            result.c = interpolateSpring(from.c, to.c, time, easing, mass, damping, stiffness, initialVelocity);
            result.d = interpolateSpring(from.d, to.d, time, easing, mass, damping, stiffness, initialVelocity);
            result.tx = interpolateSpring(from.tx, to.tx, time, easing, mass, damping, stiffness, initialVelocity);
            result.ty = interpolateSpring(from.ty, to.ty, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithCGAffineTransform:result];
        }
        else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
            UIEdgeInsets from = [fromValue UIEdgeInsetsValue];
            UIEdgeInsets to = [toValue UIEdgeInsetsValue];
            UIEdgeInsets result = UIEdgeInsetsZero;
            result.top = interpolateSpring(from.top, to.top, time, easing, mass, damping, stiffness, initialVelocity);
            result.left = interpolateSpring(from.left, to.left, time, easing, mass, damping, stiffness, initialVelocity);
            result.bottom = interpolateSpring(from.bottom, to.bottom, time, easing, mass, damping, stiffness, initialVelocity);
            result.right = interpolateSpring(from.right, to.right, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithUIEdgeInsets:result];
        }
    }
    
    return (time < 0.5) ? fromValue: toValue;
}

CGFloat interpolate(CGFloat from, CGFloat to, CGFloat time, NMUIAnimationEasings easing) {
    return interpolateSpring(from, to, time, easing, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
}

CGFloat interpolateSpring(CGFloat from, CGFloat to, CGFloat time, NMUIAnimationEasings easing, CGFloat springMass, CGFloat springDamping, CGFloat springStiffness, CGFloat springInitialVelocity) {
    switch (easing) {
        case NMUIAnimationEasingsLinear:
            time = NMUI_Linear(time);
            break;
        case NMUIAnimationEasingsEaseInSine:
            time = NMUI_EaseInSine(time);
            break;
        case NMUIAnimationEasingsEaseOutSine:
            time = NMUI_EaseOutSine(time);
            break;
        case NMUIAnimationEasingsEaseInOutSine:
            time = NMUI_EaseInOutSine(time);
            break;
        case NMUIAnimationEasingsEaseInQuad:
            time = NMUI_EaseInQuad(time);
            break;
        case NMUIAnimationEasingsEaseOutQuad:
            time = NMUI_EaseOutQuad(time);
            break;
        case NMUIAnimationEasingsEaseInOutQuad:
            time = NMUI_EaseInOutQuad(time);
            break;
        case NMUIAnimationEasingsEaseInCubic:
            time = NMUI_EaseInCubic(time);
            break;
        case NMUIAnimationEasingsEaseOutCubic:
            time = NMUI_EaseOutCubic(time);
            break;
        case NMUIAnimationEasingsEaseInOutCubic:
            time = NMUI_EaseInOutCubic(time);
            break;
        case NMUIAnimationEasingsEaseInQuart:
            time = NMUI_EaseInQuart(time);
            break;
        case NMUIAnimationEasingsEaseOutQuart:
            time = NMUI_EaseOutQuart(time);
            break;
        case NMUIAnimationEasingsEaseInOutQuart:
            time = NMUI_EaseInOutQuart(time);
            break;
        case NMUIAnimationEasingsEaseInQuint:
            time = NMUI_EaseInQuint(time);
            break;
        case NMUIAnimationEasingsEaseOutQuint:
            time = NMUI_EaseOutQuint(time);
            break;
        case NMUIAnimationEasingsEaseInOutQuint:
            time = NMUI_EaseInOutQuint(time);
            break;
        case NMUIAnimationEasingsEaseInExpo:
            time = NMUI_EaseInExpo(time);
            break;
        case NMUIAnimationEasingsEaseOutExpo:
            time = NMUI_EaseOutExpo(time);
            break;
        case NMUIAnimationEasingsEaseInOutExpo:
            time = NMUI_EaseInOutExpo(time);
            break;
        case NMUIAnimationEasingsEaseInCirc:
            time = NMUI_EaseInCirc(time);
            break;
        case NMUIAnimationEasingsEaseOutCirc:
            time = NMUI_EaseOutCirc(time);
            break;
        case NMUIAnimationEasingsEaseInOutCirc:
            time = NMUI_EaseInOutCirc(time);
            break;
        case NMUIAnimationEasingsEaseInBack:
            time = NMUI_EaseInBack(time);
            break;
        case NMUIAnimationEasingsEaseOutBack:
            time = NMUI_EaseOutBack(time);
            break;
        case NMUIAnimationEasingsEaseInOutBack:
            time = NMUI_EaseInOutBack(time);
            break;
        case NMUIAnimationEasingsEaseInElastic:
            time = NMUI_EaseInElastic(time);
            break;
        case NMUIAnimationEasingsEaseOutElastic:
            time = NMUI_EaseOutElastic(time);
            break;
        case NMUIAnimationEasingsEaseInOutElastic:
            time = NMUI_EaseInOutElastic(time);
            break;
        case NMUIAnimationEasingsEaseInBounce:
            time = NMUI_EaseInBounce(time);
            break;
        case NMUIAnimationEasingsEaseOutBounce:
            time = NMUI_EaseOutBounce(time);
            break;
        case NMUIAnimationEasingsEaseInOutBounce:
            time = NMUI_EaseInOutBounce(time);
            break;
        case NMUIAnimationEasingsSpring:
            time = NMUI_EaseSpring(time, springMass, springDamping, springStiffness, springInitialVelocity);
            break;
        case NMUIAnimationEasingsSpringKeyboard:
            time = NMUI_EaseSpring(time, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
            break;
        default:
            time = NMUI_Linear(time);
            break;
    }
    return (to - from) * time + from;
}

@end
