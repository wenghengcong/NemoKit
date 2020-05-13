//
//  UIColor+NMUITheme.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIColor+NMUITheme.h"
#import "UIColor+NMUI.h"
#import "NMUIThemePrivate.h"
#import "NSObject+NMBF.h"
#import "NMUIThemeManagerCenter.h"

@implementation NMUIThemeColor

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 随着 iOS 版本的迭代，需要不断检查 UIDynamicColor 对比 UIColor 多出来的方法是哪些，然后在 QMUIThemeColor 里补齐，否则可能出现”unrecognized selector sent to instance“的 crash
        // https://github.com/Tencent/QMUI_iOS/issues/791
#if defined(DEBUG) && defined(IOS13_SDK_ALLOWED)
        if (@available(iOS 13.0, *)) {
            Class dynamicColorClass = NSClassFromString(@"UIDynamicColor");
            NSMutableSet<NSString *> *unrecognizedSelectors = NSMutableSet.new;
            NSDictionary<NSString *, NSMutableSet<NSString *> *> *methods = @{
                NSStringFromClass(UIColor.class): NSMutableSet.new,
                NSStringFromClass(dynamicColorClass): NSMutableSet.new,
                NSStringFromClass(self): NSMutableSet.new
            };
            [methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classString, NSMutableSet<NSString *> * _Nonnull methods, BOOL * _Nonnull stop) {
                [NSObject nmbf_enumrateInstanceMethodsOfClass:NSClassFromString(classString) includingInherited:NO usingBlock:^(Method  _Nonnull method, SEL  _Nonnull selector) {
                    [methods addObject:NSStringFromSelector(selector)];
                }];
            }];
            [methods[NSStringFromClass(UIColor.class)] enumerateObjectsUsingBlock:^(NSString * _Nonnull selectorString, BOOL * _Nonnull stop) {
                if ([methods[NSStringFromClass(dynamicColorClass)] containsObject:selectorString]) {
                    [methods[NSStringFromClass(dynamicColorClass)] removeObject:selectorString];
                }
            }];
            [methods[NSStringFromClass(dynamicColorClass)] enumerateObjectsUsingBlock:^(NSString * _Nonnull selectorString, BOOL * _Nonnull stop) {
                if (![methods[NSStringFromClass(self)] containsObject:selectorString]) {
                    [unrecognizedSelectors addObject:selectorString];
                }
            }];
            if (unrecognizedSelectors.count > 0) {
                NMBFLogWarn(NSStringFromClass(self), @"%@ 还需要实现以下方法：%@", NSStringFromClass(self), unrecognizedSelectors);
            }
        }
#endif
    });
}

#pragma mark - Override

- (void)set {
    [self.nmui_rawColor set];
}

- (void)setFill {
    [self.nmui_rawColor setFill];
}

- (void)setStroke {
    [self.nmui_rawColor setStroke];
}

- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha {
    return [self.nmui_rawColor getWhite:white alpha:alpha];
}

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha {
    return [self.nmui_rawColor getHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    return [self.nmui_rawColor getRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha {
    return [UIColor nmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof NMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
        return [self.themeProvider(manager, identifier, theme) colorWithAlphaComponent:alpha];
    }];
}

- (CGFloat)alphaComponent {
    return self.nmui_rawColor.nmui_alpha;
}

- (CGColorRef)CGColor {
    CGColorRef colorRef = [UIColor colorWithCGColor:self.nmui_rawColor.CGColor].CGColor;
    [(__bridge id)(colorRef) nmbf_bindObject:self forKey:NMUICGColorOriginalColorBindKey];
    return colorRef;
}

- (NSString *)colorSpaceName {
    return [((NMUIThemeColor *)self.nmui_rawColor) colorSpaceName];
}

- (id)copyWithZone:(NSZone *)zone {
    NMUIThemeColor *color = [[self class] allocWithZone:zone];
    color.managerName = self.managerName;
    color.themeProvider = self.themeProvider;
    return color;
}

- (BOOL)isEqual:(id)object {
    return self == object;// 例如在 UIView setTintColor: 时会比较两个 color 是否相等，如果相等，则不会触发 tintColor 的更新。由于 dynamicColor 实际的返回色值随时可能变化，所以即便当前的 nmui_rawColor 值相等，也不应该认为两个 dynamicColor 相等（有可能 themeProvider block 内的逻辑不一致，只是其中的某个条件下 return 的 nmui_rawColor 恰好相同而已），所以这里直接返回 NO。
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;// 与 UIDynamicProviderColor 相同
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, nmui_rawColor = %@", [super description], self.nmui_rawColor];
}

- (UIColor *)_highContrastDynamicColor {
    return self;
}

- (UIColor *)_resolvedColorWithTraitCollection:(UITraitCollection *)traitCollection {
    return self.nmui_rawColor;
}

#pragma mark - <NMUIDynamicColorProtocol>

@dynamic nmui_isDynamicColor;

- (UIColor *)nmui_rawColor {
    NMUIThemeManager *manager = [NMUIThemeManagerCenter themeManagerWithName:self.managerName];
    UIColor *color = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme);
    UIColor *result = color.nmui_rawColor;
    return result;
}

- (BOOL)nmui_isNMUIDynamicColor {
    return YES;
}

// _isDynamic 是系统私有的方法，实现它有两个作用：
// 1. 在某些方法里（例如 UIView.backgroundColor），系统会判断当前的 color 是否为 _isDynamic，如果是，则返回 color 本身，如果否，则返回 color 的 CGColor，因此如果 QMUIThemeColor 不实现 _isDynamic 的话，`a.backgroundColor = b.backgroundColor`这种写法就会出错，因为从 `b.backgroundColor` 获取到的 color 已经是用 CGColor 重新创建的系统 UIColor，而非 QMUIThemeColor 了。
// 2. 当 iOS 13 系统设置里的 Dark Mode 发生切换时，系统会自动刷新带有 _isDynamic 方法的 color 对象，当然这个对 QMUI 而言作用不大，因为 QMUIThemeManager 有自己一套刷新逻辑，且很少有人会用 QMUIThemeColor 但却只依赖于 iOS 13 系统来刷新界面。

// 注意，NMUIThemeColor 是 UIColor 的直接子类，只有这种关系才能这样直接定义并重写，不能在 UIColor Category 里定义，否则可能污染 UIDynamicColor 里的 _isDynamic 的实现
- (BOOL)_isDynamic {
    return !!self.themeProvider;
}

@end

@implementation UIColor (NMUITheme)

+ (instancetype)nmui_colorWithThemeProvider:(UIColor * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIColor nmui_colorWithThemeManagerName:NMUIThemeManagerNameDefault provider:provider];
}

+ (UIColor *)nmui_colorWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIColor * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    NMUIThemeColor *color = NMUIThemeColor.new;
    color.managerName = name;
    color.themeProvider = provider;
    return color;
}

@end
