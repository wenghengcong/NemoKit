//
//  NSObject+NMBFMutipleDelegate.m
//  Nemo
//
//  Created by Hunt on 2019/10/30.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSObject+NMBFMultipleDelegates.h"
#import "NMBFMultipleDelegates.h"
#import "NMBCore.h"
#import "NSPointerArray+NMBF.h"
#import "NSString+NMBF.h"
#import <objc/runtime.h>


@interface NSObject ()
@property(nonatomic, strong) NSMutableDictionary<NSString *, NMBFMultipleDelegates *> *nmbfmd_delegates;
@end

@implementation NSObject (NMBFMutipleDelegate)


NMBFSynthesizeIdStrongProperty(nmbfmd_delegates, setNmbfmd_delegates)

static NSMutableSet<NSString *> *nmbf_methodsReplacedClasses;

static char kAssociatedObjectKey_nmbfMultipleDelegatesEnabled;
- (void)setNmbf_multipleDelegatesEnabled:(BOOL)nmbf_multipleDelegatesEnabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_nmbfMultipleDelegatesEnabled, @(nmbf_multipleDelegatesEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (nmbf_multipleDelegatesEnabled) {
        if (!self.nmbfmd_delegates) {
            self.nmbfmd_delegates = [NSMutableDictionary dictionary];
        }
        [self nmbf_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self nmbf_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (BOOL)nmbf_multipleDelegatesEnabled {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_nmbfMultipleDelegatesEnabled)) boolValue];
}

- (void)nmbf_registerDelegateSelector:(SEL)getter {
    if (!self.nmbf_multipleDelegatesEnabled) {
        return;
    }
    
    Class targetClass = [self class];
    SEL originDelegateSetter = setterWithGetter(getter);
    SEL newDelegateSetter = [self newSetterWithGetter:getter];
    Method originMethod = class_getInstanceMethod(targetClass, originDelegateSetter);
    if (!originMethod) {
        return;
    }
    
    // 为这个 selector 创建一个 NMBFMultipleDelegates 容器
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    if (!self.nmbfmd_delegates[delegateGetterKey]) {
        objc_property_t prop = class_getProperty(self.class, delegateGetterKey.UTF8String);
        NMBFPropertyDescriptor *property = [NMBFPropertyDescriptor descriptorWithProperty:prop];
        if (property.isStrong) {
            // strong property
            NMBFMultipleDelegates *strongDelegates = [NMBFMultipleDelegates strongDelegates];
            strongDelegates.parentObject = self;
            self.nmbfmd_delegates[delegateGetterKey] = strongDelegates;
        } else {
            // weak property
            NMBFMultipleDelegates *weakDelegates = [NMBFMultipleDelegates weakDelegates];
            weakDelegates.parentObject = self;
            self.nmbfmd_delegates[delegateGetterKey] = weakDelegates;
        }
    }
    
    // 避免为某个 class 重复替换同一个方法的实现
    if (!nmbf_methodsReplacedClasses) {
        nmbf_methodsReplacedClasses = [NSMutableSet set];
    }
    NSString *classAndMethodIdentifier = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(targetClass), delegateGetterKey];
    if (![nmbf_methodsReplacedClasses containsObject:classAndMethodIdentifier]) {
        [nmbf_methodsReplacedClasses addObject:classAndMethodIdentifier];
        
        IMP originIMP = method_getImplementation(originMethod);
        void (*originSelectorIMP)(id, SEL, id);
        originSelectorIMP = (void (*)(id, SEL, id))originIMP;
        
        BOOL isAddedMethod = class_addMethod(targetClass, newDelegateSetter, imp_implementationWithBlock(^(NSObject *selfObject, id aDelegate){
            
            // 这一段保护的原因请查看 https://github.com/Tencent/NMBF_iOS/issues/292
            if (!selfObject.nmbf_multipleDelegatesEnabled || selfObject.class != targetClass) {
                originSelectorIMP(selfObject, originDelegateSetter, aDelegate);
                return;
            }
            
            NMBFMultipleDelegates *delegates = selfObject.nmbfmd_delegates[delegateGetterKey];
            
            if (!aDelegate) {
                // 对应 setDelegate:nil，表示清理所有的 delegate
                [delegates removeAllDelegates];
                selfObject.nmbf_delegatesSelf = NO;
                // 只要 nmbf_multipleDelegatesEnabled 开启，就会保证 delegate 一直是 delegates，所以不去调用系统默认的 set nil
                //            originSelectorIMP(selfObject, originDelegateSetter, nil);
                return;
            }
            
            if (aDelegate != delegates) {// 过滤掉容器自身，避免把 delegates 传进去 delegates 里，导致死循环
                [delegates addDelegate:aDelegate];
            }
            
            // 将类似 textView.delegate = textView 的情况标志起来，避免产生循环调用 https://github.com/Tencent/NMBF_iOS/issues/346
            selfObject.nmbf_delegatesSelf = [delegates.delegates nmbf_containsPointer:(__bridge void * _Nullable)(selfObject)];
            
            originSelectorIMP(selfObject, originDelegateSetter, nil);// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/NMBF_iOS/issues/305
            originSelectorIMP(selfObject, originDelegateSetter, delegates);// 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 NMBFMultipleDelegates 容器
            
        }), method_getTypeEncoding(originMethod));
        if (isAddedMethod) {
            Method newMethod = class_getInstanceMethod(targetClass, newDelegateSetter);
            method_exchangeImplementations(originMethod, newMethod);
        }
    }
    
    // 如果原来已经有 delegate，则将其加到新建的容器里
    // @see https://github.com/Tencent/NMBF_iOS/issues/378
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    if (originDelegate && originDelegate != self.nmbfmd_delegates[delegateGetterKey]) {
        [self performSelector:originDelegateSetter withObject:originDelegate];
    }
    EndIgnorePerformSelectorLeaksWarning
}

