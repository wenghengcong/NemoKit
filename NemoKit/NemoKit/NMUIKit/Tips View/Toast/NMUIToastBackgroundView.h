//
//  NMUIToastBackgroundView.h
//  Nemo
//
//  Created by Hunt on 2019/10/17.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class NMUIVisualEffectView;

@interface NMUIToastBackgroundView : UIView

/**
 * 是否需要磨砂，默认NO。仅支持iOS8及以上版本。可以通过修改`styleColor`来控制磨砂的效果。
 */
@property(nonatomic, assign) BOOL shouldBlurBackgroundView;

@property(nullable, nonatomic, strong, readonly) NMUIVisualEffectView *effectView;

/**
 * 如果不设置磨砂，则styleColor直接作为`NMUIToastBackgroundView`的backgroundColor；如果需要磨砂，则会新增加一个`UIVisualEffectView`放在`NMUIToastBackgroundView`上面。
 */
@property(nullable, nonatomic, strong) UIColor *styleColor UI_APPEARANCE_SELECTOR;

/**
 * 设置圆角。
 */
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

@end


NS_ASSUME_NONNULL_END
