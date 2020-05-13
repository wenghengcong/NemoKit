//
//  NMFormRowDescriptor.h
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


#import <Foundation/Foundation.h>
#import "NMFormBaseCell.h"
#import "NMFormValidatorProtocol.h"
#import "NMFormValidationStatus.h"

extern CGFloat NMFormUnspecifiedCellHeight;

@class NMFormViewController;
@class NMFormSectionDescriptor;
@protocol NMFormValidatorProtocol;
@class NMFormAction;
@class NMFormBaseCell;

typedef NS_ENUM(NSUInteger, NMFormPresentationMode) {
    NMFormPresentationModeDefault = 0,
    NMFormPresentationModePush,
    NMFormPresentationModePresent
};

typedef void(^NMOnChangeBlock)(id __nullable oldValue, id __nullable newValue, NMFormRowDescriptor * __nonnull rowDescriptor);

@interface NMFormRowDescriptor : NSObject

@property (nonatomic, nullable, strong) id cellClass;
@property (nonatomic, nullable, copy  , readwrite) NSString * tag;
@property (nonatomic, nonnull , copy  , readonly) NSString * rowType;
@property (nonatomic, nullable, copy  ) NSString * title;
@property (nonatomic, nullable, strong) id value;
@property (nonatomic, nullable, strong) Class valueTransformer;
@property (nonatomic, assign  ) UITableViewCellStyle cellStyle;
@property (nonatomic, assign  ) CGFloat height;

@property (nonatomic, copy  , nullable) NMOnChangeBlock onChangeBlock;
@property (nonatomic, assign) BOOL useValueFormatterDuringInput;
@property (nonatomic, strong, nullable) NSFormatter *valueFormatter;

// returns the display text for the row descriptor, taking into account NSFormatters and default placeholder values
- (nonnull NSString *) displayTextValue;

// returns the editing text value for the row descriptor, taking into account NSFormatters.
- (nonnull NSString *) editTextValue;

@property (nonatomic, readonly, nonnull, strong) NSMutableDictionary * cellConfig;
@property (nonatomic, readonly, nonnull, strong) NSMutableDictionary * cellConfigForSelector;
@property (nonatomic, readonly, nonnull, strong) NSMutableDictionary * cellConfigIfDisabled;
@property (nonatomic, readonly, nonnull, strong) NSMutableDictionary * cellConfigAtConfigure;

@property (nonatomic, nonnull, strong) id disabled;
-(BOOL)isDisabled;

@property (nonatomic, nonnull, strong) id hidden;
-(BOOL)isHidden;

@property (getter=isRequired, nonatomic, assign) BOOL required;

@property (nonatomic, nonnull, strong) NMFormAction * action;

@property (nonatomic, weak, null_unspecified) NMFormSectionDescriptor * sectionDescriptor;

+(nonnull instancetype)formRowDescriptorWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType;
+(nonnull instancetype)formRowDescriptorWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType title:(nullable NSString *)title;
-(nonnull instancetype)initWithTag:(nullable NSString *)tag rowType:(nonnull NSString *)rowType title:(nullable NSString *)title;

-(nonnull NMFormBaseCell *)cellForFormController:(nonnull NMFormViewController *)formController;

@property (nonatomic, nullable, copy) NSString *requireMsg;
-(void)addValidator:(nonnull id<NMFormValidatorProtocol>)validator;
-(void)removeValidator:(nonnull id<NMFormValidatorProtocol>)validator;
-(nullable NMFormValidationStatus *)doValidation;

// ===========================
// property used for Selectors
// ===========================
@property (nonatomic, nullable, copy) NSString * noValueDisplayText;
@property (nonatomic, nullable, copy) NSString * selectorTitle;
@property (nonatomic, nullable, strong) NSArray * selectorOptions;

@property (null_unspecified) id leftRightSelectorLeftOptionSelected;


// =====================================
// Deprecated
// =====================================
@property (null_unspecified) Class buttonViewController DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use action.viewControllerClass instead");
@property NMFormPresentationMode buttonViewControllerPresentationMode DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("use action.viewControllerPresentationMode instead");
@property (null_unspecified) Class selectorControllerClass DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use action.viewControllerClass instead");


@end

typedef NS_ENUM(NSUInteger, NMFormLeftRightSelectorOptionLeftValueChangePolicy)
{
    NMFormLeftRightSelectorOptionLeftValueChangePolicyNullifyRightValue = 0,
    NMFormLeftRightSelectorOptionLeftValueChangePolicyChooseFirstOption,
    NMFormLeftRightSelectorOptionLeftValueChangePolicyChooseLastOption
};


// =====================================
// helper object used for LEFTRIGHTSelector Descriptor
// =====================================
@interface NMFormLeftRightSelectorOption : NSObject

@property (nonatomic, assign) NMFormLeftRightSelectorOptionLeftValueChangePolicy leftValueChangePolicy;
@property (nonatomic, readonly, nonnull) id leftValue;
@property (nonatomic, readonly, nonnull) NSArray *  rightOptions;
@property (nonatomic, readonly, null_unspecified, copy) NSString * httpParameterKey;
@property (nonatomic, nullable) Class rightSelectorControllerClass;

@property (nonatomic, nullable, copy) NSString * noValueDisplayText;
@property (nonatomic, nullable, copy) NSString * selectorTitle;


+(nonnull NMFormLeftRightSelectorOption *)formLeftRightSelectorOptionWithLeftValue:(nonnull id)leftValue
                                                          httpParameterKey:(null_unspecified NSString *)httpParameterKey
                                                              rightOptions:(nonnull NSArray *)rightOptions;


@end


@protocol NMFormOptionObject

@required

-(nonnull NSString *)formDisplayText;
-(nonnull id)formValue;

@end

@interface NMFormAction : NSObject

@property (nullable, nonatomic) Class viewControllerClass;
@property (nullable, nonatomic, copy) NSString * viewControllerStoryboardId;
@property (nullable, nonatomic, copy) NSString * viewControllerNibName;

@property (nonatomic, assign) NMFormPresentationMode viewControllerPresentationMode;

@property (nullable, nonatomic, copy) void (^formBlock)(NMFormRowDescriptor * __nonnull sender);
@property (nullable, nonatomic) SEL formSelector;
@property (nullable, nonatomic, copy) NSString * formSegueIdenfifier DEPRECATED_ATTRIBUTE DEPRECATED_MSG_ATTRIBUTE("Use formSegueIdentifier instead");
@property (nullable, nonatomic, copy) NSString * formSegueIdentifier;
@property (nullable, nonatomic) Class formSegueClass;

@end
