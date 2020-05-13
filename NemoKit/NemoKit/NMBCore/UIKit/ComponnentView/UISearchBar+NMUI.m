//
//  UISearchBar+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UISearchBar+NMUI.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"
#import "UIImage+NMUI.h"

@implementation UISearchBar (NMUI)

NMBFSynthesizeBOOLProperty(nmui_usedAsTableHeaderView, setNmui_usedAsTableHeaderView)
NMBFSynthesizeUIEdgeInsetsProperty(nmui_textFieldMargins, setNmui_textFieldMargins)

BeginIgnoreDeprecatedWarning
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfVoidMethodWithTwoArguments([UISearchBar class], @selector(setShowsCancelButton:animated:), BOOL, BOOL, ^(UISearchBar *selfObject, BOOL firstArgv, BOOL secondArgv) {
            if (selfObject.nmui_cancelButton && selfObject.nmui_cancelButtonFont) {
                selfObject.nmui_cancelButton.titleLabel.font = selfObject.nmui_cancelButtonFont;
            }
        });
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UISearchBar class], @selector(setPlaceholder:), NSString *, (^(UISearchBar *selfObject, NSString *placeholder) {
            if (selfObject.nmui_placeholderColor || selfObject.nmui_font) {
                NSMutableAttributedString *string = selfObject.nmui_textField.attributedPlaceholder.mutableCopy;
                if (selfObject.nmui_placeholderColor) {
                    [string addAttribute:NSForegroundColorAttributeName value:selfObject.nmui_placeholderColor range:NSMakeRange(0, string.length)];
                }
                if (selfObject.nmui_font) {
                    [string addAttribute:NSFontAttributeName value:selfObject.nmui_font range:NSMakeRange(0, string.length)];
                }
                // 默认移除文字阴影
                [string removeAttribute:NSShadowAttributeName range:NSMakeRange(0, string.length)];
                selfObject.nmui_textField.attributedPlaceholder = string.copy;
            }
        }));
        
        // iOS 13 下，UISearchBar 内的 UITextField 的 _placeholderLabel 会在 didMoveToWindow 时被重新设置 textColor，导致我们在 searchBar 添加到界面之前设置的 placeholderColor 失效，所以在这里重新设置一遍
        // https://github.com/Tencent/QMUI_iOS/issues/830
        if (@available(iOS 13.0, *)) {
            NMBFExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(didMoveToWindow), ^(UISearchBar *selfObject) {
                if (selfObject.nmui_placeholderColor) {
                    selfObject.placeholder = selfObject.placeholder;
                }
            });
        }
        
        if (@available(iOS 13.0, *)) {
            // -[_UISearchBarLayout applyLayout] 是 iOS 13 系统新增的方法，该方法可能会在 -[UISearchBar layoutSubviews] 后调用，作进一步的布局调整。
            Class _UISearchBarLayoutClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBar", @"Layout"]);
            NMBFOverrideImplementation(_UISearchBarLayoutClass, NSSelectorFromString(@"applyLayout"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD);
                    };
                    
                    UISearchBar *searchBar = (UISearchBar *)((UIView *)[selfObject nmbf_valueForKey:[NSString stringWithFormat:@"_%@",@"searchBarBackground"]]).superview.superview;
                    
                    NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                    
                    if (searchBar && searchBar.nmui_searchController.isBeingDismissed && searchBar.nmui_usedAsTableHeaderView) {
                        CGRect previousRect = searchBar.nmui_backgroundView.frame;
                        callSuperBlock();
                        // applyLayout 方法中会修改 _searchBarBackground  的 frame ，从而覆盖掉 nmui_usedAsTableHeaderView 做出的调整，所以这里还原本次修改。
                        searchBar.nmui_backgroundView.frame = previousRect;
                    } else {
                        callSuperBlock();
                    }
                };
                
            });
            
            // iOS 13 后，cancelButton 的 frame 由 -[_UISearchBarSearchContainerView layoutSubviews] 去修改
            Class _UISearchBarSearchContainerViewClass = NSClassFromString([NSString stringWithFormat:@"_%@%@",@"UISearchBarSearch", @"ContainerView"]);
            NMBFExtendImplementationOfVoidMethodWithoutArguments(_UISearchBarSearchContainerViewClass, @selector(layoutSubviews), ^(UIView *selfObject) {
                UISearchBar *searchBar = (UISearchBar *)selfObject.superview.superview;
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                [searchBar nmui_adjustCancelButtonFrameIfNeeded];
            });
        }
        
        Class UISearchBarTextFieldClass = NSClassFromString([NSString stringWithFormat:@"%@%@",@"UISearchBarText", @"Field"]);
        NMBFOverrideImplementation(UISearchBarTextFieldClass, @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITextField *textField, CGRect frame) {
                
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)textField.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)textField.superview.superview;
                }
                
                NSAssert(searchBar == nil || [searchBar isKindOfClass:[UISearchBar class]], @"not a searchBar");
                
                if (searchBar) {
                    frame = [searchBar nmui_adjustedSearchTextFieldFrameByOriginalFrame:frame];
                }
                
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(textField, originCMD, frame);
                
                [searchBar nmui_searchTextFieldFrameDidChange];
            };
        });
        
        
        NMBFExtendImplementationOfVoidMethodWithoutArguments([UISearchBar class], @selector(layoutSubviews), ^(UISearchBar *selfObject) {
            // 修复 iOS 13 backgroundView 没有撑开到顶部的问题
            if (IOS_VERSION >= 13.0 && selfObject.nmui_usedAsTableHeaderView && selfObject.nmui_isActive) {
                selfObject.nmui_backgroundView.nmui_height = StatusBarHeightConstant + selfObject.nmui_height;
                selfObject.nmui_backgroundView.nmui_top = -StatusBarHeightConstant;
            }
            [selfObject nmui_adjustCancelButtonFrameIfNeeded];
            [selfObject nmui_fixDismissingAnimationIfNeeded];
            [selfObject nmui_fixSearchResultsScrollViewContentInsetIfNeeded];
            
        });
        
        NMBFOverrideImplementation([UISearchBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchBar *selfObject, CGRect frame) {
                
                frame = [selfObject nmui_adjustedSearchBarFrameByOriginalFrame:frame];
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
            };
        });
    });
}
EndIgnoreDeprecatedWarning

