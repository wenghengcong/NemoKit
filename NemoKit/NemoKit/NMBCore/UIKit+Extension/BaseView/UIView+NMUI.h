//
//  UIView+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NMUI)

/// 相当于 initWithFrame:CGRectMake(0, 0, size.width, size.height)
/// @param size size 初始化时的 size
/// @return 初始化得到的实例
- (instancetype)nmui_initWithSize:(CGSize)size;

/// 将要设置的 frame 用 CGRectApplyAffineTransformWithAnchorPoint 处理后再设置
@property(nonatomic, assign) CGRect nmui_frameApplyTransform;


/// 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
@property(nonatomic, assign, readonly) UIEdgeInsets nmui_safeAreaInsets;

/// 有修改过 tintColor，则不会再受 superview.tintColor 的影响
@property(nonatomic, assign, readonly) BOOL nmui_tintColorCustomized;


/// 移除当前所有 subviews
- (void)nmui_removeAllSubviews;

/// 同 [UIView convertPoint:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)nmui_convertPoint:(CGPoint)point toView:(nullable UIView *)view;

/// 同 [UIView convertPoint:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)nmui_convertPoint:(CGPoint)point fromView:(nullable UIView *)view;

/// 同 [UIView convertRect:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)nmui_convertRect:(CGRect)rect toView:(nullable UIView *)view;

/// 同 [UIView convertRect:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)nmui_convertRect:(CGRect)rect fromView:(nullable UIView *)view;


/// UIView动画的封装
/// @param animated 是否显示动画
/// @param duration 时长
/// @param delay 延迟
/// @param options 动画执行选项
/// @param animations 动画执行回调
/// @param completion 动画完成回调
/// 可以执行动画的选项 frame、bounds、center、transform、alpha、backgroundColor、contentStretch
+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
                         options:(UIViewAnimationOptions)options
                      animations:(void (^)(void))animations
                      completion:(void (^ __nullable)(BOOL finished))completion;

/// UIView动画的封装
/// @param animated 是否显示动画
/// @param duration 时长
/// @param animations 动画执行回调
/// @param completion 动画完成回调
/// 可以执行动画的选项 frame、bounds、center、transform、alpha、backgroundColor、contentStretch
+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                      animations:(void (^ __nullable)(void))animations
                      completion:(void (^ __nullable)(BOOL finished))completion;
/// UIView动画的封装
/// @param animated 是否显示动画
/// @param duration 时长
/// @param animations 动画执行回调
/// 可以执行动画的选项 frame、bounds、center、transform、alpha、backgroundColor、contentStretch
+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                      animations:(void (^ __nullable)(void))animations;

/// UIView动画的封装
/// @param animated 是否显示动画
/// @param duration 时长
/// @param delay 延迟
/// @param dampingRatio 阻尼速度
/// @param velocity 初始化速度
/// @param options 动画执行选项
/// @param animations 动画执行回调
/// @param completion 动画完成回调
/// 可以执行动画的选项 frame、bounds、center、transform、alpha、backgroundColor、contentStretch
+ (void)nmui_animateWithAnimated:(BOOL)animated
                        duration:(NSTimeInterval)duration
                           delay:(NSTimeInterval)delay
          usingSpringWithDamping:(CGFloat)dampingRatio
           initialSpringVelocity:(CGFloat)velocity
                         options:(UIViewAnimationOptions)options
                      animations:(void (^)(void))animations
                      completion:(void (^)(BOOL finished))completion;
@end


@interface UIView (NMUI_Block)
/**
 在 UIView 的 frame 变化前会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，你可以通过返回一个 rect 来达到修改 frame 的目的，最终执行 [super setFrame:] 时会使用这个 block 的返回值（除了 setTransform: 导致的 frame 变化）。
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @param followingFrame setFrame: 的参数 frame，也即即将被修改为的 rect 值
 @return 将会真正被使用的 frame 值
 @note 仅当 followingFrame 和 self.frame 值不相等时才会被调用
 */
@property(nullable, nonatomic, copy) CGRect (^nmui_frameWillChangeBlock)(__kindof UIView *view, CGRect followingFrame);

/**
 在 UIView 的 frame 变化后会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，可用于监听布局的变化，或者在不方便重写 layoutSubviews 时使用这个 block 代替。
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @param precedingFrame 修改前的 frame 值
 */
@property(nullable, nonatomic, copy) void (^nmui_frameDidChangeBlock)(__kindof UIView *view, CGRect precedingFrame);

