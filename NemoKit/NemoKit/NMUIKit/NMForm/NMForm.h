//
//  NMForm.h
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
#import "NMBUIMacro.h"

//Descriptors
#import "NMFormDescriptor.h"
#import "NMFormRowDescriptor.h"
#import "NMFormSectionDescriptor.h"

// Categories
#import "NSArray+NMFormAdditions.h"
#import "NSExpression+NMFormAdditions.h"
#import "NSObject+NMFormAdditions.h"
#import "NSPredicate+NMFormAdditions.h"
#import "NSString+NMFormAdditions.h"
#import "UIView+NMFormAdditions.h"

//helpers
#import "NMFormOptionsObject.h"

//Controllers
#import "NMFormOptionsViewController.h"
#import "NMFormViewController.h"

//Protocols
#import "NMFormDescriptorCell.h"
#import "NMFormInlineRowDescriptorCell.h"
#import "NMFormRowDescriptorViewController.h"

//Cells
#import "NMFormBaseCell.h"
#import "NMFormButtonCell.h"
#import "NMFormCheckCell.h"
#import "NMFormDateCell.h"
#import "NMFormDatePickerCell.h"
#import "NMFormInlineSelectorCell.h"
#import "NMFormLeftRightSelectorCell.h"
#import "NMFormPickerCell.h"
#import "NMFormRightDetailCell.h"
#import "NMFormRightImageButton.h"
#import "NMFormSegmentedCell.h"
#import "NMFormSelectorCell.h"
#import "NMFormSliderCell.h"
#import "NMFormStepCounterCell.h"
#import "NMFormSwitchCell.h"
#import "NMFormTextFieldCell.h"
#import "NMFormTextViewCell.h"
#import "NMFormImageCell.h"

//Validation
#import "NMFormRegexValidator.h"


extern NSString *const NMFormRowDescriptorTypeAccount;
extern NSString *const NMFormRowDescriptorTypeBooleanCheck;
extern NSString *const NMFormRowDescriptorTypeBooleanSwitch;
extern NSString *const NMFormRowDescriptorTypeButton;
extern NSString *const NMFormRowDescriptorTypeCountDownTimer;
extern NSString *const NMFormRowDescriptorTypeCountDownTimerInline;
extern NSString *const NMFormRowDescriptorTypeDate;
extern NSString *const NMFormRowDescriptorTypeDateInline;
extern NSString *const NMFormRowDescriptorTypeDatePicker;
extern NSString *const NMFormRowDescriptorTypeDateTime;
extern NSString *const NMFormRowDescriptorTypeDateTimeInline;
extern NSString *const NMFormRowDescriptorTypeDecimal;
extern NSString *const NMFormRowDescriptorTypeEmail;
extern NSString *const NMFormRowDescriptorTypeImage;
extern NSString *const NMFormRowDescriptorTypeInfo;
extern NSString *const NMFormRowDescriptorTypeInteger;
extern NSString *const NMFormRowDescriptorTypeMultipleSelector;
extern NSString *const NMFormRowDescriptorTypeMultipleSelectorPopover;
extern NSString *const NMFormRowDescriptorTypeName;
extern NSString *const NMFormRowDescriptorTypeNumber;
extern NSString *const NMFormRowDescriptorTypePassword;
extern NSString *const NMFormRowDescriptorTypePhone;
extern NSString *const NMFormRowDescriptorTypePicker;
extern NSString *const NMFormRowDescriptorTypeSelectorActionSheet;
extern NSString *const NMFormRowDescriptorTypeSelectorAlertView;
extern NSString *const NMFormRowDescriptorTypeSelectorLeftRight;
extern NSString *const NMFormRowDescriptorTypeSelectorPickerView;
extern NSString *const NMFormRowDescriptorTypeSelectorPickerViewInline;
extern NSString *const NMFormRowDescriptorTypeSelectorPopover;
extern NSString *const NMFormRowDescriptorTypeSelectorPush;
extern NSString *const NMFormRowDescriptorTypeSelectorSegmentedControl;
extern NSString *const NMFormRowDescriptorTypeSlider;
extern NSString *const NMFormRowDescriptorTypeStepCounter;
extern NSString *const NMFormRowDescriptorTypeText;
extern NSString *const NMFormRowDescriptorTypeTextView;
extern NSString *const NMFormRowDescriptorTypeTime;
extern NSString *const NMFormRowDescriptorTypeTimeInline;
extern NSString *const NMFormRowDescriptorTypeTwitter;
extern NSString *const NMFormRowDescriptorTypeURL;
extern NSString *const NMFormRowDescriptorTypeZipCode;
