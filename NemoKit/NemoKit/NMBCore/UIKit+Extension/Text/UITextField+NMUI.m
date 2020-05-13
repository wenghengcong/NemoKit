//
//  UITextField+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UITextField+NMUI.h"
#import "NMBCore.h"

@implementation UITextField (NMUI)

- (NSRange)nmui_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (UIButton *)nmui_clearButton {
    return [self nmbf_valueForKey:@"clearButton"];
}

static char kAssociatedObjectKey_clearButtonImage;
- (void)setNmui_clearButtonImage:(UIImage *)nmui_clearButtonImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, nmui_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.nmui_clearButton setImage:nmui_clearButtonImage forState:UIControlStateNormal];
    
    // 如果当前 clearButton 正在显示的时候把自定义图片去掉，需要重新 layout 一次才能让系统默认图片显示出来
    if (!nmui_clearButtonImage) {
        [self setNeedsLayout];
    }
}

- (UIImage *)nmui_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}


@end
