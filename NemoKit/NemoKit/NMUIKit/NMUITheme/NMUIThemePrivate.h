//
//  NMUIThemePrivate.h
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+NMUITheme.h"
#import "UIVisualEffect+NMUITheme.h"
#import "UIColor+NMUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView(NMUITheme_Private)

- (void)_nmui_themeDidChangeByManager:(nullable NMUIThemeManager *)manager identifier:(nullable __kindof NSObject<NSCopying> *)identifier theme:(nullable __kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews;

@property(nonatomic, strong) UIColor *nmuiTheme_backgroundColor;

/// 记录当前 view 总共有哪些 property 需要在 theme 变化时重新设置
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *nmuiTheme_themeColorProperties;

- (BOOL)_nmui_visible;

@end


/// @warning 由于支持 NSCopying，增加属性时必须在 copyWithZone: 里复制一次
@interface NMUIThemeColor : UIColor<NMUIDynamicColorProtocol>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;

@property(nonatomic, copy) UIColor *(^themeProvider)(__kindof NMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);

@end


@interface NMUIThemeImage : UIImage <NMUIDynamicImageProtocol>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;

@property(nonatomic, copy) UIImage *(^themeProvider)(__kindof NMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

/// @warning 由于支持 NSCopying，增加属性时必须在 copyWithZone: 里复制一次
@interface NMUIThemeVisualEffect : NSObject <NMUIDynamicEffectProtocol>

@property(nonatomic, copy) NSObject<NSCopying> *managerName;
@property(nonatomic, copy) __kindof UIVisualEffect *(^themeProvider)(__kindof NMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end


NS_ASSUME_NONNULL_END
