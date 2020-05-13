//
//  UIFont+NMUI.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define UIFontLightMake(size) [UIFont nmui_lightSystemFontOfSize:size]
#define UIFontLightWithFont(_font) [UIFont nmui_lightSystemFontOfSize:_font.pointSize]
#define UIDynamicFontMake(_pointSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize weight:NMUIFontWeightNormal italic:NO]
#define UIDynamicFontMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:NMUIFontWeightNormal italic:NO]
#define UIDynamicFontBoldMake(_pointSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize weight:NMUIFontWeightBold italic:NO]
#define UIDynamicFontBoldMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:NMUIFontWeightBold italic:NO]
#define UIDynamicFontLightMake(_pointSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize weight:NMUIFontWeightLight italic:NO]
#define UIDynamicFontLightMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont nmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:NMUIFontWeightLight italic:NO]

typedef NS_ENUM(NSUInteger, NMUIFontWeight) {
    NMUIFontWeightLight,    // 对应 UIFontWeightLight
    NMUIFontWeightNormal,   // 对应 UIFontWeightRegular
    NMUIFontWeightBold      // 对应 UIFontWeightSemibold
};

@interface UIFont (NMUI)

/**
 *  返回系统字体的细体
 *
 *  @param fontSize 字体大小
 *
 *  @return 变细的系统字体的 UIFont 对象
 */
+ (UIFont *)nmui_lightSystemFontOfSize:(CGFloat)fontSize;

/**
 *  根据需要生成一个 UIFont 对象并返回
 *  @param size     字号大小
 *  @param weight   字体粗细
 *  @param italic   是否斜体
 */
+ (UIFont *)nmui_systemFontOfSize:(CGFloat)size
                           weight:(NMUIFontWeight)weight
                           italic:(BOOL)italic;

/**
 *  根据需要生成一个支持响应动态字体大小调整的 UIFont 对象并返回
 *  @param  size    字号大小
 *  @param  weight  字重
 *  @param  italic  是否斜体
 *  @return         支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)nmui_dynamicSystemFontOfSize:(CGFloat)size
                                  weight:(NMUIFontWeight)weight
                                  italic:(BOOL)italic;

/**
 *  返回支持动态字体的UIFont，支持定义最小和最大字号
 *
 *  @param pointSize        默认的size
 *  @param upperLimitSize   最大的字号限制
 *  @param lowerLimitSize   最小的字号显示
 *  @param weight           字重
 *  @param italic           是否斜体
 *
 *  @return                 支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)nmui_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(NMUIFontWeight)weight
                                  italic:(BOOL)italic;

@end

NS_ASSUME_NONNULL_END
