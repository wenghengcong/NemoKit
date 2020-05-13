//
//  NMUICellHeightCache.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICellHeightCache.h"
#import "NMUITableViewProtocols.h"
#import "NMBCore.h"
#import "UIScrollView+NMUI.h"
#import "UIView+NMUI.h"
#import "NSNumber+NMBF.h"

const CGFloat kNMUICellHeightInvalidCache = -1;

@interface NMUICellHeightCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *cachedHeights;
@end

@implementation NMUICellHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedHeights = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.cachedHeights[key];
    return number && ![number isEqualToNumber:@(kNMUICellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.cachedHeights[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
    return self.cachedHeights[key].nmbf_CGFloatValue;
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.cachedHeights removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights removeAllObjects];
}

@end

@interface NMUICellHeightIndexPathCache ()

@property(nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *cachedHeights;
@end

@implementation NMUICellHeightIndexPathCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyInvalidateEnabled = YES;
        self.cachedHeights = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.cachedHeights[indexPath.section][indexPath.row];
    return number && ![number isEqualToNumber:@(kNMUICellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    return self.cachedHeights[indexPath.section][indexPath.row].nmbf_CGFloatValue;
}

- (void)invalidateHeightInSection:(NSInteger)section {
    [self buildSectionsIfNeeded:section];
    [self.cachedHeights[section] removeAllObjects];
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(kNMUICellHeightInvalidCache);
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights enumerateObjectsUsingBlock:^(NSMutableArray<NSNumber *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    for (NSInteger section = 0; section <= targetSection; ++section) {
        if (section >= self.cachedHeights.count) {
            [self.cachedHeights addObject:[[NSMutableArray alloc] init]];
        }
    }
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    NSMutableArray<NSNumber *> *heightsInSection = self.cachedHeights[section];
    for (NSInteger row = 0; row <= targetRow; ++row) {
        if (row >= heightsInSection.count) {
            [heightsInSection addObject:@(kNMUICellHeightInvalidCache)];
        }
    }
}

@end

#pragma mark - UITableView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UITableView ()

/// key 为 tableView 的内容宽度，value 为该宽度下对应的缓存容器，从而保证 tableView 宽度变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NMUICellHeightCache *> *nmuiTableCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NMUICellHeightIndexPathCache *> *nmuiTableCache_allIndexPathHeightCaches;
@end

@implementation UITableView (NMUIKeyedHeightCache)

NMBFSynthesizeIdStrongProperty(nmuiTableCache_allKeyedHeightCaches, setNmuiTableCache_allKeyedHeightCaches)

- (NMUICellHeightCache *)nmui_keyedHeightCache {
    if (!self.nmuiTableCache_allKeyedHeightCaches) {
        self.nmuiTableCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset);
    NMUICellHeightCache *cache = self.nmuiTableCache_allKeyedHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[NMUICellHeightCache alloc] init];
        self.nmuiTableCache_allKeyedHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)nmui_invalidateHeightForKey:(id<NSCopying>)key {
    [self.nmuiTableCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:key];
    }];
}

@end

@implementation UITableView (NMUICellHeightIndexPathCache)

NMBFSynthesizeIdStrongProperty(nmuiTableCache_allIndexPathHeightCaches, setNmuiTableCache_allIndexPathHeightCaches)
NMBFSynthesizeBOOLProperty(nmui_invalidateIndexPathHeightCachedAutomatically, setNmui_invalidateIndexPathHeightCachedAutomatically)

- (NMUICellHeightIndexPathCache *)nmui_indexPathHeightCache {
    if (!self.nmuiTableCache_allIndexPathHeightCaches) {
        self.nmuiTableCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset);
    NMUICellHeightIndexPathCache *cache = self.nmuiTableCache_allIndexPathHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[NMUICellHeightIndexPathCache alloc] init];
        self.nmuiTableCache_allIndexPathHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)nmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UITableView (NMUIIndexPathHeightCacheInvalidation)

- (void)nmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self nmuiTableCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:style:),
            @selector(initWithCoder:),
            @selector(reloadData),
            @selector(insertSections:withRowAnimation:),
            @selector(deleteSections:withRowAnimation:),
            @selector(reloadSections:withRowAnimation:),
            @selector(moveSection:toSection:),
            @selector(insertRowsAtIndexPaths:withRowAnimation:),
            @selector(deleteRowsAtIndexPaths:withRowAnimation:),
            @selector(reloadRowsAtIndexPaths:withRowAnimation:),
            @selector(moveRowAtIndexPath:toIndexPath:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"nmuiTableCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            NMBFExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)nmuiTableCache_initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    [self nmuiTableCache_initWithFrame:frame style:style];
    [self nmuiTableCache_didInitialize];
    return self;
}

