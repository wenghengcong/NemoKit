//
//  UITraitCollection+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/9/25.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITraitCollection+NMUI.h"
#import "NMBCore.h"

NSNotificationName const NMUIUserInterfaceStyleWillChangeNotification = @"NMUIUserInterfaceStyleWillChangeNotification";

@implementation UIWindow (NMUIUserInterfaceStyleWillChangeNotification)

#ifdef IOS13_SDK_ALLOWED
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            static UIUserInterfaceStyle nmui_lastNotifiedUserInterfaceStyle;
            nmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            NMBFOverrideImplementation([UIWindow class] , @selector(traitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UITraitCollection *(UIWindow *selfObject) {
                    
                    id (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (id (*)(id, SEL))originalIMPProvider();
                    UITraitCollection *traitCollection = originSelectorIMP(selfObject, originCMD);
                    
                    BOOL snapshotFinishedOnBackground = traitCollection.userInterfaceLevel == UIUserInterfaceLevelElevated && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
                    // 进入后台且完成截图了就不继续去响应 style 变化（实测 iOS 13.0 iPad 进入后台并完成截图后，仍会多次改变 style，但是系统并没有调用界面的相关刷新方法）
                    if (selfObject.windowScene && !snapshotFinishedOnBackground) {
                        NSPointerArray *windows = [[selfObject windowScene] valueForKeyPath:@"_contextBinder._attachedBindables"];
                        // 系统会按照这个数组的顺序去更新 window 的 traitCollection，找出最先响应样式更新的 window
                        UIWindow *firstValidatedWindow = nil;
                        for (NSUInteger i = 0, count = windows.count; i < count; i++) {
                            UIWindow *window = [windows pointerAtIndex:i];
                            // 由于 Keyboard 可以通过 keyboardAppearance 来控制 userInterfaceStyle 的 Dark/Light，不一定和系统一样，这里要过滤掉
                            if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")] || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
                                continue;
                            }
                            if (window.overrideUserInterfaceStyle != UIUserInterfaceStyleUnspecified) {
                                NMBFLogWarn(@"UITraitCollection+NMUI", @"窗口 : %@ 设置了 overrideUserInterfaceStyle 属性，可能会影响 NMUIUserInterfaceStyleWillChangeNotification 的时机", selfObject);
                                continue;
                            }
                            firstValidatedWindow = window;
                            break;
                        }
                        if (selfObject == firstValidatedWindow) {
                            if (nmui_lastNotifiedUserInterfaceStyle != traitCollection.userInterfaceStyle) {
                                nmui_lastNotifiedUserInterfaceStyle = traitCollection.userInterfaceStyle;
                                [[NSNotificationCenter defaultCenter] postNotificationName:NMUIUserInterfaceStyleWillChangeNotification object:traitCollection];
                            }
                        }
                    }
                    return traitCollection;
                    
                };
            });
        }
    });
}
#endif

@end
