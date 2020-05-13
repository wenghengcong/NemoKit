//
//  NMModel.h
//  NemoMoney
//
//  Created by Hunt on 2020/4/12.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#ifndef NMModel_h
#define NMModel_h

#import <Foundation/Foundation.h>

#if __has_include(<NMModel/NMModel.h>)
FOUNDATION_EXPORT double NMModelVersionNumber;
FOUNDATION_EXPORT const unsigned char NMModelVersionString[];
#import <NMModel/NSObject+NMModel.h>
#import <NMModel/NMClassInfo.h>
#else
#import "NSObject+NMModel.h"
#import "NMClassInfo.h"
#endif

#endif /* NMModel_h */
