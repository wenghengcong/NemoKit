//
//  CAAnimation+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
// 这个文件依赖了 NMUIMultipleDelegates，无法作为 UIKitExtensions 的一部分，所以放在 NMUIComponents 内

@interface CAAnimation (NMUI)
@property(nonatomic, copy) void (^nmui_animationDidStartBlock)(__kindof CAAnimation *aAnimation);
@property(nonatomic, copy) void (^nmui_animationDidStopBlock)(__kindof CAAnimation *aAnimation, BOOL finished);
@end

NS_ASSUME_NONNULL_END
