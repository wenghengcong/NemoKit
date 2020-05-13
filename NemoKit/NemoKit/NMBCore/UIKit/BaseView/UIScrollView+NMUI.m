//
//  UIScrollView+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIScrollView+NMUI.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"
#import "UIViewController+NMUI.h"

@interface UIScrollView ()

@property(nonatomic, assign) CGFloat nmuiscroll_lastInsetTopWhenScrollToTop;
@property(nonatomic, assign) BOOL nmuiscroll_hasSetInitialContentInset;
@end


@implementation UIScrollView (NMUI)

NMBFSynthesizeCGFloatProperty(nmuiscroll_lastInsetTopWhenScrollToTop, setNmuiscroll_lastInsetTopWhenScrollToTop)
NMBFSynthesizeBOOLProperty(nmuiscroll_hasSetInitialContentInset, setNmuiscroll_hasSetInitialContentInset)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithoutArguments([UIScrollView class], @selector(description), NSString *, ^NSString *(UIScrollView *selfObject, NSString *originReturnValue) {
            originReturnValue = ([NSString stringWithFormat:@"%@, contentInset = %@", originReturnValue, NSStringFromUIEdgeInsets(selfObject.contentInset)]);
            if (@available(iOS 13.0, *)) {
                return originReturnValue.mutableCopy;
            }
            return originReturnValue;
        });
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            if (NMUICMIActivated && AdjustScrollIndicatorInsetsByContentInsetAdjustment) {
                NMBFOverrideImplementation([UIScrollView class], @selector(setContentInsetAdjustmentBehavior:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIScrollView *selfObject, UIScrollViewContentInsetAdjustmentBehavior firstArgv) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior);
                        originSelectorIMP = (void (*)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                        
                        if (firstArgv == UIScrollViewContentInsetAdjustmentNever) {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = NO;
                        } else {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = YES;
                        }
                    };
                });
            }
        }
#endif
    });
}

- (BOOL)nmui_alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.nmui_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)nmui_alreadyAtBottom {
    if (!self.nmui_canScroll) {
        return YES;
    }
    
    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.nmui_contentInset.bottom - CGRectGetHeight(self.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)nmui_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

static char kAssociatedObjectKey_initialContentInset;
- (void)setNmui_initialContentInset:(UIEdgeInsets)nmui_initialContentInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_initialContentInset, [NSValue valueWithUIEdgeInsets:nmui_initialContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.contentInset = nmui_initialContentInset;
    self.scrollIndicatorInsets = nmui_initialContentInset;
    if (!self.nmuiscroll_hasSetInitialContentInset || !self.nmui_viewController || self.nmui_viewController.nmui_visibleState < NMUIViewControllerDidAppear) {
        [self nmui_scrollToTopUponContentInsetTopChange];
    }
    self.nmuiscroll_hasSetInitialContentInset = YES;

}

- (UIEdgeInsets)nmui_initialContentInset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_initialContentInset)) UIEdgeInsetsValue];
}

- (BOOL)nmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.nmui_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)nmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self nmui_canScroll])) {
        [self setContentOffset:CGPointMake(-self.nmui_contentInset.left, -self.nmui_contentInset.top) animated:animated];
    }
}

- (void)nmui_scrollToTopAnimated:(BOOL)animated {
    [self nmui_scrollToTopForce:NO animated:animated];
}

- (void)nmui_scrollToTop {
    [self nmui_scrollToTopAnimated:NO];
}

- (void)nmui_scrollToTopUponContentInsetTopChange {
    if (self.nmuiscroll_lastInsetTopWhenScrollToTop != self.contentInset.top) {
        [self nmui_scrollToTop];
        self.nmuiscroll_lastInsetTopWhenScrollToTop = self.contentInset.top;
    }
}

- (void)nmui_scrollToBottomAnimated:(BOOL)animated {
    if ([self nmui_canScroll]) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.nmui_contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
    }
}

- (void)nmui_scrollToBottom {
    [self nmui_scrollToBottomAnimated:NO];
}

- (void)nmui_stopDeceleratingIfNeeded {
    if (self.decelerating) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
}

- (void)nmui_setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    [UIView nmui_animateWithAnimated:animated duration:.25 delay:0 options:NMUIViewAnimationOptionsCurveOut animations:^{
        self.contentInset = contentInset;
    } completion:nil];
}

@end
