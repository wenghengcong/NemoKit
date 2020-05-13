//
//  NMUIImagePickerPreviewViewController.m
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIImagePickerPreviewViewController.h"
#import "NMBCore.h"
#import "NMUIImagePickerViewController.h"
#import "NMUIImagePickerHelper.h"
#import "NMUIAssetsManager.h"
#import "NMUIZoomImageView.h"
#import "NMUIAsset.h"
#import "NMUIButton.h"
#import "NMUINavigationButton.h"
#import "NMUIImagePickerHelper.h"
#import "NMUIPieProgressView.h"
#import "NMUIAlertController.h"
#import "UIImage+NMUI.h"
#import "UIView+NMUI.h"
#import "UIControl+NMUI.h"
#import "NMBFLog.h"

#pragma mark - NMUIImagePickerPreviewViewController (UIAppearance)

@implementation NMUIImagePickerPreviewViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance]; // +initialize 时就先设置好默认样式
    });
}

static NMUIImagePickerPreviewViewController *imagePickerPreviewViewControllerAppearance;
+ (nonnull instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imagePickerPreviewViewControllerAppearance) {
            imagePickerPreviewViewControllerAppearance = [[NMUIImagePickerPreviewViewController alloc] init];
            imagePickerPreviewViewControllerAppearance.toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, .9f);
            imagePickerPreviewViewControllerAppearance.toolBarTintColor = UIColorWhite;
        }
    });
    return imagePickerPreviewViewControllerAppearance;
}

@end

@implementation NMUIImagePickerPreviewViewController {
    BOOL _singleCheckMode;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maximumSelectImageCount = INT_MAX;
        self.minimumSelectImageCount = 0;
        if (imagePickerPreviewViewControllerAppearance) {
            // 避免 imagePickerPreviewViewControllerAppearance init 时走到这里来，导致死循环
            self.toolBarBackgroundColor = [NMUIImagePickerPreviewViewController appearance].toolBarBackgroundColor;
            self.toolBarTintColor = [NMUIImagePickerPreviewViewController appearance].toolBarTintColor;
        }
    }
    return self;
}

- (void)initSubviews {
    [super initSubviews];
    
    self.imagePreviewView.delegate = self;
    
    _topToolBarView = [[UIView alloc] init];
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
    self.topToolBarView.tintColor = self.toolBarTintColor;
    [self.view addSubview:self.topToolBarView];
    
    _backButton = [[NMUINavigationButton alloc] initWithType:NMUINavigationButtonTypeBack];
    [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.nmui_outsideEdge = UIEdgeInsetsMake(-30, -20, -50, -80);
    [self.topToolBarView addSubview:self.backButton];
    
    _checkboxButton = [[NMUIButton alloc] init];
    self.checkboxButton.adjustsTitleTintColorAutomatically = YES;
    self.checkboxButton.adjustsImageTintColorAutomatically = YES;
    UIImage *checkboxImage = [NMUIHelper imageWithName:@"NMUI_previewImage_checkbox"];
    UIImage *checkedCheckboxImage = [NMUIHelper imageWithName:@"NMUI_previewImage_checkbox_checked"];
    [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
    [self.checkboxButton setImage:checkedCheckboxImage forState:UIControlStateSelected];
    [self.checkboxButton setImage:[self.checkboxButton imageForState:UIControlStateSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.checkboxButton sizeToFit];
    [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.checkboxButton.nmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    [self.topToolBarView addSubview:self.checkboxButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_singleCheckMode) {
        NMUIAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    
    if ([self conformsToProtocol:@protocol(NMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<NMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<NMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self conformsToProtocol:@protocol(NMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<NMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<NMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
}
BeginIgnoreDeprecatedWarning
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), NavigationContentTopConstant);
    CGFloat topToolbarPaddingTop = SafeAreaInsetsConstantForDeviceWithNotch.top;
    CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
    self.backButton.frame = CGRectSetXY(self.backButton.frame, 16 + self.view.nmui_safeAreaInsets.left, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.backButton.frame)));
    if (!self.checkboxButton.hidden) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - self.view.nmui_safeAreaInsets.right - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.checkboxButton.frame)));
    }
}
EndIgnoreDeprecatedWarning

- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    self.topToolBarView.tintColor = toolBarTintColor;
}

- (void)setDownloadStatus:(NMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (!_singleCheckMode) {
        self.checkboxButton.hidden = NO;
    }
}

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<NMUIAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<NMUIAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode {
    self.imagesAssetArray = imageAssetArray;
    self.selectedImageAssetArray = selectedImageAssetArray;
    self.imagePreviewView.currentImageIndex = currentImageIndex;
    _singleCheckMode = singleCheckMode;
    if (singleCheckMode) {
        self.checkboxButton.hidden = YES;
    }
}

#pragma mark - <NMUIImagePreviewViewDelegate>

- (NSUInteger)numberOfImagesInImagePreviewView:(NMUIImagePreviewView *)imagePreviewView {
    return [self.imagesAssetArray count];
}

- (NMUIImagePreviewMediaType)imagePreviewView:(NMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    NMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    if (imageAsset.assetType == NMUIAssetTypeImage) {
        if (@available(iOS 9.1, *)) {
            if (imageAsset.assetSubType == NMUIAssetSubTypeLivePhoto) {
                return NMUIImagePreviewMediaTypeLivePhoto;
            }
        }
        return NMUIImagePreviewMediaTypeImage;
    } else if (imageAsset.assetType == NMUIAssetTypeVideo) {
        return NMUIImagePreviewMediaTypeVideo;
    } else {
        return NMUIImagePreviewMediaTypeOthers;
    }
}

- (void)imagePreviewView:(NMUIImagePreviewView *)imagePreviewView renderZoomImageView:(NMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    [self requestImageForZoomImageView:zoomImageView withIndex:index];
}

