//
//  NMUIConsoleToolbar.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIConsoleToolbar.h"
#import "NMUIConsole.h"
#import "NMBCore.h"
#import "NMUIButton.h"
#import "NMUITextField.h"
#import "UITextField+NMUI.h"
#import "UIImage+NMUI.h"
#import "UIView+NMUI.h"
#import "UIColor+NMUI.h"
#import "UIControl+NMUI.h"
#import "UIImage+NMUI.h"

@interface NMUIConsoleToolbar ()

@property(nonatomic, strong) UIView *searchRightView;
@end

@implementation NMUIConsoleToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _levelButton = [[NMUIButton alloc] init];
        UIImage *filterImage = [[NMUIHelper imageWithName:@"NMUI_console_filter"] nmui_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        UIImage *filterSelectedImage = [[NMUIHelper imageWithName:@"NMUI_console_filter_selected"] nmui_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        
        [self.levelButton setImage:filterImage forState:UIControlStateNormal];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.levelButton setTitle:@"Level" forState:UIControlStateNormal];
        self.levelButton.titleLabel.font = UIFontMake(7);
        self.levelButton.imagePosition = NMUIButtonImagePositionTop;
        self.levelButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.levelButton];
        
        _nameButton = [[NMUIButton alloc] init];
        [self.nameButton setImage:filterImage forState:UIControlStateNormal];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.nameButton setTitle:@"Name" forState:UIControlStateNormal];
        self.nameButton.titleLabel.font = UIFontMake(7);
        self.nameButton.imagePosition = NMUIButtonImagePositionTop;
        self.nameButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.nameButton];
        
        _searchTextField = [[NMUITextField alloc] init];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchTextField.tintColor = [NMUIConsole appearance].textAttributes[NSForegroundColorAttributeName];
        self.searchTextField.textColor = self.searchTextField.tintColor;
        self.searchTextField.placeholderColor = [self.searchTextField.textColor colorWithAlphaComponent:.6];
        self.searchTextField.font = [NMUIConsole appearance].textAttributes[NSFontAttributeName];
        self.searchTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.layer.borderWidth = PixelOne;
        self.searchTextField.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.3].CGColor;
        self.searchTextField.layer.cornerRadius = 3;
        self.searchTextField.placeholder = @"Search...";
        [self addSubview:self.searchTextField];
        
        _clearButton = [[NMUIButton alloc] init];
        [self.clearButton setImage:[NMUIHelper imageWithName:@"NMUI_console_clear"] forState:UIControlStateNormal];
        [self addSubview:self.clearButton];
        
        self.searchRightView = [[UIView alloc] init];
        
        _searchResultCountLabel = [[UILabel alloc] init];
        self.searchResultCountLabel.textColor = self.searchTextField.placeholderColor;
        self.searchResultCountLabel.font = UIFontMake(11);
        [self.searchRightView addSubview:self.searchResultCountLabel];
        
        _searchResultPreviousButton = [[NMUIButton alloc] init];
        [self.searchResultPreviousButton setTitle:@"<" forState:UIControlStateNormal];
        self.searchResultPreviousButton.titleLabel.font = UIFontMake(12);
        [self.searchResultPreviousButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultPreviousButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultPreviousButton];
        
        _searchResultNextButton = [[NMUIButton alloc] init];
        [self.searchResultNextButton setTitle:@">" forState:UIControlStateNormal];
        self.searchResultNextButton.titleLabel.font = UIFontMake(12);
        [self.searchResultNextButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultNextButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultNextButton];
        
        self.searchTextField.rightView = self.searchRightView;
        self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets paddings = UIEdgeInsetsMake(8, 8, 8, 8);
    
    CGFloat x = paddings.left + self.nmui_safeAreaInsets.left;
    CGFloat contentHeight = CGRectGetHeight(self.bounds) - self.nmui_safeAreaInsets.bottom - UIEdgeInsetsGetVerticalValue(paddings);
    
    self.levelButton.frame = CGRectMake(x, paddings.top, contentHeight, contentHeight);
    x = CGRectGetMaxX(self.levelButton.frame);
    
    self.nameButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetMaxX(self.levelButton.frame));
    x = CGRectGetMaxX(self.nameButton.frame);
    
    self.clearButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetWidth(self.bounds) - self.nmui_safeAreaInsets.right - paddings.right - contentHeight);
    
    CGFloat searchTextFieldMarginHorizontal = 8;
    CGFloat searchTextFieldMinX = x + searchTextFieldMarginHorizontal;
    self.searchTextField.frame = CGRectMake(searchTextFieldMinX, paddings.top, CGRectGetMinX(self.clearButton.frame) - searchTextFieldMarginHorizontal - searchTextFieldMinX, contentHeight);
}

- (void)setNeedsLayoutSearchResultViews {
    CGFloat paddingHorizontal = 4;
    CGFloat buttonSpacing = 2;
    CGFloat countLabelMarginRight = 4;
    [self.searchResultCountLabel sizeToFit];
    
    self.searchRightView.nmui_width = paddingHorizontal * 2 + self.searchResultCountLabel.nmui_width + countLabelMarginRight + self.searchResultPreviousButton.nmui_width + buttonSpacing + self.searchResultNextButton.nmui_width;
    self.searchRightView.nmui_height = self.searchTextField.nmui_height;
    
    self.searchResultNextButton.nmui_right = self.searchRightView.nmui_width - paddingHorizontal;
    self.searchResultNextButton.nmui_top = self.searchResultNextButton.nmui_topWhenCenterInSuperview;
    self.searchResultNextButton.nmui_outsideEdge = UIEdgeInsetsMake(-self.searchResultNextButton.nmui_top, -buttonSpacing / 2, -self.searchResultNextButton.nmui_top, -paddingHorizontal);
    
    self.searchResultPreviousButton.nmui_right = self.searchResultNextButton.nmui_left - buttonSpacing;
    self.searchResultPreviousButton.nmui_top = self.searchResultPreviousButton.nmui_topWhenCenterInSuperview;
    self.searchResultNextButton.nmui_outsideEdge = UIEdgeInsetsMake(-self.searchResultPreviousButton.nmui_top, -buttonSpacing / 2, -self.searchResultPreviousButton.nmui_top, -paddingHorizontal);
    
    
    self.searchResultCountLabel.nmui_right = self.searchResultPreviousButton.nmui_left - countLabelMarginRight;
    self.searchResultCountLabel.nmui_top = self.searchResultCountLabel.nmui_topWhenCenterInSuperview;
    
    [self.searchTextField setNeedsLayout];
}

@end
