//
//  UITextInputTraits+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/11/6.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITextInputTraits+NMUI.h"
#import "NMBCore.h"

@implementation NSObject (UITextInputTraits)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSArray<Class> *inputClasses = nil;
        if (!inputClasses) inputClasses = @[UITextField.class, UITextView.class, UISearchBar.class];
        [inputClasses enumerateObjectsUsingBlock:^(Class  _Nonnull inputClass, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NMBFExtendImplementationOfNonVoidMethodWithSingleArgument(inputClass, @selector(initWithFrame:), CGRect, UIView<UITextInputTraits> *, ^UIView<UITextInputTraits> *(UIView<UITextInputTraits> *selfObject, CGRect firstArgv, UIView<UITextInputTraits> *originReturnValue) {
                if (NMUICMIActivated) selfObject.keyboardAppearance = KeyboardAppearance;
                return originReturnValue;
            });
            
            // 当输入框聚焦并显示了键盘的情况下，keyboardAppearance 发生变化了，立即刷新键盘的外观
            NMBFOverrideImplementation(inputClass, @selector(setKeyboardAppearance:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView<UITextInputTraits> *selfObject, UIKeyboardAppearance keyboardAppearance) {
                    
                    // 这个标志位不需要考虑 isFristResponder，因为 reloadInputViews 内部会自行处理
                    BOOL shouldUpdateImmediately = selfObject.keyboardAppearance != keyboardAppearance;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIKeyboardAppearance);
                    originSelectorIMP = (void (*)(id, SEL, UIKeyboardAppearance))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, keyboardAppearance);
                    
                    if (shouldUpdateImmediately) {
                        [selfObject reloadInputViews];
                    }
                };
            });
        }];
    });
}

@end
