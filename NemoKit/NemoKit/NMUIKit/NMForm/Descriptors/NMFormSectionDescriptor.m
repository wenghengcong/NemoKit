//
//  NMFormSectionDescriptor.m
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

#import "NMForm.h"
#import "NMFormSectionDescriptor.h"
#import "NSPredicate+NMFormAdditions.h"
#import "NSString+NMFormAdditions.h"
#import "UIView+NMFormAdditions.h"

NSString * const NMFormRowsKey = @"formRows";

@interface NMFormDescriptor (_NMFormSectionDescriptor)

@property (nonatomic, weak, readonly) NSDictionary *allRowsByTag;

-(void)addRowToTagCollection:(NMFormRowDescriptor *)rowDescriptor;
-(void)removeRowFromTagCollection:(NMFormRowDescriptor *) rowDescriptor;
-(void)showFormSection:(NMFormSectionDescriptor *)formSection;
-(void)hideFormSection:(NMFormSectionDescriptor *)formSection;

-(void)addObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType;
-(void)removeObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType;

@end

@interface NMFormSectionDescriptor()

@property (nonatomic, strong) NSMutableArray *formRows;
@property (nonatomic, strong) NSMutableArray *allRows;

@property (nonatomic, assign) BOOL isDirtyHidePredicateCache;
@property (nonatomic, copy  ) NSNumber *hidePredicateCache;

@end

@implementation NMFormSectionDescriptor

@synthesize hidden = _hidden;
@synthesize hidePredicateCache = _hidePredicateCache;

-(instancetype)init
{
    if (self = [super init]) {
        _formRows = [NSMutableArray array];
        _allRows = [NSMutableArray array];
        _sectionInsertMode = NMFormSectionInsertModeLastRow;
        _sectionOptions = NMFormSectionOptionNone;
        _title = nil;
        _footerTitle = nil;
        _hidden = @NO;
        _hidePredicateCache = @NO;
        _isDirtyHidePredicateCache = YES;
        
        [self addObserver:self
               forKeyPath:NMFormRowsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:0];
    }
    
    return self;
}