- (void)imagePreviewView:(NMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    if (!_singleCheckMode) {
        NMUIAsset *imageAsset = self.imagesAssetArray[index];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
}

#pragma mark - <NMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(NMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    self.topToolBarView.hidden = !self.topToolBarView.hidden;
}

- (void)didTouchICloudRetryButtonInZoomImageView:(NMUIZoomImageView *)imageView {
    NSInteger index = [self.imagePreviewView indexForZoomImageView:imageView];
    [self.imagePreviewView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)zoomImageView:(NMUIZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    self.topToolBarView.hidden = didHide;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(NMUIButton *)button {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        //        [self exitPreviewAutomatically];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewControllerDidCancel:)]) {
        [self.delegate imagePickerPreviewViewControllerDidCancel:self];
    }
}

- (void)handleCheckButtonClick:(NMUIButton *)button {
    [NMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:button];
    
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = NO;
        NMUIAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    } else {
        if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
            if (!self.alertTitleWhenExceedMaxSelectImageCount) {
                self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(self.maximumSelectImageCount)];
            }
            if (!self.alertButtonTitleWhenExceedMaxSelectImageCount) {
                self.alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            NMUIAlertController *alertController = [NMUIAlertController alertControllerWithTitle:self.alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:NMUIAlertControllerStyleAlert];
            [alertController addAction:[NMUIAlertAction actionWithTitle:self.alertButtonTitleWhenExceedMaxSelectImageCount style:NMUIAlertActionStyleCancel handler:nil]];
            [alertController showWithAnimated:YES];
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = YES;
        [NMUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:button];
        NMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    }
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(NMUIZoomImageView *)zoomImageView withIndex:(NSInteger)index {
    NMUIZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
    // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
    // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    NMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
    // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
    // 这也是系统相册能加载这么快的原因。
    // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
    PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            NMBFLogInfo(@"NMUIImagePickerLibrary", @"Download iCloud image in preview, current progress is: %f", progress);
            
            if (self.downloadStatus != NMUIAssetDownloadStatusDownloading) {
                self.downloadStatus = NMUIAssetDownloadStatusDownloading;
                imageView.cloudDownloadStatus = NMUIAssetDownloadStatusDownloading;
                
                // 重置 progressView 的显示的进度为 0
                [imageView.cloudProgressView setProgress:0 animated:NO];
            }
            // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
            float targetProgress = fmax(0.02, progress);
            if (targetProgress < imageView.cloudProgressView.progress) {
                [imageView.cloudProgressView setProgress:targetProgress animated:NO];
            } else {
                imageView.cloudProgressView.progress = fmax(0.02, progress);
            }
            if (error) {
                NMBFLog(@"NMUIImagePickerLibrary", @"Download iCloud image Failed, current progress is: %f", progress);
                self.downloadStatus = NMUIAssetDownloadStatusFailed;
                imageView.cloudDownloadStatus = NMUIAssetDownloadStatusFailed;
            }
        });
    };
    if (imageAsset.assetType == NMUIAssetTypeVideo) {
        imageView.tag = -1;
        imageAsset.requestID = [imageAsset requestPlayerItemWithCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
            // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                BOOL loadICloudImageFault = !playerItem || info[PHImageErrorKey];
                if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                    imageView.videoPlayerItem = playerItem;
                }
            });
        } withProgressHandler:phProgressHandler];
        imageView.tag = imageAsset.requestID;
    } else {
        if (imageAsset.assetType != NMUIAssetTypeImage) {
            return;
        }
        
        // 这么写是为了消除 Xcode 的 API available warning
        BOOL isLivePhoto = NO;
        if (@available(iOS 9.1, *)) {
            if (imageAsset.assetSubType == NMUIAssetSubTypeLivePhoto) {
                isLivePhoto = YES;
                imageView.tag = -1;
                imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
                    // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                    // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                        BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                        BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
                        if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                            // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
                            // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
                            if (@available(iOS 9.1, *)) {
                                imageView.livePhoto = livePhoto;
                            }
                        }
                        BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
                        if (downloadSucceed) {
                            // 资源资源已经在本地或下载成功
                            [imageAsset updateDownloadStatusWithDownloadResult:YES];
                            self.downloadStatus = NMUIAssetDownloadStatusSucceed;
                            imageView.cloudDownloadStatus = NMUIAssetDownloadStatusSucceed;
                        } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                            // 下载错误
                            [imageAsset updateDownloadStatusWithDownloadResult:NO];
                            self.downloadStatus = NMUIAssetDownloadStatusFailed;
                            imageView.cloudDownloadStatus = NMUIAssetDownloadStatusFailed;
                        }
                    });
                } withProgressHandler:phProgressHandler];
                imageView.tag = imageAsset.requestID;
            }
        }
        
        if (isLivePhoto) {
        } else if (imageAsset.assetSubType == NMUIAssetSubTypeGIF) {
            [imageAsset requestImageData:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resultImage = [UIImage nmui_animatedImageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = resultImage;
                    });
                });
            }];
        } else {
            imageView.tag = -1;
            imageView.image = [imageAsset thumbnailWithSize:CGSizeMake([NMUIImagePickerViewController appearance].minimumImageWidth, [NMUIImagePickerViewController appearance].minimumImageWidth)];
            imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !result || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        imageView.image = result;
                    }
                    BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = NMUIAssetDownloadStatusSucceed;
                        imageView.cloudDownloadStatus = NMUIAssetDownloadStatusSucceed;
                    } else if ([info objectForKey:PHImageErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = NMUIAssetDownloadStatusFailed;
                        imageView.cloudDownloadStatus = NMUIAssetDownloadStatusFailed;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
    }
}

@end
