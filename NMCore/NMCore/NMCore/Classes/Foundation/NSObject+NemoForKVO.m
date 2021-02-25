//
//  NSObject+NemoForKVO.m
//  NMCore
//
//  Created by Hunt on 2020/10/13.
//

#import "NSObject+NemoForKVO.h"
#import "NMCoreMacro.h"
#import <objc/objc.h>
#import <objc/runtime.h>

NMSYNTH_DUMMY_CLASS(NSObject_NemoForKVO)

static const int block_key;

/// 使用该中间对象监听对应的属性，并由该中间对象将属性改变通过 block 透传出去
@interface _NMNSObjectKVOBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(__weak id obj, id oldVal, id newVal);

- (instancetype)initWithBlock:(void (^)(__weak id obj, id oldVal, id newVal))block;

@end

@implementation _NMNSObjectKVOBlockTarget

- (instancetype)initWithBlock:(void (^)(__weak id, id, id))block {
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

/*
 * NSKeyValueChangeKindKey：change始终包含，是NSNumber对象，具体的数值有NSKeyValueChangeSetting、NSKeyValueChangeInsertion、NSKeyValueChangeRemoval、NSKeyValueChangeReplacement这几个，其中后三个是针对于to-many relationship的。

 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (!self.block) return;
    
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    self.block(object, oldVal, newVal);
}

@end

@implementation NSObject (NemoForKVO)

/*
 * addObserver:forKeyPath:options:context: 中 option 参数有下列值：
 * NSKeyValueObservingOptionNew：当options中包括了这个参数的时候，观察者收到的change参数中就会包含NSKeyValueChangeNewKey和它对应的值，也就是说，观察者可以得知这个property在被改变之后的新值。
 NSKeyValueObservingOptionOld：和NSKeyValueObservingOptionNew的意思类似，当包含了这个参数的时候，观察者收到的change参数中就会包含NSKeyValueChangeOldKey和它对应的值。
 * NSKeyValueObservingOptionInitial：当包含这个参数的时候，在addObserver的这个过程中，就会有一个notification被发送到观察者那里，反之则没有。
 * NSKeyValueObservingOptionPrior：当包含这个参数的时候，在被观察的property的值改变前和改变后，系统各会给观察者发送一个change notification；在property的值改变之前发送的change notification中，change参数会包含NSKeyValueChangeNotificationIsPriorKey并且值为@YES，但不会包含NSKeyValueChangeNewKey和它对应的值。
 
 */
- (void)addObserverBlockForKeyPath:(NSString *)keyPath block:(void (^)(__weak id obj, id oldVal, id newVal))block {
    if (!keyPath || !block) return;
    // new 一个中间对象，中间对象将监听
    _NMNSObjectKVOBlockTarget *target = [[_NMNSObjectKVOBlockTarget alloc] initWithBlock:block];
    NSMutableDictionary *dic = [self _nm_allNSObjectObserverBlocks];
    NSMutableArray *arr = dic[keyPath];
    if (!arr) {
        arr = [NSMutableArray new];
        dic[keyPath] = arr;
    }
    [arr addObject:target];
    // target is observer，when self's keypath changed, target will get notify
    [self addObserver:target forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObserverBlocksForKeyPath:(NSString *)keyPath {
    if (!keyPath) return;
    NSMutableDictionary *dic = [self _nm_allNSObjectObserverBlocks];
    NSMutableArray *arr = dic[keyPath];
    [arr enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeObserver:obj forKeyPath:keyPath];
    }];
    
    [dic removeObjectForKey:keyPath];
}

- (void)removeObserverBlocks {
    NSMutableDictionary *dic = [self _nm_allNSObjectObserverBlocks];
    [dic enumerateKeysAndObjectsUsingBlock: ^(NSString *key, NSArray *arr, BOOL *stop) {
        [arr enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            [self removeObserver:obj forKeyPath:key];
        }];
    }];
    
    [dic removeAllObjects];
}

- (NSMutableDictionary *)_nm_allNSObjectObserverBlocks {
    NSMutableDictionary *targets = objc_getAssociatedObject(self, &block_key);
    if (!targets) {
        targets = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &block_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
