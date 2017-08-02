//
//  CircleProgressView.m
//  CustomImageView
//
//  Created by Victoria on 15/2/1.
//  Copyright (c) 2015年 Somiya. All rights reserved.
//

#import "CircleProgressView.h"
@interface CircleProgressView()

@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *progressColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) float progress;
@property (nonatomic, strong) UILabel *progressLabel;


@end
@implementation CircleProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _backColor = backColor;
        _progressColor = progressColor;
        _lineWidth = lineWidth;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5];
        
        CGRect frame1 = self.frame;
        frame1.origin.x = 0;
        frame1.origin.y = 0;
        
        self.progressLabel = [[UILabel alloc] initWithFrame:frame1];
        self.progressLabel.backgroundColor = [UIColor clearColor];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
//        self.progressLabel.font = [UIFont fontWithName:@"Arial" size:14.0f];
        [self addSubview:self.progressLabel];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //draw background circle
    UIBezierPath *backCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2) radius:self.bounds.size.width / 3 - self.lineWidth / 3 startAngle:(CGFloat) - M_PI_2 endAngle:(CGFloat)(1.5 * M_PI) clockwise:YES];
    [self.backColor setStroke];
    backCircle.lineWidth = self.lineWidth;
    [backCircle stroke];
    
    if (self.progress != 0) {
        //draw progress circle
        UIBezierPath *progressCircle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2,self.bounds.size.height / 2) radius:self.bounds.size.width / 3 - self.lineWidth / 3 startAngle:(CGFloat) - M_PI_2 endAngle:(CGFloat)(- M_PI_2 + self.progress * 2 * M_PI) clockwise:YES];
        [self.progressColor setStroke];
        progressCircle.lineWidth = self.lineWidth;
        [progressCircle stroke];
    }
}
-(void)changeProgress1:(CGFloat)progress{
    self.progress = progress;
    //redraw back & progress circles
    [self.layer setNeedsLayout];
    [self.layer setNeedsDisplay];
//    NSLog(@"当前数值:self.progress:%f",self.progress);
    
//    NSLog(@"%.2f",self.progress/100);
    NSString *text = [NSString stringWithFormat:@"%.0f%%",self.progress*100];

    
    self.progressLabel.text = text;

    self.progressLabel.font = [UIFont systemFontOfSize:9.0];
    self.progressLabel.textColor = [UIColor whiteColor];
    
    
    

}


@end
