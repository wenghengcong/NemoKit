//
//  NMUIScrollAnimator.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIScrollAnimator.h"
#import "NMBFMultipleDelegates.h"
#import "UIScrollView+NMUI.h"
#import "UIView+NMUI.h"

@interface NMUIScrollAnimator ()

@property(nonatomic, assign) BOOL scrollViewMultipleDelegatesEnabledBeforeSet;
@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegateBeforeSet;
@end

@implementation NMUIScrollAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    if (scrollView) {
        self.scrollViewMultipleDelegatesEnabledBeforeSet = scrollView.nmbf_multipleDelegatesEnabled;
        self.scrollViewDelegateBeforeSet = scrollView.delegate;
        scrollView.nmbf_multipleDelegatesEnabled = YES;
        scrollView.delegate = self;
    } else {
        _scrollView.nmbf_multipleDelegatesEnabled = self.scrollViewMultipleDelegatesEnabledBeforeSet;
        if (_scrollView.nmbf_multipleDelegatesEnabled) {
            [((NMBFMultipleDelegates *)_scrollView.delegate) removeDelegate:self];
        } else {
            _scrollView.delegate = self.scrollViewDelegateBeforeSet;
        }
    }
    _scrollView = scrollView;
}

- (void)updateScroll {
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.enabled && scrollView == self.scrollView && self.didScrollBlock && scrollView.nmui_visible) {
        self.didScrollBlock(self);
    }
}

@end

