//
//  NMFormViewController.m
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

#import "UIView+NMFormAdditions.h"
#import "NSObject+NMFormAdditions.h"
#import "NMFormViewController.h"
#import "UIView+NMFormAdditions.h"
#import "NMForm.h"
#import "NSString+NMFormAdditions.h"


@interface NMFormRowDescriptor(_NMFormViewController)

-(BOOL)evaluateIsDisabled;
-(BOOL)evaluateIsHidden;

@end

@interface NMFormSectionDescriptor(_NMFormViewController)

-(BOOL)evaluateIsHidden;

@end

@interface NMFormDescriptor (_NMFormViewController)

@property (atomic, strong) NSMutableDictionary* rowObservers;

@end


@interface NMFormViewController()
{
    NSNumber *_oldBottomTableContentInset;
    CGRect _keyboardFrame;
}
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong) NMFormRowNavigationAccessoryView * navigationAccessoryView;

@end

@implementation NMFormViewController

@synthesize form = _form;

#pragma mark - Initialization

-(instancetype)initWithForm:(NMFormDescriptor *)form
{
    return [self initWithForm:form style:UITableViewStyleGrouped];
}

-(instancetype)initWithForm:(NMFormDescriptor *)form style:(UITableViewStyle)style
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        _tableViewStyle = style;
        _form = form;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        _form = nil;
        _tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _form = nil;
        _tableViewStyle = UITableViewStyleGrouped;
    }
    
    return self;
}

-(void)dealloc
{
    [self removeObserverFromController];

    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    self.form.delegate = nil;
    
    self.navigationAccessoryView = nil;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = self.tableView;
    if (!tableView){
        tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                      style:self.tableViewStyle];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if([tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]){
            tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
    }
    if (!tableView.superview){
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    if (!self.tableView.delegate){
        self.tableView.delegate = self;
    }
    if (!self.tableView.dataSource){
        self.tableView.dataSource = self;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
    }
    if (self.form.title){
        self.title = self.form.title;
    }
    [self.tableView setEditing:YES animated:NO];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.form.delegate = self;
    _oldBottomTableContentInset = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected) {
        // Trigger a cell refresh
        NMFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:selected];
        [self updateFormRow:rowDescriptor];
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }
    
    [self addObserverToController];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.form.assignFirstResponderOnShow) {
        self.form.assignFirstResponderOnShow = NO;
        [self.form setFirstResponder:self];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeObserverFromController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)addObserverToController {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(contentSizeCategoryChanged:)
               name:UIContentSizeCategoryDidChangeNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

-(void)removeObserverFromController {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - CellClasses

+(NSMutableDictionary *)cellClassesForRowDescriptorTypes
{
    static NSMutableDictionary * _cellClassesForRowDescriptorTypes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cellClassesForRowDescriptorTypes = [@{NMFormRowDescriptorTypeText:[NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeName: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypePhone:[NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeURL:[NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeEmail: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeTwitter: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeAccount: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypePassword: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeNumber: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeInteger: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeDecimal: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeZipCode: [NMFormTextFieldCell class],
                                               NMFormRowDescriptorTypeSelectorPush: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorPopover: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorActionSheet: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorAlertView: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorPickerView: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorPickerViewInline: [NMFormInlineSelectorCell class],
                                               NMFormRowDescriptorTypeSelectorSegmentedControl: [NMFormSegmentedCell class],
                                               NMFormRowDescriptorTypeMultipleSelector: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeMultipleSelectorPopover: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeImage: [NMFormImageCell class],
                                               NMFormRowDescriptorTypeTextView: [NMFormTextViewCell class],
                                               NMFormRowDescriptorTypeButton: [NMFormButtonCell class],
                                               NMFormRowDescriptorTypeInfo: [NMFormSelectorCell class],
                                               NMFormRowDescriptorTypeBooleanSwitch : [NMFormSwitchCell class],
                                               NMFormRowDescriptorTypeBooleanCheck : [NMFormCheckCell class],
                                               NMFormRowDescriptorTypeDate: [NMFormDateCell class],
                                               NMFormRowDescriptorTypeTime: [NMFormDateCell class],
                                               NMFormRowDescriptorTypeDateTime : [NMFormDateCell class],
                                               NMFormRowDescriptorTypeCountDownTimer : [NMFormDateCell class],
                                               NMFormRowDescriptorTypeDateInline: [NMFormDateCell class],
                                               NMFormRowDescriptorTypeTimeInline: [NMFormDateCell class],
                                               NMFormRowDescriptorTypeDateTimeInline: [NMFormDateCell class],
                                               NMFormRowDescriptorTypeCountDownTimerInline : [NMFormDateCell class],
                                               NMFormRowDescriptorTypeDatePicker : [NMFormDatePickerCell class],
                                               NMFormRowDescriptorTypePicker : [NMFormPickerCell class],
                                               NMFormRowDescriptorTypeSlider : [NMFormSliderCell class],
                                               NMFormRowDescriptorTypeSelectorLeftRight : [NMFormLeftRightSelectorCell class],
                                               NMFormRowDescriptorTypeStepCounter: [NMFormStepCounterCell class]
                                               } mutableCopy];
    });
    return _cellClassesForRowDescriptorTypes;
}

#pragma mark - inlineRowDescriptorTypes

+(NSMutableDictionary *)inlineRowDescriptorTypesForRowDescriptorTypes
{
    static NSMutableDictionary * _inlineRowDescriptorTypesForRowDescriptorTypes;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _inlineRowDescriptorTypesForRowDescriptorTypes = [
                                                          @{NMFormRowDescriptorTypeSelectorPickerViewInline: NMFormRowDescriptorTypePicker,
                                                            NMFormRowDescriptorTypeDateInline: NMFormRowDescriptorTypeDatePicker,
                                                            NMFormRowDescriptorTypeDateTimeInline: NMFormRowDescriptorTypeDatePicker,
                                                            NMFormRowDescriptorTypeTimeInline: NMFormRowDescriptorTypeDatePicker,
                                                            NMFormRowDescriptorTypeCountDownTimerInline: NMFormRowDescriptorTypeDatePicker
                                                            } mutableCopy];
    });
    return _inlineRowDescriptorTypesForRowDescriptorTypes;
}

#pragma mark - NMFormDescriptorDelegate

-(void)formRowHasBeenAdded:(NMFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:[self insertRowAnimationForRow:formRow]];
    [self.tableView endUpdates];
}