- (instancetype)nmuiTableCache_initWithCoder:(NSCoder *)aDecoder {
    [self nmuiTableCache_initWithCoder:aDecoder];
    [self nmuiTableCache_didInitialize];
    return self;
}

- (void)nmuiTableCache_didInitialize {
    self.nmui_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)nmuiTableCache_reloadData {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self nmuiTableCache_reloadData];
}

- (void)nmuiTableCache_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self nmuiTableCache_insertSections:sections withRowAnimation:animation];
}

- (void)nmuiTableCache_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self nmuiTableCache_deleteSections:sections withRowAnimation:animation];
}

- (void)nmuiTableCache_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj invalidateHeightInSection:section];
            }];
        }];
    }
    [self nmuiTableCache_reloadSections:sections withRowAnimation:animation];
}

- (void)nmuiTableCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self nmuiTableCache_moveSection:section toSection:newSection];
}

- (void)nmuiTableCache_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kNMUICellHeightInvalidCache) atIndex:indexPath.row];
            }];
        }];
    }
    [self nmuiTableCache_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)nmuiTableCache_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.row];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self nmuiTableCache_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)nmuiTableCache_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.row] = @(kNMUICellHeightInvalidCache);
            }];
        }];
    }
    [self nmuiTableCache_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)nmuiTableCache_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.row];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.row];
                sourceHeightsInSection[sourceIndexPath.row] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.row] = sourceHeight;
            }
        }];
    }
    [self nmuiTableCache_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UITableView (NMUILayoutCell)

- (__kindof UITableViewCell *)templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // 是否有通过dataSource返回的cell
        if ([self.dataSource respondsToSelector:@selector(nmui_tableView:cellWithIdentifier:)] ) {
            id <NMUICellHeightCache_UITableViewDataSource>dataSource = (id<NMUICellHeightCache_UITableViewDataSource>)self.dataSource;
            templateCell = [dataSource nmui_tableView:self cellWithIdentifier:identifier];
        }
        // 没有的话，则需要通过register来注册一个cell，否则会crash
        if (!templateCell) {
            templateCell = [self dequeueReusableCellWithIdentifier:identifier];
            NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    return templateCell;
}

- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UITableViewCell *cell = [self templateCellForReuseIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset);
    CGSize fitSize = CGSizeZero;
    if (cell && contentWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    }
    return flat(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.nmui_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.nmui_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self nmui_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.nmui_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.nmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.nmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self nmui_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.nmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)nmui_invalidateAllHeight {
    [self.nmuiTableCache_allKeyedHeightCaches removeAllObjects];
    [self.nmuiTableCache_allIndexPathHeightCaches removeAllObjects];
}

@end

#pragma mark - UICollectionView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UICollectionView ()

/// key 为 UICollectionView 的内容大小（包裹着 CGSize），value 为该大小下对应的缓存容器，从而保证 UICollectionView 大小变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSValue *, NMUICellHeightCache *> *nmuiCollectionCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSValue *, NMUICellHeightIndexPathCache *> *nmuiCollectionCache_allIndexPathHeightCaches;
@end

@implementation UICollectionView (NMUIKeyedHeightCache)

NMBFSynthesizeIdStrongProperty(nmuiCollectionCache_allKeyedHeightCaches, setNmuiCollectionCache_allKeyedHeightCaches)

- (NMUICellHeightCache *)nmui_keyedHeightCache {
    if (!self.nmuiCollectionCache_allKeyedHeightCaches) {
        self.nmuiCollectionCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.nmui_contentInset));
    NMUICellHeightCache *cache = self.nmuiCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[NMUICellHeightCache alloc] init];
        self.nmuiCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)nmui_invalidateHeightForKey:(id<NSCopying>)key {
    [self.nmuiCollectionCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:key];
    }];
}

@end

@implementation UICollectionView (NMUICellHeightIndexPathCache)

NMBFSynthesizeBOOLProperty(nmui_invalidateIndexPathHeightCachedAutomatically, setNmui_invalidateIndexPathHeightCachedAutomatically)
NMBFSynthesizeIdStrongProperty(nmuiCollectionCache_allIndexPathHeightCaches, setNmuiCollectionCache_allIndexPathHeightCaches)

