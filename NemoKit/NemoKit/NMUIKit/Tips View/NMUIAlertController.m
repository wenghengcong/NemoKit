//
//  NMUIAlertController.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIAlertController.h"
#import "NMBCore.h"
#import "NMUIButton.h"
#import "NMUITextField.h"
#import "UIView+NMUI.h"
#import "UIControl+NMUI.h"
#import "NSParagraphStyle+NMBF.h"
#import "UIImage+NMUI.h"
#import "CALayer+NMUI.h"
#import "NMUIKeyboardManager.h"

static NSUInteger alertControllerCount = 0;

#pragma mark - NMUIBUttonWrapView

@interface NMUIAlertButtonWrapView : UIView

@property(nonatomic, strong) NMUIButton *button;

@end

@implementation NMUIAlertButtonWrapView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.button = [[NMUIButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

@end


#pragma mark - NMUIAlertAction

@protocol NMUIAlertActionDelegate <NSObject>

- (void)didClickAlertAction:(NMUIAlertAction *)alertAction;

@end

@interface NMUIAlertAction ()

@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, assign, readwrite) NMUIAlertActionStyle style;
@property(nonatomic, copy) void (^handler)(NMUIAlertController *aAlertController, NMUIAlertAction *action);
@property(nonatomic, weak) id<NMUIAlertActionDelegate> delegate;

@end

@implementation NMUIAlertAction

+ (nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(NMUIAlertActionStyle)style handler:(void (^)(__kindof NMUIAlertController *, NMUIAlertAction *))handler {
    NMUIAlertAction *alertAction = [[NMUIAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        _button = [[NMUIButton alloc] init];
        self.button.adjustsButtonWhenDisabled = NO;
        self.button.adjustsButtonWhenHighlighted = NO;
        self.button.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleAlertActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.button.enabled = enabled;
}

- (void)handleAlertActionEvent:(id)sender {
    // 需要先调delegate，里面会先恢复keywindow
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAlertAction:)]) {
        [self.delegate didClickAlertAction:self];
    }
}

@end


@implementation NMUIAlertController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static NMUIAlertController *alertControllerAppearance;
+ (nonnull instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self resetAppearance];
    });
    return alertControllerAppearance;
}

