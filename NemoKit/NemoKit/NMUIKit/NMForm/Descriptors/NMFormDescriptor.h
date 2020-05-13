//
//  NMFormDescriptor.h
//  NMForm (  )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NMFormSectionDescriptor.h"
#import "NMFormRowDescriptor.h"
#import "NMFormDescriptorDelegate.h"
#import <Foundation/Foundation.h>

extern NSString * __nonnull const NMFormErrorDomain;
extern NSString * __nonnull const NMValidationStatusErrorKey;

typedef NS_ENUM(NSInteger, NMFormErrorCode)
{
    NMFormErrorCodeGen = -999,
    NMFormErrorCodeRequired = -1000
};

typedef NS_OPTIONS(NSUInteger, NMFormRowNavigationOptions) {
    NMFormRowNavigationOptionNone                               = 0,
    NMFormRowNavigationOptionEnabled                            = 1 << 0,
    NMFormRowNavigationOptionStopDisableRow                     = 1 << 1,
    NMFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow  = 1 << 2,
    NMFormRowNavigationOptionStopInlineRow                      = 1 << 3,
};

@class NMFormSectionDescriptor;

@interface NMFormDescriptor : NSObject

@property (nonatomic, strong, readonly, nonnull) NSMutableArray * formSections;
@property (nonatomic, readonly, nullable, copy) NSString * title;
@property (nonatomic, assign) BOOL endEditingTableViewOnScroll;
@property (nonatomic, assign) BOOL assignFirstResponderOnShow;
@property (nonatomic, assign) BOOL addAsteriskToRequiredRowsTitle;
@property (nonatomic, getter=isDisabled, assign) BOOL disabled;
@property (nonatomic, assign) NMFormRowNavigationOptions rowNavigationOptions;

@property (nonatomic, weak, nullable) id<NMFormDescriptorDelegate> delegate;

+(nonnull instancetype)formDescriptor;
+(nonnull instancetype)formDescriptorWithTitle:(nullable NSString *)title;

-(void)addFormSection:(nonnull NMFormSectionDescriptor *)formSection;
-(void)addFormSection:(nonnull NMFormSectionDescriptor *)formSection atIndex:(NSUInteger)index;
-(void)addFormSection:(nonnull NMFormSectionDescriptor *)formSection afterSection:(nonnull NMFormSectionDescriptor *)afterSection;
-(void)addFormRow:(nonnull NMFormRowDescriptor *)formRow beforeRow:(nonnull NMFormRowDescriptor *)afterRow;
-(void)addFormRow:(nonnull NMFormRowDescriptor *)formRow beforeRowTag:(nonnull NSString *)afterRowTag;
-(void)addFormRow:(nonnull NMFormRowDescriptor *)formRow afterRow:(nonnull NMFormRowDescriptor *)afterRow;
-(void)addFormRow:(nonnull NMFormRowDescriptor *)formRow afterRowTag:(nonnull NSString *)afterRowTag;
-(void)removeFormSectionAtIndex:(NSUInteger)index;
-(void)removeFormSection:(nonnull NMFormSectionDescriptor *)formSection;
-(void)removeFormRow:(nonnull NMFormRowDescriptor *)formRow;
-(void)removeFormRowWithTag:(nonnull NSString *)tag;

-(nullable NMFormRowDescriptor *)formRowWithTag:(nonnull NSString *)tag;
-(nullable NMFormRowDescriptor *)formRowAtIndex:(nonnull NSIndexPath *)indexPath;
-(nullable NMFormRowDescriptor *)formRowWithHash:(NSUInteger)hash;
-(nullable NMFormSectionDescriptor *)formSectionAtIndex:(NSUInteger)index;

-(nullable NSIndexPath *)indexPathOfFormRow:(nonnull NMFormRowDescriptor *)formRow;

-(nonnull NSDictionary *)formValues;
-(nonnull NSDictionary *)httpParameters:(nonnull NMFormViewController *)formViewController;

-(nonnull NSArray *)localValidationErrors:(nonnull NMFormViewController *)formViewController;
-(void)setFirstResponder:(nonnull NMFormViewController *)formViewController;

-(nullable NMFormRowDescriptor *)nextRowDescriptorForRow:(nonnull NMFormRowDescriptor *)currentRow;
-(nullable NMFormRowDescriptor *)previousRowDescriptorForRow:(nonnull NMFormRowDescriptor *)currentRow;

-(void)forceEvaluate;

@end