- (NMUICellHeightIndexPathCache *)nmui_indexPathHeightCache {
    if (!self.nmuiCollectionCache_allIndexPathHeightCaches) {
        self.nmuiCollectionCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.nmui_contentInset), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.nmui_contentInset));
    NMUICellHeightIndexPathCache *cache = self.nmuiCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[NMUICellHeightIndexPathCache alloc] init];
        self.nmuiCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)nmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UICollectionView (NMUIIndexPathHeightCacheInvalidation)

- (void)nmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self nmuiCollectionCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:collectionViewLayout:),
            @selector(initWithCoder:),
            @selector(reloadData),
            @selector(insertSections:),
            @selector(deleteSections:),
            @selector(reloadSections:),
            @selector(moveSection:toSection:),
            @selector(insertItemsAtIndexPaths:),
            @selector(deleteItemsAtIndexPaths:),
            @selector(reloadItemsAtIndexPaths:),
            @selector(moveItemAtIndexPath:toIndexPath:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"nmuiCollectionCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            NMBFExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)nmuiCollectionCache_initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    [self nmuiCollectionCache_initWithFrame:frame collectionViewLayout:layout];
    [self nmuiCollectionCache_didInitialize];
    return self;
}

- (instancetype)nmuiCollectionCache_initWithCoder:(NSCoder *)aDecoder {
    [self nmuiCollectionCache_initWithCoder:aDecoder];
    [self nmuiCollectionCache_didInitialize];
    return self;
}

- (void)nmuiCollectionCache_didInitialize {
    self.nmui_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)nmuiCollectionCache_reloadData {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self nmuiCollectionCache_reloadData];
}

- (void)nmuiCollectionCache_insertSections:(NSIndexSet *)sections {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self nmuiCollectionCache_insertSections:sections];
}

- (void)nmuiCollectionCache_deleteSections:(NSIndexSet *)sections {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self nmuiCollectionCache_deleteSections:sections];
}

- (void)nmuiCollectionCache_reloadSections:(NSIndexSet *)sections {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights[section] removeAllObjects];
            }];
        }];
    }
    [self nmuiCollectionCache_reloadSections:sections];
}

- (void)nmuiCollectionCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self nmuiCollectionCache_moveSection:section toSection:newSection];
}

- (void)nmuiCollectionCache_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kNMUICellHeightInvalidCache) atIndex:indexPath.item];
            }];
        }];
    }
    [self nmuiCollectionCache_insertItemsAtIndexPaths:indexPaths];
}

- (void)nmuiCollectionCache_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.item];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self nmuiCollectionCache_deleteItemsAtIndexPaths:indexPaths];
}

- (void)nmuiCollectionCache_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.item] = @(kNMUICellHeightInvalidCache);
            }];
        }];
    }
    [self nmuiCollectionCache_reloadItemsAtIndexPaths:indexPaths];
}

- (void)nmuiCollectionCache_moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.nmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.nmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, NMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.item];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.item];
                sourceHeightsInSection[sourceIndexPath.item] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.item] = sourceHeight;
            }
        }];
    }
    [self nmuiCollectionCache_moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UICollectionView (NMUILayoutCell)

- (__kindof UICollectionViewCell *)templateCellForReuseIdentifier:(NSString *)identifier cellClass:(Class)cellClass {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"only flow layout accept");
    NSAssert([cellClass isSubclassOfClass:[UICollectionViewCell class]], @"must be uicollection view cell");
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // CollecionView 跟 TableView 不太一样，无法通过 dequeueReusableCellWithReuseIdentifier:forIndexPath: 来拿到cell（如果这样做，首先indexPath不知道传什么值，其次是这样做会已知crash，说数组越界），所以只能通过传一个class来通过init方法初始化一个cell，但是也有缓存来复用cell。
        // templateCell = [self dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        templateCell = [[cellClass alloc] initWithFrame:CGRectZero];
        NSAssert(templateCell != nil, @"Cell must be registered to collection view for identifier - %@", identifier);
    }
    templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    templateCellsByIdentifiers[identifier] = templateCell;
    return templateCell;
}

- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UICollectionViewCell *cell = [self templateCellForReuseIdentifier:identifier cellClass:cellClass];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGSize fitSize = CGSizeZero;
    if (cell && itemWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(itemWidth, CGFLOAT_MAX)];
    }
    return ceil(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.nmui_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.nmui_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self nmui_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.nmui_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)nmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.nmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.nmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self nmui_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.nmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)nmui_invalidateAllHeight {
    [self.nmuiCollectionCache_allKeyedHeightCaches removeAllObjects];
    [self.nmuiCollectionCache_allIndexPathHeightCaches removeAllObjects];
}

@end
