//
//  NMCalendarCollectionViewLayout.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMCalendar;
@interface NMCalendarCollectionViewLayout : UICollectionViewLayout

@property (weak, nonatomic) NMCalendar *calendar;

@property (assign, nonatomic) UIEdgeInsets sectionInsets;
@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;

@end

NS_ASSUME_NONNULL_END
