//
//  NMUITextField.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUITextField.h"
#import "NMBCore.h"
#import "NSString+NMBF.h"
#import "UITextField+NMUI.h"
#import "NMBFMultipleDelegates.h"

// 私有的类，专用于实现 NMUITextFieldDelegate，避免 self.delegate = self 的写法（以前是 NMUITextField 自己实现了 delegate）
@interface _NMUITextFieldDelegator : NSObject <NMUITextFieldDelegate, UIScrollViewDelegate>

@property(nonatomic, weak) NMUITextField *textField;
- (void)handleTextChangeEvent:(NMUITextField *)textField;
@end

@interface NMUITextField ()

@property(nonatomic, strong) _NMUITextFieldDelegator *delegator;
@end

@implementation NMUITextField

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
        self.tintColor = TextFieldTintColor;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.nmbf_multipleDelegatesEnabled = YES;
    self.delegator = [[_NMUITextFieldDelegator alloc] init];
    self.delegator.textField = self;
    self.delegate = self.delegator;
    [self addTarget:self.delegator action:@selector(handleTextChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    
    self.placeholderColor = UIColorPlaceholder;
    self.textInsets = TextFieldTextInsets;
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    self.maximumTextLength = NSUIntegerMax;
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - Placeholder

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    if (self.placeholderColor) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)updateAttributedPlaceholderIfNeeded {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
    if (@available(iOS 10.0, *)) {
        UIScrollView *scrollView = self.subviews.firstObject;
        if (![scrollView isKindOfClass:[UIScrollView class]]) {
            return;
        }
        
        // 默认 delegate 是为 nil 的，所以我们才利用 delegate 修复这 个 bug，如果哪一天 delegate 不为 nil，就先不处理了。
        if (scrollView.delegate) {
            return;
        }
        
        scrollView.delegate = self.delegator;
    }
}

- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    [super setText:text];
    
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToString:text]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSAttributedString *textBeforeChange = self.attributedText;
    [super setAttributedText:attributedText];
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToAttributedString:attributedText]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)fireTextDidChangeEventForTextField:(NMUITextField *)textField {
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return self.shouldCountingNonASCIICharacterAsTwo ? string.nmbf_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
}

#pragma mark - Positioning Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    CGRect resultRect = [super textRectForBounds:bounds];
    return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect result = [super clearButtonRectForBounds:bounds];
    result = CGRectOffset(result, self.clearButtonPositionAdjustment.horizontal, self.clearButtonPositionAdjustment.vertical);
    return result;
}

@end

@implementation _NMUITextFieldDelegator

#pragma mark - <NMUITextFieldDelegate>

- (BOOL)textField:(NMUITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.maximumTextLength < NSUIntegerMax) {
        
        // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
        if (textField.markedTextRange) {
            return YES;
        }
        
        BOOL isDeleting = range.length > 0 && string.length <= 0;
        if (isDeleting) {
            if (NSMaxRange(range) > textField.text.length) {
                // https://github.com/Tencent/QMUI_iOS/issues/377
                return NO;
            } else {
                return YES;
            }
        }
        
        NSUInteger rangeLength = textField.shouldCountingNonASCIICharacterAsTwo ? [textField.text substringWithRange:range].nmbf_lengthWhenCountingNonASCIICharacterAsTwo : range.length;
        if ([textField lengthWithString:textField.text] - rangeLength + [textField lengthWithString:string] > textField.maximumTextLength) {
            // 将要插入的文字裁剪成这么长，就可以让它插入了
            NSInteger substringLength = textField.maximumTextLength - [textField lengthWithString:textField.text] + rangeLength;
            if (substringLength > 0 && [textField lengthWithString:string] > substringLength) {
                NSString *allowedText = [string nmbf_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, substringLength) lessValue:YES countingNonASCIICharacterAsTwo:textField.shouldCountingNonASCIICharacterAsTwo];
                if ([textField lengthWithString:allowedText] <= substringLength) {
                    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:allowedText];
                    
                    if (!textField.shouldResponseToProgrammaticallyTextChanges) {
                        [textField fireTextDidChangeEventForTextField:textField];
                    }
                }
            }
            
            if ([textField.delegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.delegate textField:textField didPreventTextChangeInRange:range replacementString:string];
            }
            return NO;
        }
    }
    
    return YES;
}

- (void)handleTextChangeEvent:(NMUITextField *)textField {
    // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textField:shouldChangeCharactersInRange:replacementString: 的，所以要在这里截断文字
    // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
    
    if (!textField.markedTextRange) {
        if ([textField lengthWithString:textField.text] > textField.maximumTextLength) {
            textField.text = [textField.text nmbf_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, textField.maximumTextLength) lessValue:YES countingNonASCIICharacterAsTwo:textField.shouldCountingNonASCIICharacterAsTwo];
            
            if ([textField.delegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.delegate textField:textField didPreventTextChangeInRange:textField.nmui_selectedRange replacementString:nil];
            }
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
    
    if (scrollView != self.textField.subviews.firstObject) {
        return;
    }
    
    CGFloat lineHeight = ((NSParagraphStyle *)self.textField.defaultTextAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
    lineHeight = lineHeight ?: ((UIFont *)self.textField.defaultTextAttributes[NSFontAttributeName]).lineHeight;
    if (scrollView.contentSize.height > ceil(lineHeight) && scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

@end
