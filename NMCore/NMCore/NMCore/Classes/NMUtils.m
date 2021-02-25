//
//  NMUtils.m
//  FBSnapshotTestCase
//
//  Created by Hunt on 2020/7/2.
//

#import "NMUtils.h"

NMUtils_t NMUtils;

#pragma mark - 类型值合法性判断，注意会额外判断值的合法性

static BOOL NMC_validateString(NSString *string) {
    BOOL result = NO;
    if (string && [string isKindOfClass:[NSString class]] && [string length]) {
        result = YES;
    }
    return result;
}

static BOOL NMC_validateArray(NSArray *array) {
    BOOL result = NO;
    if (array && [array isKindOfClass:[NSArray class]] && [array count]) {
        result = YES;
    }
    return result;
}

static BOOL NMC_validateNumber(NSNumber *number) {
    BOOL result = NO;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        result = YES;
    }
    return result;
}

static BOOL NMC_validateDictionary(NSDictionary *dictionary) {
    BOOL result = NO;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
        result = YES;
    }
    return result;
}

// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
static BOOL NMC_validatePropetyList(id value) {
    BOOL result = YES;
    if( [value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]] ){
        result = YES;
    }else if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]){
        if( [value isKindOfClass:[NSDictionary class]] ){
            value = [(NSDictionary*)value allValues];
        }
        
        for (id element in value) {
            if( !NMC_validatePropetyList(element) ){
                result = NO;
                break;
            }
        }
    }else{
        result = NO;
    }
    return result;
}

/*
 __attribute__ ((constructor))会使函数在main()函数之前被执行
 __attribute__ ((destructor))会使函数在main()退出后执行
 */
/// 在 main 函数之前执行
/// 会增加启动时长
__attribute__((constructor)) static void NMUtilsInjection(void) {
    NMUtils.validateString = NMC_validateString;
    NMUtils.validateArray = NMC_validateArray;
    NMUtils.validateNumber = NMC_validateNumber;
    NMUtils.validateDictionary = NMC_validateDictionary;
}

