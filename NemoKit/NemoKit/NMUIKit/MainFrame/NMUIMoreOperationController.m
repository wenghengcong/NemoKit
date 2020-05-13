//
//  NMUIMoreOperationController.m
//  Nemo
//
//  Created by Hunt on 2019/11/3.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIMoreOperationController.h"
#import "NMBCore.h"
#import "NMUIHelper.h"
#import "CALayer+NMUI.h"
#import "UIControl+NMUI.h"
#import "UIView+NMUI.h"
#import "NSArray+NMBF.h"
#import "UIScrollView+NMUI.h"
#import "NMUIHelper.h"

static NSInteger const kNMUIMoreOperationItemViewTagOffset = 999;

@interface NMUIMoreOperationItemView () {
    NSInteger _tag;
}

@property(nonatomic, weak) NMUIMoreOperationController *moreOperationController;
@property(nonatomic, copy) void (^handler)(NMUIMoreOperationController *moreOperationController, NMUIMoreOperationItemView *itemView);

// 被添加到某个 NMUIMoreOperationController 时要调用，用于更新 itemView 的样式，以及 moreOperationController 属性的指针
// @param moreOperationController 如果为空，则会自动使用 [NMUIMoreOperationController appearance]
- (void)formatItemViewStyleWithMoreOperationController:(NMUIMoreOperationController *)moreOperationController;
@end

@implementation NMUIMoreOperationController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static NMUIMoreOperationController *moreOperationViewControllerAppearance;
+ (nonnull instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self resetAppearance];
    });
    return moreOperationViewControllerAppearance;
}

+ (void)resetAppearance {
    if (!moreOperationViewControllerAppearance) {
        moreOperationViewControllerAppearance = [[NMUIMoreOperationController alloc] init];
        moreOperationViewControllerAppearance.contentBackgroundColor = UIColorForBackground;
        moreOperationViewControllerAppearance.contentEdgeMargins = UIEdgeInsetsMake(0, 10, 10, 10);
        moreOperationViewControllerAppearance.contentMaximumWidth = [NMUIHelper screenSizeFor55Inch].width - UIEdgeInsetsGetHorizontalValue(moreOperationViewControllerAppearance.contentEdgeMargins);
        moreOperationViewControllerAppearance.contentCornerRadius = 10;
        moreOperationViewControllerAppearance.contentPaddings = UIEdgeInsetsMake(10, 0, 5, 0);
        
        moreOperationViewControllerAppearance.scrollViewSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, .15f);
        moreOperationViewControllerAppearance.scrollViewContentInsets = UIEdgeInsetsMake(14, 8, 14, 8);
        
        moreOperationViewControllerAppearance.itemBackgroundColor = UIColorClear;
        moreOperationViewControllerAppearance.itemTitleColor = UIColorGrayDarken;
        moreOperationViewControllerAppearance.itemTitleFont = UIFontMake(11);
        moreOperationViewControllerAppearance.itemPaddingHorizontal = 16;
        moreOperationViewControllerAppearance.itemTitleMarginTop = 9;
        moreOperationViewControllerAppearance.itemMinimumMarginHorizontal = 0;
        moreOperationViewControllerAppearance.automaticallyAdjustItemMargins = YES;
        
        moreOperationViewControllerAppearance.cancelButtonBackgroundColor = UIColorForBackground;
        moreOperationViewControllerAppearance.cancelButtonTitleColor = UIColorBlue;
        moreOperationViewControllerAppearance.cancelButtonSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, .15f);
        moreOperationViewControllerAppearance.cancelButtonFont = UIFontBoldMake(16);
        moreOperationViewControllerAppearance.cancelButtonHeight = 56.0;
        moreOperationViewControllerAppearance.cancelButtonMarginTop = 0;
        
        moreOperationViewControllerAppearance.isExtendBottomLayout = NO;
    }
}

@end

@interface NMUIMoreOperationController ()

@property(nonatomic, strong) NSMutableArray<UIScrollView *> *mutableScrollViews;
@property(nonatomic, strong) NSMutableArray<NSMutableArray<NMUIMoreOperationItemView *> *> *mutableItems;
@property(nonatomic, strong) CALayer *extendLayer;

