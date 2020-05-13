//
//  NMFormRowDescriptor.m
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
#import "NMFormViewController.h"
#import "NMFormRowDescriptor.h"
#import "NSString+NMFormAdditions.h"

CGFloat NMFormUnspecifiedCellHeight = -3.0;
CGFloat NMFormRowInitialHeight = -2;

@interface NMFormDescriptor (_NMFormRowDescriptor)

@property (nonatomic, readonly, strong) NSDictionary *allRowsByTag;

-(void)addObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType;
-(void)removeObserversOfObject:(id)sectionOrRow predicateType:(NMPredicateType)predicateType;

@end

@interface NMFormSectionDescriptor (_NMFormRowDescriptor)

-(void)showFormRow:(NMFormRowDescriptor *)formRow;
-(void)hideFormRow:(NMFormRowDescriptor *)formRow;

@end

#import "NSObject+NMFormAdditions.h"

NSString * const NMValueKey = @"value";
NSString * const NMDisablePredicateCacheKey = @"disablePredicateCache";
NSString * const NMHidePredicateCacheKey = @"hidePredicateCache";

@interface NMFormRowDescriptor() <NSCopying>

@property (nonatomic, strong) NMFormBaseCell *cell;
@property (nonatomic, strong) NSMutableArray *validators;

@property (nonatomic, assign) BOOL isDirtyDisablePredicateCache;
@property (nonatomic, copy  ) NSNumber *disablePredicateCache;
@property (nonatomic, assign) BOOL isDirtyHidePredicateCache;
@property (nonatomic, copy  ) NSNumber *hidePredicateCache;

@end

@implementation NMFormRowDescriptor

@synthesize action = _action;
@synthesize disabled = _disabled;
@synthesize hidden = _hidden;
@synthesize hidePredicateCache = _hidePredicateCache;
@synthesize disablePredicateCache = _disablePredicateCache;
@synthesize cellConfig = _cellConfig;
@synthesize cellConfigForSelector = _cellConfigForSelector;
@synthesize cellConfigIfDisabled = _cellConfigIfDisabled;
@synthesize cellConfigAtConfigure = _cellConfigAtConfigure;
@synthesize height = _height;

-(instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException reason:@"initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title must be used" userInfo:nil];
}

