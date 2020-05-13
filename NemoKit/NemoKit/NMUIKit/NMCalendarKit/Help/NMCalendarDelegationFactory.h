//
//  NMCalendarDelegationFactory.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMCalendarDelegationProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface NMCalendarDelegationFactory : NSObject

+ (NMCalendarDelegationProxy *)dataSourceProxy;
+ (NMCalendarDelegationProxy *)delegateProxy;

@end

NS_ASSUME_NONNULL_END