@property(nonatomic, assign, getter=isShowing, readwrite) BOOL showing;
@property(nonatomic, assign, getter=isAnimating, readwrite) BOOL animating;
@property(nonatomic, assign) BOOL hideByCancel; // 是否通过点击取消按钮或者遮罩来隐藏面板，默认为 NO

@end

@implementation NMUIMoreOperationController

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
    if (moreOperationViewControllerAppearance) {
        self.contentBackgroundColor = [NMUIMoreOperationController appearance].contentBackgroundColor;
        self.contentEdgeMargins = [NMUIMoreOperationController appearance].contentEdgeMargins;
        self.contentMaximumWidth = [NMUIMoreOperationController appearance].contentMaximumWidth;
        self.contentCornerRadius = [NMUIMoreOperationController appearance].contentCornerRadius;
        self.contentPaddings = [NMUIMoreOperationController appearance].contentPaddings;
        
        self.scrollViewSeparatorColor = [NMUIMoreOperationController appearance].scrollViewSeparatorColor;
        self.scrollViewContentInsets = [NMUIMoreOperationController appearance].scrollViewContentInsets;
        
        self.itemBackgroundColor = [NMUIMoreOperationController appearance].itemBackgroundColor;
        self.itemTitleColor = [NMUIMoreOperationController appearance].itemTitleColor;
        self.itemTitleFont = [NMUIMoreOperationController appearance].itemTitleFont;
        self.itemPaddingHorizontal = [NMUIMoreOperationController appearance].itemPaddingHorizontal;
        self.itemTitleMarginTop = [NMUIMoreOperationController appearance].itemTitleMarginTop;
        self.itemMinimumMarginHorizontal = [NMUIMoreOperationController appearance].itemMinimumMarginHorizontal;
        self.automaticallyAdjustItemMargins = [NMUIMoreOperationController appearance].automaticallyAdjustItemMargins;
        
        self.cancelButtonBackgroundColor = [NMUIMoreOperationController appearance].cancelButtonBackgroundColor;
        self.cancelButtonTitleColor = [NMUIMoreOperationController appearance].cancelButtonTitleColor;
        self.cancelButtonSeparatorColor = [NMUIMoreOperationController appearance].cancelButtonSeparatorColor;
        self.cancelButtonFont = [NMUIMoreOperationController appearance].cancelButtonFont;
        self.cancelButtonHeight = [NMUIMoreOperationController appearance].cancelButtonHeight;
        self.cancelButtonMarginTop = [NMUIMoreOperationController appearance].cancelButtonMarginTop;
        
        self.isExtendBottomLayout = [NMUIMoreOperationController appearance].isExtendBottomLayout;
        
        self.mutableScrollViews = [[NSMutableArray alloc] init];
        self.mutableItems = [[NSMutableArray alloc] init];
    }
    
    [self loadViewIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = self.contentBackgroundColor;
    [self.view addSubview:self.contentView];
    
    _cancelButton = [[NMUIButton alloc] init];
    self.cancelButton.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    self.cancelButton.adjustsButtonWhenHighlighted = NO;
    self.cancelButton.titleLabel.font = self.cancelButtonFont;
    self.cancelButton.backgroundColor = self.cancelButtonBackgroundColor;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:self.cancelButtonTitleColor forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[self.cancelButtonTitleColor colorWithAlphaComponent:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
    self.cancelButton.nmui_borderPosition = NMUIViewBorderPositionBottom;
    self.cancelButton.nmui_borderColor = self.cancelButtonSeparatorColor;
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.extendLayer = [CALayer layer];
    self.extendLayer.hidden = !self.isExtendBottomLayout;
    [self.extendLayer nmui_removeDefaultAnimations];
    [self.view.layer addSublayer:self.extendLayer];
    [self updateExtendLayerAppearance];
    
    [self updateCornerRadius];
}

- (NSArray<UIScrollView *> *)scrollViews {
    return [self.mutableScrollViews copy];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    __block CGFloat layoutY = CGRectGetHeight(self.view.bounds);
    
    if (!self.extendLayer.hidden) {
        self.extendLayer.frame = CGRectMake(0, layoutY, CGRectGetWidth(self.view.bounds), SafeAreaInsetsConstantForDeviceWithNotch.bottom);
        if (self.view.clipsToBounds) {
//            NMBFLog(@"NMUIMoreOperationController", @"%@ 需要显示 extendLayer，但却被父级 clip 掉了，可能看不到", NSStringFromClass(self.class));
        }
    }
    
    BOOL isCancelButtonShowing = !self.cancelButton.hidden;
    if (isCancelButtonShowing) {
        self.cancelButton.frame = CGRectMake(0, layoutY - self.cancelButtonHeight, CGRectGetWidth(self.view.bounds), self.cancelButtonHeight);
        [self.cancelButton setNeedsLayout];
        layoutY = CGRectGetMinY(self.cancelButton.frame) - self.cancelButtonMarginTop;
    }
    
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), layoutY);
    layoutY = self.contentPaddings.top;
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentPaddings);
    
    [self.mutableScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull scrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        scrollView.frame = CGRectMake(self.contentPaddings.left, layoutY, contentWidth, CGRectGetHeight(scrollView.frame));
        
        // 要保护 safeAreaInsets 的区域，而这里不使用 scrollView.nmui_safeAreaInsets 是因为此时 scrollView 的 safeAreaInsets 仍然为 0，但 scrollView.superview.safeAreaInsets 已经正确了，所以使用 scrollView.superview 也即 self.view 的
        // 底部的 insets 暂不考虑
        //        UIEdgeInsets scrollViewSafeAreaInsets = scrollView.nmui_safeAreaInsets;
        UIEdgeInsets scrollViewSafeAreaInsets = UIEdgeInsetsMake(fmax(self.view.nmui_safeAreaInsets.top - scrollView.nmui_top, 0), fmax(self.view.nmui_safeAreaInsets.left - scrollView.nmui_left, 0), 0, fmax(self.view.nmui_safeAreaInsets.right - (self.view.nmui_width - scrollView.nmui_right), 0));
        
        NSArray<NMUIMoreOperationItemView *> *itemSection = self.mutableItems[idx];
        NMUIMoreOperationItemView *exampleItemView = itemSection.firstObject;
        CGFloat exampleItemWidth = exampleItemView.imageView.image.size.width + self.itemPaddingHorizontal * 2;
        CGFloat scrollViewVisibleWidth = contentWidth - scrollView.contentInset.left - scrollViewSafeAreaInsets.left;// 注意计算列数时不需要考虑 contentInset.right 的
        CGFloat columnCount = (scrollViewVisibleWidth + self.itemMinimumMarginHorizontal) / (exampleItemWidth + self.itemMinimumMarginHorizontal);
        
        // 让初始状态下在 scrollView 右边露出半个 item
        if (self.automaticallyAdjustItemMargins) {
            columnCount = [self suitableColumnCountWithCount:columnCount];
        }
        
        CGFloat finalItemMarginHorizontal = flat((scrollViewVisibleWidth - exampleItemWidth * columnCount) / columnCount);
        
        __block CGFloat maximumItemHeight = 0;
        __block CGFloat itemViewMinX = scrollViewSafeAreaInsets.left;
        [itemSection enumerateObjectsUsingBlock:^(NMUIMoreOperationItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize itemSize = CGSizeFlatted([itemView sizeThatFits:CGSizeMake(exampleItemWidth, CGFLOAT_MAX)]);
            maximumItemHeight = fmax(maximumItemHeight, itemSize.height);
            itemView.frame = CGRectMake(itemViewMinX, 0, exampleItemWidth, itemSize.height);
            itemViewMinX = CGRectGetMaxX(itemView.frame) + finalItemMarginHorizontal;
        }];
        scrollView.contentSize = CGSizeMake(itemViewMinX - finalItemMarginHorizontal + scrollViewSafeAreaInsets.right, maximumItemHeight);
        scrollView.frame = CGRectSetHeight(scrollView.frame, scrollView.contentSize.height + UIEdgeInsetsGetVerticalValue(scrollView.contentInset));
        layoutY = CGRectGetMaxY(scrollView.frame);
    }];
}