static char kAssociatedObjectKey_PlaceholderColor;
- (void)setNmui_placeholderColor:(UIColor *)nmui_placeholderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor, nmui_placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
}

- (UIColor *)nmui_placeholderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_PlaceholderColor);
}

static char kAssociatedObjectKey_TextColor;
- (void)setNmui_textColor:(UIColor *)nmui_textColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_TextColor, nmui_textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.nmui_textField.textColor = nmui_textColor;
}

- (UIColor *)nmui_textColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_TextColor);
}

static char kAssociatedObjectKey_font;
- (void)setNmui_font:(UIFont *)nmui_font {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_font, nmui_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        // 触发 setPlaceholder 里更新 placeholder 样式的逻辑
        self.placeholder = self.placeholder;
    }
    
    // 更新输入框的文字样式
    self.nmui_textField.font = nmui_font;
}

- (UIFont *)nmui_font {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_font);
}

- (UITextField *)nmui_textField {
    UITextField *textField = [self nmbf_valueForKey:@"searchField"];
    return textField;
}

- (UIButton *)nmui_cancelButton {
    UIButton *cancelButton = [self nmbf_valueForKey:@"cancelButton"];
    return cancelButton;
}

static char kAssociatedObjectKey_cancelButtonFont;
- (void)setNmui_cancelButtonFont:(UIFont *)nmui_cancelButtonFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont, nmui_cancelButtonFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.nmui_cancelButton.titleLabel.font = nmui_cancelButtonFont;
}

- (UIFont *)nmui_cancelButtonFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cancelButtonFont);
}

