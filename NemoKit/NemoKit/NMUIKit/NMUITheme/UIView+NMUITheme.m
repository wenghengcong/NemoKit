//
//  UIView+NMUITheme.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIView+NMUITheme.h"
#import "NMBFRuntimeMacro.h"
#import "NMUIThemePrivate.h"
#import "NMBFAssociationMacro.h"
#import "NMBFoundationMacro.h"
#import "UIView+NMUI.h"
#import "NMUIThemeManager.h"
#import "NMUIThemePrivate.h"
#import "CALayer+NMUI.h"
#import "NMBCore.h"

@implementation UIView (NMUITheme)

NMBFSynthesizeIdCopyProperty(nmui_themeDidChangeBlock, setNmui_themeDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 12 及以下的版本，[UIView setBackgroundColor:] 并不会保存传进来的 color，所以要自己用个变量保存起来，不然 NMUIThemeColor 对象就会被丢弃
        if (@available(iOS 13.0, *)) {
        } else {
            NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setBackgroundColor:), UIColor *, ^(UIView *selfObject, UIColor *color) {
                selfObject.nmuiTheme_backgroundColor = color;
            });
            NMBFExtendImplementationOfNonVoidMethodWithoutArguments([UIView class], @selector(backgroundColor), UIColor *, ^UIColor *(UIView *selfObject, UIColor *originReturnValue) {
                return selfObject.nmuiTheme_backgroundColor ?: originReturnValue;
            });
        }
        
        NMBFOverrideImplementation([UIView class], @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                BOOL valueChanged = selfObject.hidden != firstArgv;
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (valueChanged) {
                    // UIView.nmui_currentThemeIdentifier 只是为了实现判断当前的 theme 是否有发生变化，所以可以构造成一个 string，但怎么避免每次 hidden 切换时都要遍历所有的 subviews？
                    [selfObject _nmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:YES];
                }
            };
        });
        
        NMBFOverrideImplementation([UIView class], @selector(setAlpha:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGFloat firstArgv) {
                
                BOOL willShow = selfObject.alpha <= 0 && firstArgv > 0.01;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGFloat);
                originSelectorIMP = (void (*)(id, SEL, CGFloat))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (willShow) {
                    // 只设置 identifier 就可以了，内部自然会去同步更新 theme
                    [selfObject _nmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:YES];
                }
            };
        });
        
        // 这几个 class 实现了自己的 didMoveToWindow 且没有调用 super，所以需要每个都替换一遍方法
        NSArray<Class> *classes = @[UIView.class,
                                    UICollectionView.class,
                                    UITextField.class,
                                    UISearchBar.class,
                                    NSClassFromString(@"UITableViewLabel")];
        if (NSClassFromString(@"WKWebView")) {
            classes = [classes arrayByAddingObject:NSClassFromString(@"WKWebView")];
        }
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
            NMBFExtendImplementationOfVoidMethodWithoutArguments(class, @selector(didMoveToWindow), ^(UIView *selfObject) {
                // enumerateSubviews 为 NO 是因为当某个 view 的 didMoveToWindow 被触发时，它的每个 subview 的 didMoveToWindow 也都会被触发，所以不需要遍历 subview 了
                if (selfObject.window) {
                    [selfObject _nmui_themeDidChangeByManager:nil identifier:nil theme:nil shouldEnumeratorSubviews:NO];
                }
            });
        }];
    });
}

- (void)nmui_registerThemeColorProperties:(NSArray<NSString *> *)getters {
    [getters enumerateObjectsUsingBlock:^(NSString * _Nonnull getterString, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = setterWithGetter(getter);
        NSString *setterString = NSStringFromSelector(setter);
        NSAssert([self respondsToSelector:getter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), getterString);
        NSAssert([self respondsToSelector:setter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), setterString);
        
        if (!self.nmuiTheme_themeColorProperties) {
            self.nmuiTheme_themeColorProperties = NSMutableDictionary.new;
        }
        self.nmuiTheme_themeColorProperties[getterString] = setterString;
    }];
}

- (void)nmui_unregisterThemeColorProperties:(NSArray<NSString *> *)getters {
    if (!self.nmuiTheme_themeColorProperties) return;
    
    [getters enumerateObjectsUsingBlock:^(NSString * _Nonnull getterString, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.nmuiTheme_themeColorProperties removeObjectForKey:getterString];
    }];
}

