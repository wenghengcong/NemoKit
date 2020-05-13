//
//  NMUIConsoleToolbar.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NMUIButton;
@class NMUITextField;

@interface NMUIConsoleToolbar : UIView

@property(nonatomic, strong, readonly) NMUIButton *levelButton;
@property(nonatomic, strong, readonly) NMUIButton *nameButton;
@property(nonatomic, strong, readonly) NMUIButton *clearButton;
@property(nonatomic, strong, readonly) NMUITextField *searchTextField;
@property(nonatomic, strong, readonly) UILabel *searchResultCountLabel;
@property(nonatomic, strong, readonly) NMUIButton *searchResultPreviousButton;
@property(nonatomic, strong, readonly) NMUIButton *searchResultNextButton;

- (void)setNeedsLayoutSearchResultViews;
@end

NS_ASSUME_NONNULL_END