-(instancetype)initWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title;
{
    if (self = [super init]) {
        NSAssert(((![rowType isEqualToString:NMFormRowDescriptorTypeSelectorPopover] && ![rowType isEqualToString:NMFormRowDescriptorTypeMultipleSelectorPopover]) || (([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) && ([rowType isEqualToString:NMFormRowDescriptorTypeSelectorPopover] || [rowType isEqualToString:NMFormRowDescriptorTypeMultipleSelectorPopover]))), @"You must be running under UIUserInterfaceIdiomPad to use either NMFormRowDescriptorTypeSelectorPopover or NMFormRowDescriptorTypeMultipleSelectorPopover rows.");
        _tag = tag;
        _disabled = @NO;
        _hidden = @NO;
        _rowType = rowType;
        _title = title;
        _cellStyle = [rowType isEqualToString:NMFormRowDescriptorTypeButton] ? UITableViewCellStyleDefault : UITableViewCellStyleValue1;
        _validators = [NSMutableArray new];
        _cellConfig = [NSMutableDictionary dictionary];
        _cellConfigIfDisabled = [NSMutableDictionary dictionary];
        _cellConfigAtConfigure = [NSMutableDictionary dictionary];
        _isDirtyDisablePredicateCache = YES;
        _disablePredicateCache = nil;
        _isDirtyHidePredicateCache = YES;
        _hidePredicateCache = nil;
        _height = NMFormRowInitialHeight;
        
        [self addObserver:self
               forKeyPath:NMValueKey
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
        [self addObserver:self
               forKeyPath:NMDisablePredicateCacheKey
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
        [self addObserver:self
               forKeyPath:NMHidePredicateCacheKey
                  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:0];
        
    }
    
    return self;
}

+(instancetype)formRowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType
{
    return [[self class] formRowDescriptorWithTag:tag rowType:rowType title:nil];
}

+(instancetype)formRowDescriptorWithTag:(NSString *)tag rowType:(NSString *)rowType title:(NSString *)title
{
    return [[[self class] alloc] initWithTag:tag rowType:rowType title:title];
}

-(NMFormBaseCell *)cellForFormController:(NMFormViewController * __unused)formController
{
    if (!_cell) {
        id cellClass = self.cellClass ?: [NMFormViewController cellClassesForRowDescriptorTypes][self.rowType];
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *cellClassString = cellClass;
        NSString *cellResource = nil;
        NSBundle *bundleForCaller = [NSBundle bundleForClass:self.class];
        
        NSAssert(cellClass, @"Not defined NMFormRowDescriptorType: %@", self.rowType ?: @"");
        
        if ([cellClass isKindOfClass:[NSString class]]) {
            if ([cellClassString rangeOfString:@"/"].location != NSNotFound) {
                NSArray *components = [cellClassString componentsSeparatedByString:@"/"];
                cellResource = [components lastObject];
                NSString *folderName = [components firstObject];
                NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:folderName];
                bundle = [NSBundle bundleWithPath:bundlePath];
            } else {
                cellResource = [cellClassString componentsSeparatedByString:@"."].lastObject;
            }
        } else {
            cellResource = [NSStringFromClass(cellClass) componentsSeparatedByString:@"."].lastObject;
        }
        
        if ([bundle pathForResource:cellResource ofType:@"nib"]) {
            _cell = [[bundle loadNibNamed:cellResource owner:nil options:nil] firstObject];
        } else if ([bundleForCaller pathForResource:cellResource ofType:@"nib"]) {
            _cell = [[bundleForCaller loadNibNamed:cellResource owner:nil options:nil] firstObject];
        } else {
            _cell = [[cellClass alloc] initWithStyle:self.cellStyle reuseIdentifier:nil];
        }
        
        _cell.rowDescriptor = self;
        
        NSAssert([_cell isKindOfClass:[NMFormBaseCell class]], @"UITableViewCell must extend from NMFormBaseCell");
        
        [self configureCellAtCreationTime];
    }
    
    return _cell;
}

- (void)configureCellAtCreationTime
{
    [self.cellConfigAtConfigure enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, id value, __unused BOOL *stop) {
        [self.cell setValue:(value == [NSNull null]) ? nil : value forKeyPath:keyPath];
    }];
}

-(NSMutableDictionary *)cellConfig
{
    if (!_cellConfig) {
        _cellConfig = [NSMutableDictionary dictionary];
    }
    
    return _cellConfig;
}

-(NSMutableDictionary *)cellConfigForSelector
{
    if (!_cellConfigForSelector) {
        _cellConfigForSelector = [NSMutableDictionary dictionary];
    }
    
    return _cellConfigForSelector;
}


-(NSMutableDictionary *)cellConfigIfDisabled
{
    if (!_cellConfigIfDisabled) {
        _cellConfigIfDisabled = [NSMutableDictionary dictionary];
    }
    
    return _cellConfigIfDisabled;
}

-(NSMutableDictionary *)cellConfigAtConfigure
{
    if (!_cellConfigAtConfigure) {
        _cellConfigAtConfigure = [NSMutableDictionary dictionary];
    }
    
    return _cellConfigAtConfigure;
}

-(NSString *)editTextValue
{
    NSString *result = @"";
    
    if (self.value) {
        if (self.valueFormatter) {
            if (self.useValueFormatterDuringInput) {
                result = [self displayTextValue];
            }
            else {
                // have formatter, but we don't want to use it during editing
                result = [self.value displayText];
            }
        }
        else {
            // have value, but no formatter, use the value's displayText
            result = [self.value displayText];
        }
    }
    
    return result;
}

-(NSString *)displayTextValue
{
    NSString *result = self.noValueDisplayText;
    
    if (self.value) {
        if (self.valueFormatter) {
            result = [self.valueFormatter stringForObjectValue:self.value];
        }
        else {
            result = [self.value displayText];
        }
    }
    
    return result;
}

-(NSString *)description
{
    return self.tag;  // [NSString stringWithFormat:@"%@ - %@ (%@)", [super description], self.tag, self.rowType];
}

-(NMFormAction *)action
{
    if (!_action) {
        _action = [[NMFormAction alloc] init];
    }
    
    return _action;
}

-(void)setAction:(NMFormAction *)action
{
    _action = action;
}

-(CGFloat)height
{
    if (_height == NMFormRowInitialHeight) {
        if ([[self.cell class] respondsToSelector:@selector(formDescriptorCellHeightForRowDescriptor:)]){
            return [[self.cell class] formDescriptorCellHeightForRowDescriptor:self];
        }
        else {
            _height = NMFormUnspecifiedCellHeight;
        }
    }
    
    return _height;
}

-(void)setHeight:(CGFloat)height {
    _height = height;
}

// In the implementation
-(id)copyWithZone:(NSZone *)zone
{
    NMFormRowDescriptor *rowDescriptorCopy = [NMFormRowDescriptor formRowDescriptorWithTag:nil
                                                                                   rowType:[self.rowType copy]
                                                                                     title:[self.title copy]];
    rowDescriptorCopy.cellClass = [self.cellClass copy];
    [rowDescriptorCopy.cellConfig addEntriesFromDictionary:self.cellConfig];
    [rowDescriptorCopy.cellConfigAtConfigure addEntriesFromDictionary:self.cellConfigAtConfigure];
    rowDescriptorCopy.valueTransformer = [self.valueTransformer copy];
    rowDescriptorCopy.hidden = self.hidden;
    rowDescriptorCopy.disabled = self.disabled;
    rowDescriptorCopy.required = self.isRequired;
    rowDescriptorCopy.isDirtyDisablePredicateCache = YES;
    rowDescriptorCopy.isDirtyHidePredicateCache = YES;
    rowDescriptorCopy.validators = [self.validators mutableCopy];
    
    // =====================
    // properties for Button
    // =====================
    rowDescriptorCopy.action = [self.action copy];
    
    
    // ===========================
    // property used for Selectors
    // ===========================
    
    rowDescriptorCopy.noValueDisplayText = [self.noValueDisplayText copy];
    rowDescriptorCopy.selectorTitle = [self.selectorTitle copy];
    rowDescriptorCopy.selectorOptions = [self.selectorOptions copy];
    rowDescriptorCopy.leftRightSelectorLeftOptionSelected = [self.leftRightSelectorLeftOptionSelected copy];
    
    return rowDescriptorCopy;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:NMValueKey];
    [self removeObserver:self forKeyPath:NMDisablePredicateCacheKey];
    [self removeObserver:self forKeyPath:NMHidePredicateCacheKey];
    
    [self.sectionDescriptor.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeDisabled];
    [self.sectionDescriptor.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeHidden];
    
    _cell = nil;
    
    [self.validators removeAllObjects];
    self.validators = nil;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.sectionDescriptor) {
        return;
    }
    else if (object == self && ([keyPath isEqualToString:NMValueKey] ||
                                [keyPath isEqualToString:NMHidePredicateCacheKey] || [keyPath isEqualToString:NMDisablePredicateCacheKey])) {
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            id newValue = [change objectForKey:NSKeyValueChangeNewKey];
            id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            if ([keyPath isEqualToString:NMValueKey]) {
                [self.sectionDescriptor.formDescriptor.delegate formRowDescriptorValueHasChanged:object oldValue:oldValue newValue:newValue];
                if (self.onChangeBlock) {
                    self.onChangeBlock(oldValue, newValue, self);
                }
            }
            else {
                [self.sectionDescriptor.formDescriptor.delegate formRowDescriptorPredicateHasChanged:object
                                                                                            oldValue:oldValue
                                                                                            newValue:newValue
                                                                                       predicateType:([keyPath isEqualToString:NMHidePredicateCacheKey] ? NMPredicateTypeHidden : NMPredicateTypeDisabled)];
            }
        }
    }
}