+ (void)resetAppearance {
    if (!alertControllerAppearance) {
        
        alertControllerAppearance = [[NMUIAlertController alloc] init];
        
        alertControllerAppearance.alertContentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
        alertControllerAppearance.alertContentMaximumWidth = 270;
        alertControllerAppearance.alertSeparatorColor = UIColorMake(211, 211, 219);
        alertControllerAppearance.alertTitleAttributes = @{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontBoldMake(17),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
        alertControllerAppearance.alertMessageAttributes = @{NSForegroundColorAttributeName:UIColorBlack,NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
        alertControllerAppearance.alertButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
        alertControllerAppearance.alertButtonDisabledAttributes = @{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
        alertControllerAppearance.alertCancelButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(17),NSKernAttributeName:@(0)};
        alertControllerAppearance.alertDestructiveButtonAttributes = @{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(17),NSKernAttributeName:@(0)};
        alertControllerAppearance.alertContentCornerRadius = 13;
        alertControllerAppearance.alertButtonHeight = 44;
        alertControllerAppearance.alertHeaderBackgroundColor = UIColorMakeWithRGBA(247, 247, 247, 1);
        alertControllerAppearance.alertButtonBackgroundColor = alertControllerAppearance.alertHeaderBackgroundColor;
        alertControllerAppearance.alertButtonHighlightBackgroundColor = UIColorMake(232, 232, 232);
        alertControllerAppearance.alertHeaderInsets = UIEdgeInsetsMake(20, 16, 20, 16);
        alertControllerAppearance.alertTitleMessageSpacing = 3;
        alertControllerAppearance.alertTextFieldFont = UIFontMake(14);
        alertControllerAppearance.alertTextFieldTextColor = UIColorBlack;
        alertControllerAppearance.alertTextFieldBorderColor = UIColorMake(210, 210, 210);
        
        alertControllerAppearance.sheetContentMargin = UIEdgeInsetsMake(10, 10, 10, 10);
        alertControllerAppearance.sheetContentMaximumWidth = [NMUIHelper screenSizeFor55Inch].width - UIEdgeInsetsGetHorizontalValue(alertControllerAppearance.sheetContentMargin);
        alertControllerAppearance.sheetSeparatorColor = UIColorMake(211, 211, 219);
        alertControllerAppearance.sheetTitleAttributes = @{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontBoldMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
        alertControllerAppearance.sheetMessageAttributes = @{NSForegroundColorAttributeName:UIColorMake(143, 143, 143),NSFontAttributeName:UIFontMake(13),NSParagraphStyleAttributeName:[NSMutableParagraphStyle nmui_paragraphStyleWithLineHeight:0 lineBreakMode:NSLineBreakByTruncatingTail textAlignment:NSTextAlignmentCenter]};
        alertControllerAppearance.sheetButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetButtonDisabledAttributes = @{NSForegroundColorAttributeName:UIColorMake(129, 129, 129),NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetCancelButtonAttributes = @{NSForegroundColorAttributeName:UIColorBlue,NSFontAttributeName:UIFontBoldMake(20),NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetDestructiveButtonAttributes = @{NSForegroundColorAttributeName:UIColorRed,NSFontAttributeName:UIFontMake(20),NSKernAttributeName:@(0)};
        alertControllerAppearance.sheetCancelButtonMarginTop = 8;
        alertControllerAppearance.sheetContentCornerRadius = 13;
        alertControllerAppearance.sheetButtonHeight = 57;
        alertControllerAppearance.sheetHeaderBackgroundColor = UIColorMakeWithRGBA(247, 247, 247, 1);
        alertControllerAppearance.sheetButtonBackgroundColor = alertControllerAppearance.sheetHeaderBackgroundColor;
        alertControllerAppearance.sheetButtonHighlightBackgroundColor = UIColorMake(232, 232, 232);
        alertControllerAppearance.sheetHeaderInsets = UIEdgeInsetsMake(16, 16, 16, 16);
        alertControllerAppearance.sheetTitleMessageSpacing = 8;
        alertControllerAppearance.isExtendBottomLayout = NO;
    }
}

@end


#pragma mark - NMUIAlertController

@interface NMUIAlertController () <NMUIAlertActionDelegate, NMUIModalPresentationContentViewControllerProtocol, NMUIModalPresentationViewControllerDelegate, NMUITextFieldDelegate>

@property(nonatomic, assign, readwrite) NMUIAlertControllerStyle preferredStyle;
@property(nonatomic, strong, readwrite) NMUIModalPresentationViewController *modalPresentationViewController;

@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIControl *maskView;

@property(nonatomic, strong) UIView *scrollWrapView;
@property(nonatomic, strong) UIScrollView *headerScrollView;
@property(nonatomic, strong) UIScrollView *buttonScrollView;

@property(nonatomic, strong) CALayer *extendLayer;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) NMUIAlertAction *cancelAction;

@property(nonatomic, strong) NSMutableArray<NMUIAlertAction *> *alertActions;
@property(nonatomic, strong) NSMutableArray<NMUIAlertAction *> *destructiveActions;
@property(nonatomic, strong) NSMutableArray<UITextField *> *alertTextFields;

@property(nonatomic, assign) CGFloat keyboardHeight;

/// 调用 showWithAnimated 时置为 YES，在 show 动画结束时置为 NO
@property(nonatomic, assign) BOOL willShow;

/// 在 show 动画结束时置为 YES，在 hide 动画结束时置为 NO
@property(nonatomic, assign) BOOL showing;

// 保护 showing 的过程中调用 hide 无效
@property(nonatomic, assign) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign) BOOL isAnimatedForHideAfterAlertShowed;

@end

@implementation NMUIAlertController {
    NSString            *_title;
    BOOL _needsUpdateAction;
    BOOL _needsUpdateTitle;
    BOOL _needsUpdateMessage;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    if (alertControllerAppearance) {
        self.alertContentMargin = [NMUIAlertController appearance].alertContentMargin;
        self.alertContentMaximumWidth = [NMUIAlertController appearance].alertContentMaximumWidth;
        self.alertSeparatorColor = [NMUIAlertController appearance].alertSeparatorColor;
        self.alertContentCornerRadius = [NMUIAlertController appearance].alertContentCornerRadius;
        self.alertTitleAttributes = [NMUIAlertController appearance].alertTitleAttributes;
        self.alertMessageAttributes = [NMUIAlertController appearance].alertMessageAttributes;
        self.alertButtonAttributes = [NMUIAlertController appearance].alertButtonAttributes;
        self.alertButtonDisabledAttributes = [NMUIAlertController appearance].alertButtonDisabledAttributes;
        self.alertCancelButtonAttributes = [NMUIAlertController appearance].alertCancelButtonAttributes;
        self.alertDestructiveButtonAttributes = [NMUIAlertController appearance].alertDestructiveButtonAttributes;
        self.alertButtonHeight = [NMUIAlertController appearance].alertButtonHeight;
        self.alertHeaderBackgroundColor = [NMUIAlertController appearance].alertHeaderBackgroundColor;
        self.alertButtonBackgroundColor = [NMUIAlertController appearance].alertButtonBackgroundColor;
        self.alertButtonHighlightBackgroundColor = [NMUIAlertController appearance].alertButtonHighlightBackgroundColor;
        self.alertHeaderInsets = [NMUIAlertController appearance].alertHeaderInsets;
        self.alertTitleMessageSpacing = [NMUIAlertController appearance].alertTitleMessageSpacing;
        self.alertTextFieldFont = [NMUIAlertController appearance].alertTextFieldFont;
        self.alertTextFieldTextColor = [NMUIAlertController appearance].alertTextFieldTextColor;
        self.alertTextFieldBorderColor = [NMUIAlertController appearance].alertTextFieldBorderColor;
        
        self.sheetContentMargin = [NMUIAlertController appearance].sheetContentMargin;
        self.sheetContentMaximumWidth = [NMUIAlertController appearance].sheetContentMaximumWidth;
        self.sheetSeparatorColor = [NMUIAlertController appearance].sheetSeparatorColor;
        self.sheetTitleAttributes = [NMUIAlertController appearance].sheetTitleAttributes;
        self.sheetMessageAttributes = [NMUIAlertController appearance].sheetMessageAttributes;
        self.sheetButtonAttributes = [NMUIAlertController appearance].sheetButtonAttributes;
        self.sheetButtonDisabledAttributes = [NMUIAlertController appearance].sheetButtonDisabledAttributes;
        self.sheetCancelButtonAttributes = [NMUIAlertController appearance].sheetCancelButtonAttributes;
        self.sheetDestructiveButtonAttributes = [NMUIAlertController appearance].sheetDestructiveButtonAttributes;
        self.sheetCancelButtonMarginTop = [NMUIAlertController appearance].sheetCancelButtonMarginTop;
        self.sheetContentCornerRadius = [NMUIAlertController appearance].sheetContentCornerRadius;
        self.sheetButtonHeight = [NMUIAlertController appearance].sheetButtonHeight;
        self.sheetHeaderBackgroundColor = [NMUIAlertController appearance].sheetHeaderBackgroundColor;
        self.sheetButtonBackgroundColor = [NMUIAlertController appearance].sheetButtonBackgroundColor;
        self.sheetButtonHighlightBackgroundColor = [NMUIAlertController appearance].sheetButtonHighlightBackgroundColor;
        self.sheetHeaderInsets = [NMUIAlertController appearance].sheetHeaderInsets;
        self.sheetTitleMessageSpacing = [NMUIAlertController appearance].sheetTitleMessageSpacing;
        self.isExtendBottomLayout = [NMUIAlertController appearance].isExtendBottomLayout;
    }
    
    self.shouldManageTextFieldsReturnEventAutomatically = YES;
    self.dismissKeyboardAutomatically = YES;
}

- (void)setAlertButtonAttributes:(NSDictionary<NSString *,id> *)alertButtonAttributes {
    _alertButtonAttributes = alertButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonAttributes:(NSDictionary<NSString *,id> *)sheetButtonAttributes {
    _sheetButtonAttributes = sheetButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonDisabledAttributes:(NSDictionary<NSString *,id> *)alertButtonDisabledAttributes {
    _alertButtonDisabledAttributes = alertButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonDisabledAttributes:(NSDictionary<NSString *,id> *)sheetButtonDisabledAttributes {
    _sheetButtonDisabledAttributes = sheetButtonDisabledAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertCancelButtonAttributes:(NSDictionary<NSString *,id> *)alertCancelButtonAttributes {
    _alertCancelButtonAttributes = alertCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetCancelButtonAttributes:(NSDictionary<NSString *,id> *)sheetCancelButtonAttributes {
    _sheetCancelButtonAttributes = sheetCancelButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)alertDestructiveButtonAttributes {
    _alertDestructiveButtonAttributes = alertDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setSheetDestructiveButtonAttributes:(NSDictionary<NSString *,id> *)sheetDestructiveButtonAttributes {
    _sheetDestructiveButtonAttributes = sheetDestructiveButtonAttributes;
    _needsUpdateAction = YES;
}

- (void)setAlertButtonBackgroundColor:(UIColor *)alertButtonBackgroundColor {
    _alertButtonBackgroundColor = alertButtonBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonBackgroundColor:(UIColor *)sheetButtonBackgroundColor {
    _sheetButtonBackgroundColor = sheetButtonBackgroundColor;
    [self updateExtendLayerAppearance];
    _needsUpdateAction = YES;
}

- (void)setAlertButtonHighlightBackgroundColor:(UIColor *)alertButtonHighlightBackgroundColor {
    _alertButtonHighlightBackgroundColor = alertButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setSheetButtonHighlightBackgroundColor:(UIColor *)sheetButtonHighlightBackgroundColor {
    _sheetButtonHighlightBackgroundColor = sheetButtonHighlightBackgroundColor;
    _needsUpdateAction = YES;
}

- (void)setAlertTitleAttributes:(NSDictionary<NSString *,id> *)alertTitleAttributes {
    _alertTitleAttributes = alertTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setAlertMessageAttributes:(NSDictionary<NSString *,id> *)alertMessageAttributes {
    _alertMessageAttributes = alertMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setSheetTitleAttributes:(NSDictionary<NSString *,id> *)sheetTitleAttributes {
    _sheetTitleAttributes = sheetTitleAttributes;
    _needsUpdateTitle = YES;
}

- (void)setSheetMessageAttributes:(NSDictionary<NSString *,id> *)sheetMessageAttributes {
    _sheetMessageAttributes = sheetMessageAttributes;
    _needsUpdateMessage = YES;
}

- (void)setAlertHeaderBackgroundColor:(UIColor *)alertHeaderBackgroundColor {
    _alertHeaderBackgroundColor = alertHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)setSheetHeaderBackgroundColor:(UIColor *)sheetHeaderBackgroundColor {
    _sheetHeaderBackgroundColor = sheetHeaderBackgroundColor;
    [self updateHeaderBackgrondColor];
}

- (void)updateHeaderBackgrondColor {
    if (self.preferredStyle == NMUIAlertControllerStyleActionSheet) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.sheetHeaderBackgroundColor; }
    } else if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
        if (self.headerScrollView) { self.headerScrollView.backgroundColor = self.alertHeaderBackgroundColor; }
    }
}

- (void)setAlertSeparatorColor:(UIColor *)alertSeparatorColor {
    _alertSeparatorColor = alertSeparatorColor;
    [self updateSeparatorColor];
}

- (void)setSheetSeparatorColor:(UIColor *)sheetSeparatorColor {
    _sheetSeparatorColor = sheetSeparatorColor;
    [self updateSeparatorColor];
}

- (void)updateSeparatorColor {
    UIColor *separatorColor = self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertSeparatorColor : self.sheetSeparatorColor;
    [self.alertActions enumerateObjectsUsingBlock:^(NMUIAlertAction * _Nonnull alertAction, NSUInteger idx, BOOL * _Nonnull stop) {
        alertAction.button.nmui_borderColor = separatorColor;
    }];
}

- (void)setAlertContentCornerRadius:(CGFloat)alertContentCornerRadius {
    _alertContentCornerRadius = alertContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setSheetContentCornerRadius:(CGFloat)sheetContentCornerRadius {
    _sheetContentCornerRadius = sheetContentCornerRadius;
    [self updateCornerRadius];
}

- (void)setIsExtendBottomLayout:(BOOL)isExtendBottomLayout {
    _isExtendBottomLayout = isExtendBottomLayout;
    if (isExtendBottomLayout) {
        self.extendLayer.hidden = NO;
        [self updateExtendLayerAppearance];
    } else {
        self.extendLayer.hidden = YES;
    }
}

- (void)updateExtendLayerAppearance {
    if (self.extendLayer) {
        self.extendLayer.backgroundColor = self.sheetButtonBackgroundColor.CGColor;
    }
}

- (void)updateCornerRadius {
    if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
        if (self.containerView) { self.containerView.layer.cornerRadius = self.alertContentCornerRadius; self.containerView.clipsToBounds = YES; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.alertContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = NO;}
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = 0; self.scrollWrapView.clipsToBounds = NO; }
    } else {
        if (self.containerView) { self.containerView.layer.cornerRadius = 0; self.containerView.clipsToBounds = NO; }
        if (self.cancelButtonVisualEffectView) { self.cancelButtonVisualEffectView.layer.cornerRadius = self.sheetContentCornerRadius; self.cancelButtonVisualEffectView.clipsToBounds = YES; }
        if (self.scrollWrapView) { self.scrollWrapView.layer.cornerRadius = self.sheetContentCornerRadius; self.scrollWrapView.clipsToBounds = YES; }
    }
}

- (void)setAlertTextFieldFont:(UIFont *)alertTextFieldFont {
    _alertTextFieldFont = alertTextFieldFont;
    [self.textFields enumerateObjectsUsingBlock:^(NMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.font = alertTextFieldFont;
    }];
}

- (void)setAlertTextFieldBorderColor:(UIColor *)alertTextFieldBorderColor {
    _alertTextFieldBorderColor = alertTextFieldBorderColor;
    [self.textFields enumerateObjectsUsingBlock:^(NMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.layer.borderColor = alertTextFieldBorderColor.CGColor;
    }];
}

- (void)setAlertTextFieldTextColor:(UIColor *)alertTextFieldTextColor {
    _alertTextFieldTextColor = alertTextFieldTextColor;
    [self.textFields enumerateObjectsUsingBlock:^(NMUITextField * _Nonnull textField, NSUInteger idx, BOOL * _Nonnull stop) {
        textField.textColor = alertTextFieldTextColor;
    }];
}

- (void)setMainVisualEffectView:(UIView *)mainVisualEffectView {
    if (!mainVisualEffectView) {
        // 不允许为空
        mainVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _mainVisualEffectView != mainVisualEffectView;
    if (isValueChanged) {
        if ([_mainVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_mainVisualEffectView).contentView nmui_removeAllSubviews];
        } else {
            [_mainVisualEffectView nmui_removeAllSubviews];
        }
        [_mainVisualEffectView removeFromSuperview];
        _mainVisualEffectView = nil;
    }
    _mainVisualEffectView = mainVisualEffectView;
    if (isValueChanged) {
        [self.scrollWrapView insertSubview:_mainVisualEffectView atIndex:0];
        [self updateCornerRadius];
    }
}

- (void)setCancelButtonVisualEffectView:(UIView *)cancelButtonVisualEffectView {
    if (!cancelButtonVisualEffectView) {
        // 不允许为空
        cancelButtonVisualEffectView = [[UIView alloc] init];
    }
    BOOL isValueChanged = _cancelButtonVisualEffectView != cancelButtonVisualEffectView;
    if (isValueChanged) {
        if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)_cancelButtonVisualEffectView).contentView nmui_removeAllSubviews];
        } else {
            [_cancelButtonVisualEffectView nmui_removeAllSubviews];
        }
        [_cancelButtonVisualEffectView removeFromSuperview];
        _cancelButtonVisualEffectView = nil;
    }
    _cancelButtonVisualEffectView = cancelButtonVisualEffectView;
    if (isValueChanged) {
        [self.containerView addSubview:_cancelButtonVisualEffectView];
        if (self.preferredStyle == NMUIAlertControllerStyleActionSheet && self.cancelAction && !self.cancelAction.button.superview) {
            if ([_cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
                UIVisualEffectView *effectView = (UIVisualEffectView *)_cancelButtonVisualEffectView;
                [effectView.contentView addSubview:self.cancelAction.button];
            } else {
                [_cancelButtonVisualEffectView addSubview:self.cancelAction.button];
            }
        }
        
        [self updateCornerRadius];
    }
}

+ (nonnull instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(NMUIAlertControllerStyle)preferredStyle {
    NMUIAlertController *alertController = [[self alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    if (alertController) {
        return alertController;
    }
    return nil;
}

- (nonnull instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(NMUIAlertControllerStyle)preferredStyle {
    self = [self init];
    if (self) {
        
        self.preferredStyle = preferredStyle;
        
        self.shouldRespondMaskViewTouch = preferredStyle == NMUIAlertControllerStyleActionSheet;
        
        self.alertActions = [[NSMutableArray alloc] init];
        self.alertTextFields = [[NSMutableArray alloc] init];
        self.destructiveActions = [[NSMutableArray alloc] init];
        
        self.containerView = [[UIView alloc] init];
        
        self.maskView = [[UIControl alloc] init];
        self.maskView.alpha = 0;
        self.maskView.backgroundColor = UIColorMask;
        [self.maskView addTarget:self action:@selector(handleMaskViewEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        self.scrollWrapView = [[UIView alloc] init];
        self.mainVisualEffectView = [[UIView alloc] init];
        self.cancelButtonVisualEffectView = [[UIView alloc] init];
        self.headerScrollView = [[UIScrollView alloc] init];
        self.headerScrollView.scrollsToTop = NO;
        self.buttonScrollView = [[UIScrollView alloc] init];
        self.buttonScrollView.scrollsToTop = NO;
        if (@available(iOS 11, *)) {
            self.headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.buttonScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        self.extendLayer = [CALayer layer];
        self.extendLayer.hidden = !self.isExtendBottomLayout;
        [self.extendLayer nmui_removeDefaultAnimations];
        
        self.title = title;
        self.message = message;
        
        [self updateHeaderBackgrondColor];
        [self updateExtendLayerAppearance];
        
    }
    return self;
}

- (NMUIAlertControllerStyle)preferredStyle {
    return PreferredValueForDeviceIncludingiPad(1, 0, 0, 0, 0) > 0 ? NMUIAlertControllerStyleAlert : _preferredStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.scrollWrapView];
    [self.scrollWrapView addSubview:self.headerScrollView];
    [self.scrollWrapView addSubview:self.buttonScrollView];
    [self.containerView.layer addSublayer:self.extendLayer];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!_customView;
    CGFloat contentOriginY = 0;
    
    self.maskView.frame = self.view.bounds;
    
    if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
        self.containerView.nmui_width = fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.alertContentMargin));
        self.scrollWrapView.nmui_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, NMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, NMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 输入框布局
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                UITextField *textField = self.alertTextFields[i];
                textField.frame = CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, 25);
                contentOriginY = CGRectGetMaxY(textField.frame) - 1;
            }
            contentOriginY += 16;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView的布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<NMUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (newOrderActions.count > 0) {
            BOOL verticalLayout = YES;
            if (self.alertActions.count == 2) {
                CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
                NMUIAlertAction *action1 = newOrderActions[0];
                NMUIAlertAction *action2 = newOrderActions[1];
                CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMax];
                CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMax];
                if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
                    verticalLayout = NO;
                }
            }
            if (!verticalLayout) {
                // 对齐系统，先 add 的在右边，后 add 的在左边
                NMUIAlertAction *leftAction = newOrderActions[1];
                leftAction.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                leftAction.button.nmui_borderPosition = NMUIViewBorderPositionTop|NMUIViewBorderPositionRight;
                NMUIAlertAction *rightAction = newOrderActions[0];
                rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame), contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds) / 2, self.alertButtonHeight);
                rightAction.button.nmui_borderPosition = NMUIViewBorderPositionTop;
                contentOriginY = CGRectGetMaxY(leftAction.button.frame);
            } else {
                for (int i = 0; i < newOrderActions.count; i++) {
                    NMUIAlertAction *action = newOrderActions[i];
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.alertButtonHeight);
                    action.button.nmui_borderPosition = NMUIViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        // 按钮scrollView的布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最后布局
        CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight - 20) {
            screenSpaceHeight -= 20;
            CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            screenSpaceHeight += 20;
        }
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.scrollWrapView.bounds));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
    }
    
    else if (self.preferredStyle == NMUIAlertControllerStyleActionSheet) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
        self.containerView.nmui_width = fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.sheetContentMargin));
        self.scrollWrapView.nmui_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, NMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight, NMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [_customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            _customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(_customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮的布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<NMUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.alertActions.count > 0) {
            contentOriginY = (hasTitle || hasMessage || hasCustomView) ? contentOriginY : contentOriginY;
            for (int i = 0; i < newOrderActions.count; i++) {
                NMUIAlertAction *action = newOrderActions[i];
                if (action.style == NMUIAlertActionStyleCancel && i == newOrderActions.count - 1) {
                    continue;
                } else {
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds), self.sheetButtonHeight);
                    action.button.nmui_borderPosition = NMUIViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        // 按钮scrollView布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最终布局
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
        if (self.cancelAction) {
            self.cancelButtonVisualEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
            self.cancelAction.button.frame = self.cancelButtonVisualEffectView.bounds;
            contentOriginY = CGRectGetMaxY(self.cancelButtonVisualEffectView.frame);
        }
        // 把上下的margin都加上用于跟整个屏幕的高度做比较
        CGFloat contentHeight = contentOriginY + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight) {
            CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.button.bounds) + self.sheetCancelButtonMarginTop) : 0);
            screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
            CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            self.scrollWrapView.frame =  CGRectSetHeight(self.scrollWrapView.frame, CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds));
            if (self.cancelAction) {
                self.cancelButtonVisualEffectView.frame = CGRectSetY(self.cancelButtonVisualEffectView.frame, CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
            screenSpaceHeight += (cancelButtonAreaHeight + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin));
        } else {
            // 如果小于屏幕高度，则把顶部的top减掉
            contentHeight -= self.sheetContentMargin.top;
        }
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, screenSpaceHeight - contentHeight - SafeAreaInsetsConstantForDeviceWithNotch.bottom, CGRectGetWidth(self.containerView.bounds), contentHeight + (self.isExtendBottomLayout ? SafeAreaInsetsConstantForDeviceWithNotch.bottom : 0));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
        
        self.extendLayer.frame = CGRectFlatMake(0, CGRectGetHeight(self.containerView.bounds) - SafeAreaInsetsConstantForDeviceWithNotch.bottom - 1, CGRectGetWidth(self.containerView.bounds), SafeAreaInsetsConstantForDeviceWithNotch.bottom + 1);
    }
}

