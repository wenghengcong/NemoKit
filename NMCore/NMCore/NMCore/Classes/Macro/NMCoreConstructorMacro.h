//
//  NMCoreConstructorMacro.h
//  Pods
//
//  Created by Hunt on 2020/7/3.
//
#import "NMCoreMacro.h"

#ifndef NMCoreConstructorMacro_h
#define NMCoreConstructorMacro_h

NM_EXTERN_C_BEGIN

#define CGSizeMax CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)

#define UIImageMake(img) [UIImage imageNamed:img]

/// 使用文件名(不带后缀名，仅限png)创建一个UIImage对象，不会被系统缓存，用于不被复用的图片，特别是大图
#define UIImageMakeWithFile(name) UIImageMakeWithFileAndSuffix(name, @"png")
#define UIImageMakeWithFileAndSuffix(name, suffix) [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.%@", [[NSBundle mainBundle] resourcePath], name, suffix]]

/// 字体相关的宏，用于快速创建一个字体对象，更多创建宏可查看 UIFont+NMUI.h
#define UIFontMake(size)            [UIFont systemFontOfSize:size]
#define UIFontItalicMake(size)      [UIFont italicSystemFontOfSize:size] /// 斜体只对数字和字母有效，中文无效
#define UIFontBoldMake(size)        [UIFont boldSystemFontOfSize:size]
#define UIFontBoldWithFont(_font)   [UIFont boldSystemFontOfSize:_font.pointSize]

/// UIColor 相关的宏，用于快速创建一个 UIColor 对象，更多创建的宏可查看 UIColor+NMUI.h
#define UIColorMake(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define UIColorMakeWithRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]

NM_EXTERN_C_END
#endif /* NMCoreConstructorMacro_h */
