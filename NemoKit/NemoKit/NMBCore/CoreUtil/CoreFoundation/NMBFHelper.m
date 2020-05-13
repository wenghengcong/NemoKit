//
//  NMBFHelper.m
//  Nemo
//
//  Created by Hunt on 2019/10/15.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "NMBFHelper.h"
#import "NMBCore.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation NMBFHelper

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NMBFHelper sharedInstance];// 确保内部的变量、notification 都正确配置
    });
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static NMBFHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)dealloc {
    // NMUIHelper 若干个分类里有用到消息监听，所以在 dealloc 的时候注销一下
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation NMBFHelper (SystemVersion)

+ (NSInteger)numbericOSVersion {
    NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    NSArray *OSVersionArr = [OSVersion componentsSeparatedByString:@"."];
    
    NSInteger numbericOSVersion = 0;
    NSInteger pos = 0;
    
    while ([OSVersionArr count] > pos && pos < 3) {
        numbericOSVersion += ([[OSVersionArr objectAtIndex:pos] integerValue] * pow(10, (4 - pos * 2)));
        pos++;
    }
    
    return numbericOSVersion;
}

+ (NSComparisonResult)compareSystemVersion:(nonnull NSString *)currentVersion toVersion:(nonnull NSString *)targetVersion {
    // 将版本号处理成数组，13.1->[13,1]
    // 从index 为 0 开始比较，即大版本比较
    NSArray *currentVersionArr = [currentVersion componentsSeparatedByString:@"."];
    NSArray *targetVersionArr = [targetVersion componentsSeparatedByString:@"."];
    
    NSInteger pos = 0;
    
    while ([currentVersionArr count] > pos || [targetVersionArr count] > pos) {
        NSInteger v1 = [currentVersionArr count] > pos ? [[currentVersionArr objectAtIndex:pos] integerValue] : 0;
        NSInteger v2 = [targetVersionArr count] > pos ? [[targetVersionArr objectAtIndex:pos] integerValue] : 0;
        if (v1 < v2) {
            return NSOrderedAscending;
        }
        else if (v1 > v2) {
            return NSOrderedDescending;
        }
        pos++;
    }
    
    return NSOrderedSame;
}

+ (BOOL)isCurrentSystemAtLeastVersion:(nonnull NSString *)targetVersion {
       return [NMBFHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedSame || [NMBFHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedDescending;
}
+ (BOOL)isCurrentSystemLowerThanVersion:(nonnull NSString *)targetVersion {
     return [NMBFHelper compareSystemVersion:[[UIDevice currentDevice] systemVersion] toVersion:targetVersion] == NSOrderedAscending;
}

@end


@implementation NMBFHelper (AudioSession)

+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary {
    if (![[AVAudioSession sharedInstance].category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return;
    }
    if (temporary) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:speaker ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone error:nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:[AVAudioSession sharedInstance].category withOptions:speaker ? AVAudioSessionCategoryOptionDefaultToSpeaker : 0 error:nil];
    }
}

BeginIgnoreDeprecatedWarning
+ (void)setAudioSessionCategory:(nullable NSString *)category {
    // 如果不属于系统category，返回
    if (category != AVAudioSessionCategoryAmbient &&
        category != AVAudioSessionCategorySoloAmbient &&
        category != AVAudioSessionCategoryPlayback &&
        category != AVAudioSessionCategoryRecord &&
        category != AVAudioSessionCategoryPlayAndRecord &&
        category != AVAudioSessionCategoryAudioProcessing)
        {
        return;
        }
    
    [[AVAudioSession sharedInstance] setCategory:category error:nil];
}


+ (UInt32)categoryForLowVersionWithCategory:(NSString *)category {
    if ([category isEqualToString:AVAudioSessionCategoryAmbient]) {
        return kAudioSessionCategory_AmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategorySoloAmbient]) {
        return kAudioSessionCategory_SoloAmbientSound;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        return kAudioSessionCategory_MediaPlayback;
    }
    if ([category isEqualToString:AVAudioSessionCategoryRecord]) {
        return kAudioSessionCategory_RecordAudio;
    }
    if ([category isEqualToString:AVAudioSessionCategoryPlayAndRecord]) {
        return kAudioSessionCategory_PlayAndRecord;
    }
    if ([category isEqualToString:AVAudioSessionCategoryAudioProcessing]) {
        return kAudioSessionCategory_AudioProcessing;
    }
    return kAudioSessionCategory_AmbientSound;
}
EndIgnoreDeprecatedWarning

@end
