//
//  NSObject+NMBFMutipleDelegate.h
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  让所有 NSObject 都支持多个 delegate，默认只支持属性名为 delegate 的 delegate（特别地，UITableView 和 UICollectionView 额外默认支持 dataSource）。
 *  使用方式：将 nmbf_multipleDelegatesEnabled 置为 YES 后像平时一样 self.delegate = xxx 即可。
 *  如果你要清掉所有的 delegate，则像平时一样 self.delegate = nil 即可。
 *  如果你把 delegate 同时赋值给 objA 和 objB，而你只要移除 objB，则可：[self nmbf_removeDelegate:objB]
 *
 *  如果你要让其他命名的 delegate 属性也支持多 delegate，则可调用 nmbf_registerDelegateSelector: 方法将该属性的 getter 传进去，再进行实际的 delegate 赋值，例如你的 delegate 命名为 abcDelegate，则你可以这么写：
 *  [self nmbf_registerDelegateSelector:@selector(abcDelegate)];
 *  self.abcDelegate = delegateA;
 *  self.abcDelegate = delegateB;
 *  @warning 不支持 self.delegate = self 的写法，会引发死循环，有这种需求的场景建议在 self 内部创建一个对象专门用于 delegate 的响应，参考 _NMUITextViewDelegator。
 */
@interface NSObject (NMBFMutipleDelegate)


/// 当你需要当前的 class 支持多个 delegate，请将此属性置为 YES。默认为 NO。
@property(nonatomic, assign) BOOL nmbf_multipleDelegatesEnabled;

/// 让某个 delegate 属性也支持多 delegate 模式（默认只帮你加了 @selector(delegate) 的支持，如果有其他命名的 property 就需要自己用这个方法添加）
- (void)nmbf_registerDelegateSelector:(SEL)getter;

/// 移除某个特定的 delegate 对象，例如假设你把 delegate 同时赋值给 objA 和 objB，而你只要移除 objB，则可：[self nmbf_removeDelegate:objB]。但如果你想同时移除 objA 和 objB（也即全部 delegate），则像往常一样直接 self.delegate = nil 即可。
- (void)nmbf_removeDelegate:(id)delegate;

@end

@interface NSObject (NMBFMultipleDelegates_Private)

/// 内部使用，用于标志“xxx.delegate = xxx”的情况，具体请看 https://github.com/Tencent/QMUI_iOS/issues/346
@property(nonatomic, assign) BOOL nmbf_delegatesSelf;

@end

NS_ASSUME_NONNULL_END