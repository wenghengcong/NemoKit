//
//  NMUINavigationButton.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUINavigationButton.h"
#import "NMBCore.h"
#import "UIImage+NMUI.h"
#import "UIColor+NMUI.h"
#import "UIViewController+NMUI.h"
#import "NMUINavigationController.h"
#import "NMBFLog.h"
#import "UIControl+NMUI.h"
#import "UIView+NMUI.h"

typedef NS_ENUM(NSInteger, NMUINavigationButtonPosition) {
    NMUINavigationButtonPositionNone = -1,  // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    NMUINavigationButtonPositionLeft,       // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用NMUINavigationButtonPositionNone
    NMUINavigationButtonPositionRight,      // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用NMUINavigationButtonPositionNone
};

@interface NMUINavigationButton()

@property(nonatomic, assign) NMUINavigationButtonPosition buttonPosition;
@property(nonatomic, strong) UIImage *defaultHighlightedImage;// 在 set normal image 时自动拿 normal image 加 alpha 作为 highlighted image
@property(nonatomic, strong) UIImage *defaultDisabledImage;// 在 set normal image 时自动拿 normal image 加 alpha 作为 disabled image
@end


@implementation NMUINavigationButton

- (instancetype)init {
    return [self initWithType:NMUINavigationButtonTypeNormal];
}

- (instancetype)initWithType:(NMUINavigationButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(NMUINavigationButtonType)type title:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        _type = type;
        self.buttonPosition = NMUINavigationButtonPositionNone;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:NMUINavigationButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        [self sizeToFit];
    }
    return self;
}