#pragma mark - Disable Predicate functions

-(BOOL)isDisabled
{
    if (self.sectionDescriptor.formDescriptor.isDisabled) {
        return YES;
    }
    
    if (self.isDirtyDisablePredicateCache) {
        [self evaluateIsDisabled];
    }
    
    return [self.disablePredicateCache boolValue];
}

-(void)setDisabled:(id)disabled
{
    if ([_disabled isKindOfClass:[NSPredicate class]]){
        [self.sectionDescriptor.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeDisabled];
    }
    
    _disabled = [disabled isKindOfClass:[NSString class]] ? [disabled formPredicate] : disabled;
    if ([_disabled isKindOfClass:[NSPredicate class]]){
        [self.sectionDescriptor.formDescriptor addObserversOfObject:self predicateType:NMPredicateTypeDisabled];
    }
    
    [self evaluateIsDisabled];
}

-(BOOL)evaluateIsDisabled
{
    if ([_disabled isKindOfClass:[NSPredicate class]]) {
        if (!self.sectionDescriptor.formDescriptor) {
            self.isDirtyDisablePredicateCache = YES;
        }
        else {
            @try {
                self.disablePredicateCache = @([_disabled evaluateWithObject:self substitutionVariables:self.sectionDescriptor.formDescriptor.allRowsByTag ?: @{}]);
            }
            @catch (NSException *exception) {
                // predicate syntax error.
                self.isDirtyDisablePredicateCache = YES;
            };
        }
    }
    else {
        self.disablePredicateCache = _disabled;
    }
    
    if ([self.disablePredicateCache boolValue]) {
        [self.cell resignFirstResponder];
    }
    
    return [self.disablePredicateCache boolValue];
}

