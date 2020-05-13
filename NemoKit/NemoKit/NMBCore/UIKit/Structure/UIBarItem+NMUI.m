//
//  UIBarItem+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIBarItem+NMUI.h"
#import "NMBCore.h"
#import "UIView+NMUI.h"

@interface UIBarItem ()
@property(nonatomic, copy) NSString *nmuibaritem_viewDidSetBlockIdentifier;
@end


@implementation UIBarItem (NMUI)

// 用于某些低版本 iOS 里，在 UINavigationButton/UIToolbarButton/UITabBarButton 里建立对 UIBarItem 的引用
static char kAssociatedObjectKey_referenceItem;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // UIBarButtonItem -setView:
        // @warning 如果作为 UIToolbar.items 使用，则 customView 的情况下，iOS 10 及以下的版本不会调用 setView:，所以那种情况改为在 setToolbarItems:animated: 时调用，代码见下方
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIBarButtonItem class], @selector(setView:), UIView *, ^(UIBarButtonItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarButtonItem:selfObject];
        });
        
        if (IOS_VERSION_NUMBER < 110000) {
            // iOS 11.0 及以上，通过 setView: 调用 nmui_viewDidSetBlock 即可，10.0 及以下只能在 setToolbarItems 的时机触发
            NMBFExtendImplementationOfVoidMethodWithTwoArguments([UIViewController class], @selector(setToolbarItems:animated:), NSArray<__kindof UIBarButtonItem *> *, BOOL, ^(UIViewController *selfObject, NSArray<__kindof UIBarButtonItem *> *firstArgv, BOOL secondArgv) {
                for (UIBarButtonItem *item in firstArgv) {
                    [UIBarItem setView:item.customView inBarButtonItem:item];
                }
            });
        }
        
        
        // UITabBarItem -setView:
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UITabBarItem class], @selector(setView:), UIView *, ^(UITabBarItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarItem:selfObject];
        });
        
        void (^layoutSubviewsBlock)(UIView *selfObject) = ^void(UIView *selfObject) {
            UIBarItem *item = (UIBarItem *)((NMBFWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_referenceItem)).object;
            if (item.nmui_viewDidLayoutSubviewsBlock) {
                item.nmui_viewDidLayoutSubviewsBlock(item, selfObject);
            }
        };
        
        // iOS 10 及以下，UIBarButtonItem 的 view 的 layoutSubviews 没有调用 super，所以无法利用 UIView (NMUI).nmui_layoutSubviewsBlock 实现这个功能，所以这里才需要直接重写该 class 的 layoutSubviews
        if (IOS_VERSION_NUMBER < 110000) {
            NMBFExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UINavigation", @"Button"]), @selector(layoutSubviews), layoutSubviewsBlock);
            NMBFExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UIToolbar", @"Button"]), @selector(layoutSubviews), layoutSubviewsBlock);
        }
        
        // iOS 9 及以下，UITabBarItem 的 view 的 layoutSubviews 没有调用 super，所以无法利用 UIView (NMUI).nmui_layoutSubviewsBlock 实现这个功能，所以这里才需要直接重写该 class 的 layoutSubviews
        if (IOS_VERSION_NUMBER < 100000) {
            NMBFExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UITab", @"BarButton"]), @selector(layoutSubviews), layoutSubviewsBlock);
        }
    });
}

- (UIView *)nmui_view {
    // UIBarItem 本身没有 view 属性，只有子类 UIBarButtonItem 和 UITabBarItem 才有
    if ([self respondsToSelector:@selector(view)]) {
        return [self nmbf_valueForKey:@"view"];
    }
    return nil;
}

NMBFSynthesizeIdCopyProperty(nmuibaritem_viewDidSetBlockIdentifier, setNmuibaritem_viewDidSetBlockIdentifier)
NMBFSynthesizeIdCopyProperty(nmui_viewDidSetBlock, setNmui_viewDidSetBlock)

