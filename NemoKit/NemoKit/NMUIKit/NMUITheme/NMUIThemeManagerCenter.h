//
//  NMUIThemeManagerCenter.h
//  Nemo
//
//  Created by Hunt on 2019/10/7.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMUIThemeManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const NMUIThemeManagerNameDefault;

/// 用于获取NMUiThemeManager，具体使用查看NMUIThemeManager的注释
@interface NMUIThemeManagerCenter : NSObject

/// class 类属性
/// 默认的管理类
@property(class, nonatomic, strong, readonly) NMUIThemeManager *defaultThemeManager;

@property(class, nonatomic, copy, readonly) NSArray<NMUIThemeManager *> *themeManagers;

+ (nullable NMUIThemeManager *)themeManagerWithName:(__kindof NSObject<NSCopying> *)name;

@end

NS_ASSUME_NONNULL_END
