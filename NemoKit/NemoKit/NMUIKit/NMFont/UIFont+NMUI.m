//
//  UIFont+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIFont+NMUI.h"
#import "NMBCore.h"

@implementation UIFont (NMUI)

+ (UIFont *)nmui_lightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (UIFont *)nmui_systemFontOfSize:(CGFloat)size weight:(NMUIFontWeight)weight italic:(BOOL)italic {

    
    // iOS 10 以上使用常规写法
    UIFont *font = nil;
    font = [UIFont systemFontOfSize:size weight:weight == NMUIFontWeightLight ? UIFontWeightLight : (weight == NMUIFontWeightBold ? UIFontWeightSemibold : UIFontWeightRegular)];
    if (!italic) {
        return font;
    }
    
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits trait = fontDescriptor.symbolicTraits;
    trait |= UIFontDescriptorTraitItalic;
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:trait];

    font = [UIFont fontWithDescriptor:fontDescriptor size:0];
    return font;
}

+ (UIFont *)nmui_dynamicSystemFontOfSize:(CGFloat)size weight:(NMUIFontWeight)weight italic:(BOOL)italic {
    return [self nmui_dynamicSystemFontOfSize:size upperLimitSize:size + 5 lowerLimitSize:0 weight:weight italic:italic];
}

+ (UIFont *)nmui_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(NMUIFontWeight)weight
                                  italic:(BOOL)italic {
    
    // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat offsetPointSize = font.pointSize - 17;// default UIFontTextStyleBody fontSize is 17
    CGFloat finalPointSize = pointSize + offsetPointSize;
    finalPointSize = MAX(MIN(finalPointSize, upperLimitSize), lowerLimitSize);
    font = [UIFont nmui_systemFontOfSize:finalPointSize weight:weight italic:NO];
    
    return font;
}


@end
