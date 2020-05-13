//
//  NMCalendarDelegationFactory.m
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMCalendarDelegationFactory.h"

@implementation NMCalendarDelegationFactory

+ (NMCalendarDelegationProxy *)dataSourceProxy
{
    NMCalendarDelegationProxy *delegation = [[NMCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(NMCalendarDataSource);
    return delegation;
}

+ (NMCalendarDelegationProxy *)delegateProxy
{
    NMCalendarDelegationProxy *delegation = [[NMCalendarDelegationProxy alloc] init];
    delegation.protocol = @protocol(NMCalendarDelegateAppearance);
    return delegation;
}

@end

#undef NMCalendarSelectorEntry