static char kAssociatedObjectKey_viewDidLayoutSubviewsBlock;
- (void)setNmui_viewDidLayoutSubviewsBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))nmui_viewDidLayoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock, nmui_viewDidLayoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.nmui_view) {
        __weak __typeof(self)weakSelf = self;
        self.nmui_view.nmui_layoutSubviewsBlock = ^(__kindof UIView * _Nonnull view) {
            if (weakSelf.nmui_viewDidLayoutSubviewsBlock) {
                weakSelf.nmui_viewDidLayoutSubviewsBlock(weakSelf, view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))nmui_viewDidLayoutSubviewsBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock);
}

static char kAssociatedObjectKey_viewLayoutDidChangeBlock;
- (void)setNmui_viewLayoutDidChangeBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))nmui_viewLayoutDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock, nmui_viewLayoutDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 这里有个骚操作，对于 iOS 11 及以上，item.view 被放在一个 UIStackView 内，而当屏幕旋转时，通过 item.view.nmui_frameDidChangeBlock 得到的时机过早，布局尚未被更新，所以把 nmui_frameDidChangeBlock 放到 stackView 上以保证时机的准确性，但当调用 nmui_viewLayoutDidChangeBlock 时传进去的参数 view 依然要是 item.view
    UIView *view = self.nmui_view;
    if (IOS_VERSION_NUMBER >= 110000 && [view.superview isKindOfClass:[UIStackView class]]) {
        view = self.nmui_view.superview;
    }
    if (view) {
        __weak __typeof(self)weakSelf = self;
        view.nmui_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
            if (weakSelf.nmui_viewLayoutDidChangeBlock){
                weakSelf.nmui_viewLayoutDidChangeBlock(weakSelf, weakSelf.nmui_view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))nmui_viewLayoutDidChangeBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock);
}

#pragma mark - Tools

+ (NSString *)identifierWithView:(UIView *)view block:(id)block {
    return [NSString stringWithFormat:@"%p, %p", view, block];
}

+ (void)setView:(UIView *)view inBarItem:(__kindof UIBarItem *)item {
    if (IOS_VERSION_NUMBER < 110000) {
        if ([NSStringFromClass(view.class) hasPrefix:@"UINavigation"] || [NSStringFromClass(view.class) hasPrefix:@"UIToolbar"]) {
            NMBFWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_referenceItem);
            if (!weakContainer) {
                weakContainer = [NMBFWeakObjectContainer new];
            }
            weakContainer.object = item;
            objc_setAssociatedObject(view, &kAssociatedObjectKey_referenceItem, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    if (IOS_VERSION_NUMBER < 100000) {
        if ([NSStringFromClass(view.class) hasPrefix:@"UITabBar"]) {
            NMBFWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_referenceItem);
            if (!weakContainer) {
                weakContainer = [NMBFWeakObjectContainer new];
            }
            weakContainer.object = item;
            objc_setAssociatedObject(view, &kAssociatedObjectKey_referenceItem, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    if (item.nmui_viewDidSetBlock) {
        item.nmui_viewDidSetBlock(item, view);
    }
    
    if (item.nmui_viewDidLayoutSubviewsBlock) {
        item.nmui_viewDidLayoutSubviewsBlock = item.nmui_viewDidLayoutSubviewsBlock;// to call setter
    }
    
    if (item.nmui_viewLayoutDidChangeBlock) {
        item.nmui_viewLayoutDidChangeBlock = item.nmui_viewLayoutDidChangeBlock;// to call setter
    }
}

+ (void)setView:(UIView *)view inBarButtonItem:(UIBarButtonItem *)item {
    if (![[UIBarItem identifierWithView:view block:item.nmui_viewDidSetBlock] isEqualToString:item.nmuibaritem_viewDidSetBlockIdentifier]) {
        item.nmuibaritem_viewDidSetBlockIdentifier = [UIBarItem identifierWithView:view block:item.nmui_viewDidSetBlock];
        
        [self setView:view inBarItem:item];
    }
}

@end
