//
//  NSMethodSignature+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/11.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSMethodSignature+NMBF.h"
#import "NMBFoundationMacro.h"

@implementation NSMethodSignature (NMBF)

+ (NSMethodSignature *)nmbf_avoidExceptionSignature {
    // https://github.com/facebookarchive/AsyncDisplayKit/pull/1562
    // Unfortunately, in order to get this object to work properly, the use of a method which creates an NSMethodSignature
    // from a C string. -methodSignatureForSelector is called when a compiled definition for the selector cannot be found.
    // This is the place where we have to create our own dud NSMethodSignature. This is necessary because if this method
    // returns nil, a selector not found exception is raised. The string argument to -signatureWithObjCTypes: outlines
    // the return type and arguments to the message. To return a dud NSMethodSignature, pretty much any signature will
    // suffice. Since the -forwardInvocation call will do nothing if the delegate does not respond to the selector,
    // the dud NSMethodSignature simply gets us around the exception.
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (NSString *)nmbf_typeString {
    BeginIgnorePerformSelectorLeaksWarning
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    EndIgnorePerformSelectorLeaksWarning
    return typeString;
}

- (const char *)nmbf_typeEncoding {
    return self.nmbf_typeString.UTF8String;
}

@end
