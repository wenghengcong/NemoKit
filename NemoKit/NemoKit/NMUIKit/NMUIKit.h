//
//  NMUIKit.h
//  Nemo
//
//  Created by Hunt on 2019/10/29.
//  Copyright © 2019 LuCi. All rights reserved.
//

#ifndef NMUIKit_h
#define NMUIKit_h

static NSString * const NMUIKIT_VERSION = @"1.0.0";

#if __has_include("NMForm.h")
#import "NMForm.h"
#endif

#if __has_include("NMUIEasings.h")
#import "NMUIEasings.h"
#endif

#if __has_include("NMUIDisplayLinkAnimation.h")
#import "NMUIDisplayLinkAnimation.h"
#endif

#if __has_include("NMUIAnimationHelper.h")
#import "NMUIAnimationHelper.h"
#endif


#if __has_include("NMUIAsset.h")
#import "NMUIAsset.h"
#endif

#if __has_include("NMUIAssetsGroup.h")
#import "NMUIAssetsGroup.h"
#endif

#if __has_include("NMUIAssetsManager.h")
#import "NMUIAssetsManager.h"
#endif


#if __has_include("NMUIKeyboardManager.h")
#import "NMUIKeyboardManager.h"
#endif

#if __has_include("NMUIGridView.h")
#import "NMUIGridView.h"
#endif

#if __has_include("NMUICellSizeKeyCache.h")
#import "NMUICellSizeKeyCache.h"
#endif


#if __has_include("UICollectionView+NMUICellSizeKeyCache.h")
#import "UICollectionView+NMUICellSizeKeyCache.h"
#endif

#if __has_include("NMUICollectionViewPagingLayout.h")
#import "NMUICollectionViewPagingLayout.h"
#endif

#if __has_include("NMUICellHeightCache.h")
#import "NMUICellHeightCache.h"
#endif


#if __has_include("NMUICellHeightKeyCache.h")
#import "NMUICellHeightKeyCache.h"
#endif

#if __has_include("UITableView+NMUICellHeightKeyCache.h")
#import "UITableView+NMUICellHeightKeyCache.h"
#endif

#if __has_include("NMUITableViewProtocols.h")
#import "NMUITableViewProtocols.h"
#endif


#if __has_include("NMUITableView.h")
#import "NMUITableView.h"
#endif

#if __has_include("NMUITableViewHeaderFooterView.h")
#import "NMUITableViewHeaderFooterView.h"
#endif

#if __has_include("NMUITableViewCell.h")
#import "NMUITableViewCell.h"
#endif


#if __has_include("NMUIStaticTableViewCellData.h")
#import "NMUIStaticTableViewCellData.h"
#endif

#if __has_include("UITableView+NMUIStaticCell.h")
#import "UITableView+NMUIStaticCell.h"
#endif

#if __has_include("NMUIStaticTableViewCellDataSource.h")
#import "NMUIStaticTableViewCellDataSource.h"
#endif


#if __has_include("NMUIFloatLayoutView.h")
#import "NMUIFloatLayoutView.h"
#endif

#if __has_include("NMUIEmptyView.h")
#import "NMUIEmptyView.h"
#endif

#if __has_include("NMUINavigationTitleView.h")
#import "NMUINavigationTitleView.h"
#endif


#if __has_include("NMUIScrollAnimator.h")
#import "NMUIScrollAnimator.h"
#endif

#if __has_include("NMUINavigationBarScrollingAnimator.h")
#import "NMUINavigationBarScrollingAnimator.h"
#endif

#if __has_include("NMUINavigationBarScrollingSnapAnimator.h")
#import "NMUINavigationBarScrollingSnapAnimator.h"
#endif


#if __has_include("NMUINavigationController.h")
#import "NMUINavigationController.h"
#endif

#if __has_include("NMUICommonViewController.h")
#import "NMUICommonViewController.h"
#endif

#if __has_include("NMUICommonTableViewController.h")
#import "NMUICommonTableViewController.h"
#endif


#if __has_include("NMUITabBarController.h")
#import "NMUITabBarController.h"
#endif

#if __has_include("NMUIModalPresentationViewController.h")
#import "NMUIModalPresentationViewController.h"
#endif

#if __has_include("NMUIMoreOperationController.h")
#import "NMUIMoreOperationController.h"
#endif


#if __has_include("NMUIWindowSizeMonitor.h")
#import "NMUIWindowSizeMonitor.h"
#endif

