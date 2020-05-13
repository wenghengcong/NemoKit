//
//  NSCharacterSet+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSCharacterSet+NMBF.h"

@implementation NSCharacterSet (NMBF)
+ (NSCharacterSet *)nmbf_URLUserInputQueryAllowedCharacterSet {
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&="];
    return set.copy;
}
@end
