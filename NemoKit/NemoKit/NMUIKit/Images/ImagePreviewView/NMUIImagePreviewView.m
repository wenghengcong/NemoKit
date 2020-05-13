//
//  NMUIImagePreviewView.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIImagePreviewView.h"
#import "NMBCore.h"
#import "NMUICollectionViewPagingLayout.h"
#import "NSObject+NMBF.h"
#import "UICollectionView+NMUI.h"
#import "UIView+NMUI.h"
#import "NMUIEmptyView.h"
#import "NMBFLog.h"
#import "NMUIPieProgressView.h"
#import "NMUIButton.h"

@interface NMUIImagePreviewCell : UICollectionViewCell

@property(nonatomic, strong) NMUIZoomImageView *zoomImageView;
@end

@implementation NMUIImagePreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorClear;
        
        self.zoomImageView = [[NMUIZoomImageView alloc] init];
        [self.contentView addSubview:self.zoomImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.zoomImageView.nmui_frameApplyTransform = self.contentView.bounds;
}

@end

static NSString * const kLivePhotoCellIdentifier = @"livephoto";
static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";

@interface NMUIImagePreviewView ()

@property(nonatomic, assign) BOOL isChangingCollectionViewBounds;
@property(nonatomic, assign) CGFloat previousIndexWhenScrolling;
@end

@implementation NMUIImagePreviewView

@synthesize currentImageIndex = _currentImageIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitializedWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithFrame:self.frame];
    }
    return self;
}

