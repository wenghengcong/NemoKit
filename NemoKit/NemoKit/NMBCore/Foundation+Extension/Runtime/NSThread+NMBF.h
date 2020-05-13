//
//  NSThread+NMBF.h
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (NMBF)

/// 是否将当前线程标记为忽略系统的 KVC access prohibited 警告，默认为 NO，当开启后，NSException 将不会再抛出 access prohibited 异常
/// @see BeginIgnoreUIKVCAccessProhibited、EndIgnoreUIKVCAccessProhibited
@property(nonatomic, assign) BOOL nmbf_shouldIgnoreUIKVCAccessProhibited;

@end

NS_ASSUME_NONNULL_END
