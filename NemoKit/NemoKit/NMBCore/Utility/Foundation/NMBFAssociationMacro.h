//
//  NMBFAssociationMacro.h
//  Nemo
//
//  Created by Hunt on 2019/10/15.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBFAssociationMacro_h
#define NMBFAssociationMacro_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "NMBFWeakObjectContainer.h"
#import "NSNumber+NMBF.h"

/**
 以下系列宏用于在 Category 里添加 property 时，可以在 @implementation 里一句代码完成 getter/setter 的声明。暂不支持在 getter/setter 里添加自定义的逻辑，需要自定义的情况请继续使用 Code Snippet 生成的代码。
 使用方式：
 @code
 @interface NSObject (CategoryName)
 @property(nonatomic, strong) type *strongObj;
 @property(nonatomic, weak) type *weakObj;
 @property(nonatomic, assign) CGRect rectValue;
 @end
 
 @implementation NSObject (CategoryName)
 
 // 注意 setter 不需要带冒号
 NMBFSynthesizeIdStrongProperty(strongObj, setStrongObj)
 NMBFSynthesizeIdWeakProperty(weakObj, setWeakObj)
 NMBFSynthesizeCGRectProperty(rectValue, setRectValue)
 @end
 
 @endcode
 */

#pragma mark - Meta Marcos

/// 生成关联对象的存取方法：强引用
#define _NMBFSynthesizeId(_getterName, _setterName, _policy) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (id)_getterName {\
return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\
_Pragma("clang diagnostic pop")

/// 生成关联对象的存取方法：弱引用
#define _NMBFSynthesizeWeakId(_getterName, _setterName) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [[NMBFWeakObjectContainer alloc] initWithObject:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (id)_getterName {\
return ((NMBFWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)).object;\
}\
_Pragma("clang diagnostic pop")

/// 生成关联对象的存取方法：非对象，比如Int等基本类型，需要用对应的初始化方法包装成对象
#define _NMBFSynthesizeNonObject(_getterName, _setterName, _type, valueInitializer, valueGetter) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [NSNumber valueInitializer:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)) valueGetter];\
}\
_Pragma("clang diagnostic pop")



#pragma mark - Object Marcos

/// @property(nonatomic, strong) id xxx
#define NMBFSynthesizeIdStrongProperty(_getterName, _setterName) _NMBFSynthesizeId(_getterName, _setterName, RETAIN)

/// @property(nonatomic, weak) id xxx
#define NMBFSynthesizeIdWeakProperty(_getterName, _setterName) _NMBFSynthesizeWeakId(_getterName, _setterName)

/// @property(nonatomic, copy) id xxx
#define NMBFSynthesizeIdCopyProperty(_getterName, _setterName) _NMBFSynthesizeId(_getterName, _setterName, COPY)



#pragma mark - NonObject Marcos

/// @property(nonatomic, assign) Int xxx
#define NMBFSynthesizeIntProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, int, numberWithInt, intValue)

/// @property(nonatomic, assign) unsigned int xxx
#define NMBFSynthesizeUnsignedIntProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, unsigned int, numberWithUnsignedInt, unsignedIntValue)

/// @property(nonatomic, assign) float xxx
#define NMBFSynthesizeFloatProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, float, numberWithFloat, floatValue)

/// @property(nonatomic, assign) double xxx
#define NMBFSynthesizeDoubleProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, double, numberWithDouble, doubleValue)

/// @property(nonatomic, assign) BOOL xxx
#define NMBFSynthesizeBOOLProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, BOOL, numberWithBool, boolValue)

/// @property(nonatomic, assign) NSInteger xxx
#define NMBFSynthesizeNSIntegerProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, NSInteger, numberWithInteger, integerValue)

/// @property(nonatomic, assign) NSUInteger xxx
#define NMBFSynthesizeNSUIntegerProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, NSUInteger, numberWithUnsignedInteger, unsignedIntegerValue)

/// @property(nonatomic, assign) CGFloat xxx
#define NMBFSynthesizeCGFloatProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGFloat, numberWithDouble, nmbf_CGFloatValue)

/// @property(nonatomic, assign) CGPoint xxx
#define NMBFSynthesizeCGPointProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGPoint, valueWithCGPoint, CGPointValue)

/// @property(nonatomic, assign) CGSize xxx
#define NMBFSynthesizeCGSizeProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGSize, valueWithCGSize, CGSizeValue)

/// @property(nonatomic, assign) CGRect xxx
#define NMBFSynthesizeCGRectProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGRect, valueWithCGRect, CGRectValue)

/// @property(nonatomic, assign) UIEdgeInsets xxx
#define NMBFSynthesizeUIEdgeInsetsProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, UIEdgeInsets, valueWithUIEdgeInsets, UIEdgeInsetsValue)

/// @property(nonatomic, assign) CGVector xxx
#define NMBFSynthesizeCGVectorProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGVector, valueWithCGVector, CGVectorValue)

/// @property(nonatomic, assign) CGAffineTransform xxx
#define NMBFSynthesizeCGAffineTransformProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, CGAffineTransform, valueWithCGAffineTransform, CGAffineTransformValue)

/// @property(nonatomic, assign) NSDirectionalEdgeInsets xxx
#define NMBFSynthesizeNSDirectionalEdgeInsetsProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, NSDirectionalEdgeInsets, valueWithDirectionalEdgeInsets, NSDirectionalEdgeInsetsValue)

/// @property(nonatomic, assign) UIOffset xxx
#define NMBFSynthesizeUIOffsetProperty(_getterName, _setterName) _NMBFSynthesizeNonObject(_getterName, _setterName, UIOffset, valueWithUIOffset, UIOffsetValue)


#endif /* NMBFAssociationMacro_h */
