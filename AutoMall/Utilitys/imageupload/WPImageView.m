//
//  WPImageView.m
//  CustomImageViewDemo
//
//  Created by wp on 15-2-4.
//  Copyright (c) 2015年 wp. All rights reserved.
//

#import "WPImageView.h"
#import "CircleProgressView.h"


@interface WPImageView ()
@property (nonatomic, strong) CircleProgressView *circleProgressView;
@property (nonatomic, strong) UIButton *delButn;
@end
@implementation WPImageView


- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth{
    if (self = [super initWithFrame:frame]) {
        //self.layer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"people_img_box@2x"]].CGColor;
        //self.layer.borderColor = [UIColor blackColor].CGColor;
        //self.layer.borderWidth = 0.5;
        self.backgroundColor = [UIColor whiteColor];
        //self.image = [UIImage imageNamed:@"people_img_box@2x"];
        self.userInteractionEnabled = YES;
//        //初始化删除按钮
//        self.delButn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [self.delButn setFrame:CGRectMake(frame.size.width - 20, -20, 40, 40)];
//        [self.delButn setBackgroundColor:[UIColor redColor]];
//        //[self.delButn addTarget:self action:@selector(clearImage) forControlEvents:UIControlEventTouchUpInside];
//        self.delButn.hidden = YES;
//        [self addSubview:self.delButn];
        
        CGRect frame1 = self.frame;
        frame1.origin.x = 0;
        frame1.origin.y = 0;
        frame1.size.height -=0;
        frame1.size.width -=0;
        self.circleProgressView = [[CircleProgressView alloc] initWithFrame:frame1 backColor:backColor progressColor:progressColor lineWidth:lineWidth];
        self.circleProgressView.hidden = YES;
        [self addSubview:self.circleProgressView];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setNeedsLayout];
    [self layoutIfNeeded];
//    self.userInteractionEnabled = YES;
//    CGRect frame1 = self.frame;
//    frame1.origin.x = 0;
//    frame1.origin.y = 0;
//    frame1.size.height -=0;
//    frame1.size.width -=0;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // 这里可以提前获得autolayout完成后适配后的子控件的真实frame
    self.circleProgressView = [[CircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 60, 60) backColor:[UIColor colorWithWhite:0.603 alpha:0.390] progressColor:[UIColor greenColor] lineWidth:2];
    self.circleProgressView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    NSLog(@"self.circleProgressView.center:  %@",NSStringFromCGPoint(self.circleProgressView.center));
    self.circleProgressView.hidden = YES;
    [self addSubview:self.circleProgressView];
    
}

//-(void)setImage:(UIImage *)image{
//    self.imageView.image = image;
//}
-(void)setCurrentProgress:(CGFloat)progress
{
    [self.circleProgressView changeProgress1:progress];
}

-(void) setImageWithUrl:(NSURL *)imageUrl delegate:(id)delegate indexPath:(NSIndexPath *)indexPath post:(BOOL)post{
    
}

-(void) setImageViewWithImage:(UIImage *)image{
    self.image = image;
}

-(void)setCircleProgressViewHidden:(BOOL)hidden{
    self.circleProgressView.hidden = hidden;
}

-(void)clearImage{
    self.image = [UIImage imageNamed:@"people_img_box@2x"];
    self.delButn.hidden = YES;
}
-(void)addTarget:(id)delegate action:(SEL)action tag:(NSInteger)tag{
    self.delButn.tag = tag;
    [self.delButn addTarget:delegate action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
