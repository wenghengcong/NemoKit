//
//  NMCalendarDelegationProxy.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarDelegationProxy.h"
#import <objc/runtime.h>

@implementation NMCalendarDelegationProxy

- (instancetype)init
{
    return self;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    BOOL responds = [self.delegation respondsToSelector:selector];
    if (!responds) responds = [super respondsToSelector:selector];
    return responds;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    return [self.delegation conformsToProtocol:protocol];
}


/// 进行转发
/// @param invocation <#invocation description#>
- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = invocation.selector;
    if ([self.delegation respondsToSelector:selector]) {
        [invocation invokeWithTarget:self.delegation];
    }
}


/// 获取方法签名
/// @param sel <#sel description#>
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if ([self.delegation respondsToSelector:sel]) {
        return [(NSObject *)self.delegation methodSignatureForSelector:sel];
    }
    
#if TARGET_INTERFACE_BUILDER
    // TARGET_INTERFACE_BUILDER只在IB使用时编译代码
    return [NSObject methodSignatureForSelector:@selector(init)];
#else
    struct objc_method_description desc = protocol_getMethodDescription(self.protocol, sel, NO, YES);
    const char *types = desc.types;
    return types?[NSMethodSignature signatureWithObjCTypes:types]:[NSObject methodSignatureForSelector:@selector(init)];
#endif
}

@end
