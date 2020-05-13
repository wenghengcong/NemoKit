//
//  NMUIToastAnimator.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIToastAnimator.h"
#import "NMBCore.h"
#import "NMUIToastView.h"

@interface NMUIToastAnimator ()

@property(nonatomic, assign) BOOL isShowing;
@property(nonatomic, assign) BOOL isAnimating;
@end

@implementation NMUIToastAnimator

- (instancetype)init {
    NSAssert(NO, @"请使用initWithToastView:初始化");
    return [self initWithToastView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithToastView:初始化");
    return [self initWithToastView:nil];
}

- (instancetype)initWithToastView:(NMUIToastView *)toastView {
    NSAssert(toastView, @"toastView不能为空");
    if (self = [super init]) {
        _toastView = toastView;
    }
    return self;
}

- (void)showWithCompletion:(void (^)(BOOL finished))completion {
    self.isShowing = YES;
    self.isAnimating = YES;
    [UIView animateWithDuration:0.25 delay:0.0 options:NMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toastView.backgroundView.alpha = 1.0;
        self.toastView.contentView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)hideWithCompletion:(void (^)(BOOL finished))completion {
    self.isShowing = NO;
    self.isAnimating = YES;
    [UIView animateWithDuration:0.25 delay:0.0 options:NMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toastView.backgroundView.alpha = 0.0;
        self.toastView.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (BOOL)isShowing {
    return self.isShowing;
}

- (BOOL)isAnimating {
    return self.isAnimating;
}

@end
