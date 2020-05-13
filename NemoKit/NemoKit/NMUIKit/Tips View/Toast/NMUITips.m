//
//  NMUITips.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITips.h"
#import "NMBCore.h"
#import "NMUIToastContentView.h"
#import "NMUIToastBackgroundView.h"
#import "NSString+NMBF.h"

const NSInteger NMUITipsAutomaticallyHideToastSeconds = -1;

@interface NMUITips ()

@property(nonatomic, strong) UIView *contentCustomView;

@end

@implementation NMUITips

- (void)showLoading {
    [self showLoading:nil hideAfterDelay:0];
}

- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay {
    [self showLoading:nil hideAfterDelay:delay];
}

- (void)showLoading:(NSString *)text {
    [self showLoading:text hideAfterDelay:0];
}

- (void)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showLoading:text detailText:nil hideAfterDelay:delay];
}

- (void)showLoading:(NSString *)text detailText:(NSString *)detailText {
    [self showLoading:text detailText:detailText hideAfterDelay:0];
}

BeginIgnoreDeprecatedWarning
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    self.contentCustomView = indicator;
    [self showTipWithText:text detailText:detailText hideAfterDelay:delay];
}
EndIgnoreDeprecatedWarning

- (void)showWithText:(NSString *)text {
    [self showWithText:text detailText:nil hideAfterDelay:0];
}

- (void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showWithText:(NSString *)text detailText:(NSString *)detailText {
    [self showWithText:text detailText:detailText hideAfterDelay:0];
}

- (void)showWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    self.contentCustomView = nil;
    [self showTipWithText:text detailText:detailText hideAfterDelay:delay];
}

- (void)showSucceed:(NSString *)text {
    [self showSucceed:text detailText:nil hideAfterDelay:0];
}

- (void)showSucceed:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showSucceed:text detailText:nil hideAfterDelay:delay];
}

- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText {
    [self showSucceed:text detailText:detailText hideAfterDelay:0];
}

- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    self.contentCustomView = [[UIImageView alloc] initWithImage:[[NMUIHelper imageWithName:@"NMUI_tips_done"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self showTipWithText:text detailText:detailText hideAfterDelay:delay];
}

- (void)showError:(NSString *)text {
    [self showError:text detailText:nil hideAfterDelay:0];
}

- (void)showError:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showError:text detailText:nil hideAfterDelay:delay];
}

- (void)showError:(NSString *)text detailText:(NSString *)detailText {
    [self showError:text detailText:detailText hideAfterDelay:0];
}

- (void)showError:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    self.contentCustomView = [[UIImageView alloc] initWithImage:[[NMUIHelper imageWithName:@"NMUI_tips_error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self showTipWithText:text detailText:detailText hideAfterDelay:delay];
}

- (void)showInfo:(NSString *)text {
    [self showInfo:text detailText:nil hideAfterDelay:0];
}

- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self showInfo:text detailText:nil hideAfterDelay:delay];
}

- (void)showInfo:(NSString *)text detailText:(NSString *)detailText {
    [self showInfo:text detailText:detailText hideAfterDelay:0];
}

- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    self.contentCustomView = [[UIImageView alloc] initWithImage:[[NMUIHelper imageWithName:@"NMUI_tips_info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self showTipWithText:text detailText:detailText hideAfterDelay:delay];
}

- (void)showTipWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    
    NMUIToastContentView *contentView = (NMUIToastContentView *)self.contentView;
    contentView.customView = self.contentCustomView;
    
    contentView.textLabelText = text ?: @"";
    contentView.detailTextLabelText = detailText ?: @"";
    
    [self showAnimated:YES];
    
    if (delay == NMUITipsAutomaticallyHideToastSeconds) {
        [self hideAnimated:YES afterDelay:[NMUITips smartDelaySecondsForTipsText:text]];
    } else if (delay > 0) {
        [self hideAnimated:YES afterDelay:delay];
    }
}

+ (NSTimeInterval)smartDelaySecondsForTipsText:(NSString *)text {
    NSUInteger length = text.nmbf_lengthWhenCountingNonASCIICharacterAsTwo;
    if (length <= 20) {
        return 1.5;
    } else if (length <= 40) {
        return 2.0;
    } else if (length <= 50) {
        return 2.5;
    } else {
        return 3.0;
    }
}

+ (NMUITips *)showLoadingInView:(UIView *)view {
    return [self showLoading:nil detailText:nil inView:view hideAfterDelay:0];
}

+ (NMUITips *)showLoading:(NSString *)text inView:(UIView *)view {
    return [self showLoading:text detailText:nil inView:view hideAfterDelay:0];
}

+ (NMUITips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showLoading:nil detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showLoading:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showLoading:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view {
    return [self showLoading:text detailText:detailText inView:view hideAfterDelay:0];
}

+ (NMUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    NMUITips *tips = [self createTipsToView:view];
    [tips showLoading:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (NMUITips *)showWithText:(nullable NSString *)text {
    return [self showWithText:text detailText:nil inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showWithText:(nullable NSString *)text detailText:(nullable NSString *)detailText {
    return [self showWithText:text detailText:detailText inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showWithText:(NSString *)text inView:(UIView *)view {
    return [self showWithText:text detailText:nil inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showWithText:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showWithText:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view {
    return [self showWithText:text detailText:detailText inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    NMUITips *tips = [self createTipsToView:view];
    [tips showWithText:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (NMUITips *)showSucceed:(nullable NSString *)text {
    return [self showSucceed:text detailText:nil inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showSucceed:(nullable NSString *)text detailText:(nullable NSString *)detailText {
    return [self showSucceed:text detailText:detailText inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showSucceed:(NSString *)text inView:(UIView *)view {
    return [self showSucceed:text detailText:nil inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showSucceed:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showSucceed:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view {
    return [self showSucceed:text detailText:detailText inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    NMUITips *tips = [self createTipsToView:view];
    [tips showSucceed:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (NMUITips *)showError:(nullable NSString *)text {
    return [self showError:text detailText:nil inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showError:(nullable NSString *)text detailText:(nullable NSString *)detailText {
    return [self showError:text detailText:detailText inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showError:(NSString *)text inView:(UIView *)view {
    return [self showError:text detailText:nil inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showError:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showError:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view {
    return [self showError:text detailText:detailText inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    NMUITips *tips = [self createTipsToView:view];
    [tips showError:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (NMUITips *)showInfo:(nullable NSString *)text {
    return [self showInfo:text detailText:nil inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showInfo:(nullable NSString *)text detailText:(nullable NSString *)detailText {
    return [self showInfo:text detailText:detailText inView:DefaultTipsParentView hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showInfo:(NSString *)text inView:(UIView *)view {
    return [self showInfo:text detailText:nil inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showInfo:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showInfo:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (NMUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view {
    return [self showInfo:text detailText:detailText inView:view hideAfterDelay:NMUITipsAutomaticallyHideToastSeconds];
}

+ (NMUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    NMUITips *tips = [self createTipsToView:view];
    [tips showInfo:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (NMUITips *)createTipsToView:(UIView *)view {
    NMUITips *tips = [[NMUITips alloc] initWithView:view];
    [view addSubview:tips];
    tips.removeFromSuperViewWhenHide = YES;
    return tips;
}

+ (void)hideAllTipsInView:(UIView *)view {
    [self hideAllToastInView:view animated:NO];
}

+ (void)hideAllTips {
    [self hideAllToastInView:nil animated:NO];
}

@end
