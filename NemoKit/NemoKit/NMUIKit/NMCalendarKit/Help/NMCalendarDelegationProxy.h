//
//  NMCalendarDelegationProxy.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMCalendar.h"

NS_ASSUME_NONNULL_BEGIN


/// 协议代理类，将遵循对应 protocol 协议的类的处理方法都转发给 delegation
@interface NMCalendarDelegationProxy : NSProxy

@property (weak  , nonatomic) id delegation;
@property (strong, nonatomic) Protocol *protocol;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
