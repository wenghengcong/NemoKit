//
//  CAAnimation+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "CAAnimation+NMUI.h"
#import "NMBCore.h"
#import "NMBFMultipleDelegates.h"

@interface _NMUICAAnimationDelegator : NSObject<CAAnimationDelegate>

@end

@implementation CAAnimation (NMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfNonVoidMethodWithSingleArgument([CAAnimation class], @selector(copyWithZone:), NSZone *, id, ^id(CAAnimation *selfObject, NSZone *firstArgv, id originReturnValue) {
            CAAnimation *animation = (CAAnimation *)originReturnValue;
            animation.nmbf_multipleDelegatesEnabled = selfObject.nmbf_multipleDelegatesEnabled;
            animation.nmui_animationDidStartBlock = selfObject.nmui_animationDidStartBlock;
            animation.nmui_animationDidStopBlock = selfObject.nmui_animationDidStopBlock;
            return animation;
        });
    });
}

- (void)enabledDelegateBlocks {
    self.nmbf_multipleDelegatesEnabled = YES;
    BOOL shouldSetDelegator = !self.delegate;
    if (!shouldSetDelegator && [self.delegate isKindOfClass:[NMBFMultipleDelegates class]]) {
        NMBFMultipleDelegates *delegates = (NMBFMultipleDelegates *)self.delegate;
        NSPointerArray *array = delegates.delegates;
        for (NSUInteger i = 0; i < array.count; i++) {
            if ([((NSObject *)[array pointerAtIndex:i]) isKindOfClass:[_NMUICAAnimationDelegator class]]) {
                shouldSetDelegator = NO;
                break;
            }
        }
    }
    if (shouldSetDelegator) {
        self.delegate = [[_NMUICAAnimationDelegator alloc] init];// delegate is a strong property, it can retain _NMUICAAnimationDelegator
    }
}

static char kAssociatedObjectKey_animationDidStartBlock;
- (void)setNmui_animationDidStartBlock:(void (^)(__kindof CAAnimation *))nmui_animationDidStartBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock, nmui_animationDidStartBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (nmui_animationDidStartBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *))nmui_animationDidStartBlock {
    return (void (^)(__kindof CAAnimation *))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock);
}

static char kAssociatedObjectKey_animationDidStopBlock;
- (void)setNmui_animationDidStopBlock:(void (^)(__kindof CAAnimation *, BOOL))nmui_animationDidStopBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock, nmui_animationDidStopBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (nmui_animationDidStopBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *, BOOL))nmui_animationDidStopBlock {
    return (void (^)(__kindof CAAnimation *, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock);
}

@end

@implementation _NMUICAAnimationDelegator

- (void)animationDidStart:(CAAnimation *)anim {
    if (anim.nmui_animationDidStartBlock) {
        anim.nmui_animationDidStartBlock(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim.nmui_animationDidStopBlock) {
        anim.nmui_animationDidStopBlock(anim, flag);
    }
}

@end
