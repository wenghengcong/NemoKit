#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NMFoundationHeader.h"
#import "NSArray+Nemo.h"
#import "NSData+Nemo.h"
#import "NMCoreBaseMacro.h"
#import "NMCoreConstructorMacro.h"
#import "NMCoreFoundationMacro.h"
#import "NMCoreMathMacro.h"
#import "NMCoreTimeMacro.h"
#import "NMCoreUIKitMacro.h"
#import "NMCoreMacro.h"
#import "NMUtils.h"
#import "UIColor+Nemo.h"
#import "NMCore.h"

FOUNDATION_EXPORT double NMCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char NMCoreVersionString[];

