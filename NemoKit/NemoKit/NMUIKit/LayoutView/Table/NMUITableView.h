//
//  NMUITableView.h
//  Nemo
//
//  Created by Hunt on 2019/10/31.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUITableViewProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMUITableView : UITableView

@property(nonatomic, weak) id<NMUITableViewDelegate> delegate;
@property(nonatomic, weak) id<NMUITableViewDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
