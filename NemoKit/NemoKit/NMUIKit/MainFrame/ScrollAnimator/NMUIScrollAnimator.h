//
//  NMUIScrollAnimator.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个方便地监控 UIScrollView 滚动的类，可在 didScrollBlock 里做一些与滚动位置相关的事情。
 
 使用方式：
 1. 用 init 初始化。
 2. 通过 scrollView 绑定一个 UIScrollView。
 3. 在 didScrollBlock 里做一些与滚动位置相关的事情。
 */
@interface NMUIScrollAnimator : NSObject<UIScrollViewDelegate>

/// 绑定的 UIScrollView
@property(nullable, nonatomic, weak) __kindof UIScrollView *scrollView;

/// UIScrollView 滚动时会调用这个 block
@property(nonatomic, copy) void (^didScrollBlock)(__kindof NMUIScrollAnimator *animator);

/// 当 enabled 为 NO 时，即便 scrollView 滚动，didScrollBlock 也不会被调用。默认为 YES。
@property(nonatomic, assign) BOOL enabled;

/// 立即根据当前的滚动位置更新状态
- (void)updateScroll;

@end

NS_ASSUME_NONNULL_END