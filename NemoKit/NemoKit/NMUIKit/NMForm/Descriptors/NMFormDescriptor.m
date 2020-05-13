//
//  NMFormDescriptor.m
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


#import "NSObject+NMFormAdditions.h"
#import "NMFormDescriptor.h"
#import "NSPredicate+NMFormAdditions.h"
#import "NSString+NMFormAdditions.h"

NSString * const NMFormErrorDomain = @"NMFormErrorDomain";
NSString * const NMValidationStatusErrorKey = @"NMValidationStatusErrorKey";

NSString * const NMFormSectionsKey = @"formSections";


@interface NMFormSectionDescriptor (_NMFormDescriptor)

@property (nonatomic, weak) NSArray *allRows;

-(BOOL)evaluateIsHidden;

@end


@interface NMFormRowDescriptor(_NMFormDescriptor)

-(BOOL)evaluateIsDisabled;
-(BOOL)evaluateIsHidden;

@end


@interface NMFormDescriptor()

@property (nonatomic, strong) NSMutableArray *formSections;
@property (nonatomic, strong, readonly) NSMutableArray *allSections;
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, strong, readonly) NSMutableDictionary *allRowsByTag;
@property (atomic   , strong) NSMutableDictionary *rowObservers;

@end

@implementation NMFormDescriptor

-(instancetype)init
{
    return [self initWithTitle:@""];
}

-(instancetype)initWithTitle:(NSString *)title;
{
    if (self = [super init]) {
        _formSections = [NSMutableArray array];
        _allSections  = [NSMutableArray array];
        _allRowsByTag = [NSMutableDictionary dictionary];
        _rowObservers = [NSMutableDictionary dictionary];
        _title = title;
        _addAsteriskToRequiredRowsTitle = NO;
        _disabled = NO;
        _endEditingTableViewOnScroll = YES;
        _rowNavigationOptions = NMFormRowNavigationOptionEnabled;
        
        [self addObserver:self
               forKeyPath:NMFormSectionsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:0];
    }
    
    return self;
}

+(instancetype)formDescriptor
{
    return [[self class] formDescriptorWithTitle:@""];
}

+(instancetype)formDescriptorWithTitle:(NSString *)title
{
    return [[[self class] alloc] initWithTitle:title];
}

-(void)addFormSection:(NMFormSectionDescriptor *)formSection
{
    [self insertObject:formSection inAllSectionsAtIndex:[self.allSections count]];
}

-(void)addFormSection:(NMFormSectionDescriptor *)formSection atIndex:(NSUInteger)index
{
    if (index == 0) {
        [self insertObject:formSection inAllSectionsAtIndex:0];
    }
    else {
        NMFormSectionDescriptor *previousSection = [self.formSections objectAtIndex:MIN(self.formSections.count, index-1)];
        [self addFormSection:formSection afterSection:previousSection];
    }
}

-(void)addFormSection:(NMFormSectionDescriptor *)formSection afterSection:(NMFormSectionDescriptor *)afterSection
{
    NSUInteger sectionIndex;
    NSUInteger allSectionIndex;
    if ((sectionIndex = [self.allSections indexOfObject:formSection]) == NSNotFound) {
        allSectionIndex = [self.allSections indexOfObject:afterSection];
        if (allSectionIndex != NSNotFound) {
            [self insertObject:formSection inAllSectionsAtIndex:(allSectionIndex + 1)];
        }
        else { //case when afterSection does not exist. Just insert at the end.
            [self addFormSection:formSection];
            
            return;
        }
    }
    
    formSection.hidden = formSection.hidden;
}