- (void)didInitializedWithFrame:(CGRect)frame {
    _collectionViewLayout = [[NMUICollectionViewPagingLayout alloc] initWithStyle:NMUICollectionViewPagingLayoutStyleDefault];
    self.collectionViewLayout.allowsMultipleItemScroll = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMakeWithSize(frame.size) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorClear;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delaysContentTouches = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    if (@available(iOS 11, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.collectionView registerClass:[NMUIImagePreviewCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
    [self.collectionView registerClass:[NMUIImagePreviewCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
    [self.collectionView registerClass:[NMUIImagePreviewCell class] forCellWithReuseIdentifier:kLivePhotoCellIdentifier];
    [self addSubview:self.collectionView];
    
    self.loadingColor = UIColorWhite;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isCollectionViewSizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size);
    if (isCollectionViewSizeChanged) {
        self.isChangingCollectionViewBounds = YES;
        
        // 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
        [self.collectionViewLayout invalidateLayout];
        self.collectionView.frame = self.bounds;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        self.isChangingCollectionViewBounds = NO;
    }
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex {
    [self setCurrentImageIndex:currentImageIndex animated:NO];
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex animated:(BOOL)animated {
    _currentImageIndex = currentImageIndex;
    [self.collectionView reloadData];
    if (currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
        [self.collectionView layoutIfNeeded];// scroll immediately
    } else {
        NMBFLog(@"NMUIImagePreviewView", @"dataSource 里的图片数量和当前显示出来的图片数量不匹配, collectionView.numberOfItems = %@, collectionViewDataSource.numberOfItems = %@, currentImageIndex = %@", @([self.collectionView numberOfItemsInSection:0]), @([self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:1]), @(_currentImageIndex));
    }
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    BOOL isLoadingColorChanged = _loadingColor && ![_loadingColor isEqual:loadingColor];
    _loadingColor = loadingColor;
    if (isLoadingColorChanged) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInImagePreviewView:)]) {
        return [self.delegate numberOfImagesInImagePreviewView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = kImageOrUnknownCellIdentifier;
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:assetTypeAtIndex:)]) {
        NMUIImagePreviewMediaType type = [self.delegate imagePreviewView:self assetTypeAtIndex:indexPath.item];
        if (type == NMUIImagePreviewMediaTypeLivePhoto) {
            identifier = kLivePhotoCellIdentifier;
        } else if (type == NMUIImagePreviewMediaTypeVideo) {
            identifier = kVideoCellIdentifier;
        }
    }
    NMUIImagePreviewCell *cell = (NMUIImagePreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NMUIZoomImageView *zoomView = cell.zoomImageView;
    ((UIActivityIndicatorView *)zoomView.emptyView.loadingView).color = self.loadingColor;
    zoomView.cloudProgressView.tintColor = self.loadingColor;
    zoomView.cloudDownloadRetryButton.tintColor = self.loadingColor;
    zoomView.delegate = self;
    
    // 因为 cell 复用的问题，很可能此时会显示一张错误的图片，因此这里要清空所有图片的显示
    zoomView.image = nil;
    zoomView.videoPlayerItem = nil;
    if (@available(iOS 9.1, *)) {
        zoomView.livePhoto = nil;
    }
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:renderZoomImageView:atIndex:)]) {
        [self.delegate imagePreviewView:self renderZoomImageView:zoomView atIndex:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NMUIImagePreviewCell *previewCell = (NMUIImagePreviewCell *)cell;
    [previewCell.zoomImageView revertZooming];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NMUIImagePreviewCell *previewCell = (NMUIImagePreviewCell *)cell;
    [previewCell.zoomImageView endPlayingVideo];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    // 当前滚动到的页数
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:didScrollToIndex:)]) {
        [self.delegate imagePreviewView:self didScrollToIndex:self.currentImageIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    if (self.isChangingCollectionViewBounds) {
        return;
    }
    
    CGFloat pageWidth = [self collectionView:self.collectionView layout:self.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat pageHorizontalMargin = self.collectionViewLayout.minimumLineSpacing;
    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
    CGFloat index = contentOffsetX / (pageWidth + pageHorizontalMargin);
    
    // 在滑动过临界点的那一次才去调用 delegate，避免过于频繁的调用
    BOOL isFirstDidScroll = self.previousIndexWhenScrolling == 0;
    BOOL turnPageToRight = betweenOrEqual(self.previousIndexWhenScrolling, floor(index) + 0.5, index);
    BOOL turnPageToLeft = betweenOrEqual(index, floor(index) + 0.5, self.previousIndexWhenScrolling);
    if (!isFirstDidScroll && (turnPageToRight || turnPageToLeft)) {
        index = round(index);
        if (0 <= index && index < [self.collectionView numberOfItemsInSection:0]) {
            
            // 不调用 setter，避免又走一次 scrollToItem
            _currentImageIndex = index;
            
            if ([self.delegate respondsToSelector:@selector(imagePreviewView:willScrollHalfToIndex:)]) {
                [self.delegate imagePreviewView:self willScrollHalfToIndex:index];
            }
        }
    }
    self.previousIndexWhenScrolling = index;
}

@end

@implementation NMUIImagePreviewView (NMUIZoomImageView)

- (NSInteger)indexForZoomImageView:(NMUIZoomImageView *)zoomImageView {
    if ([zoomImageView.superview.superview isKindOfClass:[NMUIImagePreviewCell class]]) {
        return [self.collectionView indexPathForCell:(NMUIImagePreviewCell *)zoomImageView.superview.superview].item;
    } else {
        NSAssert(NO, @"尝试通过 %s 获取 NMUIZoomImageView 所在的 index，但找不到 NMUIZoomImageView 所在的 cell，index 获取失败。%@", __func__, zoomImageView);
    }
    return NSNotFound;
}

- (NMUIZoomImageView *)zoomImageViewAtIndex:(NSUInteger)index {
    NMUIImagePreviewCell *cell = (NMUIImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.zoomImageView;
}

- (void)checkIfDelegateMissing {
#ifdef DEBUG
    [NSObject nmbf_enumerateProtocolMethods:@protocol(NMUIZoomImageViewDelegate) usingBlock:^(SEL selector) {
        if (![self respondsToSelector:selector]) {
            NSAssert(NO, @"%@ 需要响应 %@ 的方法 -%@", NSStringFromClass([self class]), NSStringFromProtocol(@protocol(NMUIZoomImageViewDelegate)), NSStringFromSelector(selector));
        }
    }];
#endif
}

#pragma mark - <NMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(NMUIZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate singleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)doubleTouchInZoomingImageView:(NMUIZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate doubleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)longPressInZoomingImageView:(NMUIZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate longPressInZoomingImageView:imageView];
    }
}

- (void)didTouchICloudRetryButtonInZoomImageView:(NMUIZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate didTouchICloudRetryButtonInZoomImageView:imageView];
    }
}

- (void)zoomImageView:(NMUIZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate zoomImageView:imageView didHideVideoToolbar:didHide];
    }
}

- (BOOL)enabledZoomViewInZoomImageView:(NMUIZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate enabledZoomViewInZoomImageView:imageView];
    }
    return YES;
}

@end
