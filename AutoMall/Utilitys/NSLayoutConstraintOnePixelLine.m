//
//  NSLayoutConstraintOnePixelLine.m
//  AutoMall
//
//  Created by LYD on 2017/11/1.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "NSLayoutConstraintOnePixelLine.h"

@implementation NSLayoutConstraintOnePixelLine

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.constant == 1) {
        self.constant = 1 / [UIScreen mainScreen].scale;
    }
}

@end
