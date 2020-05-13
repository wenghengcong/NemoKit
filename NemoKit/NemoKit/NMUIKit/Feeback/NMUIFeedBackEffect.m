//
//  NMUIFeedBackEffect.m
//  NemoMoney
//
//  Created by Hunt on 2020/5/13.
//  Copyright © 2020 Hunt <wenghengcong@icloud.com>. All rights reserved.
//

#import "NMUIFeedBackEffect.h"

@implementation NMUIFeedBackEffect

+ (void)generateFeeBack:(UIImpactFeedbackStyle)style;
{
    /*
     导入：#import <AudioToolbox/AudioToolbox.h>
     在需要出发震动的地方写上代码：
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//默认震动效果
     如果想要其他震动效果，可参考：
     // 普通短震，3D Touch 中 Pop 震动反馈
     AudioServicesPlaySystemSound(1520);
     
     // 普通短震，3D Touch 中 Peek 震动反馈
     AudioServicesPlaySystemSound(1519);

     // 连续三次短震
     AudioServicesPlaySystemSound(1521);
     */
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
    [generator prepare];
    [generator impactOccurred];
}

+ (void)playSystemSoundID: (SystemSoundID)inSystemSoundID {
    AudioServicesPlaySystemSound(inSystemSoundID);
}

+ (void)playKeyPressEffect {
    [self playSystemSoundID: 1105];
}
 void soundCompleteCallBack(SystemSoundID soundID, void *clientData) {
     NSLog(@"播放完成");
}

+ (void)playSoundWithFileName:(NSString *)name type:(NSString *)type {
    //获取音效文件路径
    NSString *checkType = type ?: nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:checkType];
    //创建音效文件URL
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    //音效声音的唯一标示ID
    SystemSoundID soundID = 0;
    //将音效加入到系统音效服务中，NSURL需要桥接成CFURLRef，会返回一个长整形ID，用来做音效的唯一标示
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //设置音效播放完成后的回调C语言函数
    AudioServicesAddSystemSoundCompletion(soundID,NULL,NULL,soundCompleteCallBack,NULL);
    //开始播放音效
    AudioServicesPlaySystemSound(soundID);
}

@end