/**
 在 UIView 的 layoutSubviews 调用后的下一个 runloop 调用。如果不放到下一个 runloop，直接就调用，会导致先于子类重写的 layoutSubviews 就调用，这样就无法获取到正确的 subviews 的布局。
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @note 如果某些 view 重写了 layoutSubviews 但没有调用 super，则这个 block 也不会被调用
 */
@property(nullable, nonatomic, copy) void (^nmui_layoutSubviewsBlock)(__kindof UIView *view);

/**
 当 tintColorDidChange 被调用的时候会调用这个 block，就不用重写方法了
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 */
@property(nullable, nonatomic, copy) void (^nmui_tintColorDidChangeBlock)(__kindof UIView *view);

/**
 当 hitTest:withEvent: 被调用时会调用这个 block，就不用重写方法了
 @param point 事件产生的 point
 @param event 事件
 @param super 的返回结果
 */
@property(nullable, nonatomic, copy) __kindof UIView * (^nmui_hitTestBlock)(CGPoint point, UIEvent *event, __kindof UIView *originalView);

@end

@interface UIView (NMUI_ViewController)

/**
 判断当前的 view 是否属于可视（可视的定义为已存在于 view 层级树里，或者在所处的 UIViewController 的 [viewWillAppear, viewWillDisappear) 生命周期之间）
 */
@property(nonatomic, assign, readonly) BOOL nmui_visible;

/**
 当前的 view 是否是某个 UIViewController.view
 */
@property(nonatomic, assign) BOOL nmui_isControllerRootView;

/**
 获取当前 view 所在的 UIViewController，会递归查找 superview，因此注意使用场景不要有过于频繁的调用
 */
@property(nullable, nonatomic, weak, readonly) __kindof UIViewController *nmui_viewController;
@end