- (NSArray<NMUIAlertAction *> *)orderedAlertActions:(NSArray<NMUIAlertAction *> *)actions {
    NSMutableArray<NMUIAlertAction *> *newActions = [[NSMutableArray alloc] init];
    // 按照用户addAction的先后顺序来排序
    if (self.orderActionsByAddedOrdered) {
        [newActions addObjectsFromArray:self.alertActions];
        // 取消按钮不参与排序，所以先移除，在最后再重新添加
        if (self.cancelAction) {
            [newActions removeObject:self.cancelAction];
        }
    } else {
        for (NMUIAlertAction *action in self.alertActions) {
            if (action.style != NMUIAlertActionStyleCancel && action.style != NMUIAlertActionStyleDestructive) {
                [newActions addObject:action];
            }
        }
        for (NMUIAlertAction *action in self.destructiveActions) {
            [newActions addObject:action];
        }
    }
    if (self.cancelAction) {
        [newActions addObject:self.cancelAction];
    }
    return newActions;
}

- (void)initModalPresentationController {
    _modalPresentationViewController = [[NMUIModalPresentationViewController alloc] init];
    self.modalPresentationViewController.delegate = self;
    self.modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
    self.modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
    self.modalPresentationViewController.dimmingView = nil;
    self.modalPresentationViewController.contentViewController = self;
    [self customModalPresentationControllerAnimation];
}

