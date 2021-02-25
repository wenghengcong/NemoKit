//
//  NMCoreBaseMacro.h
//  Pods
//
//  Created by Hunt on 2020/7/2.
//

#import <UIKit/UIKit.h>

#ifndef NMCoreBaseMacro_h
#define NMCoreBaseMacro_h

/*
 extern "C"的主要作用: C++代码能调用其他C语言代码。
 加上extern"C"后，会指示编译器这部分代码按C语言的进行编译，而不是C++的。
 由于C++支持函数重载，因此编译器编译函数的过程中会将函数的参数类型也加到编译后的代码中，而不仅仅是函数名；
 而C语言并不支持函数重载，因此编译C语言代码的函数时不会带上函数的参数类型，一般之包括函数名。
 例如：void foo( int x, int y );
 C++ 编译产生 _foo_int_int
 C 编译产生 _foo
 */
#ifdef __cplusplus
#define NM_EXTERN_C_BEGIN extern "C" {
#define NM_EXTERN_C_END }
#else
#define NM_EXTERN_C_BEGIN
#define NM_EXTERN_C_END
#endif

NM_EXTERN_C_BEGIN

/// 判断当前是否debug编译模式
#ifdef DEBUG
#define IS_DEBUG YES
#else
#define IS_DEBUG NO
#endif




NM_EXTERN_C_END
#endif /* NMCoreBaseMacro_h */