- (CGFloat)suitableColumnCountWithCount:(CGFloat)columnCount {
    // 根据精准的列数，找到一个合适的、能让半个 item 刚好露出来的列数。例如 3.6 会被转换成 3.5，3.2 会被转换成 2.5。
    CGFloat result = round(columnCount) - .5;;
    return result;
}

- (void)showFromBottom {
    
    if (self.showing || self.animating) {
        return;
    }
    
    self.hideByCancel = YES;
    
    __weak __typeof(self)weakSelf = self;
    
    NMUIModalPresentationViewController *modalPresentationViewController = [[NMUIModalPresentationViewController alloc] init];
    modalPresentationViewController.delegate = self;
    modalPresentationViewController.maximumContentViewWidth = self.contentMaximumWidth;
    modalPresentationViewController.contentViewMargins = self.contentEdgeMargins;
    modalPresentationViewController.contentViewController = self;
    
    __weak __typeof(modalPresentationViewController)weakModalController = modalPresentationViewController;
    modalPresentationViewController.layoutBlock = ^(CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewDefaultFrame) {
        weakModalController.contentView.nmui_frameApplyTransform = CGRectSetY(contentViewDefaultFrame, CGRectGetHeight(containerBounds) - weakModalController.contentViewMargins.bottom - CGRectGetHeight(contentViewDefaultFrame) - weakModalController.view.nmui_safeAreaInsets.bottom);
    };
    modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(willPresentMoreOperationController:)]) {
            [weakSelf.delegate willPresentMoreOperationController:weakSelf];
        }
        
        dimmingView.alpha = 0;
        weakModalController.contentView.frame = CGRectSetY(contentViewFrame, CGRectGetHeight(containerBounds));
        [UIView animateWithDuration:.25 delay:0.0 options:NMUIViewAnimationOptionsCurveOut animations:^(void) {
            dimmingView.alpha = 1;
            weakModalController.contentView.frame = contentViewFrame;
        } completion:^(BOOL finished) {
            weakSelf.showing = YES;
            weakSelf.animating = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(didPresentMoreOperationController:)]) {
                [weakSelf.delegate didPresentMoreOperationController:weakSelf];
            }
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        [UIView animateWithDuration:.25 delay:0.0 options:NMUIViewAnimationOptionsCurveOut animations:^(void) {
            dimmingView.alpha = 0;
            weakModalController.contentView.frame = CGRectSetY(weakModalController.contentView.frame, CGRectGetHeight(containerBounds));
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    self.animating = YES;
    [modalPresentationViewController showWithAnimated:YES completion:NULL];
}

- (void)hideToBottom {
    if (!self.showing || self.animating) {
        return;
    }
    self.hideByCancel = NO;
    [self.nmui_modalPresentationViewController hideWithAnimated:YES completion:NULL];
}

#pragma mark - Item

- (void)setItems:(NSArray<NSArray<NMUIMoreOperationItemView *> *> *)items {
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        [itemView removeFromSuperview];
    }];
    [self.mutableItems removeAllObjects];
    
    self.mutableItems = [items nmbf_mutableCopyNestedArray];
    
    [self.mutableScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull scrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        [scrollView removeFromSuperview];
    }];
    [self.mutableScrollViews removeAllObjects];
    [self.mutableItems enumerateObjectsUsingBlock:^(NSArray<NMUIMoreOperationItemView *> * _Nonnull itemViewSection, NSUInteger scrollViewIndex, BOOL * _Nonnull stop) {
        UIScrollView *scrollView = [self addScrollViewAtIndex:scrollViewIndex];
        [itemViewSection enumerateObjectsUsingBlock:^(NMUIMoreOperationItemView * _Nonnull itemView, NSUInteger itemViewIndex, BOOL * _Nonnull stop) {
            [self addItemView:itemView toScrollView:scrollView];
        }];
    }];
    [self setViewNeedsLayoutIfLoaded];
}

