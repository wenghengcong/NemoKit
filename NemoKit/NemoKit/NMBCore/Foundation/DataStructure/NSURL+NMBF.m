//
//  NSURL+NMBF.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NSURL+NMBF.h"

@implementation NSURL (NMBF)

- (NSDictionary<NSString *, NSString *> *)nmbf_queryItems {
    if (!self.absoluteString.length) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self.absoluteString];
    
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name) {
            [params setObject:obj.value ?: [NSNull null] forKey:obj.name];
        }
    }];
    return [params copy];
}

@end