-(void)addFormRow:(NMFormRowDescriptor *)formRow beforeRow:(NMFormRowDescriptor *)beforeRow
{
    if (beforeRow.sectionDescriptor) {
        [beforeRow.sectionDescriptor addFormRow:formRow beforeRow:beforeRow];
    }
    else {
        [[self.allSections lastObject] addFormRow:formRow beforeRow:beforeRow];
    }
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow beforeRowTag:(NSString *)beforeRowTag
{
    NMFormRowDescriptor * beforeRowForm = [self formRowWithTag:beforeRowTag];
    [self addFormRow:formRow beforeRow:beforeRowForm];
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow afterRow:(NMFormRowDescriptor *)afterRow
{
    if (afterRow.sectionDescriptor) {
        [afterRow.sectionDescriptor addFormRow:formRow afterRow:afterRow];
    }
    else {
        [[self.allSections lastObject] addFormRow:formRow afterRow:afterRow];
    }
}

-(void)addFormRow:(NMFormRowDescriptor *)formRow afterRowTag:(NSString *)afterRowTag
{
    NMFormRowDescriptor *afterRowForm = [self formRowWithTag:afterRowTag];
    [self addFormRow:formRow afterRow:afterRowForm];
}

-(void)removeFormSectionAtIndex:(NSUInteger)index
{
    if (self.formSections.count > index) {
        NMFormSectionDescriptor *formSection = [self.formSections objectAtIndex:index];
        [self removeObjectFromFormSectionsAtIndex:index];
        NSUInteger allSectionIndex = [self.allSections indexOfObject:formSection];
        [self removeObjectFromAllSectionsAtIndex:allSectionIndex];
    }
}

-(void)removeFormSection:(NMFormSectionDescriptor *)formSection
{
    NSUInteger index = NSNotFound;
    if ((index = [self.formSections indexOfObject:formSection]) != NSNotFound) {
        [self removeFormSectionAtIndex:index];
    }
    if ((index = [self.allSections indexOfObject:formSection]) != NSNotFound) {
        [self removeObjectFromAllSectionsAtIndex:index];
    }
}

-(void)removeFormRow:(NMFormRowDescriptor *)formRow
{
    for (NMFormSectionDescriptor *section in self.formSections) {
        if ([section.formRows containsObject:formRow]) {
            [section removeFormRow:formRow];
            
            break;
        }
    }
}

-(void)showFormSection:(NMFormSectionDescriptor *)formSection
{
    NSUInteger formIndex = [self.formSections indexOfObject:formSection];
    if (formIndex != NSNotFound) {
        return;
    }
    
    NSUInteger index = [self.allSections indexOfObject:formSection];
    if (index != NSNotFound) {
        while (formIndex == NSNotFound && index > 0) {
            NMFormSectionDescriptor* previous = [self.allSections objectAtIndex:--index];
            formIndex = [self.formSections indexOfObject:previous];
        }
        
        [self insertObject:formSection inFormSectionsAtIndex:(formIndex == NSNotFound ? 0 : ++formIndex)];
    }
}

-(void)hideFormSection:(NMFormSectionDescriptor *)formSection
{
    NSUInteger index = [self.formSections indexOfObject:formSection];
    if (index != NSNotFound) {
        [self removeObjectFromFormSectionsAtIndex:index];
    }
}


-(NMFormRowDescriptor *)formRowWithTag:(NSString *)tag
{
    return self.allRowsByTag[tag];
}

-(NMFormRowDescriptor *)formRowWithHash:(NSUInteger)hash
{
    for (NMFormSectionDescriptor *section in self.allSections) {
        for (NMFormRowDescriptor *row in section.allRows) {
            if ([row hash] == hash) {
                return row;
            }
        }
    }
    
    return nil;
}

-(void)removeFormRowWithTag:(NSString *)tag
{
    NMFormRowDescriptor *formRow = [self formRowWithTag:tag];
    [self removeFormRow:formRow];
}

-(NMFormRowDescriptor *)formRowAtIndex:(NSIndexPath *)indexPath
{
    if ((self.formSections.count > indexPath.section) && [[self.formSections objectAtIndex:indexPath.section] formRows].count > indexPath.row) {
        return [[[self.formSections objectAtIndex:indexPath.section] formRows] objectAtIndex:indexPath.row];
    }
    
    return nil;
}

-(NMFormSectionDescriptor *)formSectionAtIndex:(NSUInteger)index
{
    return [self objectInFormSectionsAtIndex:index];
}

-(NSIndexPath *)indexPathOfFormRow:(NMFormRowDescriptor *)formRow
{
    NSIndexPath *result = nil;
    NMFormSectionDescriptor *section = formRow.sectionDescriptor;
    if (section) {
        NSUInteger sectionIndex = [self.formSections indexOfObject:section];
        if (sectionIndex != NSNotFound) {
            NSUInteger rowIndex = [section.formRows indexOfObject:formRow];
            if (rowIndex != NSNotFound) {
                result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    
    return result;
}

-(NSIndexPath *)globalIndexPathOfFormRow:(NMFormRowDescriptor *)formRow
{
    NSIndexPath *result = nil;
    NMFormSectionDescriptor *section = formRow.sectionDescriptor;
    if (section) {
        NSUInteger sectionIndex = [self.allSections indexOfObject:section];
        if (sectionIndex != NSNotFound) {
            NSUInteger rowIndex = [section.allRows indexOfObject:formRow];
            if (rowIndex != NSNotFound) {
                result = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            }
        }
    }
    
    return result;
}

-(NSDictionary *)formValues
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NMFormSectionDescriptor *section in self.formSections) {
        if (section.multivaluedTag.length > 0) {
            NSMutableArray *multiValuedValuesArray = [NSMutableArray new];
            for (NMFormRowDescriptor *row in section.formRows) {
                if (row.value && row.value != [NSNull null]) {
                    [multiValuedValuesArray addObject:row.value];
                }
            }
            
            [result setObject:multiValuedValuesArray forKey:section.multivaluedTag];
        }
        else {
            for (NMFormRowDescriptor *row in section.formRows) {
                id value = [row.value valueData];
                if (row.tag.length > 0 && value != nil) {
                    [result setObject:value forKey:row.tag];
                }
            }
        }
    }
    
    return result;
}

-(NSDictionary *)httpParameters:(NMFormViewController *)formViewController
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    for (NMFormSectionDescriptor * section in self.formSections) {
        if (section.multivaluedTag.length > 0) {
            NSMutableArray *multiValuedValuesArray = [NSMutableArray new];
            for (NMFormRowDescriptor * row in section.formRows) {
                if ([row.value valueData]) {
                    [multiValuedValuesArray addObject:[row.value valueData]];
                }
            }
            
            [result setObject:multiValuedValuesArray forKey:section.multivaluedTag];
        }
        else {
            for (NMFormRowDescriptor * row in section.formRows) {
                NSString *httpParameterKey = nil;
                if ((httpParameterKey = [self httpParameterKeyForRow:row cell:[row cellForFormController:formViewController]])) {
                    id parameterValue = [row.value valueData] ?: [NSNull null];
                    [result setObject:parameterValue forKey:httpParameterKey];
                }
            }
        }
    }
    
    return result;
}

-(NSString *)httpParameterKeyForRow:(NMFormRowDescriptor *)row cell:(UITableViewCell<NMFormDescriptorCell> *)descriptorCell
{
    NSString *result = nil;
    
    if ([descriptorCell respondsToSelector:@selector(formDescriptorHttpParameterName)]) {
        result = [descriptorCell formDescriptorHttpParameterName];
    }
    else if (row.tag.length > 0) {
        result = row.tag;
    }
    
    return result;
}

-(NSArray *)localValidationErrors:(NMFormViewController *)formViewController
{
    NSMutableArray *result = [NSMutableArray array];
    for (NMFormSectionDescriptor *section in self.formSections) {
        for (NMFormRowDescriptor *row in section.formRows) {
            NMFormValidationStatus *status = [row doValidation];
            if (status != nil && (![status isValid])) {
                NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: status.msg,
                                            NMValidationStatusErrorKey: status };
                NSError *error = [[NSError alloc] initWithDomain:NMFormErrorDomain code:NMFormErrorCodeGen userInfo:userInfo];
                if (error) {
                    [result addObject:error];
                }
            }
        }
    }
    
    return result;
}


- (void)setFirstResponder:(NMFormViewController *)formViewController
{
    for (NMFormSectionDescriptor *formSection in self.formSections) {
        for (NMFormRowDescriptor *row in formSection.formRows) {
            UITableViewCell<NMFormDescriptorCell> *cell = [row cellForFormController:formViewController];
            if ([cell formDescriptorCellCanBecomeFirstResponder]) {
                if ([cell formDescriptorCellBecomeFirstResponder]) {
                    return;
                }
            }
        }
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
    if (!self.delegate) {
        return;
    }
    else if ([keyPath isEqualToString:NMFormSectionsKey]) {
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]) {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NMFormSectionDescriptor *section = [self.formSections objectAtIndex:indexSet.firstIndex];
            [self.delegate formSectionHasBeenAdded:section atIndex:indexSet.firstIndex];
        }
        else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]) {
            NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NMFormSectionDescriptor *removedSection = [[change objectForKey:NSKeyValueChangeOldKey] objectAtIndex:0];
            [self.delegate formSectionHasBeenRemoved:removedSection atIndex:indexSet.firstIndex];
        }
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:NMFormSectionsKey];
    
    [_formSections removeAllObjects];
    _formSections = nil;
    [_allSections removeAllObjects];
    _allSections = nil;
    [_allRowsByTag removeAllObjects];
    _allRowsByTag = nil;
    [_rowObservers removeAllObjects];
    _rowObservers = nil;
}