- (NSArray<NSArray<NMUIMoreOperationItemView *> *> *)items {
    return [self.mutableItems copy];
}

- (void)addItemView:(NMUIMoreOperationItemView *)itemView inSection:(NSInteger)section {
    if (section == self.mutableItems.count) {
        // 创建新的 itemView section
        [self.mutableItems addObject:[@[itemView] mutableCopy]];
    } else {
        [self.mutableItems[section] addObject:itemView];
    }
    itemView.moreOperationController = self;
    
    if (section == self.mutableScrollViews.count) {
        // 创建新的 section
        [self addScrollViewAtIndex:section];
    }
    if (section < self.mutableScrollViews.count) {
        [self addItemView:itemView toScrollView:self.mutableScrollViews[section]];
    }
    
    [self setViewNeedsLayoutIfLoaded];
}

- (void)insertItemView:(NMUIMoreOperationItemView *)itemView atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.mutableItems.count) {
        // 创建新的 itemView section
        [self.mutableItems addObject:[@[itemView] mutableCopy]];
    } else {
        [self.mutableItems[indexPath.section] insertObject:itemView atIndex:indexPath.item];
    }
    itemView.moreOperationController = self;
    
    if (indexPath.section == self.mutableScrollViews.count) {
        // 创建新的 section
        [self addScrollViewAtIndex:indexPath.section];
    }
    if (indexPath.section < self.mutableScrollViews.count) {
        [itemView formatItemViewStyleWithMoreOperationController:self];
        [self.mutableScrollViews[indexPath.section] insertSubview:itemView atIndex:indexPath.item];
    }
    
    [self setViewNeedsLayoutIfLoaded];
}

