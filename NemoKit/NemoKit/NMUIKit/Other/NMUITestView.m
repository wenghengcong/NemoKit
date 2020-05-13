//
//  NMUITestView.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITestView.h"
#import "NMBFLog.h"

@implementation NMUITestView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    NSLog(@"NMUITestView setTintColor");
}

//- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
//}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    NMBFLog(NSStringFromClass(self.class), @"%@, dealloc", self);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (!isFrameChanged) {
        NMBFLog(NSStringFromClass(self.class), @"frame 发生变化, 旧的是 %@, 新的是 %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NMBFLog(NSStringFromClass(self.class), @"frame = %@", NSStringFromCGRect(self.frame));
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    NMBFLog(NSStringFromClass(self.class), @"superview is %@, newSuperview is %@, window is %@", self.superview, newSuperview, self.window);
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    NMBFLog(NSStringFromClass(self.class), @"superview is %@, window is %@", self.superview, self.window);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    NMBFLog(NSStringFromClass(self.class), @"self.window is %@, newWindow is %@", self.window, newWindow);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    NMBFLog(NSStringFromClass(self.class), @"self.window is %@", self.window);
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    NMBFLog(NSStringFromClass(self.class), @"subview is %@, subviews.count before addSubview is %@", view, @(self.subviews.count));
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    NMBFLog(NSStringFromClass(self.class), @"hidden is %@", @(hidden));
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}

@end

@implementation NMUITestWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    NMBFLog(NSStringFromClass(self.class), @"dealloc, %@", self);
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
}

- (void)makeKeyAndVisible {
    [super makeKeyAndVisible];
}

- (void)makeKeyWindow {
    [super makeKeyWindow];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    NMBFLog(NSStringFromClass(self.class), @"NMUITestWindow, subviews = %@, view = %@", self.subviews, view);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (isFrameChanged) {
        NMBFLog(NSStringFromClass(self.class), @"NMUITestWindow, frame发生变化, old is %@, new is %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NMBFLog(NSStringFromClass(self.class), @"NMUITestWindow, layoutSubviews");
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
}

@end
