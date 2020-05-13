//
//  NMUIImagePickerPreviewViewController.h
//  Nemo
//
//  Created by Hunt on 2019/11/4.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMUIImagePreviewViewController.h"
#import "NMUIAsset.h"

NS_ASSUME_NONNULL_BEGIN

@class NMUIButton, NMUINavigationButton;
@class NMUIImagePickerViewController;
@class NMUIImagePickerPreviewViewController;

@protocol NMUIImagePickerPreviewViewControllerDelegate <NSObject>

@optional

/// 取消选择图片后被调用
- (void)imagePickerPreviewViewControllerDidCancel:(NMUIImagePickerPreviewViewController *)imagePickerPreviewViewController;
/// 即将选中图片
- (void)imagePickerPreviewViewController:(NMUIImagePickerPreviewViewController *)imagePickerPreviewViewController willCheckImageAtIndex:(NSInteger)index;
/// 已经选中图片
- (void)imagePickerPreviewViewController:(NMUIImagePickerPreviewViewController *)imagePickerPreviewViewController didCheckImageAtIndex:(NSInteger)index;
/// 即将取消选中图片
- (void)imagePickerPreviewViewController:(NMUIImagePickerPreviewViewController *)imagePickerPreviewViewController willUncheckImageAtIndex:(NSInteger)index;
/// 已经取消选中图片
- (void)imagePickerPreviewViewController:(NMUIImagePickerPreviewViewController *)imagePickerPreviewViewController didUncheckImageAtIndex:(NSInteger)index;

@end


@interface NMUIImagePickerPreviewViewController : NMUIImagePreviewViewController <NMUIImagePreviewViewDelegate>

@property(nullable, nonatomic, weak) id<NMUIImagePickerPreviewViewControllerDelegate> delegate;

@property(nullable, nonatomic, strong) UIColor *toolBarBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nullable, nonatomic, strong) UIColor *toolBarTintColor UI_APPEARANCE_SELECTOR;

@property(nullable, nonatomic, strong, readonly) UIView *topToolBarView;
@property(nullable, nonatomic, strong, readonly) NMUINavigationButton *backButton;
@property(nullable, nonatomic, strong, readonly) NMUIButton *checkboxButton;

/// 由于组件需要通过本地图片的 NMUIAsset 对象读取图片的详细信息，因此这里的需要传入的是包含一个或多个 NMUIAsset 对象的数组
@property(nullable, nonatomic, strong) NSMutableArray<NMUIAsset *> *imagesAssetArray;
@property(nullable, nonatomic, strong) NSMutableArray<NMUIAsset *> *selectedImageAssetArray;

@property(nonatomic, assign) NMUIAssetDownloadStatus downloadStatus;

/// 最多可以选择的图片数，默认为无穷大
@property(nonatomic, assign) NSUInteger maximumSelectImageCount;
/// 最少需要选择的图片数，默认为 0
@property(nonatomic, assign) NSUInteger minimumSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertTitleWhenExceedMaxSelectImageCount;
/// 选择图片超出最大图片限制时 alertView 的标题
@property(nullable, nonatomic, copy) NSString *alertButtonTitleWhenExceedMaxSelectImageCount;

/**
 *  更新数据并刷新 UI，手工调用
 *
 *  @param imageAssetArray         包含所有需要展示的图片的数组
 *  @param selectedImageAssetArray 包含所有需要展示的图片中已经被选中的图片的数组
 *  @param currentImageIndex       当前展示的图片在 imageAssetArray 的索引
 *  @param singleCheckMode         是否为单选模式，如果是单选模式，则不显示 checkbox
 */
- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<NMUIAsset *> * _Nullable)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<NMUIAsset *> * _Nullable)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode;

@end


@interface NMUIImagePickerPreviewViewController (UIAppearance)

+ (instancetype)appearance;

@end

NS_ASSUME_NONNULL_END