- (void)renderButtonStyle {
    UIFont *font = NavBarButtonFont;
    if (font) {
        self.titleLabel.font = font;
    }
    self.titleLabel.backgroundColor = UIColorClear;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.contentMode = UIViewContentModeCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    
    // UIBarButtonItem 默认都是跟随 tintColor 的，所以这里让图片也是用 alwaysTemplate 模式
    self.adjustsImageTintColorAutomatically = YES;
    
    if (self.type == NMUINavigationButtonTypeImage) {
        if (@available(iOS 11, *)) {
            // 让 iOS 11 及以后也能走到 alignmentRectInsets，iOS 10 及以前的系统就算不置为 NO 也可以走到 alignmentRectInsets，从而保证 image 类型的按钮的布局、间距与系统的保持一致
            self.translatesAutoresizingMaskIntoConstraints = NO;
        }
    }
    
    // 系统默认对 highlighted 和 disabled 的图片的表现是变身色，但 UIBarButtonItem 是 alpha，为了与 UIBarButtonItem  表现一致，这里禁用了 UIButton 默认的行为，然后通过重写 setImage:forState:，自动将 normal image 处理为对应的 highlighted image 和 disabled image
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    switch (self.type) {
        case NMUINavigationButtonTypeNormal:
            break;
        case NMUINavigationButtonTypeImage:
            // 拓展宽度，以保证用 leftBarButtonItems/rightBarButtonItems 时，按钮与按钮之间间距与系统的保持一致
            self.contentEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 11);
            break;
        case NMUINavigationButtonTypeBold: {
            font = NavBarButtonFontBold;
            if (font) {
                self.titleLabel.font = font;
            }
        }
            break;
        case NMUINavigationButtonTypeBack: {
            UIImage *backIndicatorImage = [UINavigationBar appearance].backIndicatorImage;
            if (!backIndicatorImage) {
                // 配置表没有自定义的图片，则按照系统的返回按钮图片样式创建一张，颜色按照 tintColor 来
                UIColor *tintColor = NMUICMIActivated ? NavBarTintColor : UIColor.nmui_systemTintColor;
                backIndicatorImage = [UIImage nmui_imageWithShape:NMUIImageShapeNavBack size:CGSizeMake(13, 23) lineWidth:3 tintColor:tintColor];
            }
            [self setImage:backIndicatorImage forState:UIControlStateNormal];
            [self setImage:[backIndicatorImage nmui_imageWithAlpha:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setImage:[backIndicatorImage nmui_imageWithAlpha:NavBarDisabledAlpha] forState:UIControlStateDisabled];
            
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            UIOffset titleOffsetBaseOnSystem = UIOffsetMake(IOS_VERSION >= 11.0 ? 6 : 7, 0);// 经过这些数值的调整后，自定义返回按钮的位置才能和系统默认返回按钮的位置对准，而配置表里设置的值是在这个调整的基础上再调整
            UIOffset configurationOffset = NavBarBarBackButtonTitlePositionAdjustment;
            self.titleEdgeInsets = UIEdgeInsetsMake(titleOffsetBaseOnSystem.vertical + configurationOffset.vertical, titleOffsetBaseOnSystem.horizontal + configurationOffset.horizontal, -titleOffsetBaseOnSystem.vertical - configurationOffset.vertical, -titleOffsetBaseOnSystem.horizontal - configurationOffset.horizontal);
            self.contentEdgeInsets = UIEdgeInsetsMake(IOS_VERSION < 11.0 ? 1 : 0,// iOS 11 以前，y 值偏移一点
                                                      0,
                                                      0,
                                                      self.titleEdgeInsets.left);
        }
            break;
            
        default:
            break;
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (image && self.adjustsImageTintColorAutomatically) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if (image && [self imageForState:state] != image) {
        if (state == UIControlStateNormal) {
            // 将 normal image 处理成对应的 highlighted image 和 disabled image
            self.defaultHighlightedImage = [[image nmui_imageWithAlpha:NavBarHighlightedAlpha] imageWithRenderingMode:image.renderingMode];
            [self setImage:self.defaultHighlightedImage forState:UIControlStateHighlighted];
            
            self.defaultDisabledImage = [[image nmui_imageWithAlpha:NavBarDisabledAlpha] imageWithRenderingMode:image.renderingMode];
            [self setImage:self.defaultDisabledImage forState:UIControlStateDisabled];
        } else {
            // 如果业务主动设置了非 normal 状态的 image，则把之前 NMUI 自动加上的两个 image 去掉，相当于认为业务希望完全控制这个按钮在所有 state 下的图片
            if (image != self.defaultHighlightedImage && image != self.defaultDisabledImage) {
                if ([self imageForState:UIControlStateHighlighted] == self.defaultHighlightedImage && state != UIControlStateHighlighted) {
                    [self setImage:nil forState:UIControlStateHighlighted];
                }
                if ([self imageForState:UIControlStateDisabled] == self.defaultDisabledImage && state != UIControlStateDisabled) {
                    [self setImage:nil forState:UIControlStateDisabled];
                }
            }
        }
    }
    
    [super setImage:image forState:state];
}

- (void)setAdjustsImageTintColorAutomatically:(BOOL)adjustsImageTintColorAutomatically {
    BOOL valueDifference = _adjustsImageTintColorAutomatically != adjustsImageTintColorAutomatically;
    _adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically;
    
    if (valueDifference) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)updateImageRenderingModeIfNeeded {
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected), @(UIControlStateSelected|UIControlStateHighlighted), @(UIControlStateDisabled)];
        
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:number.unsignedIntegerValue];
            if (!image) {
                return;
            }
            
            if (self.adjustsImageTintColorAutomatically) {
                // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 setImage:forState 里去做就行了
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用 template 的模式渲染，并且之前是使用 template 的，则把 renderingMode 改回 original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

// 自定义nav按钮，需要根据这个来修改title的三态颜色。
- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarDisabledAlpha] forState:UIControlStateDisabled];
}

// 对按钮内容添加偏移，让UIBarButtonItem适配最新设备的系统行为，统一位置。注意 iOS 11 及以后，只有 image 类型的才会走进来
- (UIEdgeInsets)alignmentRectInsets {
    
    UIEdgeInsets insets = [super alignmentRectInsets];
    
    if (self.type == NMUINavigationButtonTypeNormal || self.type == NMUINavigationButtonTypeBold) {
        // 文字类型的按钮，分别对最左、最右那个按钮调整 inset（这里与 UINavigationItem(NMUINavigationButton) 里的 position 赋值配合使用）
        if (@available(iOS 10, *)) {
        } else {
            if (self.buttonPosition == NMUINavigationButtonPositionLeft) {
                insets.left = 8;
            } else if (self.buttonPosition == NMUINavigationButtonPositionRight) {
                insets.right = 8;
            }
        }
        
        // 对于奇数大小的字号，不同 iOS 版本的偏移策略不同，统一一下
        if (self.titleLabel.font.pointSize / 2.0 > 0) {
            insets.top = -PixelOne;
            insets.bottom = PixelOne;
        }
    } else if (self.type == NMUINavigationButtonTypeImage) {
        // 图片类型的按钮，分别对最左、最右那个按钮调整 inset（这里与 UINavigationItem(NMUINavigationButton) 里的 position 赋值配合使用）
        if (self.buttonPosition == NMUINavigationButtonPositionLeft) {
            insets.left = 11;
        } else if (self.buttonPosition == NMUINavigationButtonPositionRight) {
            insets.right = 11;
        }
        
        insets.top = 1;
    } else if (self.type == NMUINavigationButtonTypeBack) {
        insets.top = PixelOne;
        if (@available(iOS 11, *)) {
        } else {
            insets.left = 8;
        }
    }
    
    return insets;
}

