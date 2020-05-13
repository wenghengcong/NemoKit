//
//  UITableView+NMUICellHeightKeyCache.m
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITableView+NMUICellHeightKeyCache.h"
#import "NMBCore.h"
#import "NMUICellHeightKeyCache.h"
#import "UIView+NMUI.h"
#import "UIScrollView+NMUI.h"
#import "NMUITableViewProtocols.h"
#import "NMBFMultipleDelegates.h"

@interface UITableView ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NMUICellHeightKeyCache *> *nmui_allKeyCaches;
@end

@implementation UITableView (NMUICellHeightKeyCache)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([UITableView class], @selector(setDelegate:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, id<NMUITableViewDelegate> firstArgv) {
                
                [selfObject replaceMethodForDelegateIfNeeded:firstArgv];
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<NMUITableViewDelegate>);
                originSelectorIMP = (void (*)(id, SEL, id<NMUITableViewDelegate>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

static char kAssociatedObjectKey_nmuiCacheCellHeightByKeyAutomatically;
- (void)setNmui_cacheCellHeightByKeyAutomatically:(BOOL)nmui_cacheCellHeightByKeyAutomatically {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmuiCacheCellHeightByKeyAutomatically, @(nmui_cacheCellHeightByKeyAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (nmui_cacheCellHeightByKeyAutomatically) {
        
        NSAssert(!self.delegate || [self.delegate respondsToSelector:@selector(nmui_tableView:cacheKeyForRowAtIndexPath:)], @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", self.delegate, NSStringFromSelector(@selector(nmui_tableView:cacheKeyForRowAtIndexPath:)));
        NSAssert(self.estimatedRowHeight != 0 || [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)], @"必须为 estimatedRowHeight 赋一个不为0的值，或者实现 tableView:estimatedHeightForRowAtIndexPath: 方法，否则无法开启 self-sizing cells 功能");
        
        [self replaceMethodForDelegateIfNeeded:(id<NMUITableViewDelegate>)self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。
        self.delegate = self.delegate;
    }
}

- (BOOL)nmui_cacheCellHeightByKeyAutomatically {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiCacheCellHeightByKeyAutomatically)) boolValue];
}

static char kAssociatedObjectKey_nmuiAllKeyCaches;
- (void)setNmui_allKeyCaches:(NSMutableDictionary<NSNumber *,NMUICellHeightKeyCache *> *)nmui_allKeyCaches {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches, nmui_allKeyCaches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, NMUICellHeightKeyCache *> *)nmui_allKeyCaches {
    if (!objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches)) {
        self.nmui_allKeyCaches = [NSMutableDictionary dictionary];
    }
    return (NSMutableDictionary<NSNumber *, NMUICellHeightKeyCache *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches);
}

- (NMUICellHeightKeyCache *)nmui_currentCellHeightKeyCache {
    CGFloat width = [self widthForCacheKey];
    if (width <= 0) {
        return nil;
    }
    NMUICellHeightKeyCache *cache = self.nmui_allKeyCaches[@(width)];
    if (!cache) {
        cache = [[NMUICellHeightKeyCache alloc] init];
        self.nmui_allKeyCaches[@(width)] = cache;
    }
    return cache;
}

// 只考虑内容区域的宽度，因为 cell 的宽度就由这个来决定
- (CGFloat)widthForCacheKey {
    CGFloat width = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset);
    return width;
}

- (void)nmui_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.nmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<NMUITableViewDelegate>)tableView.delegate) nmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        [tableView.nmui_currentCellHeightKeyCache cacheHeight:CGRectGetHeight(cell.frame) forKey:cachedKey];
    }
}

- (CGFloat)nmui_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.nmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<NMUITableViewDelegate>)tableView.delegate) nmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.nmui_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.nmui_currentCellHeightKeyCache heightForKey:cachedKey];
        }
        // 由于 NMUICellHeightKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
        return UITableViewAutomaticDimension;
    } else {
        // 对于开启过 nmui_cacheCellHeightByKeyAutomatically 然后又关闭的 class 就会走到这里，做个保护而已。理论上走到这个分支本身就是没有意义的。
        return tableView.rowHeight;
    }
}

- (CGFloat)nmui_tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.nmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<NMUITableViewDelegate>)tableView.delegate) nmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.nmui_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.nmui_currentCellHeightKeyCache heightForKey:cachedKey];
        }
    }
    return UITableViewAutomaticDimension;// 表示 NMUICellHeightKeyCache 无法决定一个合适的高度，交给业务，或者交给系统默认值决定。
}

static NSMutableSet<NSString *> *nmui_methodsReplacedClasses;
- (void)replaceMethodForDelegateIfNeeded:(id<NMUITableViewDelegate>)delegate {
    if (self.nmui_cacheCellHeightByKeyAutomatically && delegate) {
        if (!nmui_methodsReplacedClasses) {
            nmui_methodsReplacedClasses = [NSMutableSet set];
        }
        
        void (^addSelectorBlock)(id<NMUITableViewDelegate>) = ^void(id<NMUITableViewDelegate> aDelegate) {
            if ([nmui_methodsReplacedClasses containsObject:NSStringFromClass(aDelegate.class)]) {
                return;
            }
            [nmui_methodsReplacedClasses addObject:NSStringFromClass(aDelegate.class)];
            
            [self handleWillDisplayCellMethodForDelegate:aDelegate];
            [self handleHeightForRowMethodForDelegate:aDelegate];
            [self handleEstimatedHeightForRowMethodForDelegate:aDelegate];
        };
        
        if ([delegate isKindOfClass:[NMBFMultipleDelegates class]]) {
            NSPointerArray *delegates = [((NMBFMultipleDelegates *)delegate).delegates copy];
            for (id d in delegates) {
                if ([d conformsToProtocol:@protocol(NMUITableViewDelegate)]) {
                    addSelectorBlock((id<NMUITableViewDelegate>)d);
                }
            }
        } else {
            addSelectorBlock((id<NMUITableViewDelegate>)delegate);
        }
    }
}

