//
//  UIImageView+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (NMUI)

/**
 暂停/恢复当前 UIImageView 上的 animation images（包括通过 animationImages 设置的图片数组，以及通过 [UIImage animatedImage] 系列方法创建的动图）的播放，默认为 NO。
 */
@property(nonatomic, assign) BOOL nmui_pause;

/**
 是否要用 NMUI 提供的高性能方式去渲染由 [UIImage animatedImage] 创建的 UIImage，（系统原生的方式在 UIImageView 被放在 UIScrollView 内时会卡顿），默认为 YES。
 */
@property(nonatomic, assign) BOOL nmui_smoothAnimation;

/**
 *  把 UIImageView 的宽高调整为能保持 image 宽高比例不变的同时又不超过给定的 `limitSize` 大小的最大frame
 *
 *  建议在设置完x/y之后调用
 */
- (void)nmui_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize;
@end

NS_ASSUME_NONNULL_END
