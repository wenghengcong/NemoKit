//
//  UIColor+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIColor+NMUI.h"
#import "NMBFRuntimeMacro.h"
#import "NSString+NMBF.h"
#import "NMBFoundationMacro.h"
#import "NMBFRuntimeMacro.h"

@implementation UIColor (NMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithoutArguments([[UIColor colorWithRed:1 green:1 blue:1 alpha:1] class], @selector(description), NSString *, ^NSString *(UIColor *selfObject, NSString *originReturnValue) {
            NSInteger red = selfObject.nmui_red * 255;
            NSInteger blue = selfObject.nmui_blue * 255;
            NSInteger green = selfObject.nmui_green * 255;
            CGFloat alpha = selfObject.nmui_alpha * 255;
            NSString *description = ([NSString stringWithFormat:@"%@, RGBA(%@, %@, %@, %.2f), %@", originReturnValue, @(red), @(green), @(blue), alpha, [selfObject nmui_hexString]]);
            return description;
        });
    });
}

#pragma mark - 十六进制

+ (UIColor *)nmui_colorWithHexString:(NSString *)hexString {
    if (hexString.length <= 0) {
        return nil;
    }
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];

    CGFloat alpha, red, green, blue;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:4 length:1];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:2 length:1];
            green = [self colorComponentFrom:colorString start:4 length:1];
            blue  = [self colorComponentFrom:colorString start:6 length:1];
            break;
        default: {
            NSAssert(NO, @"Color value %@ is invalid. It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString);
            return nil;
        }
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)nmui_hexString {
    NSInteger alpha = self.nmui_alpha * 255;
    NSInteger red = self.nmui_red * 255;
    NSInteger green = self.nmui_green * 255;
    NSInteger blue = self.nmui_blue * 255;
    return [[NSString stringWithFormat:@"#%@%@%@%@",
            [self alignColorHexStringLength:[NSString nmbf_hexStringWithInteger:alpha]],
            [self alignColorHexStringLength:[NSString nmbf_hexStringWithInteger:red]],
            [self alignColorHexStringLength:[NSString nmbf_hexStringWithInteger:green]],
            [self alignColorHexStringLength:[NSString nmbf_hexStringWithInteger:blue]]]
            lowercaseString ];
}


/// 对于色值只有单位数的，在前面补一个0，例如“F”会补齐为“0F”
/// @param hexString 十六进制
- (NSString *)alignColorHexStringLength:(NSString *)hexString {
    return hexString.length < 2 ? [@"0" stringByAppendingString:hexString] : hexString;
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *subString = [string substringWithRange:NSMakeRange(start, length)];
    // 如果截获的字符是单个，就拼凑成两个一样的字符
    NSString *fullHex = length == 2 ? subString : [NSString stringWithFormat:@"%@%@", subString, subString];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

#pragma mark - 元素

- (CGFloat)nmui_red {
    CGFloat r;
    if ([self getRed:&r green:0 blue:0 alpha:0]) {
        return r;
    }
    return 0;
}

- (CGFloat)nmui_green {
    CGFloat g;
    if ([self getRed:0 green:&g blue:0 alpha:0]) {
        return g;
    }
    return 0;
}

- (CGFloat)nmui_blue {
    CGFloat b;
    if ([self getRed:0 green:0 blue:&b alpha:0]) {
        return b;
    }
    return 0;
}

- (CGFloat)nmui_alpha {
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    return 0;
}

- (CGFloat)nmui_hue {
    CGFloat h;
    if ([self getHue:&h saturation:0 brightness:0 alpha:0]) {
        return h;
    }
    return 0;
}

- (CGFloat)nmui_saturation {
    CGFloat s;
    if ([self getHue:0 saturation:&s brightness:0 alpha:0]) {
        return s;
    }
    return 0;
}

- (CGFloat)nmui_brightness {
    CGFloat b;
    if ([self getHue:0 saturation:0 brightness:&b alpha:0]) {
        return b;
    }
    return 0;
}

#pragma mark - 颜色混合

- (nullable UIColor *)nmui_colorWithoutAlpha {
    CGFloat r, g, b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    }
    return nil;
}

- (UIColor *)nmui_colorWithAlpha:(CGFloat)alpha
                 backgroundColor:(UIColor *)backgroundColor {
    return [self nmui_colorWithBackendColor:backgroundColor frontColor:[self colorWithAlphaComponent:alpha]];
}

- (UIColor *)nmui_colorWithAlphaAddedToWhite:(CGFloat)alpha {
    // TODO: UIColorWhite
    return [self nmui_colorWithAlpha:alpha backgroundColor:[UIColor whiteColor]];
}

- (UIColor *)nmui_transitionToColor:(nullable UIColor *)toColor
                           progress:(CGFloat)progress {
    return [self nmui_colorFormColor:self toColor:toColor progress:progress];
}

