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

#import "NSMethodSignature+NMCore.h"
#import "NSNumber+NMCore.h"
#import "NSString+NMCore.h"
#import "NMBFAssociationMacro.h"
#import "NMBFMathMacro.h"
#import "NMBFoundationMacro.h"
#import "NMBFRuntimeMacro.h"
#import "NMCoreUIMacro.h"
#import "NMBFRuntimeQuick.h"
#import "NMBFWeakObjectContainer.h"
#import "NMUIOrderedDictionary.h"
#import "NMUtils.h"
#import "NMCore.h"

FOUNDATION_EXPORT double NMCoreVersionNumber;
FOUNDATION_EXPORT const unsigned char NMCoreVersionString[];