#pragma mark - KVC

-(NSUInteger)countOfFormSections
{
    return self.formSections.count;
}

- (id)objectInFormSectionsAtIndex:(NSUInteger)index
{
    return [self.formSections objectAtIndex:index];
}

- (NSArray *)formSectionsAtIndexes:(NSIndexSet *)indexes
{
    return [self.formSections objectsAtIndexes:indexes];
}

- (void)insertObject:(NMFormSectionDescriptor *)formSection inFormSectionsAtIndex:(NSUInteger)index
{
    [self.formSections insertObject:formSection atIndex:index];
}

- (void)removeObjectFromFormSectionsAtIndex:(NSUInteger)index
{
    [self.formSections removeObjectAtIndex:index];
}

#pragma mark - allSections KVO

-(NSUInteger)countOfAllSections
{
    return self.allSections.count;
}

- (id)objectInAllSectionsAtIndex:(NSUInteger)index {
    return [self.allSections objectAtIndex:index];
}

- (NSArray *)allSectionsAtIndexes:(NSIndexSet *)indexes {
    return [self.allSections objectsAtIndexes:indexes];
}

- (void)removeObjectFromAllSectionsAtIndex:(NSUInteger)index
{
    NMFormSectionDescriptor* section = [self.allSections objectAtIndex:index];
    [section.allRows enumerateObjectsUsingBlock:^(id obj, NSUInteger __unused idx, BOOL *stop) {
        NMFormRowDescriptor * row = (id)obj;
        [self removeObserversOfObject:row predicateType:NMPredicateTypeDisabled];
        [self removeObserversOfObject:row predicateType:NMPredicateTypeHidden];
    }];
    [self removeObserversOfObject:section predicateType:NMPredicateTypeHidden];
    [self.allSections removeObjectAtIndex:index];
}

