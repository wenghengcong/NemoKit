//
//  NMBFRuntimeMacro.h
//  Nemo
//
//  Created by Hunt on 2019/10/11.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBFRuntimeMacro_h
#define NMBFRuntimeMacro_h

#include "NMBFRuntimeQuick.h"

/**
 *  用 block 重写某个 class 的某个无参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param _returnType 返回值的数据类型
 *  @param _implementationBlock 格式为 ^_returnType(NSObject *selfObject, _returnType originReturnValue) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define NMBFExtendImplementationOfNonVoidMethodWithoutArguments(_targetClass, _targetSelector, _returnType, _implementationBlock) NMBFOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^_returnType (__unsafe_unretained __kindof NSObject *selfObject) {\
            \
            _returnType (*originSelectorIMP)(id, SEL);\
            originSelectorIMP = (_returnType (*)(id, SEL))originalIMPProvider();\
            _returnType result = originSelectorIMP(selfObject, originCMD);\
            \
            return _implementationBlock(selfObject, result);\
        };\
    });

/**
 *  用 block 重写某个 class 的带一个参数且返回值为 void 的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param _targetClass 要重写的 class
 *  @param _targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值为 void
 *  @param _argumentType targetSelector 的参数类型
 *  @param _implementationBlock 格式为 ^(NSObject *selfObject, _argumentType firstArgv) {}，内容即为 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写
 */
#define NMBFExtendImplementationOfVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _implementationBlock) NMBFOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^(__unsafe_unretained __kindof NSObject *selfObject, _argumentType firstArgv) {\
        \
            void (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (void (*)(id, SEL, _argumentType))originalIMPProvider();\
            originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            _implementationBlock(selfObject, firstArgv);\
        };\
    });


#define NMBFExtendImplementationOfVoidMethodWithTwoArguments(_targetClass, _targetSelector, _argumentType1, _argumentType2, _implementationBlock) NMBFOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^(__unsafe_unretained __kindof NSObject *selfObject, _argumentType1 firstArgv, _argumentType2 secondArgv) {\
            \
            void (*originSelectorIMP)(id, SEL, _argumentType1, _argumentType2);\
            originSelectorIMP = (void (*)(id, SEL, _argumentType1, _argumentType2))originalIMPProvider();\
            originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);\
            \
            _implementationBlock(selfObject, firstArgv, secondArgv);\
        };\
    });

/**
 *  用 block 重写某个 class 的带一个参数且带返回值的方法，会自动在调用 block 之前先调用该方法原本的实现。
 *  @param targetClass 要重写的 class
 *  @param targetSelector 要重写的 class 里的实例方法，注意如果该方法不存在于 targetClass 里，则什么都不做，注意该方法必须带一个参数，返回值不为空
 *  @param implementationBlock，格式为 ^_returnType (NSObject *selfObject, _argumentType firstArgv, _returnType originReturnValue){}，内容也即 targetSelector 的自定义实现，直接将你的实现写进去即可，不需要管 super 的调用。第一个参数 selfObject 代表当前正在调用这个方法的对象，也即 self 指针；第二个参数 firstArgv 代表 targetSelector 被调用时传进来的第一个参数，具体的类型请自行填写；第三个参数 originReturnValue 代表 super 的返回值，具体类型请自行填写
 */
#define NMBFExtendImplementationOfNonVoidMethodWithSingleArgument(_targetClass, _targetSelector, _argumentType, _returnType, _implementationBlock) NMBFOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^_returnType (__unsafe_unretained __kindof NSObject *selfObject, _argumentType firstArgv) {\
            \
            _returnType (*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (_returnType (*)(id, SEL, _argumentType))originalIMPProvider();\
            _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv);\
            \
            return _implementationBlock(selfObject, firstArgv, result);\
        };\
    });

#define NMBFExtendImplementationOfNonVoidMethodWithTwoArguments(_targetClass, _targetSelector, _argumentType1, _argumentType2, _returnType, _implementationBlock) NMBFOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^_returnType (__unsafe_unretained __kindof NSObject *selfObject, _argumentType1 firstArgv, _argumentType2 secondArgv) {\
            \
            _returnType (*originSelectorIMP)(id, SEL, _argumentType1, _argumentType2);\
            originSelectorIMP = (_returnType (*)(id, SEL, _argumentType1, _argumentType2))originalIMPProvider();\
            _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);\
            \
            return _implementationBlock(selfObject, firstArgv, secondArgv, result);\
        };\
    });

#pragma mark - Ivar

