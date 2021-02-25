//
//  NMUtils.h
//  FBSnapshotTestCase
//
//  Created by Hunt on 2020/7/2.
//

#import <Foundation/Foundation.h>
#import "NMCoreMacro.h"

typedef struct _NMUtils_t{
    /*!
     * 判断所传对象是否为NSString的类或子类的实例
     *
     * @param string 传入需要判断的实例
     *
     * @return 如果传入实例为NSString类或其子类的实例并且包含至少一个字符则返回YES，否则返回NO
     */
    BOOL (*validateString)(NSString *string);
    
    /*!
    *  判断所传对象是否为NSNumber的类或子类的实例
    *
    *  @param number 传入需要判断的实例
    *
    *  @return 如果传入实例为NSNumber类或其子类的实例，否则返回NO
    */
    BOOL (*validateNumber)(NSNumber *number);
    
    /*!
     *  判断所传对象是否为NSArray的类或子类的实例
     *
     *  @param string 传入需要判断的实例
     *
     *  @return 如果传入实例为NSArray类或其子类的实例并且包含至少一个对象则返回YES，否则返回NO
     */
    BOOL (*validateArray)(NSArray *array);
    /*!
     *  判断所传对象是否为NSDictionary的类或子类的实例
     *
     *  @param string 传入需要判断的实例
     *
     *  @return 如果传入实例为NSDictionary类或其子类的实例返回YES，否则返回NO
     */
    BOOL (*validateDictionary)(NSDictionary *dictionary);
    
} NMUtils_t;

/*!
 *  开发常用工具包
 */
extern NMUtils_t NMUtils;
