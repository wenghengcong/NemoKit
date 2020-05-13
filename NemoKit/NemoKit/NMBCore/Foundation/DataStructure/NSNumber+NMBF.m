//
//  NSNumber+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSNumber+NMBF.h"

@implementation NSNumber (NMBF)

- (CGFloat)nmbf_CGFloatValue {
#if CGFLOAT_IS_DOUBLE
    return self.doubleValue;
#else
    return self.floatValue;
#endif
}

@end