- (void)insertObject:(NMFormSectionDescriptor *)section inAllSectionsAtIndex:(NSUInteger)index
{
    section.formDescriptor = self;
    [self.allSections insertObject:section atIndex:index];
    section.hidden = section.hidden;
    [section.allRows enumerateObjectsUsingBlock:^(id obj, NSUInteger __unused idx, BOOL * __unused stop) {
        NMFormRowDescriptor * row = (id)obj;
        [self addRowToTagCollection:obj];
        row.hidden = row.hidden;
        row.disabled = row.disabled;
    }];
}

#pragma mark - EvaluateForm

-(void)forceEvaluate
{
    for (NMFormSectionDescriptor *section in self.allSections) {
        for (NMFormRowDescriptor *row in section.allRows) {
            [self addRowToTagCollection:row];
        }
    }
    for (NMFormSectionDescriptor *section in self.allSections) {
        for (NMFormRowDescriptor *row in section.allRows) {
            [row evaluateIsDisabled];
            [row evaluateIsHidden];
        }
        
        [section evaluateIsHidden];
    }
}

#pragma mark - private


-(NSMutableArray *)formSections
{
    return _formSections;
}

#pragma mark - Helpers

-(NMFormRowDescriptor *)nextRowDescriptorForRow:(NMFormRowDescriptor *)row
{
    NMFormRowDescriptor *result = nil;
    NSUInteger indexOfRow = [row.sectionDescriptor.formRows indexOfObject:row];
    if (indexOfRow != NSNotFound) {
        if (indexOfRow + 1 < row.sectionDescriptor.formRows.count) {
            result = [row.sectionDescriptor.formRows objectAtIndex:++indexOfRow];
        }
        else {
            NSUInteger sectionIndex = [self.formSections indexOfObject:row.sectionDescriptor];
            NSUInteger numberOfSections = [self.formSections count];
            if (sectionIndex != NSNotFound && sectionIndex < numberOfSections - 1) {
                sectionIndex++;
                NMFormSectionDescriptor *sectionDescriptor;
                while ([[(sectionDescriptor = [row.sectionDescriptor.formDescriptor.formSections objectAtIndex:sectionIndex]) formRows] count] == 0 && sectionIndex < numberOfSections - 1) {
                    sectionIndex++;
                }
                
                result = [sectionDescriptor.formRows firstObject];
            }
        }
    }
    
    return result;
}