-(id)disabled
{
    return _disabled;
}

-(void)setDisablePredicateCache:(NSNumber*)disablePredicateCache
{
    NSParameterAssert(disablePredicateCache != nil);
    self.isDirtyDisablePredicateCache = NO;
    if (_disablePredicateCache == nil || ![_disablePredicateCache isEqualToNumber:disablePredicateCache]){
        _disablePredicateCache = disablePredicateCache;
    }
}

-(NSNumber*)disablePredicateCache
{
    return _disablePredicateCache;
}

#pragma mark - Hide Predicate functions

-(NSNumber *)hidePredicateCache
{
    return _hidePredicateCache;
}

-(void)setHidePredicateCache:(NSNumber *)hidePredicateCache
{
    NSParameterAssert(hidePredicateCache != nil);
    self.isDirtyHidePredicateCache = NO;
    if (_hidePredicateCache == nil || ![_hidePredicateCache isEqualToNumber:hidePredicateCache]){
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
        if (!self.sectionDescriptor.formDescriptor) {
            self.isDirtyHidePredicateCache = YES;
        }
        else {
            @try {
                self.hidePredicateCache = @([_hidden evaluateWithObject:self substitutionVariables:self.sectionDescriptor.formDescriptor.allRowsByTag ?: @{}]);
            }
            @catch (NSException *exception) {
                // predicate syntax error or for has not finished loading.
                self.isDirtyHidePredicateCache = YES;
            };
        }
    }
    else {
        self.hidePredicateCache = _hidden;
    }
    
    if ([self.hidePredicateCache boolValue]){
        [self.cell resignFirstResponder];
        [self.sectionDescriptor hideFormRow:self];
    }
    else {
        [self.sectionDescriptor showFormRow:self];
    }
    
    return [self.hidePredicateCache boolValue];
}