- (void)removeItemViewAtIndexPath:(NSIndexPath *)indexPath {
    NMUIMoreOperationItemView *itemView = self.mutableScrollViews[indexPath.section].subviews[indexPath.item];
    itemView.moreOperationController = nil;
    [itemView removeFromSuperview];
    NSMutableArray<NMUIMoreOperationItemView *> *itemViewSection = self.mutableItems[indexPath.section];
    [itemViewSection removeObject:itemView];
    if (itemViewSection.count == 0) {
        [self.mutableItems removeObject:itemViewSection];
        [self.mutableScrollViews[indexPath.section] removeFromSuperview];
        [self.mutableScrollViews removeObjectAtIndex:indexPath.section];
        [self updateScrollViewsBorderStyle];
    }
    [self setViewNeedsLayoutIfLoaded];
}

- (NMUIMoreOperationItemView *)itemViewWithTag:(NSInteger)tag {
    __block NMUIMoreOperationItemView *result = nil;
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        if (itemView.tag == tag) {
            result = itemView;
            *stop = YES;
        }
    }];
    return result;
}

- (NSIndexPath *)indexPathWithItemView:(NMUIMoreOperationItemView *)itemView {
    for (NSInteger section = 0; section < self.mutableItems.count; section++) {
        NSInteger index = [self.mutableItems[section] indexOfObject:itemView];
        if (index != NSNotFound) {
            return [NSIndexPath indexPathForItem:index inSection:section];
        }
    }
    return nil;
}

- (UIScrollView *)addScrollViewAtIndex:(NSInteger)index {
    UIScrollView *scrollView = [self generateScrollViewWithIndex:index];
    [self.contentView addSubview:scrollView];
    [self.mutableScrollViews addObject:scrollView];
    [self updateScrollViewsBorderStyle];
    return scrollView;
}

- (void)addItemView:(NMUIMoreOperationItemView *)itemView toScrollView:(UIScrollView *)scrollView {
    [itemView formatItemViewStyleWithMoreOperationController:self];
    [scrollView addSubview:itemView];
}

- (UIScrollView *)generateScrollViewWithIndex:(NSInteger)index {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.nmui_borderColor = self.scrollViewSeparatorColor;
    scrollView.nmui_borderPosition = (self.scrollViewSeparatorColor && index != 0) ? NMUIViewBorderPositionTop : NMUIViewBorderPositionNone;
    scrollView.scrollsToTop = NO;
    if (@available(iOS 11, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    scrollView.contentInset = self.scrollViewContentInsets;
    [scrollView nmui_scrollToTopForce:YES animated:NO];
    return scrollView;
}

- (void)updateScrollViewsBorderStyle {
    [self.mutableScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull scrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        scrollView.nmui_borderColor = self.scrollViewSeparatorColor;
        scrollView.nmui_borderPosition = idx != 0 ? NMUIViewBorderPositionTop : NMUIViewBorderPositionNone;
    }];
}

#pragma mark - Event

- (void)handleCancelButtonEvent:(id)sender {
    if (!self.showing || self.animating) {
        return;
    }
    [self.nmui_modalPresentationViewController hideWithAnimated:YES completion:NULL];
}

- (void)handleItemViewEvent:(NMUIMoreOperationItemView *)itemView {
    if ([self.delegate respondsToSelector:@selector(moreOperationController:didSelectItemView:)]) {
        [self.delegate moreOperationController:self didSelectItemView:itemView];
    }
    if (itemView.handler) {
        itemView.handler(self, itemView);
    }
}

#pragma mark - Property setter

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    _contentBackgroundColor = contentBackgroundColor;
    self.contentView.backgroundColor = contentBackgroundColor;
}

