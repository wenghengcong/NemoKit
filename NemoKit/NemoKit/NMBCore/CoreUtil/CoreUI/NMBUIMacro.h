//
//  NMBUIMacro.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBUIMacro_h
#define NMBUIMacro_h

#import "NMUIHelper.h"
#import "NMBFHelper.h"

#pragma mark - 变量-设备相关

/// 设备类型
#define IS_IPAD [NMUIHelper isIPad]
#define IS_IPOD [NMUIHelper isIPod]
#define IS_IPHONE [NMUIHelper isIPhone]
#define IS_SIMULATOR [NMUIHelper isSimulator]

/// 操作系统版本号，只获取第二级的版本号，例如 10.3.1 只会得到 10.3
#define IOS_VERSION ([[[UIDevice currentDevice] systemVersion] doubleValue])

/// 数字形式的操作系统版本号，可直接用于大小比较；如 110205 代表 11.2.5 版本；根据 iOS 规范，版本号最多可能有3位
#define IOS_VERSION_NUMBER [NMBFHelper numbericOSVersion]

/*
 *  系统版本比较
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/// 是否横竖屏
/// 用户界面横屏了才会返回YES
#define IS_LANDSCAPE UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)
/// 无论支不支持横屏，只要设备横屏了，就会返回YES
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])

/// 屏幕宽度，会根据横竖屏的变化而变化
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

/// 屏幕高度，会根据横竖屏的变化而变化
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

/// 设备宽度，跟横竖屏无关
#define DEVICE_WIDTH MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

/// 设备高度，跟横竖屏无关
#define DEVICE_HEIGHT MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)

/// 在 iPad 分屏模式下等于 app 实际运行宽度，否则等同于 SCREEN_WIDTH
#define APPLICATION_WIDTH [NMUIHelper applicationSize].width

/// 在 iPad 分屏模式下等于 app 实际运行宽度，否则等同于 DEVICE_HEIGHT
#define APPLICATION_HEIGHT [NMUIHelper applicationSize].height

/// 是否全面屏设备
#define IS_NOTCHED_SCREEN [NMUIHelper isNotchedScreen]
/// iPhone XS Max
#define IS_65INCH_SCREEN [NMUIHelper is65InchScreen]
/// iPhone XR
#define IS_61INCH_SCREEN [NMUIHelper is61InchScreen]
/// iPhone X/XS
#define IS_58INCH_SCREEN [NMUIHelper is58InchScreen]
/// iPhone 6/7/8 Plus
#define IS_55INCH_SCREEN [NMUIHelper is55InchScreen]
/// iPhone 6/7/8
#define IS_47INCH_SCREEN [NMUIHelper is47InchScreen]
/// iPhone 5/5S/SE
#define IS_40INCH_SCREEN [NMUIHelper is40InchScreen]
/// iPhone 4/4S
#define IS_35INCH_SCREEN [NMUIHelper is35InchScreen]
/// iPhone 4/4S/5/5S/SE
#define IS_320WIDTH_SCREEN (IS_35INCH_SCREEN || IS_40INCH_SCREEN)

/// 是否Retina
#define IS_RETINASCREEN ([[UIScreen mainScreen] scale] >= 2.0)

/// 是否放大模式（iPhone 6及以上的设备支持放大模式，iPhone X 除外）
#define IS_ZOOMEDMODE [NMUIHelper isZoomedMode]


#pragma mark - 变量-布局相关

/// 屏幕布局适配相关
#define iPhone320Scale(x)              ceil([NMUIHelper scaleBase320Width:x])
#define iPhone375Scale(x)              ceil([NMUIHelper scaleBase375Width:x])
#define iPhone414Scale(x)              ceil([NMUIHelper scaleBase414Width:x])

/// 屏幕布局适配相关
#define ScaleBase320Width(x)        ceil([NMUIHelper scaleBase320Width:x])
#define ScaleBase375Width(x)        ceil([NMUIHelper scaleBase375Width:x])
#define ScaleBase414Width(x)         ceil([NMUIHelper scaleBase414Width:x])

/// 获取一个像素
#define PixelOne [NMUIHelper pixelOne]

/// bounds && nativeBounds / scale && nativeScale
#define ScreenBoundsSize ([[UIScreen mainScreen] bounds].size)
#define ScreenNativeBoundsSize ([[UIScreen mainScreen] nativeBounds].size)
#define ScreenScale ([[UIScreen mainScreen] scale])
#define ScreenNativeScale ([[UIScreen mainScreen] nativeScale])

/// toolBar相关frame
#define ToolBarHeight (IS_IPAD ? (IS_NOTCHED_SCREEN ? 70 : (IOS_VERSION >= 12.0 ? 50 : 44)) : (IS_LANDSCAPE ? PreferredValueForVisualDevice(44, 32) : 44) + SafeAreaInsetsConstantForDeviceWithNotch.bottom)

/// tabBar相关frame
#define TabBarHeight (IS_IPAD ? (IS_NOTCHED_SCREEN ? 65 : (IOS_VERSION >= 12.0 ? 50 : 49)) : (IS_LANDSCAPE ? PreferredValueForVisualDevice(49, 32) : 49) + SafeAreaInsetsConstantForDeviceWithNotch.bottom)

/// 状态栏高度(来电等情况下，状态栏高度会发生变化，所以应该实时计算，iOS 13 起，来电等情况下状态栏高度不会改变)
#define StatusBarHeight (UIApplication.sharedApplication.statusBarHidden ? 0 : UIApplication.sharedApplication.statusBarFrame.size.height)

/// 状态栏高度(如果状态栏不可见，也会返回一个普通状态下可见的高度)
#define StatusBarHeightConstant (UIApplication.sharedApplication.statusBarHidden ? (IS_IPAD ? (IS_NOTCHED_SCREEN ? 24 : 20) : PreferredValueForNotchedDevice(IS_LANDSCAPE ? 0 : 44, 20)) : UIApplication.sharedApplication.statusBarFrame.size.height)

/// navigationBar 的静态高度
#define NavigationBarHeight (IS_IPAD ? (IOS_VERSION >= 12.0 ? 50 : 44) : (IS_LANDSCAPE ? PreferredValueForVisualDevice(44, 32) : 44))

/// 代表(导航栏+状态栏)，这里用于获取其高度
/// @warn 如果是用于 viewController，请使用 UIViewController(NMUI) nmui_navigationBarMaxYInViewCoordinator 代替
#define NavigationContentTop (StatusBarHeight + NavigationBarHeight)

/// 同上，这里用于获取它的静态常量值
#define NavigationContentTopConstant (StatusBarHeightConstant + NavigationBarHeight)

/// iPhoneX 系列全面屏手机的安全区域的静态值
#define SafeAreaInsetsConstantForDeviceWithNotch [NMUIHelper safeAreaInsetsForDeviceWithNotch]

/// 按屏幕宽度来区分不同 iPhone 尺寸，iPhone XS Max/XR/Plus 归为一类，iPhone X/8/7/6 归为一类。
/// iPad 也会视为最大的屏幕宽度来处理
#define PreferredValueForiPhone(_65or61or55inch, _47or58inch, _40inch, _35inch) PreferredValueForDeviceIncludingiPad(_65or61or55inch, _65or61or55inch, _47or58inch, _40inch, _35inch)

/// 同上，单独将 iPad 区分对待
#define PreferredValueForDeviceIncludingiPad(_iPad, _65or61or55inch, _47or58inch, _40inch, _35inch) PreferredValueForAll(_iPad, _65or61or55inch, _65or61or55inch, _47or58inch, _65or61or55inch, _47or58inch, _40inch, _35inch)

/// 区分全面屏（iPhone X 系列）和非全面屏
#define PreferredValueForNotchedDevice(_notchedDevice, _otherDevice) ([NMUIHelper isNotchedScreen] ? _notchedDevice : _otherDevice)

/// 将所有屏幕按照宽松/紧凑分类，其中 iPad、iPhone XS Max/XR/Plus 均为宽松屏幕，但开启了放大模式的设备均会视为紧凑屏幕
#define PreferredValueForVisualDevice(_regular, _compact) ([NMUIHelper isRegularScreen] ? _regular : _compact)

/// 判断当前是否是处于分屏模式的 iPad
#define IS_SPLIT_SCREEN_IPAD (IS_IPAD && APPLICATION_WIDTH != SCREEN_WIDTH)

/// 若 iPad 处于分屏模式下，返回 iPad 接近 iPhone 宽度（320、375、414）中近似的一种，方便屏幕适配。
#define IPAD_SIMILAR_SCREEN_WIDTH [NMUIHelper preferredLayoutAsSimilarScreenWidthForIPad]

#define _40INCH_WIDTH [NMUIHelper screenSizeFor40Inch].width
#define _58INCH_WIDTH [NMUIHelper screenSizeFor58Inch].width
#define _65INCH_WIDTH [NMUIHelper screenSizeFor65Inch].width

#define AS_IPAD (DynamicPreferredValueForIPad ? ((IS_IPAD && !IS_SPLIT_SCREEN_IPAD) || (IS_SPLIT_SCREEN_IPAD && APPLICATION_WIDTH >= 768)) : IS_IPAD)
#define AS_65INCH_SCREEN (IS_65INCH_SCREEN || (IS_IPAD && DynamicPreferredValueForIPad && IPAD_SIMILAR_SCREEN_WIDTH == _65INCH_WIDTH))
#define AS_61INCH_SCREEN IS_61INCH_SCREEN
#define AS_58INCH_SCREEN (IS_58INCH_SCREEN || ((AS_61INCH_SCREEN || AS_65INCH_SCREEN) && IS_ZOOMEDMODE) || (IS_IPAD && DynamicPreferredValueForIPad && IPAD_SIMILAR_SCREEN_WIDTH == _58INCH_WIDTH))
#define AS_55INCH_SCREEN IS_55INCH_SCREEN
#define AS_47INCH_SCREEN (IS_47INCH_SCREEN || (IS_55INCH_SCREEN && IS_ZOOMEDMODE))
#define AS_40INCH_SCREEN (IS_40INCH_SCREEN || (IS_IPAD && DynamicPreferredValueForIPad && IPAD_SIMILAR_SCREEN_WIDTH == _40INCH_WIDTH))
#define AS_35INCH_SCREEN IS_35INCH_SCREEN
#define AS_320WIDTH_SCREEN IS_320WIDTH_SCREEN

#define PreferredValueForAll(_iPad, _65inch, _61inch, _58inch, _55inch, _47inch, _40inch, _35inch) \
(AS_IPAD ? _iPad :\
(AS_35INCH_SCREEN ? _35inch :\
(AS_40INCH_SCREEN ? _40inch :\
(AS_47INCH_SCREEN ? _47inch :\
(AS_55INCH_SCREEN ? _55inch :\
(AS_58INCH_SCREEN ? _58inch :\
(AS_61INCH_SCREEN ? _61inch : _65inch)))))))


#pragma mark - 动画

#define NMUIViewAnimationOptionsCurveOut (7<<16)
#define NMUIViewAnimationOptionsCurveIn (8<<16)


#pragma mark - 其他

// 固定黑色的 StatusBarStyle，用于亮色背景，作为 -preferredStatusBarStyle 方法的 return 值使用。
#define NMUIStatusBarStyleDarkContent [NMUIHelper statusBarStyleDarkContent]


/// 颜色 rgba
#define NMBUIColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]


#endif /* NMBUIMacro_h */
