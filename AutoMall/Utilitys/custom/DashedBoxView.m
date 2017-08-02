//
//  DashedBoxView.m
//  mobilely
//
//  Created by Victoria on 15/2/9.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "DashedBoxView.h"
#import "UIColor+RGBTransform.h"

@implementation DashedBoxView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor getColor:@"5d5d5d"].CGColor);
    CGFloat dashArray[] = {2,2,2,2};
    CGContextSetLineDash(context, 3, dashArray, 4);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}

@end
