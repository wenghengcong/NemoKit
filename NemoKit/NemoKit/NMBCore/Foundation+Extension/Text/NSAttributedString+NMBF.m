//
//  NSAttributedString+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/29.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSAttributedString+NMBF.h"
#import "NMBCore.h"
#import "NSString+NMBF.h"

@implementation NSAttributedString (NMSize)

/**
 *  @brief 计算文字的高度
 *
 *  @param width 约束宽度
 */
- (CGFloat)nmbf_heightWithConstrainedToWidth:(CGFloat)width
{
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                  context:nil].size;
    return ceil(textSize.height);
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param height 约束高度
 */
- (CGFloat)nmbf_widthWithConstrainedToHeight:(CGFloat)height
{
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                   context:nil].size;
    return ceil(textSize.width);
}

/**
 *  @brief 计算文字的大小
 *
 *  @param width 约束宽度
 */
- (CGSize)nmbf_sizeWithConstrainedToWidth:(CGFloat)width
{
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                  context:nil].size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  @brief 计算文字的大小
 *
 *  @param height 约束高度
 */
- (CGSize)nmbf_sizeWithConstrainedToHeight:(CGFloat)height
{
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                    options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine)
                                    context:nil].size;
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@end


@implementation NSAttributedString (NMBF)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        NMBFOverrideImplementation([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str) {
                
                str = str ?: @"";
                
                // call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSAttributedString * (*)(id, SEL, NSString *))originalIMPProvider();
                NSAttributedString * result = originSelectorIMP(selfObject, originCMD, str);
                
                return result;
            };
        });
        
        NMBFOverrideImplementation([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSAttributedString *(NSAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

- (NSUInteger)nmbf_lengthWhenCountingNonASCIICharacterAsTwo {
    return self.string.nmbf_lengthWhenCountingNonASCIICharacterAsTwo;
}

+ (instancetype)nmbf_attributedStringWithImage:(UIImage *)image {
    return [self nmbf_attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (instancetype)nmbf_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self nmbf_attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self nmbf_attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}

+ (instancetype)nmbf_attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self nmbf_attributedStringWithImage:image];
}

@end


@implementation NSMutableAttributedString (NMBF)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        NMBFOverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str) {
                
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str);
                
                return result;
            };
        });
        
        NMBFOverrideImplementation([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSMutableAttributedString *(NSMutableAttributedString *selfObject, NSString *str, NSDictionary<NSString *,id> *attrs) {
                str = str ?: @"";
                
                // call super
                NSMutableAttributedString *(*originSelectorIMP)(id, SEL, NSString *, NSDictionary<NSString *,id> *);
                originSelectorIMP = (NSMutableAttributedString *(*)(id, SEL, NSString *, NSDictionary<NSString *,id> *))originalIMPProvider();
                NSMutableAttributedString *result = originSelectorIMP(selfObject, originCMD, str, attrs);
                
                return result;
            };
        });
    });
}

@end