#if __has_include("NMUITextView.h")
#import "NMUITextView.h"
#endif

#if __has_include("NMUITextField.h")
#import "NMUITextField.h"
#endif


#if __has_include("NMUILabel.h")
#import "NMUILabel.h"
#endif

#if __has_include("NMUILayerLabel.h")
#import "NMUILayerLabel.h"
#endif

#if __has_include("NMUIMarqueeLabel.h")
#import "NMUIMarqueeLabel.h"
#endif


#if __has_include("NMUISlider.h")
#import "NMUISlider.h"
#endif

#if __has_include("NMUIPieProgressView.h")
#import "NMUIPieProgressView.h"
#endif


#if __has_include("NMUISegmentedControl.h")
#import "NMUISegmentedControl.h"
#endif

#if __has_include("NMUIAlertController.h")
#import "NMUIAlertController.h"
#endif

#if __has_include("UIBarItem+NMUIBadge.h")
#import "UIBarItem+NMUIBadge.h"
#endif


#if __has_include("NMUIDialogViewController.h")
#import "NMUIDialogViewController.h"
#endif

#if __has_include("NMUITips.h")
#import "NMUITips.h"
#endif


#if __has_include("NMUIToastBackgroundView.h")
#import "NMUIToastBackgroundView.h"
#endif

#if __has_include("NMUIToastAnimator.h")
#import "NMUIToastAnimator.h"
#endif

#if __has_include("NMUIToastContentView.h")
#import "NMUIToastContentView.h"
#endif


#if __has_include("NMUIToastView.h")
#import "NMUIToastView.h"
#endif

#if __has_include("NMUIPopupMenuItemProtocol.h")
#import "NMUIPopupMenuItemProtocol.h"
#endif


#if __has_include("NMUIPopupContainerView.h")
#import "NMUIPopupContainerView.h"
#endif

#if __has_include("NMUIPopupMenuBaseItem.h")
#import "NMUIPopupMenuBaseItem.h"
#endif

#if __has_include("NMUIPopupMenuButtonItem.h")
#import "NMUIPopupMenuButtonItem.h"
#endif


#if __has_include("NMUIPopupMenuView.h")
#import "NMUIPopupMenuView.h"
#endif

#if __has_include("NMUISearchBar.h")
#import "NMUISearchBar.h"
#endif


#if __has_include("NMUISearchController.h")
#import "NMUISearchController.h"
#endif

#if __has_include("NMUIConsoleHeader.h")
#import "NMUIConsoleHeader.h"
#endif

#if __has_include("NMUIButtonHeader.h")
#import "NMUIButtonHeader.h"
#endif

#if __has_include("NMFontHeader.h")
#import "NMFontHeader.h"
#endif

#if __has_include("NMUITheme.h")
#import "NMUITheme.h"
#endif

#if __has_include("NMUIAlbumTableViewCell.h")
#import "NMUIAlbumTableViewCell.h"
#endif

#if __has_include("NMUIImagePickerCollectionViewCell.h")
#import "NMUIImagePickerCollectionViewCell.h"
#endif

#if __has_include("NMUIImagePickerHelper.h")
#import "NMUIImagePickerHelper.h"
#endif

#if __has_include("NMUIImagePickerPreviewViewController.h")
#import "NMUIImagePickerPreviewViewController.h"
#endif

#if __has_include("NMUIImagePickerViewController.h")
#import "NMUIImagePickerViewController.h"
#endif

#if __has_include("NMUIImagePreviewView.h")
#import "NMUIImagePreviewView.h"
#endif

#if __has_include("NMUIImagePreviewViewController.h")
#import "NMUIImagePreviewViewController.h"
#endif

#if __has_include("NMUIImagePreviewViewTransitionAnimator.h")
#import "NMUIImagePreviewViewTransitionAnimator.h"
#endif

#if __has_include("NMUIZoomImageView.h")
#import "NMUIZoomImageView.h"
#endif

#if __has_include("NMUIReflectionView.h")
#import "NMUIReflectionView.h"
#endif

#if __has_include("NMUIVisualEffectView.h")
#import "NMUIVisualEffectView.h"
#endif
#if __has_include("NMUITestView.h")
#import "NMUITestView.h"
#endif

#if __has_include("MJRefresh.h")
#import "MJRefresh.h"
#endif

#if __has_include("NMUIFeedBackEffect.h")
#import "NMUIFeedBackEffect.h"
#endif

#endif /* NMUIKit_h */
