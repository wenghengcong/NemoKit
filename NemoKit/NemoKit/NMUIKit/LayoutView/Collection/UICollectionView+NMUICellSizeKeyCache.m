//
//  UICollectionView+NMUICellSizeKeyCache.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UICollectionView+NMUICellSizeKeyCache.h"
#import "NMBCore.h"
#import "NMUICellSizeKeyCache.h"
#import "UIScrollView+NMUI.h"
#import "NMBFMultipleDelegates.h"

//@interface UICollectionViewCell (NMUICellSizeKeyCache)
//
//@property(nonatomic, weak) UICollectionView *nmui_collectionView;
//@end
//
//@implementation UICollectionViewCell (NMUICellSizeKeyCache)
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NMBFExchangeImplementations(self.class, @selector(preferredLayoutAttributesFittingAttributes:), @selector(nmui_preferredLayoutAttributesFittingAttributes:));
//        NMBFExchangeImplementations(self.class, @selector(didMoveToSuperview), @selector(nmui_didMoveToSuperview));
//    });
//}
//
//static char kAssociatedObjectKey_collectionView;
//- (void)setNmui_collectionView:(UICollectionView *)nmui_collectionView {
//    objc_setAssociatedObject(self, &kAssociatedObjectKey_collectionView, nmui_collectionView, OBJC_ASSOCIATION_ASSIGN);
//}
//
//- (UICollectionView *)nmui_collectionView {
//    return (UICollectionView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_collectionView);
//}
//
//- (void)nmui_didMoveToSuperview {
//    [self nmui_didMoveToSuperview];
//    if ([self.superview isKindOfClass:[UICollectionView class]]) {
//        __weak UICollectionView *weakCollectionView = (UICollectionView *)self.superview;
//        self.nmui_collectionView = weakCollectionView;
//    } else {
//        self.nmui_collectionView = nil;
//    }
//}
//
//- (UICollectionViewLayoutAttributes *)nmui_preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    if (self.nmui_collectionView.nmui_cacheCellSizeByKeyAutomatically) {
//        id<NSCopying> key = [((id<NMUICellSizeKeyCache_UICollectionViewDelegate>)self.nmui_collectionView.delegate) nmui_collectionView:self.nmui_collectionView cacheKeyForItemAtIndexPath:layoutAttributes.indexPath];
//        if ([self.nmui_collectionView.nmui_currentCellSizeKeyCache existsSizeForKey:key]) {
//            CGSize cachedSize = [self.nmui_collectionView.nmui_currentCellSizeKeyCache sizeForKey:key];
//            layoutAttributes.size = cachedSize;
//            return layoutAttributes;
//        }
//    }
//    return [self nmui_preferredLayoutAttributesFittingAttributes:layoutAttributes];
//}
//
//@end

@interface UICollectionView ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NMUICellSizeKeyCache *> *nmui_allKeyCaches;
@end