- (void)customModalPresentationControllerAnimation {
    
    __weak __typeof(self)weakSelf = self;
    
    self.modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakSelf.view.frame = CGRectMake(0, 0, CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
        weakSelf.keyboardHeight = keyboardHeight;
        [weakSelf.view setNeedsLayout];
    };
    
    self.modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
            weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
            [UIView animateWithDuration:0.25f delay:0 options:NMUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == NMUIAlertControllerStyleActionSheet) {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            [UIView animateWithDuration:0.25f delay:0 options:NMUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 1;
                weakSelf.containerView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
    
    self.modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
            [UIView animateWithDuration:0.25f delay:0 options:NMUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.alpha = 0;
            } completion:^(BOOL finished) {
                weakSelf.containerView.alpha = 1;
                if (completion) {
                    completion(finished);
                }
            }];
        } else if (self.preferredStyle == NMUIAlertControllerStyleActionSheet) {
            [UIView animateWithDuration:0.25f delay:0 options:NMUIViewAnimationOptionsCurveOut animations:^{
                weakSelf.maskView.alpha = 0;
                weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
        }
    };
}

- (void)showWithAnimated:(BOOL)animated {
    if (self.willShow || self.showing) {
        return;
    }
    self.willShow = YES;
    
    if (self.alertTextFields.count > 0) {
        [self.alertTextFields.firstObject becomeFirstResponder];
    } else {
        // iOS 10 及以上的版本在显示 window 时都会自动降下当前 App 的键盘，所以只有 iOS 9 及以下才需要手动处理
        if (@available(iOS 10.0, *)) {
        } else {
            if (self.dismissKeyboardAutomatically && [NMUIKeyboardManager isKeyboardVisible]) {
                [UIApplication.sharedApplication sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            }
        }

    }
    if (_needsUpdateAction) {
        [self updateAction];
    }
    if (_needsUpdateTitle) {
        [self updateTitleLabel];
    }
    if (_needsUpdateMessage) {
        [self updateMessageLabel];
    }
    
    [self initModalPresentationController];
    
    if ([self.delegate respondsToSelector:@selector(willShowAlertController:)]) {
        [self.delegate willShowAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController showWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.maskView.alpha = 1;
        weakSelf.willShow = NO;
        weakSelf.showing = YES;
        if (weakSelf.isNeedsHideAfterAlertShowed) {
            [weakSelf hideWithAnimated:weakSelf.isAnimatedForHideAfterAlertShowed];
            weakSelf.isNeedsHideAfterAlertShowed = NO;
            weakSelf.isAnimatedForHideAfterAlertShowed = NO;
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didShowAlertController:)]) {
            [weakSelf.delegate didShowAlertController:weakSelf];
        }
    }];
    
    // 增加alertController计数
    alertControllerCount++;
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:NULL];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(shouldHideAlertController:)] && ![self.delegate shouldHideAlertController:self]) {
        return;
    }
    
    if (!self.showing) {
        if (self.willShow) {
            self.isNeedsHideAfterAlertShowed = YES;
            self.isAnimatedForHideAfterAlertShowed = animated;
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(willHideAlertController:)]) {
        [self.delegate willHideAlertController:self];
    }
    
    __weak __typeof(self)weakSelf = self;
    
    [self.modalPresentationViewController hideWithAnimated:animated completion:^(BOOL finished) {
        weakSelf.modalPresentationViewController = nil;
        weakSelf.willShow = NO;
        weakSelf.showing = NO;
        weakSelf.maskView.alpha = 0;
        if (self.preferredStyle == NMUIAlertControllerStyleAlert) {
            weakSelf.containerView.alpha = 0;
        } else {
            weakSelf.containerView.layer.transform = CATransform3DMakeTranslation(0, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetMinY(weakSelf.containerView.frame), 0);
        }
        if ([weakSelf.delegate respondsToSelector:@selector(didHideAlertController:)]) {
            [weakSelf.delegate didHideAlertController:weakSelf];
        }
        if (completion) completion();
    }];
    
    // 减少alertController计数
    alertControllerCount--;
}

