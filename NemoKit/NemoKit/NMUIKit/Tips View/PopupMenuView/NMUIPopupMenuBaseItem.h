//
//  NMUIPopupMenuBaseItem.h
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUIPopupMenuItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用于 NMUIPopupMenuView 的 item 基类，便于自定义各种类型的 item。若有 subview 请直接添加到 self 上，自身大小的计算请写到 sizeThatFits:，布局写到 layoutSubviews。
 */
@interface NMUIPopupMenuBaseItem : UIView <NMUIPopupMenuItemProtocol>

@end

NS_ASSUME_NONNULL_END
