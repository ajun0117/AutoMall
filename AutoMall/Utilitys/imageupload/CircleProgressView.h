//
//  CircleProgressView.h
//  CustomImageView
//
//  Created by Victoria on 15/2/1.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressView : UIView
- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;

-(void)changeProgress1:(CGFloat)progress;
@end