- (void)addAction:(nonnull NMUIAlertAction *)action {
    if (action.style == NMUIAlertActionStyleCancel && self.cancelAction) {
        [NSException raise:@"NMUIAlertController使用错误" format:@"同一个alertController不可以同时添加两个cancel按钮"];
    }
    if (action.style == NMUIAlertActionStyleCancel) {
        self.cancelAction = action;
    }
    if (action.style == NMUIAlertActionStyleDestructive) {
        [self.destructiveActions addObject:action];
    }
    // 只有ActionSheet的取消按钮不参与滚动
    if (self.preferredStyle == NMUIAlertControllerStyleActionSheet && action.style == NMUIAlertActionStyleCancel) {
        if (!self.cancelButtonVisualEffectView.superview) {
            [self.containerView addSubview:self.cancelButtonVisualEffectView];
        }
        if ([self.cancelButtonVisualEffectView isKindOfClass:[UIVisualEffectView class]]) {
            [((UIVisualEffectView *)self.cancelButtonVisualEffectView).contentView addSubview:action.button];
        } else {
            [self.cancelButtonVisualEffectView addSubview:action.button];
        }
    } else {
        [self.buttonScrollView addSubview:action.button];
    }
    action.delegate = self;
    [self.alertActions addObject:action];
}

- (void)addCancelAction {
    NMUIAlertAction *action = [NMUIAlertAction actionWithTitle:@"取消" style:NMUIAlertActionStyleCancel handler:nil];
    [self addAction:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(NMUITextField *textField))configurationHandler {
    if (_customView) {
        [NSException raise:@"NMUIAlertController使用错误" format:@"UITextField和CustomView不能共存"];
    }
    if (self.preferredStyle == NMUIAlertControllerStyleActionSheet) {
        [NSException raise:@"NMUIAlertController使用错误" format:@"Sheet类型不运行添加UITextField"];
    }
    NMUITextField *textField = [[NMUITextField alloc] init];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.backgroundColor = UIColorWhite;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.font = self.alertTextFieldFont;
    textField.textColor = self.alertTextFieldTextColor;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.layer.borderColor = self.alertTextFieldBorderColor.CGColor;
    textField.layer.borderWidth = PixelOne;
    [self.headerScrollView addSubview:textField];
    [self.alertTextFields addObject:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)addCustomView:(UIView *)view {
    if (view && self.alertTextFields.count > 0) {
        [NSException raise:@"NMUIAlertController使用错误" format:@"UITextField 和 customView 不能共存"];
    }
    if (_customView && _customView != view) {
        [_customView removeFromSuperview];
    }
    _customView = view;
    if (_customView) {
        [self.headerScrollView addSubview:_customView];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.titleLabel];
    }
    if (!_title || [_title isEqualToString:@""]) {
        self.titleLabel.hidden = YES;
    } else {
        self.titleLabel.hidden = NO;
        [self updateTitleLabel];
    }
}

- (NSString *)title {
    return _title;
}

- (void)updateTitleLabel {
    if (self.titleLabel && !self.titleLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.title attributes:self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertTitleAttributes : self.sheetTitleAttributes];
        self.titleLabel.attributedText = attributeString;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (!self.messageLabel) {
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        [self.headerScrollView addSubview:self.messageLabel];
    }
    if (!_message || [_message isEqualToString:@""]) {
        self.messageLabel.hidden = YES;
    } else {
        self.messageLabel.hidden = NO;
        [self updateMessageLabel];
    }
}

- (void)updateMessageLabel {
    if (self.messageLabel && !self.messageLabel.hidden) {
        NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self.message attributes:self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertMessageAttributes : self.sheetMessageAttributes];
        self.messageLabel.attributedText = attributeString;
    }
}

