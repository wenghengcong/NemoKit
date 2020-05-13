//
//  UIVisualEffect+NMUITheme.m
//  Nemo
//
//  Created by Hunt on 2019/9/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIVisualEffect+NMUITheme.h"
#import "NMUIThemePrivate.h"
#import "NSMethodSignature+NMBF.h"
#import "NMUIThemeManagerCenter.h"


@implementation NMUIThemeVisualEffect

- (id)copyWithZone:(NSZone *)zone {
    NMUIThemeVisualEffect *effect = [[self class] allocWithZone:zone];
    effect.managerName = self.managerName;
    effect.themeProvider = self.themeProvider;
    return effect;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.nmui_rawEffect methodSignatureForSelector:aSelector];
    if (result && [self.nmui_rawEffect respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature nmbf_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.nmui_rawEffect respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.nmui_rawEffect];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.nmui_rawEffect respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == NMUIThemeVisualEffect.class) return YES;
    return [self.nmui_rawEffect isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == NMUIThemeVisualEffect.class) return YES;
    return [self.nmui_rawEffect isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.nmui_rawEffect conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <NMUIDynamicEffectProtocol>

- (UIVisualEffect *)nmui_rawEffect {
    NMUIThemeManager *manager = [NMUIThemeManagerCenter themeManagerWithName:self.managerName];
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).nmui_rawEffect;
}

- (BOOL)nmui_isDynamicEffect {
    return YES;
}

@end

@implementation UIVisualEffect (NMUITheme)

+ (UIVisualEffect *)nmui_effectWithThemeProvider:(UIVisualEffect * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIVisualEffect nmui_effectWithThemeManagerName:NMUIThemeManagerNameDefault provider:provider];
}

+ (UIVisualEffect *)nmui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect * _Nonnull (^)(__kindof NMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    NMUIThemeVisualEffect *effect = [[NMUIThemeVisualEffect alloc] init];
    effect.managerName = name;
    effect.themeProvider = provider;
    return (UIVisualEffect *)effect;
}

#pragma mark - <NMUIDynamicEffectProtocol>

- (UIVisualEffect *)nmui_rawEffect {
    return self;
}

- (BOOL)nmui_isDynamicEffect {
    return NO;
}

@end