- (void)setScrollViewSeparatorColor:(UIColor *)scrollViewSeparatorColor {
    _scrollViewSeparatorColor = scrollViewSeparatorColor;
    [self updateScrollViewsBorderStyle];
}

- (void)setScrollViewContentInsets:(UIEdgeInsets)scrollViewContentInsets {
    _scrollViewContentInsets = scrollViewContentInsets;
    if (self.mutableScrollViews) {
        for (UIScrollView *scrollView in self.mutableScrollViews) {
            scrollView.contentInset = scrollViewContentInsets;
        }
        [self setViewNeedsLayoutIfLoaded];
    }
}

- (void)setCancelButtonBackgroundColor:(UIColor *)cancelButtonBackgroundColor {
    _cancelButtonBackgroundColor = cancelButtonBackgroundColor;
    self.cancelButton.backgroundColor = cancelButtonBackgroundColor;
    [self updateExtendLayerAppearance];
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    _cancelButtonTitleColor = cancelButtonTitleColor;
    if (self.cancelButton) {
        [self.cancelButton setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[cancelButtonTitleColor colorWithAlphaComponent:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
    }
}

- (void)setCancelButtonSeparatorColor:(UIColor *)cancelButtonSeparatorColor {
    _cancelButtonSeparatorColor = cancelButtonSeparatorColor;
    self.cancelButton.nmui_borderColor = cancelButtonSeparatorColor;
}

- (void)setItemBackgroundColor:(UIColor *)itemBackgroundColor {
    _itemBackgroundColor = itemBackgroundColor;
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        itemView.imageView.backgroundColor = itemBackgroundColor;
    }];
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor {
    _itemTitleColor = itemTitleColor;
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        [itemView setTitleColor:itemTitleColor forState:UIControlStateNormal];
    }];
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        itemView.titleLabel.font = itemTitleFont;
        [itemView setNeedsLayout];
    }];
}

- (void)setItemPaddingHorizontal:(CGFloat)itemPaddingHorizontal {
    _itemPaddingHorizontal = itemPaddingHorizontal;
    [self setViewNeedsLayoutIfLoaded];
}

- (void)setItemTitleMarginTop:(CGFloat)itemTitleMarginTop {
    _itemTitleMarginTop = itemTitleMarginTop;
    [self.mutableItems nmbf_enumerateNestedArrayWithBlock:^(NMUIMoreOperationItemView *itemView, BOOL *stop) {
        itemView.titleEdgeInsets = UIEdgeInsetsMake(itemTitleMarginTop, 0, 0, 0);
        [itemView setNeedsLayout];
    }];
}

- (void)setItemMinimumMarginHorizontal:(CGFloat)itemMinimumMarginHorizontal {
    _itemMinimumMarginHorizontal = itemMinimumMarginHorizontal;
    [self setViewNeedsLayoutIfLoaded];
}

