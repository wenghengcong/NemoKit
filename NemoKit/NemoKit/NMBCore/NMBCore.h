//
//  NMBCore.h
//  Nemo
//
//  Created by Hunt on 2019/10/8.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMBCore_h
#define NMBCore_h
#import <Foundation/Foundation.h>

static NSString * const NMBCORE_VERSION = @"1.0.0";

#if __has_include("NMBCoreUtilsHeader.h")
#import "NMBCoreUtilsHeader.h"
#endif

#if __has_include("NMBCoreUIKitHeader.h")
#import "NMBCoreUIKitHeader.h"
#endif

#if __has_include("NMBCoreFoundationHeaders.h")
#import "NMBCoreFoundationHeaders.h"
#endif


#endif /* NMBCore_h */
