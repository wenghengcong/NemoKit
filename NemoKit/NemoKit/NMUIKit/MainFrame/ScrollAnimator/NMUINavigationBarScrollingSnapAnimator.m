//
//  NMUINavigationBarScrollingSnapAnimator.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUINavigationBarScrollingSnapAnimator.h"
#import "UINavigationBar+NMUI.h"
#import "UIViewController+NMUI.h"
#import "UIScrollView+NMUI.h"

@interface NMUINavigationBarScrollingSnapAnimator ()

@property(nonatomic, assign) BOOL alreadyCalledScrollDownAnimation;
@property(nonatomic, assign) BOOL alreadyCalledScrollUpAnimation;
@end

@implementation NMUINavigationBarScrollingSnapAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.adjustsOffsetYWithInsetTopAutomatically = YES;
        
        self.didScrollBlock = ^(NMUINavigationBarScrollingSnapAnimator * _Nonnull animator) {
            if (!animator.navigationBar) {
                UINavigationBar *navigationBar = [NMUIHelper visibleViewController].navigationController.navigationBar;
                if (navigationBar) {
                    animator.navigationBar = navigationBar;
                }
            }
            if (!animator.navigationBar) {
                NSLog(@"无法自动找到 UINavigationBar，请通过 %@.%@ 手动设置一个", NSStringFromClass(animator.class), NSStringFromSelector(@selector(navigationBar)));
                return;
            }
            
            if (animator.animationBlock) {
                if (animator.offsetYReached) {
                    if (animator.continuous || !animator.alreadyCalledScrollDownAnimation) {
                        animator.animationBlock(animator, YES);
                        animator.alreadyCalledScrollDownAnimation = YES;
                        animator.alreadyCalledScrollUpAnimation = NO;
                    }
                } else {
                    if (animator.continuous || !animator.alreadyCalledScrollUpAnimation) {
                        animator.animationBlock(animator, NO);
                        animator.alreadyCalledScrollUpAnimation = YES;
                        animator.alreadyCalledScrollDownAnimation = NO;
                    }
                }
            }
        };
    }
    return self;
}

- (BOOL)offsetYReached {
    UIScrollView *scrollView = self.scrollView;
    CGFloat contentOffsetY = flat(scrollView.contentOffset.y);
    CGFloat offsetYToStartAnimation = flat(self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.nmui_contentInset.top : 0));
    return contentOffsetY > offsetYToStartAnimation;
}

- (void)setOffsetYToStartAnimation:(CGFloat)offsetYToStartAnimation {
    BOOL valueChanged = _offsetYToStartAnimation != offsetYToStartAnimation;
    _offsetYToStartAnimation = offsetYToStartAnimation;
    if (valueChanged) {
        [self resetState];
    }
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    BOOL scrollViewChanged = self.scrollView != scrollView;
    [super setScrollView:scrollView];
    if (scrollViewChanged) {
        [self resetState];
    }
}

- (void)resetState {
    self.alreadyCalledScrollUpAnimation = NO;
    self.alreadyCalledScrollDownAnimation = NO;
    [self updateScroll];
}

@end