@end

@implementation UIBarButtonItem (NMUINavigationButton)

+ (instancetype)nmui_itemWithButton:(nullable NMUINavigationButton *)button target:(nullable id)target action:(nullable SEL)action {
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (instancetype)nmui_itemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action {
    return [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)nmui_itemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

+ (instancetype)nmui_itemWithBoldTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:target action:action];
}

+ (instancetype)nmui_backItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action {
    NMUINavigationButton *button = [[NMUINavigationButton alloc] initWithType:NMUINavigationButtonTypeBack title:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

+ (instancetype)nmui_backItemWithTarget:(nullable id)target action:(nullable SEL)action {
    NSString *backTitle = nil;
    if (NeedsBackBarButtonItemTitle) {
        backTitle = @"返回"; // 默认文字用返回
        if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)target;
            UIViewController *previousViewController = viewController.nmui_previousViewController;
            if (previousViewController.navigationItem.backBarButtonItem) {
                // 如果前一个界面有主动设置返回按钮的文字，则取这个文字
                backTitle = previousViewController.navigationItem.backBarButtonItem.title;
            } else if ([viewController respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
                // 否则看是否有通过 NMUI 提供的接口来设置返回按钮的文字，有就用它的值
                backTitle = [((UIViewController<NMUINavigationControllerAppearanceDelegate> *)viewController) backBarButtonItemTitleWithPreviousViewController:previousViewController];
            } else if (previousViewController.title) {
                // 否则取上一个界面的标题
                backTitle = previousViewController.title;
            }
        }
    } else {
        backTitle = @" ";
    }
    
    return [UIBarButtonItem nmui_backItemWithTitle:backTitle target:target action:action];
}

+ (instancetype)nmui_closeItemWithTarget:(nullable id)target action:(nullable SEL)action {
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:NavBarCloseButtonImage style:UIBarButtonItemStylePlain target:target action:action];
    closeItem.accessibilityLabel = @"关闭";
    return closeItem;
}

+ (instancetype)nmui_fixedSpaceItemWithWidth:(CGFloat)width {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    item.width = width;
    return item;
}

+ (instancetype)nmui_flexibleSpaceItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
}

@end

@interface UIBarButtonItem (NMUINavigationButton_Private)

/// 判断当前的 UIBarButtonItem 是否是 NMUINavigationButton
@property(nonatomic, assign, readonly) BOOL nmui_isCustomizedBarButtonItem;

/// 判断当前的 UIBarButtonItem 是否是用 NMUINavigationButton 自定义返回按钮生成的
@property(nonatomic, assign, readonly) BOOL nmui_isCustomizedBackBarButtonItem;

/// 获取内部的 NMUINavigationButton（如果有的话）
@property(nonatomic, strong, readonly) NMUINavigationButton *nmui_navigationButton;
@end

@interface UINavigationItem (NMUINavigationButton)

@property(nonatomic, weak, readonly) UINavigationBar *nmui_navigationBar;
@property(nonatomic, copy) NSArray<UIBarButtonItem *> *tempLeftBarButtonItems;
@property(nonatomic, copy) NSArray<UIBarButtonItem *> *tempRightBarButtonItems;
@end

@interface UIViewController (NMUINavigationButton)

@end

@interface UINavigationBar (NMUINavigationButton)

/// 获取 navigationBar 内部的 contentView
@property(nonatomic, weak, readonly) UIView *nmui_contentView;

/// 判断当前的 UINavigationBar 的返回按钮是不是自定义的
@property(nonatomic, readonly) BOOL nmui_customizingBackBarButtonItem;
@end

@implementation UIBarButtonItem (NMUINavigationButton_Private)

- (BOOL)nmui_isCustomizedBarButtonItem {
    if (!self.customView) {
        return NO;
    }
    return [self.customView isKindOfClass:[NMUINavigationButton class]];
}

- (BOOL)nmui_isCustomizedBackBarButtonItem {
    return self.nmui_isCustomizedBarButtonItem && ((NMUINavigationButton *)self.customView).type == NMUINavigationButtonTypeBack;
}

