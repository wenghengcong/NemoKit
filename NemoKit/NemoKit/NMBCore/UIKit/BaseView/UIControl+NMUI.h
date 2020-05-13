//
//  UIControl+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (NMUI)

/**
 *  是否接管 UIControl 的 touch 事件。
 *
 *  UIControl 在 UIScrollView 上会有300毫秒的延迟，默认情况下快速点击某个 UIControl，将不会看到 setHighlighted 的效果。如果通过将 UIScrollView.delaysContentTouches 置为 NO 来取消这个延迟，则系统无法判断 touch 时是要点击还是要滚动。
 *
 *  此时可以将 UIControl.nmui_automaticallyAdjustTouchHighlightedInScrollView 属性置为 YES，会使用自己的一套计算方式去判断触发 setHighlighted 的时机，从而保证既不影响 UIScrollView 的滚动，又能让 UIControl 在被快速点击时也能立马看到 setHighlighted 的效果。
 *
 *  @warning 使用了这个属性则不需要设置 UIScrollView.delaysContentTouches。
 */
@property(nonatomic, assign) BOOL nmui_automaticallyAdjustTouchHighlightedInScrollView;

/// 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小
@property(nonatomic,assign) UIEdgeInsets nmui_outsideEdge;

/// setHighlighted: 方法的回调 block
@property(nonatomic, copy) void (^nmui_setHighlightedBlock)(BOOL highlighted);

/// 等同于 addTarget:action:forControlEvents:UIControlEventTouchUpInside
@property(nonatomic, copy) void (^nmui_tapBlock)(__kindof UIControl *sender);

@end

NS_ASSUME_NONNULL_END
