//
//  NSData+NMBF.m
//  NemoMoney
//
//  Created by Hunt on 2020/4/12.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import "NSData+NMBF.h"

@implementation NSData (NMBF)

+ (NSData *)dataWithNamed: (NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    if (!path) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

@end
