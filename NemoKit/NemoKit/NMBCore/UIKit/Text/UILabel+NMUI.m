//
//  UILabel+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UILabel+NMUI.h"
#import "NMBCore.h"
#import "NSNumber+NMBF.h"
#import "NSParagraphStyle+NMBF.h"

const CGFloat NMUILineHeightIdentity = -1000;

@implementation UILabel (NMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExchangeImplementations([self class], @selector(setText:), @selector(nmui_setText:));
        NMBFExchangeImplementations([self class], @selector(setAttributedText:), @selector(nmui_setAttributedText:));
    });
}

- (void)nmui_setText:(NSString *)text {
    if (!text) {
        [self nmui_setText:text];
        return;
    }
    if (!self.nmui_textAttributes.count && ![self _hasSetNmuiLineHeight]) {
        [self nmui_setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.nmui_textAttributes];
    [self nmui_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:attributedString]];
}

// 在 nmui_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
- (void)nmui_setAttributedText:(NSAttributedString *)text {
    if (!text || (!self.nmui_textAttributes.count && ![self _hasSetNmuiLineHeight])) {
        [self nmui_setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.nmui_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [self nmui_setAttributedText:attributedString];
}

static char kAssociatedObjectKey_textAttributes;
// 在现有样式基础上增加 nmui_textAttributes 样式。换句话说，如果这个方法里有样式冲突，则以 nmui_textAttributes 为准
- (void)setNmui_textAttributes:(NSDictionary<NSAttributedStringKey, id> *)nmui_textAttributes {
    NSDictionary *prevTextAttributes = self.nmui_textAttributes;
    if ([prevTextAttributes isEqualToDictionary:nmui_textAttributes]) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textAttributes, nmui_textAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!self.text.length) {
        return;
    }
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    NSRange fullRange = NSMakeRange(0, string.length);
    
    // 1）当前 attributedText 包含的样式可能来源于两方面：通过 nmui_textAttributes 设置的、通过直接传入 attributedString 设置的，这里要过滤删除掉前者的样式效果，保留后者的样式效果
    if (prevTextAttributes) {
        // 找出现在 attributedText 中哪些 attrs 是通过上次的 nmui_textAttributes 设置的
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 nmui_textAttribtus 设置的
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:prevTextAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 nmui_textAttributes 设置的
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
                if (prevTextAttributes[attr] == value) {
                    [willRemovedAttributes addObject:attr];
                }
            }];
        }];
        [willRemovedAttributes enumerateObjectsUsingBlock:^(id  _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
            [string removeAttribute:attr range:fullRange];
        }];
    }
    
    // 2）添加新样式
    if (nmui_textAttributes) {
        [string addAttributes:nmui_textAttributes range:fullRange];
    }
    // 不能调用 setAttributedText: ，否则若遇到样式冲突，那个方法会让用户传进来的 NSAttributedString 样式覆盖 nmui_textAttributes 的样式
    [self nmui_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:string]];
}

- (NSDictionary *)nmui_textAttributes {
    return (NSDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textAttributes);
}

// 去除最后一个字的 kern 效果，并且在有必要的情况下应用 nmui_setLineHeight: 设置的行高
- (NSAttributedString *)attributedStringWithKernAndLineHeightAdjusted:(NSAttributedString *)string {
    if (!string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString = (NSMutableAttributedString *)string;
    } else {
        attributedString = [string mutableCopy];
    }
    
    // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
    // 只有当 nmui_textAttributes 中设置了 kern 时这里才应该做调整
    if (self.nmui_textAttributes[NSKernAttributeName]) {
        [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    }
    
    // 判断是否应该应用上通过 nmui_setLineHeight: 设置的行高
    __block BOOL shouldAdjustLineHeight = [self _hasSetNmuiLineHeight];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
        // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
        if (NSEqualRanges(range, NSMakeRange(0, attributedString.length))) {
            if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                shouldAdjustLineHeight = NO;
                *stop = YES;
            }
        }
    }];
    if (shouldAdjustLineHeight) {
        NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:self.nmui_lineHeight lineBreakMode:self.lineBreakMode textAlignment:self.textAlignment];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length)];
    }
    
    return attributedString;
}

static char kAssociatedObjectKey_lineHeight;
- (void)setNmui_lineHeight:(CGFloat)nmui_lineHeight {
    if (nmui_lineHeight == NMUILineHeightIdentity) {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_lineHeight, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_lineHeight, @(nmui_lineHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 注意：对于 UILabel，只要你设置过 text，则 attributedText 就是有值的，因此这里无需区分 setText 还是 setAttributedText
    // 注意：这里需要刷新一下 nmui_textAttributes 对 text 的样式，否则刚进行设置的 lineHeight 就会无法设置。
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.attributedText.string attributes:self.nmui_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [self setAttributedText:attributedString];
}

- (CGFloat)nmui_lineHeight {
    if ([self _hasSetNmuiLineHeight]) {
        return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lineHeight) nmbf_CGFloatValue];
    } else if (self.attributedText.length) {
        __block NSMutableAttributedString *string = [self.attributedText mutableCopy];
        __block CGFloat result = 0;
        [string enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
            // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
            if (NSEqualRanges(range, NSMakeRange(0, string.length))) {
                if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                    result = style.maximumLineHeight;
                    *stop = YES;
                }
            }
        }];
        
        return result == 0 ? self.font.lineHeight : result;
    } else if (self.text.length) {
        return self.font.lineHeight;
    }
    
    return 0;
}

- (BOOL)_hasSetNmuiLineHeight {
    return !!objc_getAssociatedObject(self, &kAssociatedObjectKey_lineHeight);
}

- (instancetype)nmui_initWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    BeginIgnoreClangWarning(-Wunused-value)
    [self init];
    EndIgnoreClangWarning
    self.font = font;
    self.textColor = textColor;
    return self;
}

- (void)nmui_setTheSameAppearanceAsLabel:(UILabel *)label {
    self.font = label.font;
    self.textColor = label.textColor;
    self.backgroundColor = label.backgroundColor;
    self.lineBreakMode = label.lineBreakMode;
    self.textAlignment = label.textAlignment;
    if ([self respondsToSelector:@selector(setContentEdgeInsets:)] && [label respondsToSelector:@selector(contentEdgeInsets)]) {
        UIEdgeInsets contentEdgeInsets;
        [label nmbf_performSelector:@selector(contentEdgeInsets) withPrimitiveReturnValue:&contentEdgeInsets];
        [self nmbf_performSelector:@selector(setContentEdgeInsets:) withArguments:&contentEdgeInsets, nil];
    }
}

- (void)nmui_calculateHeightAfterSetAppearance {
    self.text = @"测";
    [self sizeToFit];
    self.text = nil;
}

- (void)nmui_avoidBlendedLayersIfShowingChineseWithBackgroundColor:(UIColor *)color {
    self.opaque = YES;// 本来默认就是YES，这里还是明确写一下
    self.backgroundColor = color;
    self.clipsToBounds = YES;// 只 clip 不使用 cornerRadius就不会触发offscreen render
}

@end
