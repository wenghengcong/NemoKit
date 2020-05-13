//
//  NSAttributedString+NMBF.h
//  Nemo
//
//  Created by Hunt on 2019/10/29.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (NMSize)

/**
 *  @brief 计算文字的高度
 *
 *  @param width 约束宽度
 */
- (CGFloat)nmbf_heightWithConstrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算文字的宽度
 *
 *  @param height 约束高度
 */
- (CGFloat)nmbf_widthWithConstrainedToHeight:(CGFloat)height;

/**
 *  @brief 计算文字的大小
 *
 *  @param width 约束宽度
 */
- (CGSize)nmbf_sizeWithConstrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算文字的大小
 *
 *  @param height 约束高度
 */
- (CGSize)nmbf_sizeWithConstrainedToHeight:(CGFloat)height;

@end

@interface NSAttributedString (NMBF)

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
- (NSUInteger)nmbf_lengthWhenCountingNonASCIICharacterAsTwo;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 */
+ (instancetype)nmbf_attributedStringWithImage:(UIImage *)image;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 * @param offset 图片相对基线的垂直偏移（当 offset > 0 时，图片会向上偏移）
 * @param leftMargin 图片距离左侧内容的间距
 * @param rightMargin 图片距离右侧内容的间距
 * @note leftMargin 和 rightMargin 必须大于或等于 0
 */
+ (instancetype)nmbf_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/**
 * @brief 创建一个用来占位的空白 attributedString
 * @param width 空白占位符的宽度
 */
+ (instancetype)nmbf_attributedStringWithFixedSpace:(CGFloat)width;


@end

@interface NSMutableAttributedString (NMBF)

@end

NS_ASSUME_NONNULL_END