- (void)setAutomaticallyAdjustItemMargins:(BOOL)automaticallyAdjustItemMargins {
    _automaticallyAdjustItemMargins = automaticallyAdjustItemMargins;
    [self setViewNeedsLayoutIfLoaded];
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont {
    _cancelButtonFont = cancelButtonFont;
    self.cancelButton.titleLabel.font = cancelButtonFont;
    [self.cancelButton setNeedsLayout];
}

- (void)setContentCornerRadius:(CGFloat)contentCornerRadius {
    _contentCornerRadius = contentCornerRadius;
    [self updateCornerRadius];
}

- (void)setCancelButtonMarginTop:(CGFloat)cancelButtonMarginTop {
    _cancelButtonMarginTop = cancelButtonMarginTop;
    self.cancelButton.nmui_borderPosition = cancelButtonMarginTop > 0 ? NMUIViewBorderPositionNone : NMUIViewBorderPositionTop;
    [self updateCornerRadius];
    [self setViewNeedsLayoutIfLoaded];
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

- (void)setViewNeedsLayoutIfLoaded {
    if (self.isShowing) {
        [self.nmui_modalPresentationViewController updateLayout];
        [self.view setNeedsLayout];
    } else if ([self isViewLoaded]) {
        [self.view setNeedsLayout];
    }
}

- (void)updateExtendLayerAppearance {
    self.extendLayer.backgroundColor = self.cancelButtonBackgroundColor.CGColor;
}

- (void)updateCornerRadius {
    if (self.cancelButtonMarginTop > 0) {
        self.view.layer.cornerRadius = 0;
        self.view.clipsToBounds = NO;
        
        self.contentView.layer.cornerRadius = self.contentCornerRadius;
        self.cancelButton.layer.cornerRadius = self.contentCornerRadius;
    } else {
        self.view.layer.cornerRadius = self.contentCornerRadius;
        self.view.clipsToBounds = self.view.layer.cornerRadius > 0;// 有圆角才需要 clip
        self.contentView.layer.cornerRadius = 0;
        self.cancelButton.layer.cornerRadius = 0;
    }
}

#pragma mark - <NMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(NMUIModalPresentationViewController *)controller keyboardHeight:(CGFloat)keyboardHeight limitSize:(CGSize)limitSize {
    __block CGFloat contentHeight = (self.cancelButton.hidden ? 0 : self.cancelButtonHeight + self.cancelButtonMarginTop);
    [self.mutableScrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull scrollView, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<NMUIMoreOperationItemView *> *itemSection = self.mutableItems[idx];
        NMUIMoreOperationItemView *exampleItemView = itemSection.firstObject;
        CGFloat exampleItemWidth = exampleItemView.imageView.image.size.width + self.itemPaddingHorizontal * 2;
        __block CGFloat maximumItemHeight = 0;
        [itemSection enumerateObjectsUsingBlock:^(NMUIMoreOperationItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize itemSize = CGSizeFlatted([itemView sizeThatFits:CGSizeMake(exampleItemWidth, CGFLOAT_MAX)]);
            maximumItemHeight = fmax(maximumItemHeight, itemSize.height);
        }];
        contentHeight += maximumItemHeight + UIEdgeInsetsGetVerticalValue(scrollView.contentInset);
    }];
    if (self.mutableScrollViews.count) {
        contentHeight += UIEdgeInsetsGetVerticalValue(self.contentPaddings);
    }
    limitSize.height = contentHeight;
    return limitSize;
}

#pragma mark - <NMUIModalPresentationViewControllerDelegate>

- (void)willHideModalPresentationViewController:(NMUIModalPresentationViewController *)controller {
    self.animating = YES;
    if ([self.delegate respondsToSelector:@selector(willDismissMoreOperationController:cancelled:)]) {
        [self.delegate willDismissMoreOperationController:self cancelled:self.hideByCancel];
    }
}

- (void)didHideModalPresentationViewController:(NMUIModalPresentationViewController *)controller {
    self.showing = NO;
    self.animating = NO;
    if ([self.delegate respondsToSelector:@selector(didDismissMoreOperationController:cancelled:)]) {
        [self.delegate didDismissMoreOperationController:self cancelled:self.hideByCancel];
    }
}

#pragma mark - <NMUIModalPresentationComponentProtocol>

- (void)hideModalPresentationComponent {
    [self hideToBottom];
}

@end

@implementation NMUIMoreOperationItemView

@dynamic tag;

+ (instancetype)itemViewWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title selectedTitle:(NSString *)selectedTitle handler:(void (^)(NMUIMoreOperationController *, NMUIMoreOperationItemView *))handler {
    NMUIMoreOperationItemView *itemView = [[NMUIMoreOperationItemView alloc] init];
    [itemView setImage:image forState:UIControlStateNormal];
    [itemView setImage:selectedImage forState:UIControlStateSelected];
    [itemView setImage:selectedImage forState:UIControlStateHighlighted|UIControlStateSelected];
    [itemView setTitle:title forState:UIControlStateNormal];
    [itemView setTitle:selectedTitle forState:UIControlStateHighlighted|UIControlStateSelected];
    [itemView setTitle:selectedTitle forState:UIControlStateSelected];
    itemView.handler = handler;
    [itemView formatItemViewStyleWithMoreOperationController:nil];
    return itemView;
}