-(void)formRowHasBeenRemoved:(NMFormRowDescriptor *)formRow atIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self deleteRowAnimationForRow:formRow]];
    [self.tableView endUpdates];
}

-(void)formSectionHasBeenRemoved:(NMFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:[self deleteRowAnimationForSection:formSection]];
    [self.tableView endUpdates];
}

-(void)formSectionHasBeenAdded:(NMFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:[self insertRowAnimationForSection:formSection]];
    [self.tableView endUpdates];
}

-(void)formRowDescriptorValueHasChanged:(NMFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue
{
    [self updateAfterDependentRowChanged:formRow];
}

-(void)formRowDescriptorPredicateHasChanged:(NMFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue predicateType:(NMPredicateType)predicateType
{
    if (oldValue != newValue) {
        [self updateAfterDependentRowChanged:formRow];
    }
}

-(void)updateAfterDependentRowChanged:(NMFormRowDescriptor *)formRow
{
    NSMutableArray* revaluateHidden   = [self.form.rowObservers[[formRow.tag formKeyForPredicateType:NMPredicateTypeHidden]] mutableCopy];
    NSMutableArray* revaluateDisabled = [self.form.rowObservers[[formRow.tag formKeyForPredicateType:NMPredicateTypeDisabled]] mutableCopy];
    for (id object in revaluateDisabled) {
        if ([object isKindOfClass:[NSString class]]) {
            NMFormRowDescriptor* row = [self.form formRowWithTag:object];
            if (row){
                [row evaluateIsDisabled];
                [self updateFormRow:row];
            }
        }
    }
    for (id object in revaluateHidden) {
        if ([object isKindOfClass:[NSString class]]) {
            NMFormRowDescriptor* row = [self.form formRowWithTag:object];
            if (row){
                [row evaluateIsHidden];
            }
        }
        else if ([object isKindOfClass:[NMFormSectionDescriptor class]]) {
            NMFormSectionDescriptor* section = (NMFormSectionDescriptor*) object;
            [section evaluateIsHidden];
        }
    }
}

#pragma mark - NMFormViewControllerDelegate

-(NSDictionary *)formValues
{
    return [self.form formValues];
}

-(NSDictionary *)httpParameters
{
    return [self.form httpParameters:self];
}


-(void)didSelectFormRow:(NMFormRowDescriptor *)formRow
{
    if ([[formRow cellForFormController:self] respondsToSelector:@selector(formDescriptorCellDidSelectedWithFormController:)]){
        [[formRow cellForFormController:self] formDescriptorCellDidSelectedWithFormController:self];
    }
}

-(UITableViewRowAnimation)insertRowAnimationForRow:(NMFormRowDescriptor *)formRow
{
    if (formRow.sectionDescriptor.sectionOptions & NMFormSectionOptionCanInsert){
        if (formRow.sectionDescriptor.sectionInsertMode == NMFormSectionInsertModeButton){
            return UITableViewRowAnimationAutomatic;
        }
        else if (formRow.sectionDescriptor.sectionInsertMode == NMFormSectionInsertModeLastRow){
            return YES;
        }
    }
    return UITableViewRowAnimationFade;
}

-(UITableViewRowAnimation)deleteRowAnimationForRow:(NMFormRowDescriptor *)formRow
{
    return UITableViewRowAnimationFade;
}

-(UITableViewRowAnimation)insertRowAnimationForSection:(NMFormSectionDescriptor *)formSection
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)deleteRowAnimationForSection:(NMFormSectionDescriptor *)formSection
{
    return UITableViewRowAnimationAutomatic;
}

-(UIView *)inputAccessoryViewForRowDescriptor:(NMFormRowDescriptor *)rowDescriptor
{
    if ((self.form.rowNavigationOptions & NMFormRowNavigationOptionEnabled) != NMFormRowNavigationOptionEnabled){
        return nil;
    }
    if ([[[[self class] inlineRowDescriptorTypesForRowDescriptorTypes] allKeys] containsObject:rowDescriptor.rowType]) {
        return nil;
    }
    UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[rowDescriptor cellForFormController:self];
    if (![cell formDescriptorCellCanBecomeFirstResponder]){
        return nil;
    }
    NMFormRowDescriptor * previousRow = [self nextRowDescriptorForRow:rowDescriptor
                                                            withDirection:NMFormRowNavigationDirectionPrevious];
    NMFormRowDescriptor * nextRow     = [self nextRowDescriptorForRow:rowDescriptor
                                                            withDirection:NMFormRowNavigationDirectionNext];
    [self.navigationAccessoryView.previousButton setEnabled:(previousRow != nil)];
    [self.navigationAccessoryView.nextButton setEnabled:(nextRow != nil)];
    return self.navigationAccessoryView;
}

-(void)beginEditing:(NMFormRowDescriptor *)rowDescriptor
{
    [[rowDescriptor cellForFormController:self] highlight];
}

-(void)endEditing:(NMFormRowDescriptor *)rowDescriptor
{
    [[rowDescriptor cellForFormController:self] unhighlight];
}

-(NMFormRowDescriptor *)formRowFormMultivaluedFormSection:(NMFormSectionDescriptor *)formSection
{
    if (formSection.multivaluedRowTemplate){
        return [formSection.multivaluedRowTemplate copy];
    }
    NMFormRowDescriptor * formRowDescriptor = [[formSection.formRows objectAtIndex:0] copy];
    formRowDescriptor.tag = nil;
    return formRowDescriptor;
}

-(void)multivaluedInsertButtonTapped:(NMFormRowDescriptor *)formRow
{
    [self deselectFormRow:formRow];
    NMFormSectionDescriptor * multivaluedFormSection = formRow.sectionDescriptor;
    NMFormRowDescriptor * formRowDescriptor = [self formRowFormMultivaluedFormSection:multivaluedFormSection];
    [multivaluedFormSection addFormRow:formRowDescriptor];
    __weak typeof(self) weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weak.tableView.editing = !weak.tableView.editing;
        weak.tableView.editing = !weak.tableView.editing;
    });
    UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[formRowDescriptor cellForFormController:self];
    if ([cell formDescriptorCellCanBecomeFirstResponder]){
        [cell formDescriptorCellBecomeFirstResponder];
    }
}

