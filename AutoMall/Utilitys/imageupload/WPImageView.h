//
//  WPImageView.h
//  CustomImageViewDemo
//
//  Created by wp on 15-2-4.
//  Copyright (c) 2015年 wp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WPImageView : UIImageView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;

//-(void)setImage:(UIImage *)image;
/**
 *  设置圆形进度条是否隐藏
 *
 *  @param hidden <#hidden description#>
 */
-(void)setCircleProgressViewHidden:(BOOL)hidden;

/**
 *  设置进度条的当前数值
 *
 *  @param progress <#progress description#>
 */
-(void)setCurrentProgress:(CGFloat)progress;

/**
 *  设置图片
 *
 *  @param image <#image description#>
 */
-(void) setImageViewWithImage:(UIImage *)image;
@end