-(void)setHidden:(id)hidden
{
    if ([_hidden isKindOfClass:[NSPredicate class]]){
        [self.sectionDescriptor.formDescriptor removeObserversOfObject:self predicateType:NMPredicateTypeHidden];
    }
    
    _hidden = [hidden isKindOfClass:[NSString class]] ? [hidden formPredicate] : hidden;
    if ([_hidden isKindOfClass:[NSPredicate class]]){
        [self.sectionDescriptor.formDescriptor addObserversOfObject:self predicateType:NMPredicateTypeHidden];
    }
    
    [self evaluateIsHidden]; // check and update if this row should be hidden.
}

-(id)hidden
{
    return _hidden;
}


#pragma mark - validation

-(void)addValidator:(id<NMFormValidatorProtocol>)validator
{
    if (validator == nil || ![validator conformsToProtocol:@protocol(NMFormValidatorProtocol)]) {
        return;
    }
    else if (![self.validators containsObject:validator]) {
        [self.validators addObject:validator];
    }
}

-(void)removeValidator:(id<NMFormValidatorProtocol>)validator
{
    if (validator == nil || ![validator conformsToProtocol:@protocol(NMFormValidatorProtocol)]) {
        return;
    }
    else if ([self.validators containsObject:validator]) {
        [self.validators removeObject:validator];
    }
}

- (BOOL)valueIsEmpty
{
    return self.value == nil || [self.value isKindOfClass:[NSNull class]] ||
        ([self.value respondsToSelector:@selector(length)] && [self.value length] == 0) ||
        ([self.value respondsToSelector:@selector(count)] && [self.value count] == 0);
}

-(NMFormValidationStatus *)doValidation
{
    NMFormValidationStatus *valStatus = nil;
    
    if (self.required) {
        // do required validation here
        if ([self valueIsEmpty]) {
            valStatus = [NMFormValidationStatus formValidationStatusWithMsg:@"" status:NO rowDescriptor:self];
            NSString *msg = nil;
            if (self.requireMsg != nil) {
                msg = self.requireMsg;
            }
            else {
                // default message for required msg
                msg = NSLocalizedString(@"%@ can't be empty", nil);
            }
            
            if (self.title.length) {
                valStatus.msg = [NSString stringWithFormat:msg, self.title];
            }
            else {
                valStatus.msg = [NSString stringWithFormat:msg, self.tag];
            }
            
            return valStatus;
        }
    }
    // custom validator
    for (id<NMFormValidatorProtocol> v in self.validators) {
        if ([v conformsToProtocol:@protocol(NMFormValidatorProtocol)]) {
            NMFormValidationStatus *vStatus = [v isValid:self];
            // fail validation
            if (vStatus != nil && !vStatus.isValid) {
                return vStatus;
            }
            valStatus = vStatus;
        }
        else {
            valStatus = nil;
        }
    }
    
    return valStatus;
}


#pragma mark - Deprecations

-(void)setButtonViewController:(Class)buttonViewController
{
    self.action.viewControllerClass = buttonViewController;
}

-(Class)buttonViewController
{
    return self.action.viewControllerClass;
}

-(void)setSelectorControllerClass:(Class)selectorControllerClass
{
    self.action.viewControllerClass = selectorControllerClass;
}

-(Class)selectorControllerClass
{
    return self.action.viewControllerClass;
}

-(void)setButtonViewControllerPresentationMode:(NMFormPresentationMode)buttonViewControllerPresentationMode
{
    self.action.viewControllerPresentationMode = buttonViewControllerPresentationMode;
}

-(NMFormPresentationMode)buttonViewControllerPresentationMode
{
    return self.action.viewControllerPresentationMode;
}

@end



@implementation NMFormLeftRightSelectorOption


