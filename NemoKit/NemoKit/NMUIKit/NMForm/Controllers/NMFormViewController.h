//
//  NMFormViewController.h
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

#import <UIKit/UIKit.h>
#import "NMFormOptionsViewController.h"
#import "NMFormDescriptor.h"
#import "NMFormSectionDescriptor.h"
#import "NMFormDescriptorDelegate.h"
#import "NMFormRowNavigationAccessoryView.h"
#import "NMFormBaseCell.h"
#import "NMUICommonViewController.h"

@class NMFormViewController;
@class NMFormRowDescriptor;
@class NMFormSectionDescriptor;
@class NMFormDescriptor;
@class NMFormBaseCell;

typedef NS_ENUM(NSUInteger, NMFormRowNavigationDirection) {
    NMFormRowNavigationDirectionPrevious = 0,
    NMFormRowNavigationDirectionNext
};

@protocol NMFormViewControllerDelegate <NSObject>

@optional

-(void)didSelectFormRow:(NMFormRowDescriptor *)formRow;
-(void)deselectFormRow:(NMFormRowDescriptor *)formRow;
-(void)reloadFormRow:(NMFormRowDescriptor *)formRow;
-(NMFormBaseCell *)updateFormRow:(NMFormRowDescriptor *)formRow;

-(NSDictionary *)formValues;
-(NSDictionary *)httpParameters;

-(NMFormRowDescriptor *)formRowFormMultivaluedFormSection:(NMFormSectionDescriptor *)formSection;
-(void)multivaluedInsertButtonTapped:(NMFormRowDescriptor *)formRow;
-(UIStoryboard *)storyboardForRow:(NMFormRowDescriptor *)formRow;

-(NSArray *)formValidationErrors;
-(void)showFormValidationError:(NSError *)error;
-(void)showFormValidationError:(NSError *)error withTitle:(NSString*)title;

-(UITableViewRowAnimation)insertRowAnimationForRow:(NMFormRowDescriptor *)formRow;
-(UITableViewRowAnimation)deleteRowAnimationForRow:(NMFormRowDescriptor *)formRow;
-(UITableViewRowAnimation)insertRowAnimationForSection:(NMFormSectionDescriptor *)formSection;
-(UITableViewRowAnimation)deleteRowAnimationForSection:(NMFormSectionDescriptor *)formSection;

// InputAccessoryView
-(UIView *)inputAccessoryViewForRowDescriptor:(NMFormRowDescriptor *)rowDescriptor;
-(NMFormRowDescriptor *)nextRowDescriptorForRow:(NMFormRowDescriptor*)currentRow withDirection:(NMFormRowNavigationDirection)direction;

// highlight/unhighlight
-(void)beginEditing:(NMFormRowDescriptor *)rowDescriptor;
-(void)endEditing:(NMFormRowDescriptor *)rowDescriptor;

-(void)ensureRowIsVisible:(NMFormRowDescriptor *)inlineRowDescriptor;

@end

@interface NMFormViewController : NMUICommonViewController<UITableViewDataSource, UITableViewDelegate, NMFormDescriptorDelegate, UITextFieldDelegate, UITextViewDelegate, NMFormViewControllerDelegate>

@property (nonatomic, strong) NMFormDescriptor * form;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

-(instancetype)initWithForm:(NMFormDescriptor *)form;
-(instancetype)initWithForm:(NMFormDescriptor *)form style:(UITableViewStyle)style;
-(instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
+(NSMutableDictionary *)cellClassesForRowDescriptorTypes;
+(NSMutableDictionary *)inlineRowDescriptorTypesForRowDescriptorTypes;

-(void)performFormSelector:(SEL)selector withObject:(id)sender;

@end
