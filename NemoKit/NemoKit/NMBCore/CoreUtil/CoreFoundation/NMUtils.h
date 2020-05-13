//
//  NMUtils.h
//  NemoMoney
//
//  Created by Hunt on 2019/12/25.
//  Copyright © 2019 ChuAng. All rights reserved.
//

#import <Foundation/Foundation.h>

//HCTODO :
typedef struct _NMUtils_t{
    
    /*!
     *  获取指定文件名的绝对路径，工作流程如下：
     *  1，首先检测Document目录下是否有指定文件（不搜索子目录）
     *  2，如果Document目录下不存在此文件，则使用NSBundle查找的目录
     *
     *  @param filename 文件名
     *  @param ext 文件扩展名
     *
     *  @return 返回此文件的绝对路径，如果没找到则返回nil
     *  @since 1.0+
     */
    NSString * (*getFilePath)(NSString* filename, NSString* ext);
    
    
    /*!
     *  用NSBundle查找文件目录
     *
     *  @param filename 文件名
     *  @param ext 文件扩展名
     *
     *  @return 返回此文件的路径，如果没找到则返回nil
     *
     *  @since 1.0+
     */
    NSString * (*getBundleFilePath)(NSString* filename, NSString* ext);
    
    /*!
     *  获取当前时间的格式化后字串，如：2013-12-19 16:10
     *
     *  @return 返回时间字串
     *  @since 1.0+
     */
    NSString * (*getNowTimeStr)(void);
    
    
    /*!
     *  获取当前时间格式化后字串，如：20131219161452
     *
     *  @return 返回时间字串
     *
     *  @since 1.0+
     */
    NSString * (*getCurrentDateTimer)(void);
    
    /*!
     *  去字符串前后空格
     *
     *  @param str 传入需要缩减字串
     *
     *  @return 返回处理完的新字串
     *
     *  @since 1.0+
     */
    NSString * (*trim)(NSString *str);
    
    /*!
     *  判断所传对象是否为NSDictionary、NSArray(至少包括一个实例)、NSString（trim后至少包括一个字串）类或其子类的实例
     *
     *  @param components 传入需要判断的NSObject实例
     *
     *  @return 如果为NSDictionary, NSArray, NSString中的一个实例则返回YES，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*checkSetAvailable)(id components);
    
    /*!
     *  判断所传对象是否为NSString的类或子类的实例
     *
     *  @param string 传入需要判断的实例
     *
     *  @return 如果传入实例为NSString类或其子类的实例并且包含至少一个字符则返回YES，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*validateString)(NSString *string);
    
    
    /*!
     *  判断所传对象是否为NSNumber的类或子类的实例
     *
     *  @param number 传入需要判断的实例
     *
     *  @return 如果传入实例为NSNumber类或其子类的实例，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*validateNumber)(NSNumber *number);
    
    /*!
     *  判断所传对象是否为NSArray的类或子类的实例
     *
     *  @param string 传入需要判断的实例
     *
     *  @return 如果传入实例为NSArray类或其子类的实例并且包含至少一个对象则返回YES，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*validateArray)(NSArray *array);
    
    /*!
     *  判断所传对象是否为NSDictionary的类或子类的实例
     *
     *  @param string 传入需要判断的实例
     *
     *  @return 如果传入实例为NSDictionary类或其子类的实例返回YES，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*validateDictionary)(NSDictionary *dictionary);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToString)(NSString *obj1, NSString *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToAttributedString)(NSAttributedString *obj1, NSAttributedString *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToNumber)(NSNumber *obj1, NSNumber *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToArray)(NSArray *obj1, NSArray *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToDictionary)(NSDictionary *obj1, NSDictionary *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToData)(NSData *obj1, NSData *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToDate)(NSDate *obj1, NSDate *obj2);
    
    /*!
     *  判断所传对象是否相等
     *
     *  @return 如果任一实例为nil或类型不匹配都会返回NO
     *
     *  @since 5.5+
     */
    BOOL (*isEqualToValue)(NSValue *obj1, NSValue *obj2);
    
    /*!
     *  此方法用CFUUIDCreate返回一个随机字串
     *
     *  @return 随机字串
     *
     *  @since 1.0+
     */
    NSString * (*createUUID)(void);
    
    
    /*!
     *  调用OpenUDID的API，返回设备唯一标识。此ID不会调用系统的UUID、VenderID、ADID，而是生成此设备唯一值，保存在粘贴板、应用配制、应用沙盒里。其中保存在粘贴板中的目的是为了与其它应用共享此值。
     *
     *
     *  @return 返回此设备唯一标识
     *
     *  @since 1.0+
     */
    NSString * (*getOpenUDID)(void);
    
    /*!
     *  通过系统提供的ASIdentifierManager获取广告ID，此API仅在iOS6.0以上支持
     *
     *  @return 返回ADID的字串
     *
     *  @since 1.0+
     */
    //    NSString * (*getAdid)();
    
    /*!
     *  返回设备名，如，@”iPhone” and @”iPod touch”.
     *
     *  @return 返回设备名
     *
     *  @since 1.0+
     */
    NSString * (*getDeviceModel)(void);
    
    /*!
     *  获取当前客户端的版本号。此值取自工程配制文件，在主站中为当前应用的版本。在Framework中如果此值未配，则返回1.0。
     *
     *  @return 版本号字串
     *
     *  @since 1.0+
     */
    NSString * (*getClientVersion)(void);
    
    /*!
     *  获取当前iOS系统的版本，如，7.0
     *
     *  @return 返回版本字串
     *
     *  @since 1.0+
     */
    NSString * (*getOsVersion)(void);
    
    /*!
     *  获取当前iOS系统的版本int值，如，70
     *
     *  @return 返回版本int，
     *
     *  @since 1.0+
     */
    int (*checkiOS)(void);
    
    /*!
     *  计算给定字串的MD5值。如果所传字串长度为0、字串不可用、不为NSString字串，则直接返回nil
     *
     *  @param str 需要MD5加密的字串
     *
     *  @return 返回MD5加密后的串
     *
     *  @since 1.0+
     */
    NSString * (*md5Encode)(NSString *str);
    
    /*!
     *  商城内部使用，不推直接使用荐使用此
     *
     *  @since 1.0+
     */
    NSString * (*md5sign)(NSArray* array);
    
    /*!
     *  获取当前设备屏幕的长*宽字串
     *
     *  @return 屏幕长*宽字串
     *
     *  @since 1.0+
     */
    NSString * (*getResolution)(void);
    
    
    /*!
     *  获取网络类型字串
     *
     *  @return 值如，wifi, 2g, 3g
     *
     *  @since 1.0+
     */
    NSString * (*getNetworkTyvoidpe)(void);
    
    
    
    /*!
     *  @brief  检测网站是否可用
     *
     *  @return YES|NO
     *
     *  @since 4.0.0
     */
    BOOL (*isNetworkAvailability)(void);
    
    /*!
     *  查找subviews中函有viewClass的UIView
     *
     *  @param viewClass 需要查找的class
     *  @param subviews  需要查找的视图列表
     *
     *  @return 返回查找到的视图，如果没找到返回nil
     *
     *  @since 1.0+
     */
    UIView * (*findViewForClass)(Class viewClass, NSArray* subviews);
    
    /*!
     *  是否是支持高清的设备
     *
     *  @return 如果支持高清返回YES，否则返回NO
     *
     *  @since 1.0+
     */
    BOOL (*isRetinaEnabled)(void);
    
    /*!
     *  返回时间的字串，如，10:10:10
     *
     *  @param timeSec
     *
     *  @return 返回冒号分隔的时间
     *
     *  @since 1.0+
     */
    NSString * (*timeString)(double timeSec);
    
    
    
    NSString * (*timeStringFromDay)(double timeSec);
    
    /*!
     *  检测摄像头是否可用
     *
     *  @return 如果可用返回YES
     *
     *  @since 1.0+
     */
    BOOL (*isCameraCanUse)(void);
    
    /*!
     *  弧度转度函数
     *
     *  @param degrees 弧度值
     *
     *  @return  返回度值
     *
     *  @since 1.0+
     */
    CGFloat (*degreesToRadians)(CGFloat degrees);
    
    /*!
     *  度转弧度函数
     *
     *  @param degrees 度值
     *
     *  @return  弧度值
     *
     *  @since 1.0+
     */
    CGFloat (*radiansToDegrees)(CGFloat radians);
    
    /*!
     *  用UIAlertView提示信息
     *
     *  @param msg 提示信息字串
     *
     *  @since 1.0+
     */
    void (*showAlert)(NSString *msg);
    
    
    /**
     *  @brief  检测是否为网络超时错误
     *
     *  @since 1.0+
     */
    BOOL (*isNetworkRequestTimeout)(NSError* error);
    
    
    /**
     *  @brief  检测是否为网络错误
     *
     *  @since 4.0+
     */
    BOOL (*isNetworkErrorDomain)(NSError* error);
    
    
    /*!
     *  XML字符串反序列化成NSDictonary的过程
     *
     *  @param str 需要处理的XML字串
     *  @param err 错误的指针对象，如果出错此实例不为空
     *
     *  @return 返回NSDictionary实例，如果中间处理出错，返回nil
     *
     *  @since 1.0+
     */
    NSDictionary* (*getDictionaryFromXMLString)(NSString *str,NSError **err);
    NSDictionary* (*getDictionaryFromXMLData)(NSData *data,NSError **err);
    
    
    
    /*!
     *  获取Hex字串所表示的UIColor实例，如：#ffffff，ffffff  返回的值为白色的UIColor实例
     *
     *  @param hexColor 需要进行转换的六字符RGB颜色字串
     *
     *  @return 返回UIColor实例
     *
     *  @since 1.0+
     */
    UIColor* (*getColorByHex)(NSString *hexColor);
    
    
    /*!
     *  des加密
     *
     *  @param t   字符串
     *  @param key key
     *
     *  @return 加密后的字符串
     *
     *  @since 2.0+
     */
    NSString * (*enDes)(NSString* t, NSString *key);
    
    
    
    /*!
     *  des解密
     *
     *  @param t   字符串
     *  @param key key
     *
     *  @return 解密后的字符串
     *
     *  @since 2.0+
     */
    NSString * (*deDes)(NSString* t, NSString *key);
    
    
    
    /*!
     *  @brief  3des加密
     *
     *  @param t   字符串
     *  @param key key
     *
     *  @return 加密后的字符串
     *
     *  @since 4.3+
     */
    NSString * (*en3Des)(NSString* t, NSString *key);
    
    
    /*!
     *  @brief  3des解密
     *
     *  @param t   字符串
     *  @param key key
     *
     *  @return 解密后的字符串
     *
     *  @since 4.3+
     */
    NSString * (*de3Des)(NSString* t, NSString *key);
    
    
    
    
    /*!
     *  数组转json串
     *
     *  @param arr 数组
     *
     *  @return 字符串
     *
     *  @since 2.0+
     */
    NSString * (*arrayToJson)(NSArray* arr);
    
    /*!
     *  字典转json串
     *
     *  @param dic 字典
     *
     *  @return 字符串
     *
     *  @since 2.0+
     */
    NSString * (*dictionaryToJson)(NSDictionary *dic);
    
    /*!
     *  data转数组
     *
     *  @param data data
     *
     *  @return 数组
     *
     *  @since 2.0+
     */
    NSArray * (*jsonToArray)(NSData *data);
    
    
    /*!
     *  data转字典
     *
     *  @param data data
     *
     *  @return 字典
     *
     *  @since 2.0+
     */
    NSDictionary * (*jsonToDictionary)(NSData *data);
    
    
    
    
    /*!
     *  data转字典,数组
     *
     *  @param data data
     *
     *  @return 字典｜数组
     *
     *  @since 4.0+
     */
    //    NSDictionary * (*jsonToObject)(NSData *data);
    
    
    /*!
     *  html编码
     *
     *  @param src html内容
     *
     *  @return 编码内容
     *
     *  @since 2.0+
     */
    NSString * (*escapeHTML)(NSString* src);
    
    
    /*!
     *  html解码
     *
     *  @param src html编码内容
     *
     *  @return 解码内容
     *
     *  @since 2.0+
     */
    NSString * (*unescapeHTML)(NSString* src);
    
    
    /*!
     *  url编码
     *
     *  @param src url
     *
     *  @return 编码后的url
     *
     *  @since 2.0+
     */
    NSString * (*escapeURIComponent)(NSString* src);
    
    
    /*!
     *  url解码
     *
     *  @param src 编码的url
     *
     *  @return 解码的url
     *
     *  @since 2.0+
     */
    NSString * (*unescapeURIComponent)(NSString* src);
    
    
    
    NSString * (*base64stringByEncodingData)(NSData* data);
    NSData * (*base64decodeString)(NSString* str);
    
    
    
    
    //
    NSString * (*SHA1Digest)(NSString* str);
    NSString * (*SHA1Mac)(NSString* key, NSString *text);
    
    
    
    
    //------
    // SFHFKeychainUtils
    NSString * (*sfGetPassword)(NSString* username, NSString *serviceName, NSError **error);
    
    
    void (*sfStoreUsername)(NSString *username, NSString *password, NSString *serviceName, BOOL updateExisting, NSError ** error);
    
    void (*sfDeleteItem)(NSString *username, NSString *serviceName, NSError ** error);
    
    
    //--------
    
    
    /*!
     *  RSA key公钥生成
     *
     *  @param peerName  公钥key
     *  @param keyString 公钥字符串
     *
     *  @return SecKeyRef
     *
     *  @since 4.x
     */
    SecKeyRef (*rsaAddPeerPublicKey)(NSString *peerName, NSString* keyString);
    
    
    /*!
     *  RSA 加密
     *
     *  @param plainTextString 加密源字符串
     *  @param publicKey       publicKey
     *
     *  @return 加密后的字串
     *
     *  @since 4.x
     */
    NSString * (*rsaEncrypt)(NSString *plainTextString, SecKeyRef publicKey);
    
    
    /*!
     *  RSA 加密 (JD 加密串超100字符，使用|分隔加密)
     *
     *  @param plainTextString 加密源字符串
     *  @param publicKey       publicKey
     *
     *  @return 加密后的字串
     *
     *  @since 4.x
     */
    NSString * (*rsaEncrypt1)(NSString *plainTextString, SecKeyRef publicKey);
    
    
    
    /*!
     *  RSA 根据key移除公钥
     *
     *  @since 4.x
     */
    void (*rsaremovePeerPublicKey)(NSString *peerName);
    
    
    
    /**
     *  @brief  获取设备地址
     *
     *  @param getDeviceAddresses
     *
     *  @return 设备地址
     *
     *  @since 3.9.8
     */
    NSArray * (*getDeviceAddresses)();
    
    /**
     *  当前IP地址(该方法会根据当前网络类型来返回)
     *
     *
     *  @return IP地址(*.*.*.*)
     */
    NSString * (*getIPAddress)();
    
    
    /**
     *  @brief  获取设备存储大小
     *
     *  @param getDevicePhysicalMemory
     *
     *  @return 内存大小
     *
     *  @since 3.9.8
     */
    NSString * (*getDevicePhysicalMemory)(void);
    
    
    
    /**
     *  @brief  获取bundle路径
     *
     *  @param getPathForBundleResource 相关路径
     *
     *  @return bundle路径
     *
     *  @since 3.9.0
     */
    NSString * (*getPathForBundleResource)(NSString* relativePath);
    
    
    /**
     *  @brief  获取bundle中的图片资源
     *
     *  @param loadImageFromBundle 图片地址
     *
     *  @return 图片
     *
     *  @since 3.9.0
     */
    UIImage * (*loadImageFromBundle)(NSString* url);
    
    
    
    
    /**
     *  @brief  服务端下发serverConfig，httpsDomains加密字段，解密后用来匹配网络请求是否启动https
     *
     *  @param 加密字符串
     *
     *  @return 解密字符串
     *
     *  @since 5.0.0
     */
    NSString * (*getHttpsDomains)(NSString* domains);
    
    /**
     *  @brief  解密PatchScript
     *
     *  @param  加密字符串
     *
     *  @return 解密字符串
     *
     *  @since 5.0.0
     */
    NSString * (*decodePatchScript)(NSString* script);
    
    
    
    
    
    
    // rsa 加解密 - public
    NSString* (*rsaPubEncryptString)(NSString* str, NSString *publicKey);
    
    NSData* (*rsaPubEncryptData)(NSData* data, NSString *publicKey);
    
    NSString* (*rsaPubDecryptString)(NSString* str, NSString *publicKey);
    
    NSData* (*rsaPubDecryptData)(NSData* data, NSString *publicKey);
    
    
    // private
    //    NSString* (*rsaPriEncryptString)(NSString* str, NSString *privateKey);
    //
    //    NSData* (*rsaPriEncryptData)(NSData* data, NSString *publicKey);
    
    NSString* (*rsaPriDecryptString)(NSString* str, NSString *privateKey);
    
    NSData* (*rsaPriDecryptData)(NSData* data, NSString *privateKey);
    
    
    /**
     *  @author steven, 16-08-25 13:08:13
     *
     *  获取build id
     *
     *  @since >=5.3.0
     */
    NSString* (*getBuild)(void);
    
    
    
    
    /**
     *  @author steven, 16-12-06 18:23:13
     *
     *  类方法替换
     *
     *  @since >=5.7.0
     */
    BOOL (*replaceMethodWithBlock)(Class c, SEL origSEL, SEL newSEL, id block);
    
    
} NMUtils_t;

/*!
 *  开发常用工具包，包括设备信息、时间格式化、资源目录、JSON、XML、BASE64，MD5，COLOR 等相关的方法
 */
extern NMUtils_t NMUtils;


