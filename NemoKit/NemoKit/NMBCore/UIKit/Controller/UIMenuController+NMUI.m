//
//  UIMenuController+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIMenuController+NMUI.h"
#import "NMBCore.h"


@interface UIMenuController ()

@property(nonatomic, assign) NSInteger nmui_originWindowLevel;
@property(nonatomic, assign) BOOL nmui_windowLevelChanged;

@end

@implementation UIMenuController (NMUI)

NMBFSynthesizeNSIntegerProperty(nmui_originWindowLevel, setNmui_originWindowLevel);
NMBFSynthesizeBOOLProperty(nmui_windowLevelChanged, setNmui_windowLevelChanged);

static UIWindow *kMenuControllerWindow = nil;
static BOOL kHasAddedMenuControllerNotification = NO;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation(object_getClass([UIMenuController class]), @selector(sharedMenuController), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIMenuController *selfObject) {
                
                // call super
                UIMenuController *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIMenuController *(*)(id, SEL))originalIMPProvider();
                UIMenuController *menuController = originSelectorIMP(selfObject, originCMD);
                
                /// 修复 issue：https://github.com/Tencent/QMUI_iOS/issues/659
                if (@available(iOS 13.0, *)) {
                    if (!kHasAddedMenuControllerNotification) {
                        kHasAddedMenuControllerNotification = YES;
                        [[NSNotificationCenter defaultCenter] addObserver:menuController selector:@selector(handleMenuWillShowNotification:) name:UIMenuControllerWillShowMenuNotification object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:menuController selector:@selector(handleMenuWillHideNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
                    }
                }
                
                return menuController;
            };
        });
    });
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    UIWindow *window = [self menuControllerWindow];
    UIWindow *targetWindow = [self windowForFirstResponder];
    if (window && targetWindow && ![NMUIHelper isKeyboardVisible]) {
        NMBFLog(NSStringFromClass(self.class), @"show menu - cur window level = %@, origin window level = %@ target window level = %@", @(window.windowLevel), @(self.nmui_originWindowLevel), @(targetWindow.windowLevel));
        self.nmui_windowLevelChanged = YES;
        self.nmui_originWindowLevel = window.windowLevel;
        window.windowLevel = targetWindow.windowLevel + 1;
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    UIWindow *window = [self menuControllerWindow];
    if (window && self.nmui_windowLevelChanged) {
        NMBFLog(NSStringFromClass(self.class), @"hide menu - cur window level = %@, origin window level = %@", @(window.windowLevel), @(self.nmui_originWindowLevel));
        window.windowLevel = self.nmui_originWindowLevel;
        self.nmui_originWindowLevel = 0;
        self.nmui_windowLevelChanged = NO;
    }
}

- (UIWindow *)menuControllerWindow {
    if (kMenuControllerWindow && !kMenuControllerWindow.hidden) {
        return kMenuControllerWindow;
    }
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *windowString = [NSString stringWithFormat:@"UI%@%@", @"Text", @"EffectsWindow"];
        if ([window isKindOfClass:NSClassFromString(windowString)] && !window.hidden) {
            [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *targetView = [NSString stringWithFormat:@"UI%@%@", @"Callout", @"Bar"];
                if ([subview isKindOfClass:NSClassFromString(targetView)]) {
                    kMenuControllerWindow = window;
                    *stop = YES;
                }
            }];
        }
    }];
    return kMenuControllerWindow;
}

- (UIWindow *)windowForFirstResponder {
    __block UIWindow *resultWindow = nil;
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window != UIApplication.sharedApplication.delegate.window) {
            UIResponder *responder = [self findFirstResponderInView:window];
            if (responder) {
                resultWindow = window;
                *stop = YES;
            }
        }
    }];
    return resultWindow;
}

- (UIResponder *)findFirstResponderInView:(UIView *)view {
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        id responder = [self findFirstResponderInView:subView];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end