-(instancetype)initWithTitle:(NSString *)title sectionOptions:(NMFormSectionOptions)sectionOptions sectionInsertMode:(NMFormSectionInsertMode)sectionInsertMode
{
    if (self = [self init]) {
        _sectionInsertMode = sectionInsertMode;
        _sectionOptions = sectionOptions;
        _title = title;
        
        if ([self canInsertUsingButton]) {
            _multivaluedAddButton = [NMFormRowDescriptor formRowDescriptorWithTag:nil
                                                                          rowType:NMFormRowDescriptorTypeButton
                                                                            title:@"Add Item"];
            
            [_multivaluedAddButton.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
            _multivaluedAddButton.action.formSelector = NSSelectorFromString(@"multivaluedInsertButtonTapped:");
            
            [self insertObject:_multivaluedAddButton inFormRowsAtIndex:0];
            [self insertObject:_multivaluedAddButton inAllRowsAtIndex:0];
        }
    }
    
    return self;
}

+(instancetype)formSection
{
    return [[self class] formSectionWithTitle:nil];
}

+(instancetype)formSectionWithTitle:(NSString *)title
{
    return [[self class] formSectionWithTitle:title sectionOptions:NMFormSectionOptionNone];
}

+(instancetype)formSectionWithTitle:(NSString *)title multivaluedSection:(BOOL)multivaluedSection
{
    return [[self class] formSectionWithTitle:title sectionOptions:(multivaluedSection ? NMFormSectionOptionCanInsert | NMFormSectionOptionCanDelete : NMFormSectionOptionNone)];
}

+(instancetype)formSectionWithTitle:(NSString *)title sectionOptions:(NMFormSectionOptions)sectionOptions
{
    return [[self class] formSectionWithTitle:title sectionOptions:sectionOptions sectionInsertMode:NMFormSectionInsertModeLastRow];
}

+(instancetype)formSectionWithTitle:(NSString *)title sectionOptions:(NMFormSectionOptions)sectionOptions sectionInsertMode:(NMFormSectionInsertMode)sectionInsertMode
{
    return [[[self class] alloc] initWithTitle:title sectionOptions:sectionOptions sectionInsertMode:sectionInsertMode];
}

-(BOOL)isMultivaluedSection
{
    return (self.sectionOptions != NMFormSectionOptionNone);
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow
{
    NSUInteger index = [self.allRows count];
    
    if ([self canInsertUsingButton]) {
        index = ([self.formRows count] > 0) ? [self.formRows count] - 1 : 0;
    }
    
    [self insertObject:formRow inAllRowsAtIndex:index];
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow afterRow:(NMFormRowDescriptor *)afterRow
{
    NSUInteger allRowIndex = [self.allRows indexOfObject:afterRow];
    if (allRowIndex != NSNotFound) {
        [self insertObject:formRow inAllRowsAtIndex:allRowIndex+1];
    }
    else { //case when afterRow does not exist. Just insert at the end.
        [self addFormRow:formRow];
    }
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow beforeRow:(NMFormRowDescriptor *)beforeRow
{
    NSUInteger allRowIndex = [self.allRows indexOfObject:beforeRow];
    if (allRowIndex != NSNotFound) {
        [self insertObject:formRow inAllRowsAtIndex:allRowIndex];
    }
    else { //case when afterRow does not exist. Just insert at the end.
        [self addFormRow:formRow];
    }
}

-(void)removeFormRowAtIndex:(NSUInteger)index
{
    if (self.formRows.count > index) {
        NMFormRowDescriptor *formRow = [self.formRows objectAtIndex:index];
        NSUInteger allRowIndex = [self.allRows indexOfObject:formRow];
        [self removeObjectFromFormRowsAtIndex:index];
        [self removeObjectFromAllRowsAtIndex:allRowIndex];
    }
}

-(void)removeFormRow:(NMFormRowDescriptor *)formRow
{
    NSUInteger index = NSNotFound;
    if ((index = [self.formRows indexOfObject:formRow]) != NSNotFound) {
        [self removeFormRowAtIndex:index];
    }
    else if ((index = [self.allRows indexOfObject:formRow]) != NSNotFound) {
        if (self.allRows.count > index) {
            [self removeObjectFromAllRowsAtIndex:index];
        }
    }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)sourceIndex toIndexPath:(NSIndexPath *)destinationIndex
{
    if ((sourceIndex.row < self.formRows.count) && (destinationIndex.row < self.formRows.count) && (sourceIndex.row != destinationIndex.row)) {
        NMFormRowDescriptor *row = [self objectInFormRowsAtIndex:sourceIndex.row];
        NMFormRowDescriptor *destRow = [self objectInFormRowsAtIndex:destinationIndex.row];
        [self.formRows removeObjectAtIndex:sourceIndex.row];
        [self.formRows insertObject:row atIndex:destinationIndex.row];
        
        [self.allRows removeObjectAtIndex:[self.allRows indexOfObject:row]];
        [self.allRows insertObject:row atIndex:[self.allRows indexOfObject:destRow]];
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:NMFormRowsKey];
    
    [self.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeHidden];
    
    [self.formRows removeAllObjects];
    self.formRows = nil;
    
    [self.allRows removeAllObjects];
    self.allRows = nil;
}

#pragma mark - Show/hide rows

-(void)showFormRow:(NMFormRowDescriptor*)formRow{
    
    NSUInteger formIndex = [self.formRows indexOfObject:formRow];
    if (formIndex != NSNotFound) {
        return;
    }
    
    NSUInteger index = [self.allRows indexOfObject:formRow];
    if (index != NSNotFound) {
        while (formIndex == NSNotFound && index > 0) {
            NMFormRowDescriptor* previous = [self.allRows objectAtIndex:--index];
            formIndex = [self.formRows indexOfObject:previous];
        }
        
        if (formIndex == NSNotFound) { // index == 0 => insert at the beginning
            [self insertObject:formRow inFormRowsAtIndex:0];
        }
        else {
            [self insertObject:formRow inFormRowsAtIndex:formIndex+1];
        }
        
    }
}

-(void)hideFormRow:(NMFormRowDescriptor*)formRow{
    NSUInteger index = [self.formRows indexOfObject:formRow];
    if (index != NSNotFound) {
        [self removeObjectFromFormRowsAtIndex:index];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
    if (!self.formDescriptor.delegate) {
        return;
    }
    else if ([keyPath isEqualToString:NMFormRowsKey]) {
        if ([self.formDescriptor.formSections containsObject:self]) {
            if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
                NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
                NMFormRowDescriptor *formRow = [((NMFormSectionDescriptor *)object).formRows objectAtIndex:indexSet.firstIndex];
                NSUInteger sectionIndex = [self.formDescriptor.formSections indexOfObject:object];
                [self.formDescriptor.delegate formRowHasBeenAdded:formRow
                                                      atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
            }
            else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]) {
                NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
                NMFormRowDescriptor *removedRow = [[change objectForKey:NSKeyValueChangeOldKey] objectAtIndex:0];
                NSUInteger sectionIndex = [self.formDescriptor.formSections indexOfObject:object];
                [self.formDescriptor.delegate formRowHasBeenRemoved:removedRow
                                                        atIndexPath:[NSIndexPath indexPathForRow:indexSet.firstIndex inSection:sectionIndex]];
            }
        }
    }
}

#pragma mark - KVC

-(NSUInteger)countOfFormRows
{
    return self.formRows.count;
}

- (id)objectInFormRowsAtIndex:(NSUInteger)index
{
    return [self.formRows objectAtIndex:index];
}

- (NSArray *)formRowsAtIndexes:(NSIndexSet *)indexes
{
    return [self.formRows objectsAtIndexes:indexes];
}

- (void)insertObject:(NMFormRowDescriptor *)formRow inFormRowsAtIndex:(NSUInteger)index
{
    formRow.sectionDescriptor = self;
    [self.formRows insertObject:formRow atIndex:index];
}

- (void)removeObjectFromFormRowsAtIndex:(NSUInteger)index
{
    [self.formRows removeObjectAtIndex:index];
}

#pragma mark - KVC ALL

-(NSUInteger)countOfAllRows
{
    return self.allRows.count;
}

- (id)objectInAllRowsAtIndex:(NSUInteger)index
{
    return [self.allRows objectAtIndex:index];
}

- (NSArray *)allRowsAtIndexes:(NSIndexSet *)indexes
{
    return [self.allRows objectsAtIndexes:indexes];
}

- (void)insertObject:(NMFormRowDescriptor *)row inAllRowsAtIndex:(NSUInteger)index
{
    row.sectionDescriptor = self;
    [self.formDescriptor addRowToTagCollection:row];
    [self.allRows insertObject:row atIndex:index];
    row.disabled = row.disabled;
    row.hidden = row.hidden;
}

- (void)removeObjectFromAllRowsAtIndex:(NSUInteger)index
{
    NMFormRowDescriptor * row = [self.allRows objectAtIndex:index];
    [self.formDescriptor removeRowFromTagCollection:row];
    [self.formDescriptor removeObserversOfObject:row predicateType:NMPredicateTypeDisabled];
    [self.formDescriptor removeObserversOfObject:row predicateType:NMPredicateTypeHidden];
    [self.allRows removeObjectAtIndex:index];
}

#pragma mark - Helpers

-(BOOL)canInsertUsingButton
{
    return (self.sectionInsertMode == NMFormSectionInsertModeButton && self.sectionOptions & NMFormSectionOptionCanInsert);
}

#pragma mark - Predicates


-(NSNumber *)hidePredicateCache
{
    return _hidePredicateCache;
}

-(void)setHidePredicateCache:(NSNumber *)hidePredicateCache
{
    NSParameterAssert(hidePredicateCache != nil);
    self.isDirtyHidePredicateCache = NO;
    if (_hidePredicateCache == nil || ![_hidePredicateCache isEqualToNumber:hidePredicateCache]) {
        _hidePredicateCache = hidePredicateCache;
    }
}

-(BOOL)isHidden
{
    if (self.isDirtyHidePredicateCache) {
        return [self evaluateIsHidden];
    }
    
    return [self.hidePredicateCache boolValue];
}

-(BOOL)evaluateIsHidden
{
    if ([_hidden isKindOfClass:[NSPredicate class]]) {
        if (!self.formDescriptor) {
            self.isDirtyHidePredicateCache = YES;
        }
        else {
            @try {
                self.hidePredicateCache = @([_hidden evaluateWithObject:self substitutionVariables:self.formDescriptor.allRowsByTag ?: @{}]);
            }
            @catch (NSException *exception) {
                // predicate syntax error.
                self.isDirtyHidePredicateCache = YES;
            };
        }
    }
    else {
        self.hidePredicateCache = _hidden;
    }
    
    if ([self.hidePredicateCache boolValue]) {
        if ([self.formDescriptor.delegate isKindOfClass:[NMFormViewController class]]) {
            NMFormBaseCell *firtResponder = (NMFormBaseCell *)[((NMFormViewController *)self.formDescriptor.delegate).tableView findFirstResponder];
            if ([firtResponder isKindOfClass:[NMFormBaseCell class]] && firtResponder.rowDescriptor.sectionDescriptor == self) {
                [firtResponder resignFirstResponder];
            }
        }
        
        [self.formDescriptor hideFormSection:self];
    }
    else {
        [self.formDescriptor showFormSection:self];
    }
    
    return [self.hidePredicateCache boolValue];
}


-(id)hidden
{
    return _hidden;
}

-(void)setHidden:(id)hidden
{
    if ([_hidden isKindOfClass:[NSPredicate class]]) {
        [self.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeHidden];
    }
    
    _hidden = [hidden isKindOfClass:[NSString class]] ? [hidden formPredicate] : hidden;
    if ([_hidden isKindOfClass:[NSPredicate class]]) {
        [self.formDescriptor addObserversOfObject:self predicateType:NMPredicateTypeHidden];
    }
    
    [self evaluateIsHidden]; // check and update if this row should be hidden.
}

@end