- (void)nmui_themeDidChangeByManager:(NMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    if (![self _nmui_visible]) return;
    
    // 常见的 view 在 NMUIThemePrivate 里注册了 getter，在这里被调用
    [self.nmuiTheme_themeColorProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull getterString, NSString * _Nonnull setterString, BOOL * _Nonnull stop) {
        
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = NSSelectorFromString(setterString);
        
        // 由于 tintColor 属性自带向下传递的性质，并且当值为 nil 时会自动从 superview 读取值，所以不需要在这里遍历修改，否则取出 tintColor 后再设置回去，会打破这个传递链
        if (getter == @selector(tintColor)) {
            if (!self.nmui_tintColorCustomized) return;
        }
        
        // 注意，需要遍历的属性不一定都是 UIColor 类型，也有可能是 NSAttributedString，例如 UITextField.attributedText
        BeginIgnorePerformSelectorLeaksWarning
        id value = [self performSelector:getter];
        if (!value) return;
        BOOL isValidatedColor = [value isKindOfClass:NMUIThemeColor.class] && (!manager || [((NMUIThemeColor *)value).managerName isEqual:manager.name]);
        BOOL isValidatedImage = [value isKindOfClass:NMUIThemeImage.class] && (!manager || [((NMUIThemeImage *)value).managerName isEqual:manager.name]);
        BOOL isValidatedEffect = [value isKindOfClass:NMUIThemeVisualEffect.class] && (!manager || [((NMUIThemeVisualEffect *)value).managerName isEqual:manager.name]);
        BOOL isOtherObject = ![value isKindOfClass:UIColor.class] && ![value isKindOfClass:UIImage.class] && ![value isKindOfClass:UIVisualEffect.class];// 支持所有非 color、image、effect 的其他对象，例如 NSAttributedString
        if (isOtherObject || isValidatedColor || isValidatedImage || isValidatedEffect) {
            [self performSelector:setter withObject:value];
        }
        EndIgnorePerformSelectorLeaksWarning
    }];
    
    // 特殊的 view 特殊处理
    // iOS 10-11 里当 UILabel.attributedText 的文字颜色都相同时，也无法使用 setNeedsDisplay 刷新样式，但只要某个 range 颜色不同就没问题，iOS 9、12-13 也没问题，这个通过 UILabel (NMUIThemeCompatibility) 兼容。
    // iOS 9-13，当 UITextField 没有聚焦时，不需要调用 setNeedsDisplay 系统都可以自动更新文字样式，但聚焦时调用 setNeedsDisplay 也无法更新样式，这里依赖了 UITextField (NMUIThemeCompatibility) 对 setNeedsDisplay 做的兼容实现了更新
    // 注意，iOS 11 及以下的 UITextView 直接调用 setNeedsDisplay 是无法刷新文字样式的，这里依赖了 UITextView (NMUIThemeCompatibility) 里通过 swizzle 实现了兼容，iOS 12 及以上没问题。
    static NSArray<Class> *needsDisplayClasses = nil;
    if (!needsDisplayClasses) needsDisplayClasses = @[UILabel.class, UITextField.class, UITextView.class];
    [needsDisplayClasses enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isKindOfClass:class]) [self setNeedsDisplay];
    }];
    
    // 输入框、搜索框的键盘跟随主题变化
    if (NMUICMIActivated && [self conformsToProtocol:@protocol(UITextInputTraits)]) {
        NSObject<UITextInputTraits> *input = (NSObject<UITextInputTraits> *)self;
        if ([input respondsToSelector:@selector(keyboardAppearance)]) {
            if (input.keyboardAppearance != KeyboardAppearance) {
                input.keyboardAppearance = KeyboardAppearance;
            }
        }
    }
    
    /** 这里去掉动画有 2 个原因：
     1. iOS 13 进入后台时会对 currentTraitCollection.userInterfaceStyle 做一次取反进行截图，以便在后台切换 Drak/Light 后能够更新 app 多任务缩略图，NMUI 响应了这个操作去调整取反后的 layer 的颜色，而在对 layer 设置属性的时候，如果包含了动画会导致截图不到最终的状态，这样会导致在后台切换 Drak/Light 后多任务缩略图无法及时更新。
     2. 对于 UIView 层，修改 backgroundColor 默认是没有动画的，而 CALayer 修改 backgroundColor 会有隐式动画，这里为了在响应主题变化时颜色同步更新，统一把 CALayer 的动画去掉
     */
    [CALayer nmui_performWithoutAnimation:^{
        [self.layer nmui_setNeedsUpdateDynamicStyle];
    }];
    
    if (self.nmui_themeDidChangeBlock) {
        self.nmui_themeDidChangeBlock();
    }
}

@end

@implementation UIView (NMUITheme_Private)

NMBFSynthesizeIdStrongProperty(nmuiTheme_backgroundColor, setNmuiTheme_backgroundColor)
NMBFSynthesizeIdStrongProperty(nmuiTheme_themeColorProperties, setNmuiTheme_themeColorProperties)

- (BOOL)_nmui_visible {
    BOOL hidden = self.hidden;
    if ([self respondsToSelector:@selector(prepareForReuse)]) {
        hidden = NO;// UITableViewCell 在 prepareForReuse 前会被 setHidden:YES，然后再被 setHidden:NO，然而后者是无效的，执行完之后依然是 hidden 为 YES，导致认为非 visible 而无法触发 themeDidChange，所以这里对 UITableViewCell 做特殊处理
    }
    return !hidden && self.alpha > 0.01 && self.window;
}

- (void)_nmui_themeDidChangeByManager:(NMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [self nmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    if (shouldEnumeratorSubviews) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview _nmui_themeDidChangeByManager:manager identifier:identifier theme:theme shouldEnumeratorSubviews:YES];
        }];
    }
}

@end