@interface UIView (NMUI_Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIView 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIView 默认的实现
 */
- (BOOL)nmui_hasOverrideUIKitMethod:(SEL)selector;

@end

/*
 视图Border位置
 */
typedef NS_OPTIONS(NSUInteger, NMUIViewBorderPosition) {
    NMUIViewBorderPositionNone      = 0,
    NMUIViewBorderPositionTop       = 1 << 0,
    NMUIViewBorderPositionLeft      = 1 << 1,
    NMUIViewBorderPositionBottom    = 1 << 2,
    NMUIViewBorderPositionRight     = 1 << 3
};


typedef NS_ENUM(NSUInteger, NMUIViewBorderLocation) {
    NMUIViewBorderLocationInside,
    NMUIViewBorderLocationCenter,
    NMUIViewBorderLocationOutside
};

/**
 *  UIView (NMUI_Border) 为 UIView 方便地显示某几个方向上的边框。
 *
 *  系统的默认实现里，要为 UIView 加边框一般是通过 view.layer 来实现，view.layer 会给四条边都加上边框，如果你只想为其中某几条加上边框就很麻烦，于是 UIView (NMUI_Border) 提供了 nmui_borderPosition 来解决这个问题。
 *  @warning 注意如果你需要为 UIView 四条边都加上边框，请使用系统默认的 view.layer 来实现，而不要用 UIView (NMUI_Border)，会浪费资源，这也是为什么 NMUIViewBorderPosition 不提供一个 NMUIViewBorderPositionAll 枚举值的原因。
 */
@interface UIView (NMUI_Border)

/// 设置边框的位置，默认为 NMUIViewBorderLocationInside，与 view.layer.border 一致。
@property(nonatomic, assign) NMUIViewBorderLocation nmui_borderLocation;

/// 设置边框类型，支持组合，例如：`borderPosition = NMUIViewBorderPositionTop|NMUIViewBorderPositionBottom`。默认为 NMUIViewBorderPositionNone。
@property(nonatomic, assign) NMUIViewBorderPosition nmui_borderPosition;

/// 边框的大小，默认为PixelOne。请注意修改 nmui_borderPosition 的值以将边框显示出来。
@property(nonatomic, assign) IBInspectable CGFloat nmui_borderWidth;

/// 边框的颜色，默认为UIColorSeparator。请注意修改 nmui_borderPosition 的值以将边框显示出来。
@property(nullable, nonatomic, strong) IBInspectable UIColor *nmui_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
/// nmui_dashPhase 表示虚线起始的偏移，nmui_dashPattern 可以传一个数组，表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
@property(nonatomic, assign) CGFloat nmui_dashPhase;
/// NSNumber的数组，索引从1开始记，奇数位数值表示实线长度，偶数位数值表示空白长度。系统会按照数值自动重复设置虚线。
@property(nullable, nonatomic, copy)   NSArray <NSNumber *> *nmui_dashPattern;

/// border的layer
@property(nullable, nonatomic, strong, readonly) CAShapeLayer *nmui_borderLayer;

@end


/**
 *  方便地将某个 UIView 截图并转成一个 UIImage，注意如果这个 UIView 本身做了 transform，也不会在截图上反映出来，截图始终都是原始 UIView 的截图。
 */
@interface UIView (NMUI_Snapshotting)

- (UIImage *)nmui_snapshotLayerImage;
- (UIImage *)nmui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;

@end


/**
 当某个 UIView 在 setFrame: 时高度传这个值，则会自动将 sizeThatFits 算出的高度设置为当前 view 的高度，相当于以下这段代码的简化：
 @code
 // 以前这么写
 CGSize size = [view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
 view.frame = CGRectMake(x, y, width, size.height);
 
 // 现在可以这么写：
 view.frame = CGRectMake(x, y, width, NMUIViewSelfSizingHeight);
 @endcode
 */
extern const CGFloat NMUIViewSelfSizingHeight;

/**
 *  对 view.frame 操作的简便封装，注意 view 与 view 之间互相计算时，需要保证处于同一个坐标系内。
 */
@interface UIView (NMUI_Layout)

/// 等价于 CGRectGetMinY(frame)
@property(nonatomic, assign) CGFloat nmui_top;

/// 等价于 CGRectGetMinX(frame)
@property(nonatomic, assign) CGFloat nmui_left;

/// 等价于 CGRectGetMaxY(frame)
@property(nonatomic, assign) CGFloat nmui_bottom;

/// 等价于 CGRectGetMaxX(frame)
@property(nonatomic, assign) CGFloat nmui_right;

/// 等价于 CGRectGetWidth(frame)
@property(nonatomic, assign) CGFloat nmui_width;

/// 等价于 CGRectGetHeight(frame)
@property(nonatomic, assign) CGFloat nmui_height;

/// 保持其他三个边缘的位置不变的情况下，将顶边缘拓展到某个指定的位置，注意高度会跟随变化。
@property(nonatomic, assign) CGFloat nmui_extendToTop;

/// 保持其他三个边缘的位置不变的情况下，将左边缘拓展到某个指定的位置，注意宽度会跟随变化。
@property(nonatomic, assign) CGFloat nmui_extendToLeft;

/// 保持其他三个边缘的位置不变的情况下，将底边缘拓展到某个指定的位置，注意高度会跟随变化。
@property(nonatomic, assign) CGFloat nmui_extendToBottom;

/// 保持其他三个边缘的位置不变的情况下，将右边缘拓展到某个指定的位置，注意宽度会跟随变化。
@property(nonatomic, assign) CGFloat nmui_extendToRight;

/// 获取当前 view 在 superview 内水平居中时的 left
@property(nonatomic, assign, readonly) CGFloat nmui_leftWhenCenterInSuperview;

/// 获取当前 view 在 superview 内垂直居中时的 top
@property(nonatomic, assign, readonly) CGFloat nmui_topWhenCenterInSuperview;

@end


@interface UIView (CGAffineTransform)

/// 获取当前 view 的 transform scale x
@property(nonatomic, assign, readonly) CGFloat nmui_scaleX;

/// 获取当前 view 的 transform scale y
@property(nonatomic, assign, readonly) CGFloat nmui_scaleY;

/// 获取当前 view 的 transform translation x
@property(nonatomic, assign, readonly) CGFloat nmui_translationX;

/// 获取当前 view 的 transform translation y
@property(nonatomic, assign, readonly) CGFloat nmui_translationY;

@end

/**
 *  Debug UIView 的时候用，对某个 view 的 subviews 都添加一个半透明的背景色，方面查看 view 的布局情况
 */
@interface UIView (NMUI_Debug)

/// 是否需要添加debug背景色，默认NO
@property(nonatomic, assign) BOOL nmui_shouldShowDebugColor;

/// 是否每个view的背景色随机，如果不随机则统一使用半透明红色，默认NO
@property(nonatomic, assign) BOOL nmui_needsDifferentDebugColor;

/// 标记一个view是否已经被添加了debug背景色，外部一般不使用
@property(nonatomic, assign, readonly) BOOL nmui_hasDebugColor;

@end

NS_ASSUME_NONNULL_END
