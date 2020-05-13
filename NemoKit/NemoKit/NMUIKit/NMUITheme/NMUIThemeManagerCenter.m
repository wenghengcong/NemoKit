//
//  NMUIThemeManagerCenter.m
//  Nemo
//
//  Created by Hunt on 2019/10/7.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIThemeManagerCenter.h"

NSString *const NMUIThemeManagerNameDefault = @"Default";

@interface NMUIThemeManager()

// 这个方法的实现在 NMUIThemeManager.m 里，这里只是为了内部使用而显式声明一次
- (instancetype)initWithName:(__kindof NSObject<NSCopying> *)name;
@end

@interface NMUIThemeManagerCenter()

@property (nonatomic, strong) NSMutableArray<NMUIThemeManager *> *allManagers;

@end

@implementation NMUIThemeManagerCenter

+ (instancetype)shardInstance {
    static NMUIThemeManagerCenter *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[super allocWithZone:NULL] init];
        shared.allManagers = NSMutableArray.new;
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shardInstance];
}

+ (NMUIThemeManager *)themeManagerWithName:(__kindof NSObject<NSCopying> *)name {
    NMUIThemeManagerCenter *center = [NMUIThemeManagerCenter shardInstance];
    for (NMUIThemeManager *manager in center.allManagers) {
        if ([manager.name isEqual:name]) {
            return manager;
        }
    }
    
    NMUIThemeManager *manager = [[NMUIThemeManager alloc] initWithName:name];
    [center.allManagers addObject:manager];
    return manager;
}

+ (NMUIThemeManager *)defaultThemeManager {
    return [NMUIThemeManagerCenter themeManagerWithName:NMUIThemeManagerNameDefault];
}

+ (NSArray<NMUIThemeManager *> *)themeManagers {
    return [NMUIThemeManagerCenter shardInstance].allManagers.copy;
}

@end