- (NMUINavigationButton *)nmui_navigationButton {
    if ([self.customView isKindOfClass:[NMUINavigationButton class]]) {
        return (NMUINavigationButton *)self.customView;
    }
    return nil;
}

@end

@implementation UINavigationItem (NMUINavigationButton)

NMBFSynthesizeIdCopyProperty(tempLeftBarButtonItems, setTempLeftBarButtonItems)
NMBFSynthesizeIdCopyProperty(tempRightBarButtonItems, setTempRightBarButtonItems)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setLeftBarButtonItem:animated:),
            @selector(setLeftBarButtonItems:animated:),
            @selector(setRightBarButtonItem:animated:),
            @selector(setRightBarButtonItems:animated:),
            
            // 如果被拦截，则 getter 也要返回被缓存的 item，否则会出现这个 bug：https://github.com/Tencent/QMUI_iOS/issues/362
            @selector(leftBarButtonItem),
            @selector(leftBarButtonItems),
            @selector(rightBarButtonItem),
            @selector(rightBarButtonItems)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"nmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            NMBFExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

// 监控是否在 iOS 10 及以下，手势返回的过程中，手势返回背后的那个界面修改了 navigationItem，这可能导致 bug：https://github.com/Tencent/QMUI_iOS/issues/302
- (BOOL)detectSetItemsWhenPopping {
    if (@available(iOS 11, *)) {
    } else {
        if (self.nmui_navigationBar && [self.nmui_navigationBar.delegate isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)self.nmui_navigationBar.delegate;
            
            //            NMBFLog(@"UINavigationItem (NMUINavigationButton)", @"navigationController is %@, topViewController is %@, viewControllers is %@, willAppearByInteractivePopGestureRecognizer is %@, navigationControllerPopGestureRecognizerChanging is %@", navController, navController.topViewController, navController.viewControllers, StringFromBOOL(navController.topViewController.nmui_willAppearByInteractivePopGestureRecognizer), StringFromBOOL(navController.topViewController.nmui_navigationControllerPopGestureRecognizerChanging));
            
            // 判断是否当前处于手势返回的过程中，且背后的控制器的 viewWillAppear: 已经被执行过。
            // 注意，判断条件里的 nmui_navigationControllerPopGestureRecognizerChanging 关键在于，它是在 viewWillAppear: 执行后才被置为 YES，而 NMUICommonViewController 是在 viewWillAppear: 里调用 setNavigationItems:，所以刚好过滤了这种场景。因为测试过，在 viewWillAppear: 里操作 items 是没问题的，但在那之后的操作就会有问题。
            BOOL isPopGestureRecognizerChanging = navController.topViewController.nmui_willAppearByInteractivePopGestureRecognizer && navController.topViewController.nmui_navigationControllerPopGestureRecognizerChanging;
            
            // 侧滑松手后，如果因为距离不够放弃返回，在还原位置还原的过程中去修改 navigationItem 也会导致布局错误，nmui_willAppearByInteractivePopGestureRecognizer 在 viewDidAppear: 才会被置为 YES，而在松手后 state 会被置为 UIGestureRecognizerStatePossible， navController.topViewController.view.superview.frame < 0 可以作为松手后放弃返回的判断条件（成功返回则等于 0）
            BOOL isPopGestureRecognizerCanceled = navController.topViewController.nmui_willAppearByInteractivePopGestureRecognizer && navController.interactivePopGestureRecognizer.state == UIGestureRecognizerStatePossible && CGRectGetMinX(navController.topViewController.view.superview.frame) < 0;
            
            if (isPopGestureRecognizerChanging || isPopGestureRecognizerCanceled) {
                NMBFLog(@"UINavigationItem (NMUINavigationButton)", @"拦截了一次可能产生顶部按钮混乱的操作");
                return YES;
            }
        }
    }
    return NO;
}

- (void)nmui_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempLeftBarButtonItems = item ? @[item] : nil;
        return;
    }
    
    [self nmui_setLeftBarButtonItem:item animated:animated];
    
    // 自动给 position 赋值
    item.nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionLeft;
}

- (void)nmui_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempLeftBarButtonItems = items;
        return;
    }
    
    [self nmui_setLeftBarButtonItems:items animated:animated];
    
    // 自动给 position 赋值
    for (NSInteger i = 0; i < items.count; i++) {
        if (i == 0) {
            items[i].nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionLeft;
        } else {
            items[i].nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionNone;
        }
    }
}

