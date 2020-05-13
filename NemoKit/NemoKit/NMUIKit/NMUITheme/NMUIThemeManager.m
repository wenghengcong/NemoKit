//
//  NMUIThemeManager.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIThemeManager.h"
#import "UITraitCollection+NMUI.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"
#import "NMUIThemePrivate.h"
#import "UIViewController+NMUITheme.h"

NSString *const NMUIThemeDidChangeNotification = @"NMUIThemeDidChangeNotification";

@interface NMUIThemeManager ()

@property(nonatomic, strong) NSMutableArray<NSObject<NSCopying> *> *_themeIdentifiers;
@property(nonatomic, strong) NSMutableArray<NSObject *> *_themes;
@end

@implementation NMUIThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NMUIThemeManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[self allocWithZone:NULL] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, name = %@, themes = %@", [super description], self.name, self.themes];
}

// 这个方法的声明放在 NMUIThemeManagerCenter.m 里，简单实现 private 的效果
- (instancetype)initWithName:(__kindof NSObject<NSCopying> *)name {
    if (self = [super init]) {
        _name = name;
        self._themeIdentifiers = NSMutableArray.new;
        self._themes = NSMutableArray.new;
        if (@available(iOS 13.0, *)) {
            // 如果是iOS 13，注册监听系统的Dark Mode
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInterfaceStyleWillChangeNotification:) name:NMUIUserInterfaceStyleWillChangeNotification object:nil];
        }
    }
    return self;
}

- (void)handleUserInterfaceStyleWillChangeNotification:(NSNotification *)notification {
    if (!_respondsSystemStyleAutomatically) return;
    
    if (@available(iOS 13.0, *)) {
        UITraitCollection *traitCollection = notification.object;
        if (traitCollection && self.identifierForTrait) {
            self.currentThemeIdentifier = self.identifierForTrait(traitCollection);
        }
    }
}

- (void)setRespondsSystemStyleAutomatically:(BOOL)respondsSystemStyleAutomatically {
    _respondsSystemStyleAutomatically = respondsSystemStyleAutomatically;
#ifdef IOS13_SDK_ALLOWED
    if (@available(iOS 13.0, *)) {
        if (_respondsSystemStyleAutomatically && self.identifierForTrait) {
            self.currentThemeIdentifier = self.identifierForTrait([UITraitCollection currentTraitCollection]);
        }
    }
#endif
}

- (void)setCurrentThemeIdentifier:(NSObject<NSCopying> *)currentThemeIdentifier {
    if (![self._themeIdentifiers containsObject:currentThemeIdentifier] && self.themeGenerator) {
        NSObject *theme = self.themeGenerator(currentThemeIdentifier);
        [self addThemeIdentifier:currentThemeIdentifier theme:theme];
    }
    
    NSAssert([self._themeIdentifiers containsObject:currentThemeIdentifier], @"%@ should be added to NMUIThemeManager.themes before it becomes current theme identifier.", currentThemeIdentifier);
    
    BOOL themeChanged = _currentThemeIdentifier && ![_currentThemeIdentifier isEqual:currentThemeIdentifier];
    
    _currentThemeIdentifier = currentThemeIdentifier;
    _currentTheme = [self themeForIdentifier:currentThemeIdentifier];
    
    if (themeChanged) {
        [self notifyThemeChanged];
    }
}

- (void)setCurrentTheme:(NSObject *)currentTheme {
    if (![self._themes containsObject:currentTheme] && self.themeIdentifierGenerator) {
        __kindof NSObject<NSCopying> *identifier = self.themeIdentifierGenerator(currentTheme);
        [self addThemeIdentifier:identifier theme:currentTheme];
    }
    
    NSAssert([self._themes containsObject:currentTheme], @"%@ should be added to NMUIThemeManager.themes before it becomes current theme.", currentTheme);
    
    BOOL themeChanged = _currentTheme && ![_currentTheme isEqual:currentTheme];
    
    _currentTheme = currentTheme;
    _currentThemeIdentifier = [self identifierForTheme:currentTheme];
    
    if (themeChanged) {
        [self notifyThemeChanged];
    }
}

- (NSArray<NSObject<NSCopying> *> *)themeIdentifiers {
    return self._themeIdentifiers.count ? self._themeIdentifiers.copy : nil;
}

- (NSArray<NSObject *> *)themes {
    return self._themes.count ? self._themes.copy : nil;
}

- (__kindof NSObject *)themeForIdentifier:(__kindof NSObject<NSCopying> *)identifier {
    NSUInteger index = [self._themeIdentifiers indexOfObject:identifier];
    if (index != NSNotFound) return self._themes[index];
    return nil;
}

- (__kindof NSObject<NSCopying> *)identifierForTheme:(__kindof NSObject *)theme {
    NSUInteger index = [self._themes indexOfObject:theme];
    if (index != NSNotFound) return self._themeIdentifiers[index];
    return nil;
}

- (void)addThemeIdentifier:(NSObject<NSCopying> *)identifier theme:(NSObject *)theme {
    NSAssert(![self._themeIdentifiers containsObject:identifier], @"unable to add duplicate theme identifier");
    NSAssert(![self._themes containsObject:theme], @"unable to add duplicate theme");
    
    [self._themeIdentifiers addObject:identifier];
    [self._themes addObject:theme];
}

- (void)removeThemeIdentifier:(NSObject<NSCopying> *)identifier {
    [self._themeIdentifiers removeObject:identifier];
}

- (void)removeTheme:(NSObject *)theme {
    [self._themes removeObject:theme];
}

- (void)notifyThemeChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:NMUIThemeDidChangeNotification object:self];
    
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!window.hidden && window.alpha > 0.01 && window.rootViewController) {
            [window.rootViewController nmui_themeDidChangeByManager:self identifier:self.currentThemeIdentifier theme:self.currentTheme];
            if (window.rootViewController.isViewLoaded) {
                [window.rootViewController.view _nmui_themeDidChangeByManager:self identifier:self.currentThemeIdentifier theme:self.currentTheme shouldEnumeratorSubviews:YES];
                //                window.rootViewController.view.nmui_currentThemeIdentifier = self.currentThemeIdentifier;
                //                window.rootViewController.view.nmui_currentTheme = self.currentTheme;
            }
        }
    }];
}

@end
