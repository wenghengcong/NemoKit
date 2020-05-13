//
//  NMCalendarHeaderView.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMCalendar, NMCalendarAppearance, NMCalendarHeaderLayout, NMCalendarCollectionView;
@interface NMCalendarHeaderView : UIView

@property (weak, nonatomic) NMCalendarCollectionView *collectionView;
@property (weak, nonatomic) NMCalendarHeaderLayout *collectionViewLayout;
@property (weak, nonatomic) NMCalendar *calendar;

@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)setScrollOffset:(CGFloat)scrollOffset;
- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated;
- (void)reloadData;
- (void)configureAppearance;

@end

/// 顶部导航视图
@interface NMCalendarHeaderCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) NMCalendarHeaderView *header;

@end

@interface NMCalendarHeaderLayout : UICollectionViewFlowLayout

@end

@interface NMCalendarHeaderTouchDeliver : UIView

@property (weak, nonatomic) NMCalendar *calendar;
@property (weak, nonatomic) NMCalendarHeaderView *header;

@end


NS_ASSUME_NONNULL_END
