//
//  UIControl+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIControl+NMUI.h"
#import "NMBCore.h"

@interface UIControl ()

@property(nonatomic,assign) BOOL canSetHighlighted;
@property(nonatomic,assign) NSInteger touchEndCount;

@end


@implementation UIControl (NMUI)

NMBFSynthesizeUIEdgeInsetsProperty(nmui_outsideEdge, setNmui_outsideEdge)
NMBFSynthesizeBOOLProperty(nmui_automaticallyAdjustTouchHighlightedInScrollView, setNmui_automaticallyAdjustTouchHighlightedInScrollView)
NMBFSynthesizeBOOLProperty(canSetHighlighted, setCanSetHighlighted)
NMBFSynthesizeNSIntegerProperty(touchEndCount, setTouchEndCount)
NMBFSynthesizeIdCopyProperty(nmui_setHighlightedBlock, setNmui_setHighlightedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIControl class], @selector(setHighlighted:), BOOL, ^(UIControl *selfObject, BOOL highlighted) {
            if (selfObject.nmui_setHighlightedBlock) {
                selfObject.nmui_setHighlightedBlock(highlighted);
            }
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(pointInside:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIControl *selfObject, CGPoint point, UIEvent *event) {
                
                if (event.type != UIEventTypeTouches) {
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint, UIEvent *);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint, UIEvent *))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, point, event);
                    return result;
                }
                
                UIEdgeInsets nmui_outsideEdge = selfObject.nmui_outsideEdge;
                CGRect boundsInsetOutsideEdge = CGRectMake(CGRectGetMinX(selfObject.bounds) + nmui_outsideEdge.left, CGRectGetMinY(selfObject.bounds) + nmui_outsideEdge.top, CGRectGetWidth(selfObject.bounds) - UIEdgeInsetsGetHorizontalValue(nmui_outsideEdge), CGRectGetHeight(selfObject.bounds) - UIEdgeInsetsGetVerticalValue(nmui_outsideEdge));
                return CGRectContainsPoint(boundsInsetOutsideEdge, point);
            };
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(removeTarget:action:forControlEvents:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIControl *selfObject, id target, SEL action, UIControlEvents controlEvents) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, id, SEL, UIControlEvents);
                originSelectorIMP = (void (*)(id, SEL, id, SEL, UIControlEvents))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, target, action, controlEvents);
                
                BOOL isTouchUpInsideEvent = controlEvents & UIControlEventTouchUpInside;
                BOOL shouldRemoveTouchUpInsideSelector = (action == @selector(nmui_handleTouchUpInside:)) || (target == selfObject && !action) || (!target && !action);
                if (isTouchUpInsideEvent && shouldRemoveTouchUpInsideSelector) {
                    // 避免触发 setter 又反过来 removeTarget，然后就死循环了
                    objc_setAssociatedObject(selfObject, &kAssociatedObjectKey_tapBlock, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
            };
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(touchesBegan:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                
                // call super
                void (^callSuperBlock)(void) = ^{
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
                
                selfObject.touchEndCount = 0;
                if (selfObject.nmui_automaticallyAdjustTouchHighlightedInScrollView) {
                    selfObject.canSetHighlighted = YES;
                    callSuperBlock();
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (selfObject.canSetHighlighted) {
                            [selfObject setHighlighted:YES];
                        }
                    });
                } else {
                    callSuperBlock();
                }
            };
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(touchesMoved:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                
                if (selfObject.nmui_automaticallyAdjustTouchHighlightedInScrollView) {
                    selfObject.canSetHighlighted = NO;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, touches, event);
            };
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(touchesEnded:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                
                if (selfObject.nmui_automaticallyAdjustTouchHighlightedInScrollView) {
                    selfObject.canSetHighlighted = NO;
                    if (selfObject.touchInside) {
                        [selfObject setHighlighted:YES];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                            // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                            // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [selfObject nmui_touchesEnded:touches withEvent:event];
                            [selfObject sendActionsForAllTouchEventsIfCan];
                            if (selfObject.highlighted) {
                                [selfObject setHighlighted:NO];
                            }
                        });
                    } else {
                        [selfObject setHighlighted:NO];
                    }
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, touches, event);
            };
        });
        
        NMBFOverrideImplementation([UIControl class], @selector(touchesCancelled:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                
                // call super
                void (^callSuperBlock)(void) = ^{
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
                
                if (selfObject.nmui_automaticallyAdjustTouchHighlightedInScrollView) {
                    selfObject.canSetHighlighted = NO;
                    callSuperBlock();
                    if (selfObject.highlighted) {
                        [selfObject setHighlighted:NO];
                    }
                    return;
                }
                callSuperBlock();
            };
        });
    });
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.touchEndCount += 1;
    if (self.touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

#pragma mark - Tap Block

static char kAssociatedObjectKey_tapBlock;
- (void)setNmui_tapBlock:(void (^)(__kindof UIControl *))nmui_tapBlock {
    SEL action = @selector(nmui_handleTouchUpInside:);
    if (!nmui_tapBlock) {
        [self removeTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tapBlock, nmui_tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIControl *))nmui_tapBlock {
    return (void (^)(__kindof UIControl *))objc_getAssociatedObject(self, &kAssociatedObjectKey_tapBlock);
}

- (void)nmui_handleTouchUpInside:(__kindof UIControl *)sender {
    if (self.nmui_tapBlock) {
        self.nmui_tapBlock(self);
    }
}

@end
