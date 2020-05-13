//
//  NMUICellSizeKeyCache.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUICellSizeKeyCache.h"

@interface NMUICellSizeKeyCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSValue *> *cachedSizes;
@end

@implementation NMUICellSizeKeyCache

- (instancetype)init {
    if (self = [super init]) {
        self.cachedSizes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)existsSizeForKey:(id<NSCopying>)key {
    NSValue *sizeValue = self.cachedSizes[key];
    return sizeValue && !CGSizeEqualToSize(sizeValue.CGSizeValue, CGSizeMake(-1, -1));
}

- (void)cacheSize:(CGSize)size forKey:(id<NSCopying>)key {
    self.cachedSizes[key] = @(size);
}

- (CGSize)sizeForKey:(id<NSCopying>)key {
    return self.cachedSizes[key].CGSizeValue;
}

- (void)invalidateSizeForKey:(id<NSCopying>)key {
    [self.cachedSizes removeObjectForKey:key];
}

- (void)invalidateAllSizeCache {
    [self.cachedSizes removeAllObjects];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, cachedSizes = %@", [super description], _cachedSizes];
}

@end