- (void)nmbf_removeDelegate:(id)delegate {
    if (!self.nmbf_multipleDelegatesEnabled) {
        return;
    }
    NSMutableArray<NSString *> *delegateGetters = [[NSMutableArray alloc] init];
    [self.nmbfmd_delegates enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NMBFMultipleDelegates * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL removeSucceed = [obj removeDelegate:delegate];
        if (removeSucceed) {
            [delegateGetters addObject:key];
        }
    }];
    if (delegateGetters.count > 0) {
        for (NSString *getterString in delegateGetters) {
            [self refreshDelegateWithGetter:NSSelectorFromString(getterString)];
        }
    }
}

- (void)refreshDelegateWithGetter:(SEL)getter {
    SEL originSetterSEL = [self newSetterWithGetter:getter];
    BeginIgnorePerformSelectorLeaksWarning
    id originDelegate = [self performSelector:getter];
    [self performSelector:originSetterSEL withObject:nil];// 先置为 nil 再设置 delegates，从而避免这个问题 https://github.com/Tencent/NMBF_iOS/issues/305
    [self performSelector:originSetterSEL withObject:originDelegate];
    EndIgnorePerformSelectorLeaksWarning
}

// 根据 delegate property 的 getter，得到 NMBFMultipleDelegates 为它的 setter 创建的新 setter 方法，最终交换原方法，因此利用这个方法返回的 SEL，可以调用到原来的 delegate property setter 的实现
- (SEL)newSetterWithGetter:(SEL)getter {
    return NSSelectorFromString([NSString stringWithFormat:@"nmbfmd_%@", NSStringFromSelector(setterWithGetter(getter))]);
}

@end

@implementation NSObject (NMBFMultipleDelegates_Private)

NMBFSynthesizeBOOLProperty(nmbf_delegatesSelf, setNmbf_delegatesSelf)

@end