- (void)handleWillDisplayCellMethodForDelegate:(id<NMUITableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:willDisplayCell:forRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则在调用完 delegate 自身的实现后，再调用我们自己的实现去存储计算后的 cell 高度
    SEL willDisplayCellSelector = @selector(tableView:willDisplayCell:forRowAtIndexPath:);
    Method willDisplayCellMethod = class_getInstanceMethod([self class], @selector(nmui_tableView:willDisplayCell:forRowAtIndexPath:));
    IMP willDisplayCellIMP = method_getImplementation(willDisplayCellMethod);
    void (*willDisplayCellFunction)(id<NMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
    willDisplayCellFunction = (void (*)(id<NMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))willDisplayCellIMP;
    
    BOOL addedSuccessfully = class_addMethod(delegate.class, willDisplayCellSelector, willDisplayCellIMP, method_getTypeEncoding(willDisplayCellMethod));
    if (!addedSuccessfully) {
        NMBFOverrideImplementation([delegate class], willDisplayCellSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(id<NMUITableViewDelegate> delegateSelf, UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath) {
                
                // call super
                void (*originSelectorIMP)(id<NMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id<NMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))originalIMPProvider();
                originSelectorIMP(delegateSelf, originCMD, tableView, cell, indexPath);
                
                // call NMUI
                willDisplayCellFunction(delegateSelf, willDisplayCellSelector, tableView, cell, indexPath);
            };
        });
    }
}

- (void)handleHeightForRowMethodForDelegate:(id<NMUITableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:heightForRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则优先拿它的实现的值来 return，如果它的值小于0（例如-1），则认为它想用 NMUICellHeightKeyCache 的计算，此时再 return 我们自己的计算结果
    SEL heightForRowSelector = @selector(tableView:heightForRowAtIndexPath:);
    Method heightForRowMethod = class_getInstanceMethod([self class], @selector(nmui_tableView:heightForRowAtIndexPath:));
    IMP heightForRowIMP = method_getImplementation(heightForRowMethod);
    CGFloat (*heightForRowFunction)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
    heightForRowFunction = (CGFloat (*)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))heightForRowIMP;
    
    BOOL addedSuccessfully = class_addMethod([delegate class], heightForRowSelector, heightForRowIMP, method_getTypeEncoding(heightForRowMethod));
    if (!addedSuccessfully) {
        NMBFOverrideImplementation([delegate class], heightForRowSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGFloat(id<NMUITableViewDelegate> delegateSelf, UITableView *tableView, NSIndexPath *indexPath) {
                
                // call super
                CGFloat (*originSelectorIMP)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
                originSelectorIMP = (CGFloat (*)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))originalIMPProvider();
                CGFloat result = originSelectorIMP(delegateSelf, originCMD, tableView, indexPath);
                
                if (result >= 0) {
                    return result;
                }
                
                // call NMUI
                return heightForRowFunction(delegateSelf, heightForRowSelector, tableView, indexPath);
            };
        });
    }
}

- (void)handleEstimatedHeightForRowMethodForDelegate:(id<NMUITableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:estimatedHeightForRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，会优先拿 NMUICellHeightKeyCache 的结果，如果 NMUICellHeightKeyCache 在 cache 里找不到值，才会返回业务在 tableView:estimatedHeightForRowAtIndexPath: 里的返回值
    SEL heightForRowSelector = @selector(tableView:estimatedHeightForRowAtIndexPath:);
    Method heightForRowMethod = class_getInstanceMethod([self class], @selector(nmui_tableView:estimatedHeightForRowAtIndexPath:));
    IMP heightForRowIMP = method_getImplementation(heightForRowMethod);
    CGFloat (*heightForRowFunction)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
    heightForRowFunction = (CGFloat (*)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))heightForRowIMP;
    
    BOOL addedSuccessfully = class_addMethod([delegate class], heightForRowSelector, heightForRowIMP, method_getTypeEncoding(heightForRowMethod));
    if (!addedSuccessfully) {
        NMBFOverrideImplementation([delegate class], heightForRowSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGFloat(id<NMUITableViewDelegate> delegateSelf, UITableView *tableView, NSIndexPath *indexPath) {
                
                CGFloat result = heightForRowFunction(delegateSelf, heightForRowSelector, tableView, indexPath);
                if (result != UITableViewAutomaticDimension) {
                    return result;
                }
                
                // call super
                CGFloat (*originSelectorIMP)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
                originSelectorIMP = (CGFloat (*)(id<NMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))originalIMPProvider();
                result = originSelectorIMP(delegateSelf, originCMD, tableView, indexPath);
                return result;
            };
        });
    }
}

- (void)nmui_invalidateCellHeightCachedForKey:(id<NSCopying>)key {
    [self.nmui_allKeyCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull widthKey, NMUICellHeightKeyCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:key];
    }];
}

- (void)nmui_invalidateAllCellHeightKeyCache {
    [self.nmui_allKeyCaches removeAllObjects];
}

@end