-(void)ensureRowIsVisible:(NMFormRowDescriptor *)inlineRowDescriptor
{
    NMFormBaseCell * inlineCell = [inlineRowDescriptor cellForFormController:self];
    NSIndexPath * indexOfOutOfWindowCell = [self.form indexPathOfFormRow:inlineRowDescriptor];
    if(!inlineCell.window || (self.tableView.contentOffset.y + self.tableView.frame.size.height <= inlineCell.frame.origin.y + inlineCell.frame.size.height)){
        [self.tableView scrollToRowAtIndexPath:indexOfOutOfWindowCell atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Methods

-(NSArray *)formValidationErrors
{
    return [self.form localValidationErrors:self];
}

-(void)showFormValidationError:(NSError *)error
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NMFormViewController_ValidationErrorTitle", nil)
                                                                              message:error.localizedDescription
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)showFormValidationError:(NSError *)error withTitle:(NSString*)title
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil)
                                                                              message:error.localizedDescription
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)performFormSelector:(SEL)selector withObject:(id)sender
{
    UIResponder * responder = [self targetForAction:selector withSender:sender];;
    if (responder) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
        [responder performSelector:selector withObject:sender];
#pragma GCC diagnostic pop
    }
}

#pragma mark - Private

- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    UIView * firstResponderView = [self.tableView findFirstResponder];
    UITableViewCell<NMFormDescriptorCell> * cell = [firstResponderView formDescriptorCell];
    if (cell){
        NSDictionary *keyboardInfo = [notification userInfo];
        _keyboardFrame = [self.tableView.window convertRect:[keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.tableView.superview];
        CGFloat newBottomInset = self.tableView.frame.origin.y + self.tableView.frame.size.height - _keyboardFrame.origin.y;
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        _oldBottomTableContentInset = _oldBottomTableContentInset ?: @(tableContentInset.bottom);
        if (newBottomInset > [_oldBottomTableContentInset floatValue]){
            tableContentInset.bottom = newBottomInset;
            tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
            [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
            self.tableView.contentInset = tableContentInset;
            self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
            NSIndexPath *selectedRow = [self.tableView indexPathForCell:cell];
            [self.tableView scrollToRowAtIndexPath:selectedRow atScrollPosition:UITableViewScrollPositionNone animated:NO];
            [UIView commitAnimations];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    UIView * firstResponderView = [self.tableView findFirstResponder];
    UITableViewCell<NMFormDescriptorCell> * cell = [firstResponderView formDescriptorCell];
    if (cell){
        _keyboardFrame = CGRectZero;
        NSDictionary *keyboardInfo = [notification userInfo];
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        tableContentInset.bottom = [_oldBottomTableContentInset floatValue];
        tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
        _oldBottomTableContentInset = nil;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
        self.tableView.contentInset = tableContentInset;
        self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
        [UIView commitAnimations];
    }
}

#pragma mark - Helpers

-(void)deselectFormRow:(NMFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)reloadFormRow:(NMFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(NMFormBaseCell *)updateFormRow:(NMFormRowDescriptor *)formRow
{
    NMFormBaseCell * cell = [formRow cellForFormController:self];
    if (cell != nil) {
        [self configureCell:cell];
        [cell setNeedsUpdateConstraints];
        [cell setNeedsLayout];
    }
    return cell;
}

-(void)configureCell:(NMFormBaseCell*) cell
{
    [cell update];

    if(cell.rowDescriptor != nil && cell.rowDescriptor.cellConfig != nil) {
        [cell.rowDescriptor.cellConfig enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, BOOL * __unused stop) {
            [cell setValue:(value == [NSNull null]) ? nil : value forKeyPath:keyPath];
        }];
    }

    if (cell.rowDescriptor.isDisabled){
        [cell.rowDescriptor.cellConfigIfDisabled enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, BOOL * __unused stop) {
            [cell setValue:(value == [NSNull null]) ? nil : value forKeyPath:keyPath];
        }];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.form.formSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section >= self.form.formSections.count){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"" userInfo:nil];
    }
    return [[[self.form.formSections objectAtIndex:section] formRows] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:indexPath];
    [self updateFormRow:rowDescriptor];
    return [rowDescriptor cellForFormController:self];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    if (rowDescriptor.isDisabled || !rowDescriptor.sectionDescriptor.isMultivaluedSection){
        return NO;
    }
    NMFormBaseCell * baseCell = [rowDescriptor cellForFormController:self];
    if ([baseCell conformsToProtocol:@protocol(NMFormInlineRowDescriptorCell)] && ((id<NMFormInlineRowDescriptorCell>)baseCell).inlineRowDescriptor){
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    NMFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    NMFormSectionDescriptor * section = rowDescriptor.sectionDescriptor;
    if (section.sectionOptions & NMFormSectionOptionCanReorder && section.formRows.count > 1) {
        if (section.sectionInsertMode == NMFormSectionInsertModeButton && section.sectionOptions & NMFormSectionOptionCanInsert){
            if (section.formRows.count <= 2 || rowDescriptor == section.multivaluedAddButton){
                return NO;
            }
        }
        NMFormBaseCell * baseCell = [rowDescriptor cellForFormController:self];
        return !([baseCell conformsToProtocol:@protocol(NMFormInlineRowDescriptorCell)] && ((id<NMFormInlineRowDescriptorCell>)baseCell).inlineRowDescriptor);
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NMFormRowDescriptor * row = [self.form formRowAtIndex:sourceIndexPath];
    NMFormSectionDescriptor * section = row.sectionDescriptor;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
    [section performSelector:NSSelectorFromString(@"moveRowAtIndexPath:toIndexPath:") withObject:sourceIndexPath withObject:destinationIndexPath];
#pragma GCC diagnostic pop
    // update the accessory view
    [self inputAccessoryViewForRowDescriptor:row];
    __weak typeof(self) weak = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weak.tableView.editing = !weak.tableView.editing;
        weak.tableView.editing = !weak.tableView.editing;
    });

}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NMFormRowDescriptor * multivaluedFormRow = [self.form formRowAtIndex:indexPath];
        // end editing
        UIView * firstResponder = [[multivaluedFormRow cellForFormController:self] findFirstResponder];
        if (firstResponder){
                [self.tableView endEditing:YES];
        }
        [multivaluedFormRow.sectionDescriptor removeFormRowAtIndex:indexPath.row];
        __weak typeof(self) weak = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weak.tableView.editing = !weak.tableView.editing;
            weak.tableView.editing = !weak.tableView.editing;
        });
        if (firstResponder){
            UITableViewCell<NMFormDescriptorCell> * firstResponderCell = [firstResponder formDescriptorCell];
            NMFormRowDescriptor * rowDescriptor = firstResponderCell.rowDescriptor;
            [self inputAccessoryViewForRowDescriptor:rowDescriptor];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert){

        NMFormSectionDescriptor * multivaluedFormSection = [self.form formSectionAtIndex:indexPath.section];
        if (multivaluedFormSection.sectionInsertMode == NMFormSectionInsertModeButton && multivaluedFormSection.sectionOptions & NMFormSectionOptionCanInsert){
            [self multivaluedInsertButtonTapped:multivaluedFormSection.multivaluedAddButton];
        }
        else{
            NMFormRowDescriptor * formRowDescriptor = [self formRowFormMultivaluedFormSection:multivaluedFormSection];
            [multivaluedFormSection addFormRow:formRowDescriptor];
            __weak typeof(self) weak = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weak.tableView.editing = !weak.tableView.editing;
                weak.tableView.editing = !weak.tableView.editing;
            });
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[formRowDescriptor cellForFormController:self];
            if ([cell formDescriptorCellCanBecomeFirstResponder]){
                [cell formDescriptorCellBecomeFirstResponder];
            }
        }
    }
}

