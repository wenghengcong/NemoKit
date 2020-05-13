//
//  NSCharacterSet+NMBF.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (NMBF)

/**
 也即在系统的 URLQueryAllowedCharacterSet 基础上去掉“#&=”这3个字符，专用于 URL query 里来源于用户输入的 value，避免服务器解析出现异常。
 */
@property (class, readonly, copy) NSCharacterSet *nmbf_URLUserInputQueryAllowedCharacterSet;

@end

NS_ASSUME_NONNULL_END
