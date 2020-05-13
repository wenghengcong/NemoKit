//
//  NMCalendarCollectionView.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMCalendarCollectionView;
@protocol NMCalendarCollectionViewInternalDelegate <UICollectionViewDelegate>

@optional
- (void)collectionViewDidFinishLayoutSubviews:(NMCalendarCollectionView *)collectionView;

@end

@interface NMCalendarCollectionView : UICollectionView

@property (weak, nonatomic) id<NMCalendarCollectionViewInternalDelegate> internalDelegate;

@end

NS_ASSUME_NONNULL_END
