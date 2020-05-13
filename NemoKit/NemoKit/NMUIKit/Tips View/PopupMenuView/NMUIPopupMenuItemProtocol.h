//
//  NMUIPopupMenuItemProtocol.h
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUIPopupMenuView;

@protocol NMUIPopupMenuItemProtocol <NSObject>

/// item 里的文字
@property(nonatomic, copy, nullable) NSString *title;

/// item 的高度，默认为 -1。小于 0 的值均表示高度以 NMUIPopupMenuView.itemHeight 为准，当需要给某个 item 指定特定高度时才需要用这个 height 属性。
@property(nonatomic, assign) CGFloat height;

/// item 被点击时的事件处理，需要在内部自行隐藏 NMUIPopupMenuView。
@property(nonatomic, copy, nullable) void (^handler)(__kindof NSObject<NMUIPopupMenuItemProtocol> *aItem);

/// 当前 item 所在的 NMUIPopupMenuView 的引用，只有在 item 被添加到菜单之后才有值。
@property(nonatomic, weak, nullable) NMUIPopupMenuView *menuView;

/// item 被添加到 menuView 之后（也即 menuView 属性有值了）会被调用，可在这个方法里更新 item 的样式（因为某些样式可能需要从 menuView 那边读取）
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END