#pragma mark - UITableViewDelegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] title];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[self.form.formSections objectAtIndex:section] footerTitle];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    [rowDescriptor cellForFormController:self];
    CGFloat height = rowDescriptor.height;
    if (height != NMFormUnspecifiedCellHeight){
        return height;
    }
    return self.tableView.rowHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor *rowDescriptor = [self.form formRowAtIndex:indexPath];
    [rowDescriptor cellForFormController:self];
    CGFloat height = rowDescriptor.height;
    if (height != NMFormUnspecifiedCellHeight){
        return height;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        return self.tableView.estimatedRowHeight;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor * row = [self.form formRowAtIndex:indexPath];
    if (row.isDisabled) {
        return;
    }
    UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[row cellForFormController:self];
    if (!([cell formDescriptorCellCanBecomeFirstResponder] && [cell formDescriptorCellBecomeFirstResponder])){
        [self.tableView endEditing:YES];
    }
    [self didSelectFormRow:row];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMFormRowDescriptor * row = [self.form formRowAtIndex:indexPath];
    NMFormSectionDescriptor * section = row.sectionDescriptor;
    if (section.sectionOptions & NMFormSectionOptionCanInsert){
        if (section.formRows.count == indexPath.row + 2){
            if ([[NMFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:row.rowType]){
                UITableViewCell<NMFormDescriptorCell> * cell = [row cellForFormController:self];
                UIView * firstResponder = [cell findFirstResponder];
                if (firstResponder){
                    return UITableViewCellEditingStyleInsert;
                }
            }
        }
        else if (section.formRows.count == (indexPath.row + 1)){
            return UITableViewCellEditingStyleInsert;
        }
    }
    if (section.sectionOptions & NMFormSectionOptionCanDelete){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return sourceIndexPath;
    }
    NMFormSectionDescriptor * sectionDescriptor = [self.form formSectionAtIndex:sourceIndexPath.section];
    NMFormRowDescriptor * proposedDestination = [sectionDescriptor.formRows objectAtIndex:proposedDestinationIndexPath.row];
    NMFormBaseCell * proposedDestinationCell = [proposedDestination cellForFormController:self];
    if (([proposedDestinationCell conformsToProtocol:@protocol(NMFormInlineRowDescriptorCell)] && ((id<NMFormInlineRowDescriptorCell>)proposedDestinationCell).inlineRowDescriptor) || ([[NMFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:proposedDestinationCell.rowDescriptor.rowType] && [[proposedDestinationCell findFirstResponder] formDescriptorCell] == proposedDestinationCell)) {
        if (sourceIndexPath.row < proposedDestinationIndexPath.row){
            return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row + 1 inSection:sourceIndexPath.section];
        }
        else{
            return [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row - 1 inSection:sourceIndexPath.section];
        }
    }

    if ((sectionDescriptor.sectionInsertMode == NMFormSectionInsertModeButton && sectionDescriptor.sectionOptions & NMFormSectionOptionCanInsert)){
        if (proposedDestinationIndexPath.row == sectionDescriptor.formRows.count - 1){
            return [NSIndexPath indexPathForRow:(sectionDescriptor.formRows.count - 2) inSection:sourceIndexPath.section];
        }
    }
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle editingStyle = [self tableView:tableView editingStyleForRowAtIndexPath:indexPath];
    if (editingStyle == UITableViewCellEditingStyleNone){
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
    // end editing if inline cell is first responder
    UITableViewCell<NMFormDescriptorCell> * cell = [[self.tableView findFirstResponder] formDescriptorCell];
    if ([[self.form indexPathOfFormRow:cell.rowDescriptor] isEqual:indexPath]){
        if ([[NMFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:cell.rowDescriptor.rowType]){
            [self.tableView endEditing:YES];
        }
    }
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // called when 'return' key pressed. return NO to ignore.
    UITableViewCell<NMFormDescriptorCell> * cell = [textField formDescriptorCell];
    NMFormRowDescriptor * currentRow = cell.rowDescriptor;
    NMFormRowDescriptor * nextRow = [self nextRowDescriptorForRow:currentRow
                                                    withDirection:NMFormRowNavigationDirectionNext];
    if (nextRow){
        UITableViewCell<NMFormDescriptorCell> * nextCell = (UITableViewCell<NMFormDescriptorCell> *)[nextRow cellForFormController:self];
        if ([nextCell formDescriptorCellCanBecomeFirstResponder]){
            [nextCell formDescriptorCellBecomeFirstResponder];
            return YES;
        }
    }
    [self.tableView endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UITableViewCell<NMFormDescriptorCell>* cell = textField.formDescriptorCell;
    NMFormRowDescriptor * nextRow     = [self nextRowDescriptorForRow:textField.formDescriptorCell.rowDescriptor
                                                        withDirection:NMFormRowNavigationDirectionNext];
    
    
    if ([cell conformsToProtocol:@protocol(NMFormReturnKeyProtocol)]) {
        textField.returnKeyType = nextRow ? ((id<NMFormReturnKeyProtocol>)cell).nextReturnKeyType : ((id<NMFormReturnKeyProtocol>)cell).returnKeyType;
    }
    else {
        textField.returnKeyType = nextRow ? UIReturnKeyNext : UIReturnKeyDefault;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //dismiss keyboard
    if (NO == self.form.endEditingTableViewOnScroll) {
        return;
    }

    UIView * firstResponder = [self.tableView findFirstResponder];
    if ([firstResponder conformsToProtocol:@protocol(NMFormDescriptorCell)]){
        id<NMFormDescriptorCell> cell = (id<NMFormDescriptorCell>)firstResponder;
        if ([[NMFormViewController inlineRowDescriptorTypesForRowDescriptorTypes].allKeys containsObject:cell.rowDescriptor.rowType]){
            return;
        }
    }
    [self.tableView endEditing:YES];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[NMFormRowDescriptor class]]){
        UIViewController * destinationViewController = segue.destinationViewController;
        NMFormRowDescriptor * rowDescriptor = (NMFormRowDescriptor *)sender;
        if (rowDescriptor.rowType == NMFormRowDescriptorTypeSelectorPush || rowDescriptor.rowType == NMFormRowDescriptorTypeSelectorPopover){
            NSAssert([destinationViewController conformsToProtocol:@protocol(NMFormRowDescriptorViewController)], @"Segue destinationViewController must conform to NMFormRowDescriptorViewController protocol");
            UIViewController<NMFormRowDescriptorViewController> * rowDescriptorViewController = (UIViewController<NMFormRowDescriptorViewController> *)destinationViewController;
            rowDescriptorViewController.rowDescriptor = rowDescriptor;
        }
        else if ([destinationViewController conformsToProtocol:@protocol(NMFormRowDescriptorViewController)]){
            UIViewController<NMFormRowDescriptorViewController> * rowDescriptorViewController = (UIViewController<NMFormRowDescriptorViewController> *)destinationViewController;
            rowDescriptorViewController.rowDescriptor = rowDescriptor;
        }
    }
}

#pragma mark - Navigation Between Fields


-(void)rowNavigationAction:(UIBarButtonItem *)sender
{
    [self navigateToDirection:(sender == self.navigationAccessoryView.nextButton ? NMFormRowNavigationDirectionNext : NMFormRowNavigationDirectionPrevious)];
}

-(void)rowNavigationDone:(UIBarButtonItem *)sender
{
    [self.tableView endEditing:YES];
}

-(void)navigateToDirection:(NMFormRowNavigationDirection)direction
{
    UIView * firstResponder = [self.tableView findFirstResponder];
    UITableViewCell<NMFormDescriptorCell> * currentCell = [firstResponder formDescriptorCell];
    NSIndexPath * currentIndexPath = [self.tableView indexPathForCell:currentCell];
    NMFormRowDescriptor * currentRow = [self.form formRowAtIndex:currentIndexPath];
    NMFormRowDescriptor * nextRow = [self nextRowDescriptorForRow:currentRow withDirection:direction];
    if (nextRow) {
        UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[nextRow cellForFormController:self];
        if ([cell formDescriptorCellCanBecomeFirstResponder]){
            NSIndexPath * indexPath = [self.form indexPathOfFormRow:nextRow];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            [cell formDescriptorCellBecomeFirstResponder];
        }
    }
}

-(NMFormRowDescriptor *)nextRowDescriptorForRow:(NMFormRowDescriptor*)currentRow withDirection:(NMFormRowNavigationDirection)direction
{
    if (!currentRow || (self.form.rowNavigationOptions & NMFormRowNavigationOptionEnabled) != NMFormRowNavigationOptionEnabled) {
        return nil;
    }
    NMFormRowDescriptor * nextRow = (direction == NMFormRowNavigationDirectionNext) ? [self.form nextRowDescriptorForRow:currentRow] : [self.form previousRowDescriptorForRow:currentRow];
    if (!nextRow) {
        return nil;
    }
    if ([[nextRow cellForFormController:self] conformsToProtocol:@protocol(NMFormInlineRowDescriptorCell)]) {
        id<NMFormInlineRowDescriptorCell> inlineCell = (id<NMFormInlineRowDescriptorCell>)[nextRow cellForFormController:self];
        if (inlineCell.inlineRowDescriptor){
            return [self nextRowDescriptorForRow:nextRow withDirection:direction];
        }
    }
    NMFormRowNavigationOptions rowNavigationOptions = self.form.rowNavigationOptions;
    if (nextRow.isDisabled && ((rowNavigationOptions & NMFormRowNavigationOptionStopDisableRow) == NMFormRowNavigationOptionStopDisableRow)){
        return nil;
    }
    if (!nextRow.isDisabled && ((rowNavigationOptions & NMFormRowNavigationOptionStopInlineRow) == NMFormRowNavigationOptionStopInlineRow) && [[[NMFormViewController inlineRowDescriptorTypesForRowDescriptorTypes] allKeys] containsObject:nextRow.rowType]){
        return nil;
    }
    UITableViewCell<NMFormDescriptorCell> * cell = (UITableViewCell<NMFormDescriptorCell> *)[nextRow cellForFormController:self];
    if (!nextRow.isDisabled && ((rowNavigationOptions & NMFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow) != NMFormRowNavigationOptionSkipCanNotBecomeFirstResponderRow) && (![cell formDescriptorCellCanBecomeFirstResponder])){
        return nil;
    }
    if (!nextRow.isDisabled && [cell formDescriptorCellCanBecomeFirstResponder]){
        return nextRow;
    }
    return [self nextRowDescriptorForRow:nextRow withDirection:direction];
}

#pragma mark - properties

-(void)setForm:(NMFormDescriptor *)form
{
    _form.delegate = nil;
    [self.tableView endEditing:YES];
    _form = form;
    _form.delegate = self;
    [_form forceEvaluate];
    if ([self isViewLoaded]){
        [self.tableView reloadData];
    }
}

-(NMFormDescriptor *)form
{
    return _form;
}

-(NMFormRowNavigationAccessoryView *)navigationAccessoryView
{
    if (_navigationAccessoryView) return _navigationAccessoryView;
    _navigationAccessoryView = [NMFormRowNavigationAccessoryView new];
    _navigationAccessoryView.previousButton.target = self;
    _navigationAccessoryView.previousButton.action = @selector(rowNavigationAction:);
    _navigationAccessoryView.nextButton.target = self;
    _navigationAccessoryView.nextButton.action = @selector(rowNavigationAction:);
    _navigationAccessoryView.doneButton.target = self;
    _navigationAccessoryView.doneButton.action = @selector(rowNavigationDone:);
    _navigationAccessoryView.tintColor = self.view.tintColor;
    return _navigationAccessoryView;
}

@end

