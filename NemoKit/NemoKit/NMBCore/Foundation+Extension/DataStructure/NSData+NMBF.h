//
//  NSData+NMBF.h
//  NemoMoney
//
//  Created by Hunt on 2020/4/12.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (NMBF)

/**
 Create data from the file in main bundle (similar to [UIImage imageNamed:]).
 
 @param name The file name (in main bundle).
 
 @return A new data create from the file.
 */
+ (nullable NSData *)dataWithNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
