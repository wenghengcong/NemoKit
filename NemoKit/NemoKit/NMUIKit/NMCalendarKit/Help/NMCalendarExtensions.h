//
//  NMCalendarExtensions.h
//  Nemo
//
//  Created by Hunt on 2019/8/26.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+NMUI.h"
#import "CALayer+NMUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSCalendar (NMCalendarExtensions)

- (nullable NSDate *)nm_firstDayOfMonth:(NSDate *)month;
- (nullable NSDate *)nm_lastDayOfMonth:(NSDate *)month;
- (nullable NSDate *)nm_firstDayOfWeek:(NSDate *)week;
- (nullable NSDate *)nm_lastDayOfWeek:(NSDate *)week;
- (nullable NSDate *)nm_middleDayOfWeek:(NSDate *)week;
- (NSInteger)nm_numberOfDaysInMonth:(NSDate *)month;

@end

@interface NSMapTable (NMCalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end

@interface NSCache (NMCalendarExtensions)

- (void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

@end


@interface NSObject (NMCalendarExtensions)

#define IVAR_DEF(SET,GET,TYPE) \
- (void)nm_set##SET##Variable:(TYPE)value forKey:(NSString *)key; \
- (TYPE)nm_##GET##VariableForKey:(NSString *)key;
IVAR_DEF(Bool, bool, BOOL)
IVAR_DEF(Float, float, CGFloat)
IVAR_DEF(Integer, integer, NSInteger)
IVAR_DEF(UnsignedInteger, unsignedInteger, NSUInteger)
#undef IVAR_DEF

- (void)nm_setVariable:(id)variable forKey:(NSString *)key;
- (id)nm_variableForKey:(NSString *)key;

- (nullable id)nm_performSelector:(SEL)selector withObjects:(nullable id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END