+ (instancetype)itemViewWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(NMUIMoreOperationController *, NMUIMoreOperationItemView *))handler {
    return [self itemViewWithImage:image selectedImage:nil title:title selectedTitle:nil handler:handler];
}

+ (instancetype)itemViewWithImage:(UIImage *)image
                            title:(NSString *)title
                              tag:(NSInteger)tag
                          handler:(void (^)(NMUIMoreOperationController *moreOperationController, NMUIMoreOperationItemView *itemView))handler {
    NMUIMoreOperationItemView *itemView = [self itemViewWithImage:image title:title handler:handler];
    itemView.tag = tag;
    return itemView;
}

+ (instancetype)itemViewWithImage:(UIImage *)image
                    selectedImage:(UIImage *)selectedImage
                            title:(NSString *)title
                    selectedTitle:(NSString *)selectedTitle
                              tag:(NSInteger)tag
                          handler:(void (^)(NMUIMoreOperationController *moreOperationController, NMUIMoreOperationItemView *itemView))handler {
    NMUIMoreOperationItemView *itemView = [self itemViewWithImage:image selectedImage:selectedImage title:title selectedTitle:selectedTitle handler:handler];
    itemView.tag = tag;
    return itemView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imagePosition = NMUIButtonImagePositionTop;
        self.adjustsButtonWhenHighlighted = NO;
        self.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.imageView.alpha = highlighted ? ButtonHighlightedAlpha : 1;
}

// 从某个指定的 NMUIMoreOperationController 里取 itemView 的样式，应用到当前 itemView 里
- (void)formatItemViewStyleWithMoreOperationController:(NMUIMoreOperationController *)moreOperationController {
    if (moreOperationController) {
        // 将事件放到 controller 级别去做，以便实现 delegate 功能
        [self addTarget:moreOperationController action:@selector(handleItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        // 参数 nil 则默认使用 appearance 的样式
        moreOperationController = [NMUIMoreOperationController appearance];
    }
    self.titleLabel.font = moreOperationController.itemTitleFont;
    self.titleEdgeInsets = UIEdgeInsetsMake(moreOperationController.itemTitleMarginTop, 0, 0, 0);
    [self setTitleColor:moreOperationController.itemTitleColor forState:UIControlStateNormal];
    self.imageView.backgroundColor = moreOperationController.itemBackgroundColor;
    
}

- (void)setTag:(NSInteger)tag {
    _tag = tag + kNMUIMoreOperationItemViewTagOffset;
}

- (NSInteger)tag {
    return MAX(-1, _tag - kNMUIMoreOperationItemViewTagOffset);// 为什么这里用-1而不是0：如果一个 itemView 通过带 tag: 参数初始化，那么 itemView.tag 最小值为 0，而如果一个 itemView 不通过带 tag: 的参数初始化，那么 itemView.tag 固定为 0，可见 tag 为 0 代表的意义不唯一，为了消除歧义，这里用 -1 代表那种不使用 tag: 参数初始化的 itemView
}

- (NSIndexPath *)indexPath {
    if (self.moreOperationController) {
        return [self.moreOperationController indexPathWithItemView:self];
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:\t%p\nimage:\t\t\t%@\nselectedImage:\t%@\ntitle:\t\t\t%@\nselectedTitle:\t%@\nindexPath:\t\t%@\ntag:\t\t\t\t%@", NSStringFromClass(self.class), self, [self imageForState:UIControlStateNormal], [self imageForState:UIControlStateSelected] == [self imageForState:UIControlStateNormal] ? nil : [self imageForState:UIControlStateSelected], [self titleForState:UIControlStateNormal], [self titleForState:UIControlStateSelected] == [self titleForState:UIControlStateNormal] ? nil : [self titleForState:UIControlStateSelected], ({self.indexPath ? [NSString stringWithFormat:@"%@ - %@", @(self.indexPath.section), @(self.indexPath.item)] : nil;}), @(self.tag)];
}

@end
