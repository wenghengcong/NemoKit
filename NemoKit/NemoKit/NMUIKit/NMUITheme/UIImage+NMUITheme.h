//
//  UIImage+NMUITheme.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUIThemeManager;

@protocol NMUIDynamicImageProtocol <NSObject>

@required
/// 获取当前 UIImage 的实际图片（返回的图片必定不是 dynamic image）
@property(nonatomic, strong, readonly) UIImage *nmui_rawImage;

/// 标志当前 UIImage 对象是否为动态图片（由 [UIImage nmui_imageWithThemeProvider:] 创建的颜色
@property(nonatomic, assign, readonly) BOOL nmui_isDynamicImage;

@end

@interface UIImage (NMUITheme)<NMUIDynamicImageProtocol>


/// 生成一个动态的 image 对象，每次使用该图片时都会动态根据当前的 NMUIThemeManager 主题返回对应的图片。
/// @param provider provider 当 image 被使用时，这个 provider 会被调用，返回对应当前主题的 image 值
/// @return 当前主题下的实际图片，由 provider 返回
+ (UIImage *)nmui_imageWithThemeProvider:(UIImage *(^)(__kindof NMUIThemeManager *managerm, __kindof NSObject<NSCopying> *_Nullable identifier, __kindof NSObject * _Nullable theme))provider;


/// 生成一个动态的 image 对象，每次使用该图片时都会动态根据当前的 NMUIThemeManager name 和主题返回对应的图片。
/// @param name  themeManager 的 name，用于区分不同维度的主题管理器
/// @param provider 当 image 被使用时，这个 provider 会被调用，返回对应当前主题的 image 值
/// @return 当前主题下的实际图片，由 provider 返回
+ (UIImage *)nmui_imageWithThemeManagerName:(__kindof NSObject<NSCopying> *)name
                                   provider:(UIImage *(^)(__kindof NMUIThemeManager *managerm, __kindof NSObject<NSCopying> *_Nullable identifier, __kindof NSObject * _Nullable theme))provider;


/// 修正图片方向
- (UIImage *)nmui_fixOrientation;

@end

NS_ASSUME_NONNULL_END