/**
 用于判断一个给定的 type encoding（const char *）或者 Ivar 是哪种类型的系列函数。
 
 为了节省代码量，函数由宏展开生成，一个宏会展开为两个函数定义：
 
 1. isXxxTypeEncoding(const char *)，例如判断是否为 BOOL 类型的函数名为：isBOOLTypeEncoding()
 2. isXxxIvar(Ivar)，例如判断是否为 BOOL 的 Ivar 的函数名为：isBOOLIvar()
 
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 */
#define _NMBFTypeEncodingDetectorGenerator(_TypeInFunctionName, _typeForEncode) \
    CG_INLINE BOOL is##_TypeInFunctionName##TypeEncoding(const char *typeEncoding) {\
        return strncmp(@encode(_typeForEncode), typeEncoding, strlen(@encode(_typeForEncode))) == 0;\
    }\
    CG_INLINE BOOL is##_TypeInFunctionName##Ivar(Ivar ivar) {\
        return is##_TypeInFunctionName##TypeEncoding(ivar_getTypeEncoding(ivar));\
    }

_NMBFTypeEncodingDetectorGenerator(Char, char)
_NMBFTypeEncodingDetectorGenerator(Int, int)
_NMBFTypeEncodingDetectorGenerator(Short, short)
_NMBFTypeEncodingDetectorGenerator(Long, long)
_NMBFTypeEncodingDetectorGenerator(LongLong, long long)
_NMBFTypeEncodingDetectorGenerator(NSInteger, NSInteger)
_NMBFTypeEncodingDetectorGenerator(UnsignedChar, unsigned char)
_NMBFTypeEncodingDetectorGenerator(UnsignedInt, unsigned int)
_NMBFTypeEncodingDetectorGenerator(UnsignedShort, unsigned short)
_NMBFTypeEncodingDetectorGenerator(UnsignedLong, unsigned long)
_NMBFTypeEncodingDetectorGenerator(UnsignedLongLong, unsigned long long)
_NMBFTypeEncodingDetectorGenerator(NSUInteger, NSUInteger)
_NMBFTypeEncodingDetectorGenerator(Float, float)
_NMBFTypeEncodingDetectorGenerator(Double, double)
_NMBFTypeEncodingDetectorGenerator(CGFloat, CGFloat)
_NMBFTypeEncodingDetectorGenerator(BOOL, BOOL)
_NMBFTypeEncodingDetectorGenerator(Void, void)
_NMBFTypeEncodingDetectorGenerator(Character, char *)
_NMBFTypeEncodingDetectorGenerator(Object, id)
_NMBFTypeEncodingDetectorGenerator(Class, Class)
_NMBFTypeEncodingDetectorGenerator(Selector, SEL)

//CG_INLINE char getCharIvarValue(id object, Ivar ivar) {
//    ptrdiff_t ivarOffset = ivar_getOffset(ivar);
//    unsigned char * bytes = (unsigned char *)(__bridge void *)object;
//    char value = *((char *)(bytes + ivarOffset));
//    return value;
//}

#define _NMBFGetIvarValueGenerator(_TypeInFunctionName, _typeForEncode) \
    CG_INLINE _typeForEncode get##_TypeInFunctionName##IvarValue(id object, Ivar ivar) {\
        ptrdiff_t ivarOffset = ivar_getOffset(ivar);\
        unsigned char * bytes = (unsigned char *)(__bridge void *)object;\
        _typeForEncode value = *((_typeForEncode *)(bytes + ivarOffset));\
        return value;\
}

_NMBFGetIvarValueGenerator(Char, char)
_NMBFGetIvarValueGenerator(Int, int)
_NMBFGetIvarValueGenerator(Short, short)
_NMBFGetIvarValueGenerator(Long, long)
_NMBFGetIvarValueGenerator(LongLong, long long)
_NMBFGetIvarValueGenerator(UnsignedChar, unsigned char)
_NMBFGetIvarValueGenerator(UnsignedInt, unsigned int)
_NMBFGetIvarValueGenerator(UnsignedShort, unsigned short)
_NMBFGetIvarValueGenerator(UnsignedLong, unsigned long)
_NMBFGetIvarValueGenerator(UnsignedLongLong, unsigned long long)
_NMBFGetIvarValueGenerator(Float, float)
_NMBFGetIvarValueGenerator(Double, double)
_NMBFGetIvarValueGenerator(BOOL, BOOL)
_NMBFGetIvarValueGenerator(Character, char *)
_NMBFGetIvarValueGenerator(Selector, SEL)

CG_INLINE id getObjectIvarValue(id object, Ivar ivar) {
    return object_getIvar(object, ivar);
}

#endif /* NMBFRuntimeMacro_h */
