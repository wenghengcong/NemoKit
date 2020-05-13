//
//  UIGestureRecognizer+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIGestureRecognizer+NMUI.h"

@implementation UIGestureRecognizer (NMUI)

- (nullable UIView *)nmui_targetView {
    CGPoint location = [self locationInView:self.view];
    UIView *targetView = [self.view hitTest:location withEvent:nil];
    return targetView;
}

@end