- (UISegmentedControl *)nmui_segmentedControl {
    // 注意，segmentedControl 只是整条 scopeBar 里的一部分，虽然它的 key 叫做“scopeBar”
    UISegmentedControl *segmentedControl = [self nmbf_valueForKey:@"scopeBar"];
    return segmentedControl;
}

- (BOOL)nmui_isActive {
    return (self.nmui_searchController.isBeingPresented || self.nmui_searchController.isActive);
}

- (UISearchController *)nmui_searchController {
    return [self nmbf_valueForKey:@"_searchController"];
}

- (UIView *)nmui_backgroundView {
    BeginIgnorePerformSelectorLeaksWarning
    UIView *backgroundView = [self performSelector:NSSelectorFromString(@"_backgroundView")];
    EndIgnorePerformSelectorLeaksWarning
    return backgroundView;
}


- (void)nmui_styledAsNMUISearchBar {
    if (!NMUICMIActivated) {
        return;
    }
    
    // 搜索框的字号及 placeholder 的字号
    self.nmui_font = SearchBarFont;
    
    // 搜索框的文字颜色
    self.nmui_textColor = SearchBarTextColor;
    
    // placeholder 的文字颜色
    self.nmui_placeholderColor = SearchBarPlaceholderColor;
    
    self.placeholder = @"搜索";
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    // 设置搜索icon
    UIImage *searchIconImage = SearchBarSearchIconImage;
    if (searchIconImage) {
        if (!CGSizeEqualToSize(searchIconImage.size, CGSizeMake(14, 14))) {
            NSLog(@"搜索框放大镜图片（SearchBarSearchIconImage）的大小最好为 (14, 14)，否则会失真，目前的大小为 %@", NSStringFromCGSize(searchIconImage.size));
        }
        [self setImage:searchIconImage forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    }
    
    // 设置搜索右边的清除按钮的icon
    UIImage *clearIconImage = SearchBarClearIconImage;
    if (clearIconImage) {
        [self setImage:clearIconImage forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }
    
    // 设置SearchBar上的按钮颜色
    self.tintColor = SearchBarTintColor;
    
    // 输入框背景图
    UIImage *searchFieldBackgroundImage = SearchBarTextFieldBackgroundImage;
    if (searchFieldBackgroundImage) {
        [self setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    }
    
    // 输入框边框
    UIColor *textFieldBorderColor = SearchBarTextFieldBorderColor;
    if (textFieldBorderColor) {
        self.nmui_textField.layer.borderWidth = PixelOne;
        self.nmui_textField.layer.borderColor = textFieldBorderColor.CGColor;
    }
    
    // 整条bar的背景
    // 为了让 searchBar 底部的边框颜色支持修改，背景色不使用 barTintColor 的方式去改，而是用 backgroundImage
    UIImage *backgroundImage = SearchBarBackgroundImage;
    if (backgroundImage) {
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self setBackgroundImage:backgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefaultPrompt];
    }
}

+ (UIImage *)nmui_generateTextFieldBackgroundImageWithColor:(UIColor *)color {
    // 背景图片的高度会决定输入框的高度，在 iOS 11 及以上，系统默认高度是 36，iOS 10 及以下的高度是 28 的搜索输入框的高度计算: UISearchBar+NMUI.m
    // 至于圆角，输入框会在 UIView 层面控制，背景图里无需处理
    return [[UIImage nmui_imageWithColor:color size:self.nmui_textFieldDefaultSize cornerRadius:0] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
}

+ (UIImage *)nmui_generateBackgroundImageWithColor:(UIColor *)backgroundColor borderColor:(UIColor *)borderColor {
    UIImage *backgroundImage = nil;
    if (backgroundColor || borderColor) {
        backgroundImage = [UIImage nmui_imageWithColor:backgroundColor ?: UIColorWhite size:CGSizeMake(10, 10) cornerRadius:0];
        if (borderColor) {
            backgroundImage = [backgroundImage nmui_imageWithBorderColor:borderColor borderWidth:PixelOne borderPosition:NMUIImageBorderPositionBottom];
        }
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    }
    return backgroundImage;
}

#pragma mark - Layout Fix

- (BOOL)nmui_shouldFixLayoutWhenUsedAsTableHeaderView {
    if (@available(iOS 11, *)) {
        return self.nmui_usedAsTableHeaderView && self.nmui_searchController.hidesNavigationBarDuringPresentation;
    }
    return NO;
}

- (void)nmui_adjustCancelButtonFrameIfNeeded  {
    if (!self.nmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if ([self nmui_isActive]) {
        CGRect textFieldFrame = self.nmui_textField.frame;
        self.nmui_cancelButton.nmui_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.nmui_cancelButton.frame);
        if (self.nmui_segmentedControl.superview.nmui_top < self.nmui_textField.nmui_bottom) {
            // scopeBar 显示在搜索框右边
            self.nmui_segmentedControl.superview.nmui_top = CGRectGetMinYVerticallyCenter(textFieldFrame, self.nmui_segmentedControl.superview.frame);
        }
    }
}

- (CGRect)nmui_adjustedSearchBarFrameByOriginalFrame:(CGRect)frame {
    if (!self.nmui_shouldFixLayoutWhenUsedAsTableHeaderView) return frame;
    
    // 重写 setFrame: 是为了这个 issue：https://github.com/Tencent/QMUI_iOS/issues/233
    // iOS 11 下用 tableHeaderView 的方式使用 searchBar 的话，进入搜索状态时 y 偏上了，导致间距错乱
    // iOS 13 iPad 在退出动画时 y 值可能为负，需要修正
    
    if (self.nmui_searchController.isBeingDismissed && CGRectGetMinY(frame) < 0) {
        frame = CGRectSetY(frame, 0);
    }
    
    if (![self nmui_isActive]) {
        return frame;
    }
    
    if (IS_NOTCHED_SCREEN) {
        // 竖屏
        if (CGRectGetMinY(frame) == 38) {
            // searching
            frame = CGRectSetY(frame, 44);
        }
        
        // 全面屏 iPad
        if (CGRectGetMinY(frame) == 18) {
            // searching
            frame = CGRectSetY(frame, 24);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    } else {
        
        // 竖屏
        if (CGRectGetMinY(frame) == 14) {
            frame = CGRectSetY(frame, 20);
        }
        
        // 横屏
        if (CGRectGetMinY(frame) == -6) {
            frame = CGRectSetY(frame, 0);
        }
    }
    // 强制在激活状态下 高度也为 56，方便后续做平滑过渡动画 (iOS 11 默认下，非刘海屏的机器激活后为 50，刘海屏激活后为 55)
    if (frame.size.height != 56) {
        frame.size.height = 56;
    }
    return frame;
}
BeginIgnoreDeprecatedWarning
- (CGRect)nmui_adjustedSearchTextFieldFrameByOriginalFrame:(CGRect)frame {
    if (self.nmui_shouldFixLayoutWhenUsedAsTableHeaderView) {
        if (self.nmui_searchController.isBeingPresented) {
            BOOL statusBarHidden = NO;
            if (@available(iOS 13.0, *)) {
                statusBarHidden = self.window.windowScene.statusBarManager.statusBarHidden;
            } else {
                statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
            }
            CGFloat visibleHeight = statusBarHidden ? 56 : 50;
            frame.origin.y = (visibleHeight - self.nmui_textField.nmui_height) / 2;
        } else if (self.nmui_searchController.isBeingDismissed) {
            frame.origin.y = (56 - self.nmui_textField.nmui_height) / 2;
        }
    }
    
    // apply nmui_textFieldMargins
    if (!UIEdgeInsetsEqualToEdgeInsets(self.nmui_textFieldMargins, UIEdgeInsetsZero)) {
        frame = CGRectInsetEdges(frame, self.nmui_textFieldMargins);
    }
    return frame;
}
EndIgnoreDeprecatedWarning

- (void)nmui_searchTextFieldFrameDidChange {
    // apply SearchBarTextFieldCornerRadius
    CGFloat textFieldCornerRadius = SearchBarTextFieldCornerRadius;
    if (textFieldCornerRadius != 0) {
        textFieldCornerRadius = textFieldCornerRadius > 0 ? textFieldCornerRadius : CGRectGetHeight(self.nmui_textField.frame) / 2.0;
    }
    self.nmui_textField.layer.cornerRadius = textFieldCornerRadius;
    self.nmui_textField.clipsToBounds = textFieldCornerRadius != 0;
    
    [self nmui_adjustCancelButtonFrameIfNeeded];
}

BeginIgnoreDeprecatedWarning
- (void)nmui_fixDismissingAnimationIfNeeded {
    if (!self.nmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    
    if (self.nmui_searchController.isBeingDismissed) {
        
        if (IS_NOTCHED_SCREEN && self.frame.origin.y == 43) { // 修复刘海屏下，系统计算少了一个 pt
            self.frame = CGRectSetY(self.frame, StatusBarHeightConstant);
        }
        
        UIView *searchBarContainerView = self.superview;
        // 每次激活搜索框，searchBarContainerView 都会重新创建一个
        if (searchBarContainerView.layer.masksToBounds == YES) {
            searchBarContainerView.layer.masksToBounds = NO;
            // backgroundView 被 searchBarContainerView masksToBounds 裁减掉的底部。
            CGFloat backgroundViewBottomClipped = CGRectGetMaxY([searchBarContainerView convertRect:self.nmui_backgroundView.frame fromView:self.nmui_backgroundView.superview]) - CGRectGetHeight(searchBarContainerView.bounds);
            // UISeachbar 取消激活时，如果 BackgroundView 底部超出了 searchBarContainerView，需要以动画的形式来过渡：
            if (backgroundViewBottomClipped > 0) {
                CGFloat previousHeight = self.nmui_backgroundView.nmui_height;
                [UIView performWithoutAnimation:^{
                    // 先减去 backgroundViewBottomClipped 使得 backgroundView 和 searchBarContainerView 底部对齐，由于这个时机是包裹在 animationBlock 里的，所以要包裹在 performWithoutAnimation 中来设置
                    self.nmui_backgroundView.nmui_height -= backgroundViewBottomClipped;
                }];
                // 再还原高度，这里在 animationBlock 中，所以会以动画来过渡这个效果
                self.nmui_backgroundView.nmui_height = previousHeight;
                
                // 以下代码为了保持原有的顶部的 mask，否则在 NavigationBar 为透明或者磨砂时，会看到 backgroundView
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddRect(path, NULL, CGRectMake(0, 0, searchBarContainerView.nmui_width, previousHeight));
                maskLayer.path = path;
                searchBarContainerView.layer.mask = maskLayer;
            }
        }
    }
}
EndIgnoreDeprecatedWarning
- (void)nmui_fixSearchResultsScrollViewContentInsetIfNeeded {
    if (!self.nmui_shouldFixLayoutWhenUsedAsTableHeaderView) return;
    if (self.nmui_isActive) {
        UIViewController *searchResultsController = self.nmui_searchController.searchResultsController;
        if (searchResultsController && [searchResultsController isViewLoaded]) {
            UIView *view = searchResultsController.view;
            UIScrollView *scrollView =
            [view isKindOfClass:UIScrollView.class] ? view :
            [view.subviews.firstObject isKindOfClass:UIScrollView.class] ? view.subviews.firstObject : nil;
            UIView *searchBarContainerView = self.superview;
            if (scrollView && searchBarContainerView) {
                scrollView.contentInset = UIEdgeInsetsMake(searchBarContainerView.nmui_height, 0, 0, 0);
            }
        }
    }
}

static CGSize textFieldDefaultSize;
+ (CGSize)nmui_textFieldDefaultSize {
    if (CGSizeIsEmpty(textFieldDefaultSize)) {
        textFieldDefaultSize = CGSizeMake(60, 28);
        // 在 iOS 11 及以上，搜索输入框系统默认高度是 36，iOS 10 及以下的高度是 28
        if (@available(iOS 11.0, *)) {
            textFieldDefaultSize.height = 36;
        }
    }
    return textFieldDefaultSize;
}


@end
