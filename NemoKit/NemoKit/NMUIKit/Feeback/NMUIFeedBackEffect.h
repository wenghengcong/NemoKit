//
//  NMUIFeedBackEffect.h
//  NemoMoney
//
//  Created by Hunt on 2020/5/13.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMUIFeedBackEffect : NSObject

/// 振动效果
/// @param style 强度
+ (void)generateFeeBack:(UIImpactFeedbackStyle)style;

/// 播放系统声音
/// @param inSystemSoundID 系统声音 ID，参考 https://github.com/TUNER88/iOSSystemSoundsLibrary
+ (void)playSystemSoundID: (SystemSoundID)inSystemSoundID;

+ (void)playKeyPressEffect;

/// 播放声音
/// @param name 声音文件名
/// @param type 文件类型
+ (void)playSoundWithFileName:(NSString *)name type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
