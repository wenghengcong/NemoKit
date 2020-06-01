//
//  NMBFMutipleDelegates.h
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+NMBFMultipleDelegates.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 存放多个 delegate 指针的容器，必须搭配其他控件使用，一般不需要你自己 init。作用是让某个 class 支持同时存在多个 delegate。更多说明请查看 NSObject (NMBFMultipleDelegates) 的注释。
@interface NMBFMultipleDelegates : NSObject

+ (instancetype)weakDelegates;
+ (instancetype)strongDelegates;

@property(nonatomic, strong, readonly) NSPointerArray *delegates;
@property(nonatomic, weak) NSObject *parentObject;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (BOOL)containsDelegate:(id)delegate;
@end

NS_ASSUME_NONNULL_END
