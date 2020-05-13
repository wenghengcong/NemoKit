//
//  UIWindow+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIWindow+NMUI.h"
#import "NMBCore.h"

@implementation UIWindow (NMUI)

NMBFSynthesizeBOOLProperty(nmui_capturesStatusBarAppearance, setNmui_capturesStatusBarAppearance)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UIWindow class], @selector(initWithFrame:), CGRect, UIWindow *, ^UIWindow *(UIWindow *selfObject, CGRect frame, UIWindow *originReturnValue) {
            selfObject.nmui_capturesStatusBarAppearance = YES;
            return originReturnValue;
        });
        
        if (@available(iOS 13.0, *)) {
            NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([UIWindow class], @selector(initWithWindowScene:), UIWindowScene *, UIWindow *, ^UIWindow *(UIWindow *selfObject, UIWindowScene *windowScene, UIWindow *originReturnValue) {
                selfObject.nmui_capturesStatusBarAppearance = YES;
                return originReturnValue;
            });
        }
        
        NMBFOverrideImplementation([UIWindow class], NSSelectorFromString([NSString stringWithFormat:@"_%@%@%@", @"canAffect", @"StatusBar", @"Appearance"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIWindow *selfObject) {
                
                if (selfObject.nmui_capturesStatusBarAppearance) {
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    return result;
                }
                
                return NO;
            };
        });
    });
}

+ (nullable UIWindow *)nmui_keyWindow {
    
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    }
    
    // 如果未能从connectedScenes获取到keywindow
    if (keyWindow == nil) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *window in windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
    }
    
    if (keyWindow == nil) {
        if ([UIApplication.sharedApplication.delegate respondsToSelector:@selector(window)]) {
            keyWindow = UIApplication.sharedApplication.delegate.window;
        }
    }
  
    return keyWindow;
}


/// 主app 根控制器所在的window，不管是否处于前台激活状态
+ (nullable UIWindow *)nmui_rootViewControllerWindow {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.delegate && [windowScene.delegate respondsToSelector:@selector(window)]) {
                id sceneDelegate = windowScene.delegate;
                keyWindow = [sceneDelegate performSelector:@selector(window)];
                break;
            }
        }
    }else{
BeginIgnoreDeprecatedWarning
        keyWindow = [UIApplication sharedApplication].keyWindow;
EndIgnoreDeprecatedWarning
    }
    return keyWindow;
}

@end
