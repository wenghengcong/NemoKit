//
//  NMUIConsole.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIConsole.h"
#import "NMBCore.h"
#import "NSParagraphStyle+NMBF.h"
#import "UIView+NMUI.h"
#import "UIWindow+NMUI.h"
#import "UIColor+NMUI.h"
#import "NMUITextView.h"

@interface NMUIConsole ()

@property(nonatomic, strong) UIWindow *consoleWindow;
@property(nonatomic, strong) NMUIConsoleViewController *consoleViewController;
@end

@implementation NMUIConsole

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NMUIConsole *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.canShow = IS_DEBUG;
        instance.showConsoleAutomatically = YES;
        instance.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        instance.textAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12],
                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                    NSParagraphStyleAttributeName: ({
                                        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:16];
                                        paragraphStyle.paragraphSpacing = 8;
                                        paragraphStyle;
                                    }),
        };
        instance.timeAttributes = ({
            NSMutableDictionary<NSAttributedStringKey, id> *attributes = instance.textAttributes.mutableCopy;
            attributes[NSForegroundColorAttributeName] = [attributes[NSForegroundColorAttributeName] nmui_colorWithAlpha:.6 backgroundColor:instance.backgroundColor];
            attributes.copy;
        });
        instance.searchResultHighlightedBackgroundColor = [UIColorBlue colorWithAlphaComponent:.8];
    });
    return instance;
}

+ (instancetype)appearance {
    return [self sharedInstance];
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (void)logWithLevel:(NSString *)level name:(NSString *)name logString:(id)logString {
    NMUIConsole *console = [NMUIConsole sharedInstance];
    [console initConsoleWindowIfNeeded];
    [console.consoleViewController logWithLevel:level name:name logString:logString];
    if (console.showConsoleAutomatically) {
        [NMUIConsole show];
    }
}

+ (void)log:(id)logString {
    [self logWithLevel:nil name:nil logString:logString];
}

+ (void)clear {
    [[NMUIConsole sharedInstance].consoleViewController clear];
}

+ (void)show {
    NMUIConsole *console = [NMUIConsole sharedInstance];
    if (console.canShow) {
        if (!console.consoleWindow.hidden) return;
        
        // 在某些情况下 show 的时候刚好界面正在做动画，就可能会看到 consoleWindow 从左上角展开的过程（window 默认背景色是黑色的），所以这里做了一些小处理
        // https://github.com/Tencent/QMUI_iOS/issues/743
        [UIView performWithoutAnimation:^{
            [console initConsoleWindowIfNeeded];
            console.consoleWindow.alpha = 0;
            console.consoleWindow.hidden = NO;
        }];
        [UIView animateWithDuration:.25 delay:.2 options:NMUIViewAnimationOptionsCurveOut animations:^{
            console.consoleWindow.alpha = 1;
        } completion:nil];

    }
}

+ (void)hide {
    [NMUIConsole sharedInstance].consoleWindow.hidden = YES;
}

- (void)initConsoleWindowIfNeeded {
    if (!self.consoleWindow) {
        self.consoleWindow = [[UIWindow alloc] init];
        self.consoleWindow.backgroundColor = nil;
        self.consoleWindow.nmui_capturesStatusBarAppearance = NO;
        __weak __typeof(self)weakSelf = self;
        self.consoleWindow.nmui_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
            return originalView == weakSelf.consoleWindow ? nil : originalView;
        };
        
        self.consoleViewController = [[NMUIConsoleViewController alloc] init];
        self.consoleWindow.rootViewController = self.consoleViewController;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.consoleViewController.backgroundColor = backgroundColor;
}

@end
