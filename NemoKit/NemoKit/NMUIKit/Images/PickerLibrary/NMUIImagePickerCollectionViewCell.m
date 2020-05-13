//
//  NMUIImagePickerCollectionViewCell.m
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMUIImagePickerCollectionViewCell.h"
#import "NMBCore.h"
#import "NMUIImagePickerHelper.h"
#import "NMUIPieProgressView.h"
#import "UIControl+NMUI.h"
#import "UILabel+NMUI.h"
#import "CALayer+NMUI.h"
#import "NMUIButton.h"
#import "UIView+NMUI.h"
#import "NSString+NMBF.h"

@interface NMUIImagePickerCollectionViewCell ()

@property(nonatomic, strong, readwrite) UIImageView *favoriteImageView;
@property(nonatomic, strong, readwrite) NMUIButton *checkboxButton;
@property(nonatomic, strong, readwrite) CAGradientLayer *bottomShadowLayer;

@end


@implementation NMUIImagePickerCollectionViewCell

@synthesize videoDurationLabel = _videoDurationLabel;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NMUIImagePickerCollectionViewCell appearance].favoriteImage = [NMUIHelper imageWithName:@"NMUI_pickerImage_favorite"];
        [NMUIImagePickerCollectionViewCell appearance].favoriteImageMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [NMUIImagePickerCollectionViewCell appearance].checkboxImage = [NMUIHelper imageWithName:@"NMUI_pickerImage_checkbox"];
        [NMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage = [NMUIHelper imageWithName:@"NMUI_pickerImage_checkbox_checked"];
        [NMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelFont = UIFontMake(12);
        [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelTextColor = UIColorWhite;
        [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelMargins = UIEdgeInsetsMake(5, 5, 5, 7);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
        self.favoriteImage = [NMUIImagePickerCollectionViewCell appearance].favoriteImage;
        self.favoriteImageMargins = [NMUIImagePickerCollectionViewCell appearance].favoriteImageMargins;
        self.checkboxImage = [NMUIImagePickerCollectionViewCell appearance].checkboxImage;
        self.checkboxCheckedImage = [NMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage;
        self.checkboxButtonMargins = [NMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins;
        self.videoDurationLabelFont = [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelFont;
        self.videoDurationLabelTextColor = [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelTextColor;
        self.videoDurationLabelMargins = [NMUIImagePickerCollectionViewCell appearance].videoDurationLabelMargins;
    }
    return self;
}

- (void)initImagePickerCollectionViewCellUI {
    _contentImageView = [[UIImageView alloc] init];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.contentImageView];
    
    self.bottomShadowLayer = [CAGradientLayer layer];
    [self.bottomShadowLayer nmui_removeDefaultAnimations];
    self.bottomShadowLayer.colors = @[(id)UIColorMakeWithRGBA(0, 0, 0, 0).CGColor, (id)UIColorMakeWithRGBA(0, 0, 0, .6).CGColor];
    self.bottomShadowLayer.hidden = YES;
    [self.contentView.layer addSublayer:self.bottomShadowLayer];
    [self setNeedsLayout];
    
    self.favoriteImageView = [[UIImageView alloc] init];
    self.favoriteImageView.hidden = YES;
    [self.contentView addSubview:self.favoriteImageView];
    
    self.checkboxButton = [[NMUIButton alloc] init];
    self.checkboxButton.nmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    self.checkboxButton.nmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
}

- (void)renderWithAsset:(NMUIAsset *)asset referenceSize:(CGSize)referenceSize {
    self.assetIdentifier = asset.identifier;
    
    // 异步请求资源对应的缩略图
    [asset requestThumbnailImageWithSize:referenceSize completion:^(UIImage *result, NSDictionary *info) {
        if ([self.assetIdentifier isEqualToString:asset.identifier]) {
            self.contentImageView.image = result;
        } else {
            self.contentImageView.image = nil;
        }
    }];
    
    if (asset.assetType == NMUIAssetTypeVideo) {
        [self initVideoDurationLabelIfNeeded];
        self.videoDurationLabel.text = [NSString nmbf_timeStringWithMinsAndSecsFromSecs:asset.duration];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
    
    self.favoriteImageView.hidden = !asset.phAsset.favorite;
    
    self.bottomShadowLayer.hidden = !((self.videoDurationLabel && !self.videoDurationLabel.hidden) || !self.favoriteImageView.hidden);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentImageView.frame = self.contentView.bounds;
    if (_selectable) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.bounds), self.checkboxButtonMargins.top);
    }
    
    CGFloat bottomShadowLayerHeight = 0;
    
    if (!self.favoriteImageView.hidden) {
        self.favoriteImageView.frame = CGRectSetXY(self.favoriteImageView.frame, self.favoriteImageMargins.left, CGRectGetHeight(self.contentView.bounds) - self.favoriteImageMargins.bottom - CGRectGetHeight(self.favoriteImageView.frame));
        bottomShadowLayerHeight = CGRectGetHeight(self.favoriteImageView.frame) + UIEdgeInsetsGetVerticalValue(self.favoriteImageMargins);
    }
    
    if (self.videoDurationLabel && !self.videoDurationLabel.hidden) {
        [self.videoDurationLabel sizeToFit];
        self.videoDurationLabel.frame = CGRectSetXY(self.videoDurationLabel.frame, CGRectGetWidth(self.contentView.bounds) - self.videoDurationLabelMargins.right - CGRectGetWidth(self.videoDurationLabel.frame), CGRectGetHeight(self.contentView.bounds) - self.videoDurationLabelMargins.bottom - CGRectGetHeight(self.videoDurationLabel.frame));
        bottomShadowLayerHeight = MAX(bottomShadowLayerHeight, CGRectGetHeight(self.videoDurationLabel.frame) + UIEdgeInsetsGetVerticalValue(self.videoDurationLabelMargins));
    }
    
    if (!self.bottomShadowLayer.hidden) {
        self.bottomShadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - bottomShadowLayerHeight, CGRectGetWidth(self.contentView.bounds), bottomShadowLayerHeight);
    }
}

- (void)setFavoriteImage:(UIImage *)favoriteImage {
    if (![self.favoriteImage isEqual:favoriteImage]) {
        self.favoriteImageView.image = favoriteImage;
        [self.favoriteImageView sizeToFit];
        [self setNeedsLayout];
    }
    _favoriteImage = favoriteImage;
}

- (void)setCheckboxImage:(UIImage *)checkboxImage {
    if (![self.checkboxImage isEqual:checkboxImage]) {
        [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxImage = checkboxImage;
}

- (void)setCheckboxCheckedImage:(UIImage *)checkboxCheckedImage {
    if (![self.checkboxCheckedImage isEqual:checkboxCheckedImage]) {
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected];
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxCheckedImage = checkboxCheckedImage;
}

- (void)setVideoDurationLabelFont:(UIFont *)videoDurationLabelFont {
    if (![self.videoDurationLabelFont isEqual:videoDurationLabelFont]) {
        _videoDurationLabel.font = videoDurationLabelFont;
        [_videoDurationLabel nmui_calculateHeightAfterSetAppearance];
        [self setNeedsLayout];
    }
    _videoDurationLabelFont = videoDurationLabelFont;
}

- (void)setVideoDurationLabelTextColor:(UIColor *)videoDurationLabelTextColor {
    if (![self.videoDurationLabelTextColor isEqual:videoDurationLabelTextColor]) {
        _videoDurationLabel.textColor = videoDurationLabelTextColor;
    }
    _videoDurationLabelTextColor = videoDurationLabelTextColor;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_selectable) {
        self.checkboxButton.selected = checked;
        [NMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        if (checked) {
            [NMUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        }
    }
}

- (void)setSelectable:(BOOL)editing {
    _selectable = editing;
    if (self.downloadStatus == NMUIAssetDownloadStatusSucceed) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)setDownloadStatus:(NMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (_selectable) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)initVideoDurationLabelIfNeeded {
    if (!self.videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] nmui_initWithFont:self.videoDurationLabelFont textColor:self.videoDurationLabelTextColor];
        [self.contentView addSubview:_videoDurationLabel];
        [self setNeedsLayout];
    }
}

@end