-(NMFormRowDescriptor *)previousRowDescriptorForRow:(NMFormRowDescriptor *)row
{
    NMFormRowDescriptor *result = nil;
    NSUInteger indexOfRow = [row.sectionDescriptor.formRows indexOfObject:row];
    if (indexOfRow != NSNotFound) {
        if (indexOfRow > 0 ) {
            result = [row.sectionDescriptor.formRows objectAtIndex:--indexOfRow];
        }
        else {
            NSUInteger sectionIndex = [self.formSections indexOfObject:row.sectionDescriptor];
            if (sectionIndex != NSNotFound && sectionIndex > 0) {
                sectionIndex--;
                NMFormSectionDescriptor * sectionDescriptor;
                while ([[(sectionDescriptor = [row.sectionDescriptor.formDescriptor.formSections objectAtIndex:sectionIndex]) formRows] count] == 0 && sectionIndex > 0 ) {
                    sectionIndex--;
                }
                result = [sectionDescriptor.formRows lastObject];
            }
        }
    }
    
    return result;
}

-(void)addRowToTagCollection:(NMFormRowDescriptor *)rowDescriptor
{
    if (rowDescriptor.tag.length) {
        self.allRowsByTag[rowDescriptor.tag] = rowDescriptor;
    }
}

-(void)removeRowFromTagCollection:(NMFormRowDescriptor *)rowDescriptor
{
    if (rowDescriptor.tag.length) {
        [self.allRowsByTag removeObjectForKey:rowDescriptor.tag];
    }
}


-(void)addObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType
{
    NSPredicate *predicate;
    id descriptor;
    
    switch (predicateType) {
        case NMPredicateTypeHidden:
            if ([sectionOrRow isKindOfClass:([NMFormRowDescriptor class])]) {
                descriptor = ((NMFormRowDescriptor *)sectionOrRow).tag;
                predicate = ((NMFormRowDescriptor *)sectionOrRow).hidden;
            }
            else if ([sectionOrRow isKindOfClass:([NMFormSectionDescriptor class])]) {
                descriptor = sectionOrRow;
                predicate = ((NMFormSectionDescriptor *)sectionOrRow).hidden;
            }
            break;
        case NMPredicateTypeDisabled:
            if ([sectionOrRow isKindOfClass:([NMFormRowDescriptor class])]) {
                descriptor = ((NMFormRowDescriptor *)sectionOrRow).tag;
                predicate = ((NMFormRowDescriptor *)sectionOrRow).disabled;
            }
            else {
                return;
            }
            
            break;
    }
    
    NSMutableArray *tags = [predicate getPredicateVars];
    for (NSString *tag in tags) {
        NSString *auxTag = [tag formKeyForPredicateType:predicateType];
        if (!self.rowObservers[auxTag]) {
            self.rowObservers[auxTag] = [NSMutableArray array];
        }
        if (![self.rowObservers[auxTag] containsObject:descriptor])
            [self.rowObservers[auxTag] addObject:descriptor];
    }
    
}

-(void)removeObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType
{
    NSPredicate *predicate;
    id descriptor;
    
    switch(predicateType) {
        case NMPredicateTypeHidden:
            if ([sectionOrRow isKindOfClass:([NMFormRowDescriptor class])]) {
                descriptor = ((NMFormRowDescriptor *)sectionOrRow).tag;
                predicate = ((NMFormRowDescriptor *)sectionOrRow).hidden;
            }
            else if ([sectionOrRow isKindOfClass:([NMFormSectionDescriptor class])]) {
                descriptor = sectionOrRow;
                predicate = ((NMFormSectionDescriptor *)sectionOrRow).hidden;
            }
            break;
        case NMPredicateTypeDisabled:
            if ([sectionOrRow isKindOfClass:([NMFormRowDescriptor class])]) {
                descriptor = ((NMFormRowDescriptor *)sectionOrRow).tag;
                predicate = ((NMFormRowDescriptor *)sectionOrRow).disabled;
            }
            break;
    }
    if (descriptor && [predicate isKindOfClass:[NSPredicate class]]) {
        NSMutableArray *tags = [predicate getPredicateVars];
        for (NSString *tag in tags) {
            NSString *auxTag = [tag formKeyForPredicateType:predicateType];
            if (self.rowObservers[auxTag]) {
                [self.rowObservers[auxTag] removeObject:descriptor];
            }
        }
    }
}

@end
