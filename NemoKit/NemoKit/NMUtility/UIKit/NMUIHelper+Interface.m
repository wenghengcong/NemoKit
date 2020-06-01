//
//  NMUIHelper+Interface.m
//  Nemo
//
//  Created by Hunt on 2019/10/24.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIHelper+Interface.h"
#import "NMBCore.h"

@implementation NMUIHelper (Interface)

NMBFSynthesizeNSIntegerProperty(orientationBeforeChangingByHelper, setOrientationBeforeChangingByHelper)

- (void)handleDeviceOrientationNotification:(NSNotification *)notification {
    // 如果是由 setValue:forKey: 方式修改方向而走到这个 notification 的话，理论上是不需要重置为 Unknown 的，但因为在 UIViewController (NMUI) 那边会再次记录旋转前的值，所以这里就算重置也无所谓
    [NMUIHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
}

+ (BOOL)rotateToDeviceOrientation:(UIDeviceOrientation)orientation {
    if ([UIDevice currentDevice].orientation == orientation) {
        [UIViewController attemptRotationToDeviceOrientation];
        return NO;
    }
    
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    return YES;
}

+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIDeviceOrientationPortrait;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIDeviceOrientationLandscapeLeft;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    return [UIDevice currentDevice].orientation;
}

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    if (deviceOrientation == UIDeviceOrientationUnknown) {
        return YES;// YES 表示不用额外处理
    }
    
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return YES;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown != deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation || UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown == deviceOrientation;
    }
    
    return YES;
}

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self interfaceOrientationMask:mask containsDeviceOrientation:(UIDeviceOrientation)interfaceOrientation];
}

+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle;
    switch (orientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
            case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
            case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
            default:
            angle = 0.0;
            break;
        }
    return angle;
}

BeginIgnoreDeprecatedWarning
+ (CGAffineTransform)transformForCurrentInterfaceOrientation {
    return [NMUIHelper transformWithInterfaceOrientation:[UIApplication.sharedApplication statusBarOrientation]];
}
EndIgnoreDeprecatedWarning

+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle = [NMUIHelper angleForTransformWithInterfaceOrientation:orientation];
    return CGAffineTransformMakeRotation(angle);
}
@end