- (NSArray<NMUIAlertAction *> *)actions {
    return [self.alertActions copy];
}

- (void)updateAction {
    
    for (NMUIAlertAction *alertAction in self.alertActions) {
        
        UIColor *backgroundColor = self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertButtonBackgroundColor : self.sheetButtonBackgroundColor;
        UIColor *highlightBackgroundColor = self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertButtonHighlightBackgroundColor : self.sheetButtonHighlightBackgroundColor;
        UIColor *borderColor = self.preferredStyle == NMUIAlertControllerStyleAlert ? self.alertSeparatorColor : self.sheetSeparatorColor;
        
        alertAction.button.clipsToBounds = alertAction.style == NMUIAlertActionStyleCancel;
        alertAction.button.backgroundColor = backgroundColor;
        alertAction.button.highlightedBackgroundColor = highlightBackgroundColor;
        alertAction.button.nmui_borderColor = borderColor;
        
        NSAttributedString *attributeString = nil;
        if (alertAction.style == NMUIAlertActionStyleCancel) {
            
            NSDictionary *attributes = (self.preferredStyle == NMUIAlertControllerStyleAlert) ? self.alertCancelButtonAttributes : self.sheetCancelButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else if (alertAction.style == NMUIAlertActionStyleDestructive) {
            
            NSDictionary *attributes = (self.preferredStyle == NMUIAlertControllerStyleAlert) ? self.alertDestructiveButtonAttributes : self.sheetDestructiveButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
            
        } else {
            
            NSDictionary *attributes = (self.preferredStyle == NMUIAlertControllerStyleAlert) ? self.alertButtonAttributes : self.sheetButtonAttributes;
            if (alertAction.buttonAttributes) {
                attributes = alertAction.buttonAttributes;
            }
            
            attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        }
        
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        NSDictionary *attributes = (self.preferredStyle == NMUIAlertControllerStyleAlert) ? self.alertButtonDisabledAttributes : self.sheetButtonDisabledAttributes;
        if (alertAction.buttonDisabledAttributes) {
            attributes = alertAction.buttonDisabledAttributes;
        }
        
        attributeString = [[NSAttributedString alloc] initWithString:alertAction.title attributes:attributes];
        [alertAction.button setAttributedTitle:attributeString forState:UIControlStateDisabled];
        
        if ([alertAction.button imageForState:UIControlStateNormal]) {
            NSRange range = NSMakeRange(0, attributeString.length);
            UIColor *disabledColor = [attributeString attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
            [alertAction.button setImage:[[alertAction.button imageForState:UIControlStateNormal] nmui_imageWithTintColor:disabledColor] forState:UIControlStateDisabled];
        }
    }
}

- (NSArray<NMUITextField *> *)textFields {
    return [self.alertTextFields copy];
}

- (void)handleMaskViewEvent:(id)sender {
    if (_shouldRespondMaskViewTouch) {
        [self hideWithAnimated:YES completion:NULL];
    }
}

#pragma mark - <NMUIAlertActionDelegate>

- (void)didClickAlertAction:(NMUIAlertAction *)alertAction {
    [self hideWithAnimated:YES completion:^{
        if (alertAction.handler) {
            alertAction.handler(self, alertAction);
        }
    }];
}

#pragma mark - <NMUIModalPresentationComponentProtocol>

- (void)hideModalPresentationComponent {
    [self hideWithAnimated:NO completion:NULL];
}

#pragma mark - <NMUIModalPresentationViewControllerDelegate>

- (BOOL)shouldHideModalPresentationViewController:(NMUIModalPresentationViewController *)controller {
    if ([self.delegate respondsToSelector:@selector(shouldHideAlertController:)]) {
        return [self.delegate shouldHideAlertController:self];
    }
    return YES;
}

#pragma mark - <NMUITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(NMUITextField *)textField {
    if (!self.shouldManageTextFieldsReturnEventAutomatically) {
        return NO;
    }
    
    if (![self.textFields containsObject:textField]) {
        return NO;
    }
    
    // 最后一个输入框，默认的 return 行为与 iOS 9-11 保持一致，也即：
    // 如果 action = 1，则自动响应这个 action 的事件
    // 如果 action = 2，并且其中有一个是 Cancel，则响应另一个 action 的事件，如果其中不存在 Cancel，则降下键盘，不响应任何 action
    // 如果 action > 2，则降下键盘，不响应任何 action
    if (textField == self.textFields.lastObject) {
        if (self.actions.count == 1) {
            [self.actions.firstObject.button sendActionsForControlEvents:UIControlEventTouchUpInside];
        } else if (self.actions.count == 2) {
            if (self.cancelAction) {
                NMUIAlertAction *targetAction = self.actions.firstObject == self.cancelAction ? self.actions.lastObject : self.actions.firstObject;
                [targetAction.button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self.view endEditing:YES];
        return NO;
    }
    // 非最后一个输入框，则默认的 return 行为是聚焦到下一个输入框
    NSUInteger index = [self.textFields indexOfObject:textField];
    [self.textFields[index + 1] becomeFirstResponder];
    return NO;
}

@end

@implementation NMUIAlertController (Manager)

+ (BOOL)isAnyAlertControllerVisible {
    return alertControllerCount > 0;
}

@end