- (UIColor *)nmui_colorWithBackendColor:(UIColor *)backendColor
                             frontColor:(UIColor *)frontColor {
    CGFloat bgAlpha = [backendColor nmui_alpha];
    CGFloat bgRed = [backendColor nmui_red];
    CGFloat bgGreen = [backendColor nmui_green];
    CGFloat bgBlue = [backendColor nmui_blue];
    
    CGFloat frAlpha = [frontColor nmui_alpha];
    CGFloat frRed = [frontColor nmui_red];
    CGFloat frGreen = [frontColor nmui_green];
    CGFloat frBlue = [frontColor nmui_blue];
    
    CGFloat resultAlpha = frAlpha + bgAlpha * (1 - frAlpha);
    CGFloat resultRed = (frRed * frAlpha + bgRed * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultGreen = (frGreen * frAlpha + bgGreen * bgAlpha * (1 - frAlpha)) / resultAlpha;
    CGFloat resultBlue = (frBlue * frAlpha + bgBlue * bgAlpha * (1 - frAlpha)) / resultAlpha;
    return [UIColor colorWithRed:resultRed green:resultGreen blue:resultBlue alpha:resultAlpha];
}

- (UIColor *)nmui_colorFormColor:(UIColor *)fromColor
                         toColor:(UIColor *)toColor
                        progress:(CGFloat)progress {
    progress = MIN(progress, 1.0f);
    CGFloat fromRed = fromColor.nmui_red;
    CGFloat fromGreen = fromColor.nmui_green;
    CGFloat fromBlue = fromColor.nmui_blue;
    CGFloat fromAlpha = fromColor.nmui_alpha;
    
    CGFloat toRed = toColor.nmui_red;
    CGFloat toGreen = toColor.nmui_green;
    CGFloat toBlue = toColor.nmui_blue;
    CGFloat toAlpha = toColor.nmui_alpha;
    
    CGFloat finalRed = fromRed + (toRed - fromRed) * progress;
    CGFloat finalGreen = fromGreen + (toGreen - fromGreen) * progress;
    CGFloat finalBlue = fromBlue + (toBlue - fromBlue) * progress;
    CGFloat finalAlpha = fromAlpha + (toAlpha - fromAlpha) * progress;
    
    return [UIColor colorWithRed:finalRed green:finalGreen blue:finalBlue alpha:finalAlpha];
}

#pragma mark - 其他

- (BOOL)nmui_isDarkColor {
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:0]) {
        float refreenceValue = 0.411;
        float colorDelta = ( (red * 0.299) + (green * 0.587) + (blue * 0.114) );
        return 1.0 - colorDelta > refreenceValue;
    }
    return YES;
}

- (UIColor *)nmui_inverseColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                                green:(1.0 - componentColors[1])
                                                 blue:(1.0 - componentColors[2])
                                                alpha:1.0 - componentColors[3]] ;
    return newColor;
}

- (BOOL)numi_isSystemTintColor {
    return [self isEqual:[UIColor nmui_systemTintColor]];
}

+ (UIColor *)nmui_systemTintColor {
    static UIColor *systemTintColor = nil;
    if (!systemTintColor) {
        UIView *view = [[UIView alloc] init];
        systemTintColor = view.tintColor;
    }
    return systemTintColor;
}

+ (UIColor *)nmui_randomColor {
    CGFloat red = ( arc4random() % 255 / 255.0 );
    CGFloat green = ( arc4random() % 255 / 255.0 );
    CGFloat blue = ( arc4random() % 255 / 255.0 );
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end

#pragma mark - NMUIDynamicColorProtocol

NSString *const NMUICGColorOriginalColorBindKey = @"NMUICGColorOriginalColorBindKey";

@implementation UIColor(NMUI_DynamicColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            NMBFExtendImplementationOfNonVoidMethodWithoutArguments([UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                return [UIColor clearColor];
            }].class, @selector(CGColor), CGColorRef, ^CGColorRef(UIColor *selfObject, CGColorRef originReturnValue) {
                if (selfObject.nmui_isDynamicColor) {
                    UIColor *color = [UIColor colorWithCGColor:originReturnValue];
                    originReturnValue = color.CGColor;
//                    [(__bridge id)(originReturnValue) nmbin]
                }
                return originReturnValue;
            });
        }
#endif
    });
}

- (BOOL)nmui_isDynamicColor {
    if ([self respondsToSelector:@selector(_isDynamic)]) {
        return self._isDynamic;
    }
    return NO;
}

- (BOOL)nmui_isNMUIDynamicColor {
    return NO;
}

- (UIColor *)nmui_rawColor {
    if (self.nmui_isDynamicColor) {
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            if ([self respondsToSelector:@selector(resolvedColorWithTraitCollection:)]) {
                UIColor *color = [self resolvedColorWithTraitCollection:UITraitCollection.currentTraitCollection];
                return color.nmui_rawColor;
            }
        }
#endif
    }
    return self;
}

@end
