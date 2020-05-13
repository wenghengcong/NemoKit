//
//  NMCalendarConstants.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NMBUIMacro.h"
#import "NMBFMathMacro.h"

#pragma mark - Constants

CG_EXTERN CGFloat const NMCalendarStandardHeaderHeight;
CG_EXTERN CGFloat const NMCalendarStandardWeekdayHeight;
CG_EXTERN CGFloat const NMCalendarStandardMonthlyPageHeight;
CG_EXTERN CGFloat const NMCalendarStandardWeeklyPageHeight;
CG_EXTERN CGFloat const NMCalendarStandardCellDiameter;
CG_EXTERN CGFloat const NMCalendarStandardSeparatorThickness;
CG_EXTERN CGFloat const NMCalendarAutomaticDimension;
// 选中动画bounce的时间
CG_EXTERN CGFloat const NMCalendarDefaultBounceAnimationDuration;
CG_EXTERN CGFloat const NMCalendarStandardRowHeight;

// 标题字体
CG_EXTERN CGFloat const NMCalendarStandardTitleTextSize;
// 子标题字体
CG_EXTERN CGFloat const NMCalendarStandardSubtitleTextSize;
// 星期字体
CG_EXTERN CGFloat const NMCalendarStandardWeekdayTextSize;
// 头部月份字体
CG_EXTERN CGFloat const NMCalendarStandardHeaderTextSize;

// 事件标识符直径
CG_EXTERN CGFloat const NMCalendarMaximumEventDotDiameter;

UIKIT_EXTERN NSInteger const NMCalendarDefaultHourComponent;

UIKIT_EXTERN NSString * const NMCalendarDefaultCellReuseIdentifier;
UIKIT_EXTERN NSString * const NMCalendarBlankCellReuseIdentifier;
UIKIT_EXTERN NSString * const NMCalendarInvalidArgumentsExceptionName;

CG_EXTERN CGPoint const CGPointInfinity;
CG_EXTERN CGSize const CGSizeAutomatic;

#define NMCalendarStandardSelectionColor   NMBUIColorRGBA(31,119,219,1.0)
#define NMCalendarStandardTodayColor       NMBUIColorRGBA(198,51,42 ,1.0)
#define NMCalendarStandardTitleTextColor   NMBUIColorRGBA(14,69,221 ,1.0)
#define NMCalendarStandardEventDotColor    NMBUIColorRGBA(31,119,219,0.75)

#define NMCalendarStandardLineColor        [[UIColor lightGrayColor] colorWithAlphaComponent:0.30]
#define NMCalendarStandardSeparatorColor   [[UIColor lightGrayColor] colorWithAlphaComponent:0.60]

#define NMCalendarInAppExtension [[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]


#define NMCalendarUseWeakSelf __weak __typeof__(self) NMCalendarWeakSelf = self;
#define NMCalendarUseStrongSelf __strong __typeof__(self) self = NMCalendarWeakSelf;

#pragma mark - Deprecated

#define NMCalendarDeprecated(instead) DEPRECATED_MSG_ATTRIBUTE(" Use " # instead " instead")

static inline void NMCalendarSliceCake(CGFloat cake, NSInteger count, CGFloat *pieces) {
    CGFloat total = cake;
    for (int i = 0; i < count; i++) {
        NSInteger remains = count - i;
        CGFloat piece = NMBMathRound(total/remains*2)*0.5;
        total -= piece;
        pieces[i] = piece;
    }
}
