//
//  NMCalendarWeekdayView.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 星期头部视图
@interface NMCalendarWeekdayView : UIView

/**
 An array of UILabel objects displaying the weekday symbols.
 星期符号lab数字
 */
@property (readonly, nonatomic) NSArray<UILabel *> *weekdayLabels;

- (void)configureAppearance;

@end

NS_ASSUME_NONNULL_END