@implementation UICollectionView (NMUICellSizeKeyCache)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFOverrideImplementation([UICollectionView class], @selector(setDelegate:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UICollectionView *selfObject, id<UICollectionViewDelegate> firstArgv) {
                
                [selfObject replaceMethodForDelegateIfNeeded:firstArgv];
                
                // call super
                void (*originSelectorIMP)(id, SEL, id<UICollectionViewDelegate>);
                originSelectorIMP = (void (*)(id, SEL, id<UICollectionViewDelegate>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

static char kAssociatedObjectKey_nmuiCacheCellSizeByKeyAutomatically;
- (void)setNmui_cacheCellSizeByKeyAutomatically:(BOOL)nmui_cacheCellSizeByKeyAutomatically {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmuiCacheCellSizeByKeyAutomatically, @(nmui_cacheCellSizeByKeyAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (nmui_cacheCellSizeByKeyAutomatically) {
        NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"NMUICellSizeKeyCache 只支持 UICollectionViewFlowLayout");
        
        [self replaceMethodForDelegateIfNeeded:self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。与 UITableView 不同，UICollectionView 不管哪个 iOS 版本都要先置为 nil 再重新设置才能让 delegate 方法替换立即生效
        id <UICollectionViewDelegate> tempDelegate = self.delegate;
        self.delegate = nil;
        self.delegate = tempDelegate;
    }
}

- (BOOL)nmui_cacheCellSizeByKeyAutomatically {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiCacheCellSizeByKeyAutomatically)) boolValue];
}

static char kAssociatedObjectKey_nmuiAllKeyCaches;
- (void)setNmui_allKeyCaches:(NSMutableDictionary<NSNumber *,NMUICellSizeKeyCache *> *)nmui_allKeyCaches {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches, nmui_allKeyCaches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, NMUICellSizeKeyCache *> *)nmui_allKeyCaches {
    if (!objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches)) {
        self.nmui_allKeyCaches = [NSMutableDictionary dictionary];
    }
    return (NSMutableDictionary<NSNumber *, NMUICellSizeKeyCache *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_nmuiAllKeyCaches);
}

- (NMUICellSizeKeyCache *)nmui_currentCellSizeKeyCache {
    CGFloat width = [self widthForCacheKey];
    if (width <= 0) {
        return nil;
    }
    NMUICellSizeKeyCache *cache = self.nmui_allKeyCaches[@(width)];
    if (!cache) {
        cache = [[NMUICellSizeKeyCache alloc] init];
        self.nmui_allKeyCaches[@(width)] = cache;
    }
    return cache;
}

// 当 collectionView 水平滚动时，则认为垂直方向的内容区域会影响 cell 的 size 计算。而当 collectionView 垂直滚动时，则认为水平方向的内容区域会影响 cell 的 size 计算。
- (CGFloat)widthForCacheKey {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat height = CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.nmui_contentInset) - UIEdgeInsetsGetVerticalValue(layout.sectionInset);
        return height;
    }
    CGFloat width = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset) - UIEdgeInsetsGetHorizontalValue(((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset);
    return width;
}

- (void)nmui_collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView nmui_collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    if (collectionView.nmui_cacheCellSizeByKeyAutomatically) {
        if (![collectionView.delegate respondsToSelector:@selector(nmui_collectionView:cacheKeyForItemAtIndexPath:)]) {
            NSAssert(NO, @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", collectionView.delegate, NSStringFromSelector(@selector(nmui_collectionView:cacheKeyForItemAtIndexPath:)));
        }
        id<NSCopying> cachedKey = [((id<NMUICellSizeKeyCache_UICollectionViewDelegate>)self) nmui_collectionView:collectionView cacheKeyForItemAtIndexPath:indexPath];
        [collectionView.nmui_currentCellSizeKeyCache cacheSize:cell.frame.size forKey:cachedKey];
    }
}

//- (CGSize)nmui_collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (collectionView.nmui_cacheCellSizeByKeyAutomatically) {
//        if (![collectionView.delegate respondsToSelector:@selector(nmui_collectionView:cacheKeyForItemAtIndexPath:)]) {
//            NSAssert(NO, @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", collectionView.delegate, NSStringFromSelector(@selector(nmui_collectionView:cacheKeyForItemAtIndexPath:)));
//        }
//        id<NSCopying> cachedKey = [((id<NMUICellSizeKeyCache_UICollectionViewDelegate>)self) nmui_collectionView:collectionView cacheKeyForItemAtIndexPath:indexPath];
//        if ([collectionView.nmui_currentCellSizeKeyCache existsSizeForKey:cachedKey]) {
//            return [collectionView.nmui_currentCellSizeKeyCache sizeForKey:cachedKey];
//        }
//    } else {
//        // 对于开启过 nmui_cacheCellSizeByKeyAutomatically 然后又关闭的 class 就会走到这里，此时已经无法调用回之前被替换的方法的实现，所以直接使用 collecionView.itemSize
//        // TODO: molice 最好应该在 replaceMethodForDelegateIfNeeded: 里判断在替换方法之前 delegate 是否已经有实现 sizeForItem，如果有，则在这里调用回它自己的实现，如果没有，再使用 collecionView.itemSize，不然现在的做法会导致 delegate 里关闭了自动缓存的情况下就算实现了 sizeForItem，也无法被调用。
//        return collectionViewLayout.estimatedItemSize;
//    }
//
//    // 由于 NMUICellSizeKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
//    return collectionViewLayout.estimatedItemSize;
//}

static NSMutableSet<NSString *> *nmui_methodsReplacedClasses;
- (void)replaceMethodForDelegateIfNeeded:(id<UICollectionViewDelegate>)delegate {
    if (self.nmui_cacheCellSizeByKeyAutomatically && delegate) {
        if (!nmui_methodsReplacedClasses) {
            nmui_methodsReplacedClasses = [NSMutableSet set];
        }
        void (^addSelectorBlock)(id<UICollectionViewDelegate>) = ^void(id<UICollectionViewDelegate> aDelegate) {
            if ([nmui_methodsReplacedClasses containsObject:NSStringFromClass(aDelegate.class)]) {
                return;
            }
            [nmui_methodsReplacedClasses addObject:NSStringFromClass(aDelegate.class)];
        };
        
        if ([delegate isKindOfClass:[NMBFMultipleDelegates class]]) {
            NSPointerArray *delegates = [((NMBFMultipleDelegates *)delegate).delegates copy];
            for (id d in delegates) {
                if ([d conformsToProtocol:@protocol(UICollectionViewDelegate)]) {
                    addSelectorBlock((id<UICollectionViewDelegate>)d);
                }
            }
        } else {
            addSelectorBlock((id<UICollectionViewDelegate>)delegate);
        }
    }
}

@end