+(NMFormLeftRightSelectorOption *)formLeftRightSelectorOptionWithLeftValue:(id)leftValue
                                                          httpParameterKey:(NSString *)httpParameterKey
                                                              rightOptions:(NSArray *)rightOptions;
{
    return [[NMFormLeftRightSelectorOption alloc] initWithLeftValue:leftValue
                                                   httpParameterKey:httpParameterKey
                                                       rightOptions:rightOptions];
}


-(instancetype)initWithLeftValue:(NSString *)leftValue httpParameterKey:(NSString *)httpParameterKey rightOptions:(NSArray *)rightOptions
{
    if (self = [super init]) {
        _selectorTitle = nil;
        _leftValue = leftValue;
        _rightOptions = rightOptions;
        _httpParameterKey = httpParameterKey;
    }
    
    return self;
}


@end

@implementation NMFormAction

- (instancetype)init
{
    if (self = [super init]) {
        _viewControllerPresentationMode = NMFormPresentationModeDefault;
    }
    
    return self;
}

// In the implementation
-(id)copyWithZone:(NSZone *)zone
{
    NMFormAction * actionCopy = [[NMFormAction alloc] init];
    actionCopy.viewControllerPresentationMode = self.viewControllerPresentationMode;
    if (self.viewControllerClass){
        actionCopy.viewControllerClass = [self.viewControllerClass copy];
    }
    else if ([self.viewControllerStoryboardId length]  != 0) {
        actionCopy.viewControllerStoryboardId = [self.viewControllerStoryboardId copy];
    }
    else if ([self.viewControllerNibName length] != 0) {
        actionCopy.viewControllerNibName = [self.viewControllerNibName copy];
    }
    if (self.formBlock) {
        actionCopy.formBlock = [self.formBlock copy];
    }
    else if (self.formSelector) {
        actionCopy.formSelector = self.formSelector;
    }
    else if (self.formSegueIdentifier) {
        actionCopy.formSegueIdentifier = [self.formSegueIdentifier copy];
    }
    else if (self.formSegueClass){
        actionCopy.formSegueClass = [self.formSegueClass copy];
    }
    
    return actionCopy;
}

-(void)setViewControllerClass:(Class)viewControllerClass
{
    _viewControllerClass = viewControllerClass;
    _viewControllerNibName = nil;
    _viewControllerStoryboardId = nil;
}

-(void)setViewControllerNibName:(NSString *)viewControllerNibName
{
    _viewControllerClass = nil;
    _viewControllerNibName = viewControllerNibName;
    _viewControllerStoryboardId = nil;
}

-(void)setViewControllerStoryboardId:(NSString *)viewControllerStoryboardId
{
    _viewControllerClass = nil;
    _viewControllerNibName = nil;
    _viewControllerStoryboardId = viewControllerStoryboardId;
}

-(void)setFormSelector:(SEL)formSelector
{
    _formBlock = nil;
    _formSegueClass = nil;
    _formSegueIdentifier = nil;
    _formSelector = formSelector;
}

-(void)setFormBlock:(void (^)(NMFormRowDescriptor *))formBlock
{
    _formSegueClass = nil;
    _formSegueIdentifier = nil;
    _formSelector = nil;
    _formBlock = formBlock;
}

-(void)setFormSegueClass:(Class)formSegueClass
{
    _formSelector = nil;
    _formBlock = nil;
    _formSegueIdentifier = nil;
    _formSegueClass = formSegueClass;
}

-(void)setFormSegueIdentifier:(NSString *)formSegueIdentifier
{
    _formSelector = nil;
    _formBlock = nil;
    _formSegueClass = nil;
    _formSegueIdentifier = formSegueIdentifier;
}

// Deprecated:
-(void)setFormSegueIdenfifier:(NSString *)formSegueIdenfifier
{
    self.formSegueIdentifier = formSegueIdenfifier;
}

-(NSString *)formSegueIdenfifier
{
    return self.formSegueIdentifier;
}

@end
