//
//  NMUIConsoleViewController.h
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class NMUIButton;
@class NMUITextView;
@class NMUIConsoleToolbar;

@interface NMUIConsoleViewController : NMUICommonViewController

@property(nonatomic, strong, readonly) NMUIButton *popoverButton;
@property(nonatomic, strong, readonly) NMUITextView *textView;
@property(nonatomic, strong, readonly) NMUIConsoleToolbar *toolbar;
@property(nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@property(nonatomic, strong) UIColor *backgroundColor;

- (void)logWithLevel:(nullable NSString *)level name:(nullable NSString *)name logString:(id)logString;
- (void)log:(id)logString;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
