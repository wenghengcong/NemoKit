//
//  NMClassInfo.h
//  NemoMoney
//
//  Created by Hunt on 2020/4/12.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, NMEncodingType) {
    NMEncodingTypeMask       = 0xFF, ///< mask of type value
    NMEncodingTypeUnknown    = 0, ///< unknown
    NMEncodingTypeVoid       = 1, ///< void
    NMEncodingTypeBool       = 2, ///< bool
    NMEncodingTypeInt8       = 3, ///< char / BOOL
    NMEncodingTypeUInt8      = 4, ///< unsigned char
    NMEncodingTypeInt16      = 5, ///< short
    NMEncodingTypeUInt16     = 6, ///< unsigned short
    NMEncodingTypeInt32      = 7, ///< int
    NMEncodingTypeUInt32     = 8, ///< unsigned int
    NMEncodingTypeInt64      = 9, ///< long long
    NMEncodingTypeUInt64     = 10, ///< unsigned long long
    NMEncodingTypeFloat      = 11, ///< float
    NMEncodingTypeDouble     = 12, ///< double
    NMEncodingTypeLongDouble = 13, ///< long double
    NMEncodingTypeObject     = 14, ///< id
    NMEncodingTypeClass      = 15, ///< Class
    NMEncodingTypeSEL        = 16, ///< SEL
    NMEncodingTypeBlock      = 17, ///< block
    NMEncodingTypePointer    = 18, ///< void*
    NMEncodingTypeStruct     = 19, ///< struct
    NMEncodingTypeUnion      = 20, ///< union
    NMEncodingTypeCString    = 21, ///< char*
    NMEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    NMEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    NMEncodingTypeQualifierConst  = 1 << 8,  ///< const
    NMEncodingTypeQualifierIn     = 1 << 9,  ///< in
    NMEncodingTypeQualifierInout  = 1 << 10, ///< inout
    NMEncodingTypeQualifierOut    = 1 << 11, ///< out
    NMEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    NMEncodingTypeQualifierByref  = 1 << 13, ///< byref
    NMEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    NMEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    NMEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    NMEncodingTypePropertyCopy         = 1 << 17, ///< copy
    NMEncodingTypePropertyRetain       = 1 << 18, ///< retain
    NMEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    NMEncodingTypePropertyWeak         = 1 << 20, ///< weak
    NMEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    NMEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    NMEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
NMEncodingType NMEncodingGetType(const char *typeEncoding);


/**
 Instance variable information.
 */
@interface NMClassIvarInfo : NSObject
@property (nonatomic, assign, readonly) Ivar ivar;              ///< ivar opaque struct
@property (nonatomic, strong, readonly) NSString *name;         ///< Ivar's name
@property (nonatomic, assign, readonly) ptrdiff_t offset;       ///< Ivar's offset
@property (nonatomic, strong, readonly) NSString *typeEncoding; ///< Ivar's type encoding
@property (nonatomic, assign, readonly) NMEncodingType type;    ///< Ivar's type

/**
 Creates and returns an ivar info object.
 
 @param ivar ivar opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithIvar:(Ivar)ivar;
@end


/**
 Method information.
 */
@interface NMClassMethodInfo : NSObject
@property (nonatomic, assign, readonly) Method method;                  ///< method opaque struct
@property (nonatomic, strong, readonly) NSString *name;                 ///< method name
@property (nonatomic, assign, readonly) SEL sel;                        ///< method's selector
@property (nonatomic, assign, readonly) IMP imp;                        ///< method's implementation
@property (nonatomic, strong, readonly) NSString *typeEncoding;         ///< method's parameter and return types
@property (nonatomic, strong, readonly) NSString *returnTypeEncoding;   ///< return value's type
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings; ///< array of arguments' type

/**
 Creates and returns a method info object.
 
 @param method method opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithMethod:(Method)method;
@end


/**
 Property information.
 */
@interface NMClassPropertyInfo : NSObject
@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) NMEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;
@end


/**
 Class information for a class.
 */
@interface NMClassInfo : NSObject
@property (nonatomic, assign, readonly) Class cls; ///< class object
@property (nullable, nonatomic, assign, readonly) Class superCls; ///< super class object
@property (nullable, nonatomic, assign, readonly) Class metaCls;  ///< class's meta class object
@property (nonatomic, readonly) BOOL isMeta; ///< whether this class is meta class
@property (nonatomic, strong, readonly) NSString *name; ///< class name
@property (nullable, nonatomic, strong, readonly) NMClassInfo *superClassInfo; ///< super class's class info
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, NMClassIvarInfo *> *ivarInfos; ///< ivars
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, NMClassMethodInfo *> *methodInfos; ///< methods
@property (nullable, nonatomic, strong, readonly) NSDictionary<NSString *, NMClassPropertyInfo *> *propertyInfos; ///< properties

/**
 If the class is changed (for example: you add a method to this class with
 'class_addMethod()'), you should call this method to refresh the class info cache.
 
 After called this method, `needUpdate` will returns `YES`, and you should call
 'classInfoWithClass' or 'classInfoWithClassName' to get the updated class info.
 */
- (void)setNeedUpdate;

/**
 If this method returns `YES`, you should stop using this instance and call
 `classInfoWithClass` or `classInfoWithClassName` to get the updated class info.
 
 @return Whether this class info need update.
 */
- (BOOL)needUpdate;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param cls A class.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClass:(Class)cls;

/**
 Get the class info of a specified Class.
 
 @discussion This method will cache the class info and super-class info
 at the first access to the Class. This method is thread-safe.
 
 @param className A class name.
 @return A class info, or nil if an error occurs.
 */
+ (nullable instancetype)classInfoWithClassName:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
