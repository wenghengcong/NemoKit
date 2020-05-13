//
//  UIActivityIndicatorView+NMUI.m
//  Nemo
//
//  Created by Hunt on 2019/10/18.
//  Copyright © 2019 LuCi. All rights reserved.
//

#import "UIActivityIndicatorView+NMUI.h"


@implementation UIActivityIndicatorView (NMUI)


- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size {
    if (self = [self initWithActivityIndicatorStyle:style]) {
        CGSize initialSize = self.bounds.size;
        CGFloat scale = size.width / initialSize.width;
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return self;
}

@end