- (void)nmui_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempRightBarButtonItems = item ? @[item] : nil;
        return;
    }
    
    [self nmui_setRightBarButtonItem:item animated:animated];
    
    // 自动给 position 赋值
    item.nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionRight;
}

- (void)nmui_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)items animated:(BOOL)animated {
    if ([self detectSetItemsWhenPopping]) {
        self.tempRightBarButtonItems = items;
        return;
    }
    
    [self nmui_setRightBarButtonItems:items animated:animated];
    
    // 自动给 position 赋值
    for (NSInteger i = 0; i < items.count; i++) {
        if (i == 0) {
            items[i].nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionRight;
        } else {
            items[i].nmui_navigationButton.buttonPosition = NMUINavigationButtonPositionNone;
        }
    }
}

- (UIBarButtonItem *)nmui_leftBarButtonItem {
    if (self.tempLeftBarButtonItems) {
        return self.tempLeftBarButtonItems.firstObject;
    }
    return [self nmui_leftBarButtonItem];
}

- (NSArray<UIBarButtonItem *> *)nmui_leftBarButtonItems {
    if (self.tempLeftBarButtonItems) {
        return self.tempLeftBarButtonItems;
    }
    return [self nmui_leftBarButtonItems];
}

- (UIBarButtonItem *)nmui_rightBarButtonItem {
    if (self.tempRightBarButtonItems) {
        return self.tempRightBarButtonItems.firstObject;
    }
    return [self nmui_rightBarButtonItem];
}

- (NSArray<UIBarButtonItem *> *)nmui_rightBarButtonItems {
    if (self.tempRightBarButtonItems) {
        return self.tempRightBarButtonItems;
    }
    return [self nmui_rightBarButtonItems];
}

- (UINavigationBar *)nmui_navigationBar {
    // UINavigationItem 内部有个方法可以获取 navigationBar
    if ([self respondsToSelector:@selector(navigationBar)]) {
        return [self performSelector:@selector(navigationBar)];
    }
    return nil;
}

@end

@implementation UIViewController (NMUINavigationButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NMBFExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if (selfObject.navigationItem.tempLeftBarButtonItems) {
                selfObject.navigationItem.leftBarButtonItems = selfObject.navigationItem.tempLeftBarButtonItems;
                selfObject.navigationItem.tempLeftBarButtonItems = nil;
            }
            if (selfObject.navigationItem.tempRightBarButtonItems) {
                selfObject.navigationItem.rightBarButtonItems = selfObject.navigationItem.tempRightBarButtonItems;
                selfObject.navigationItem.tempRightBarButtonItems = nil;
            }
        });
    });
}

@end

@implementation UINavigationBar (NMUINavigationButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 强制修改 contentView 的 directionalLayoutMargins.leading，在使用自定义返回按钮时减小 8
        // Xcode11 beta2 修改私有 view 的 directionalLayoutMargins 会 crash，换个方式
        if (@available(iOS 11, *)) {
            
            NSString *barContentViewString = [NSString stringWithFormat:@"_%@Content%@", @"UINavigationBar", @"View"];
            
            NMBFOverrideImplementation(NSClassFromString(barContentViewString), @selector(directionalLayoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^NSDirectionalEdgeInsets(UIView *selfObject) {
                    
                    // call super
                    NSDirectionalEdgeInsets (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (NSDirectionalEdgeInsets (*)(id, SEL))originalIMPProvider();
                    NSDirectionalEdgeInsets originResult = originSelectorIMP(selfObject, originCMD);
                    
                    // get navbar
                    UINavigationBar *navBar = nil;
                    if ([NSStringFromClass([selfObject class]) isEqualToString:barContentViewString] &&
                        [selfObject.superview isKindOfClass:[UINavigationBar class]]) {
                        navBar = (UINavigationBar *)selfObject.superview;
                    }
                    
                    // change insets
                    if (navBar) {
                        NSDirectionalEdgeInsets value = originResult;
                        value.leading = value.trailing - (navBar.nmui_customizingBackBarButtonItem ? 8 : 0);
                        return value;
                    }
                    
                    return originResult;
                };
            });
        }
        
    });
}

- (BOOL)nmui_customizingBackBarButtonItem {
    if (self.topItem.leftBarButtonItem) {
        return self.topItem.leftBarButtonItem.nmui_isCustomizedBackBarButtonItem;
    }
    return NO;
}

- (UIView *)nmui_contentView {
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass(subview.class) containsString:@"BarContentView"]) {
            return subview;
        }
    }
    return nil;
}

@end
