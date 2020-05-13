//
//  NMCalendarStickyHeader.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class NMCalendar, NMCalendarAppearance;
@interface NMCalendarStickyHeader : UICollectionReusableView

@property (weak, nonatomic) NMCalendar *calendar;

@property (weak, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) NSDate *month;

- (void)configureAppearance;
@end

NS_ASSUME_NONNULL_END
