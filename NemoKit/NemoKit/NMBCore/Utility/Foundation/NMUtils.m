//
//  NMUtils.m
//  NemoMoney
//
//  Created by Hunt on 2019/12/25.
//  Copyright © 2019 ChuAng. All rights reserved.
//

#import "NMUtils.h"
#import "NSString+NMBF.h"

NMUtils_t NMUtils;


#pragma mark - 类型值合法性判断，注意会额外判断值的合法性

static BOOL NMBF_validateString(NSString *string) {
    BOOL result = NO;
    if (string && [string isKindOfClass:[NSString class]] && [string length]) {
        result = YES;
    }
    return result;
}

static BOOL NMBF_validateArray(NSArray *array) {
    BOOL result = NO;
    if (array && [array isKindOfClass:[NSArray class]] && [array count]) {
        result = YES;
    }
    return result;
}

static BOOL NMBF_validateNumber(NSNumber *number) {
    BOOL result = NO;
    if (number && [number isKindOfClass:[NSNumber class]]) {
        result = YES;
    }
    return result;
}

static BOOL NMBF_validateDictionary(NSDictionary *dictionary) {
    BOOL result = NO;
    if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
        result = YES;
    }
    return result;
}

// NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
static BOOL NMBF_validatePropetyList(id value)
{
    BOOL result = YES;
    if( [value isKindOfClass:[NSData class]] || [value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSDate class]] ){
        result = YES;
    }else if ( [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]){
        if( [value isKindOfClass:[NSDictionary class]] ){
            value = [(NSDictionary*)value allValues];
        }
        
        for (id element in value) {
            if( !NMBF_validatePropetyList(element) ){
                result = NO;
                break;
            }
        }
    }else{
        result = NO;
    }
    return result;
}


#pragma mark - 文件相关操作

static NSString *NMBF_getFilePath(NSString* filename) {
    if( !NMBF_validateString(filename) ){
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *pathToUserCopyOfPlist = [documentsDirectory stringByAppendingPathComponent:filename];
    return pathToUserCopyOfPlist;
}

static NSString *NMBF_getFilePathWithExt(NSString* filename, NSString* ext) {
    if( !NMBF_validateString(filename) ){
        return nil;
    }
    if( !NMBF_validateString(ext) ){
        return NMBF_getFilePath(filename);
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *pathToUserCopyOfPlist = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", filename, ext]];
    return pathToUserCopyOfPlist;
}

static NSString *NMBF_getBundleFilePath(NSString* filename, NSString* ext) {
    return [[NSBundle mainBundle] pathForResource:filename ofType:ext];
}

BOOL NMBF_creatDirInDocument(NSString *dirName)
{
    if( !NMBF_validateString(dirName) ){
        return @"";
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createDir = [pathDocuments stringByAppendingPathComponent:dirName];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![fileManager fileExistsAtPath:createDir]) {
        NSError* error = nil;
        BOOL suc = [fileManager createDirectoryAtPath:createDir withIntermediateDirectories:YES attributes:nil error:&error];
        if( suc && (error == nil) ){
            return YES;
        }else{
            return NO;
        }
    } else {
        return NO;
    }
}


__attribute__((constructor)) static void KSCrashInjection(void) {
    NMUtils.validateString = NMBF_validateString;
    NMUtils.validateArray = NMBF_validateArray;
    NMUtils.validateNumber = NMBF_validateNumber;
    NMUtils.validateDictionary = NMBF_validateDictionary;
    
    
    NMUtils.getFilePath = NMBF_getFilePath;
    NMUtils.getBundleFilePath = NMBF_getBundleFilePath;
    
//    NMUtils.validatePropetyList = NMBF_validatePropetyList;
//    NMUtils.getFilePathWithExt = NMBF_getFilePathWithExt;
//    NMUtils.creatDirInDocument = NMBF_creatDirInDocument;
}
