//
//  AJMessageView.m
//  YMYL
//
//  Created by LYD on 15/10/27.
//  Copyright © 2015年 ljy. All rights reserved.
//

#import "AJMessageView.h"

#define KImgWidth   80
#define KImgHeight   80

@interface AJMessageView()<UIScrollViewDelegate>
{
//    UILabel *_titleL;
//    UILabel *_detailTitleL;
    NSTimer *timer;
}

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat width;
@end

@implementation AJMessageView

- (CGFloat)height{
    return self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initSubViews];
        
    }
    return self;
}

- (void)reloadData{
    int num =(int)[self.delegate numberInAJMessageView:self];
    if (num) {
        _sIndex = 0;
        
//        if (num != 1) {
//            self.pageControl.frame = CGRectMake(self.width - 15*num - 10, self.height - 15, 15*num, 15);
//            self.pageControl.numberOfPages = num;
//            [self.scrollView setContentSize:CGSizeMake(self.width, self.height*num)];
        if (! timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:DefineMessageTime target:self selector:@selector(cycleClick:) userInfo:nil repeats:YES];
        }
        
//        }
        
        for (int i = 0 ; i<num; i++) {
            UIImageView *img = (UIImageView *)[self.scrollView viewWithTag:i+10];
            [img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAJMessageView:self index:i]]] placeholderImage:[UIImage imageNamed:DefineMessageImage]];
            
            UILabel *_titleL = (UILabel *)[self.scrollView viewWithTag:i+20];
            _titleL.text = [self.delegate titleStringInAJMessageView:self index:i];
            
            UILabel *_detailTitleL = (UILabel *)[self.scrollView viewWithTag:i+30];
            _detailTitleL.text = [self.delegate detailTitleStringInAJMessageView:self index:i];
        }
//        [self initScrollViewSubViewsWithSelectNum:1];
        
    }
}

- (void)cycleClick:(id)sender{
    if (self.scrollView.contentOffset.y > 0) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    [self.scrollView setContentOffset:CGPointMake(0, self.height*1) animated:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self initScrollViewSubViewsWithSelectNum:1];
//    });
}

- (void)initSubViews{
    
//    self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//    [self addSubview:self.bgImageView];
//    self.bgImageView.image = [UIImage imageNamed:DefineMessageImage];
    
    if (! self.scrollView) {
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        [self addSubview:self.scrollView];
    }
    for (UIView *view in self.scrollView.subviews) {    //删除所有已有的视图
        [view removeFromSuperview];
    }
    
    for (int i = 0 ; i<[self.delegate numberInAJMessageView:self]; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, i*self.height + 10, KImgWidth, KImgHeight)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAJMessageView:self index:_sIndex]]] placeholderImage:[UIImage imageNamed:DefineMessageImage]];
        [self.scrollView addSubview:imageView];
        //        imageView.clipsToBounds = YES;
        //        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.tag = i+10;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchClick:)];
        [imageView addGestureRecognizer:tapGesture];
        
        UILabel *_titleL = [[UILabel alloc] initWithFrame:CGRectMake(KImgWidth  + 10 + 10, i*self.height + 10, self.width - KImgWidth - 30, 21)];
        _titleL.textColor = [UIColor blackColor];
        _titleL.font = [UIFont systemFontOfSize:15];
        _titleL.text = [self.delegate titleStringInAJMessageView:self index:0];
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.tag = i+20;
        [self.scrollView addSubview:_titleL];
        
         UILabel *_detailTitleL = [[UILabel alloc] initWithFrame:CGRectMake(KImgWidth  + 10 + 10, i*self.height + 40, self.width - KImgWidth - 30, self.height -  40 - 10)];
        _detailTitleL.textColor = [UIColor grayColor];
        _detailTitleL.font = [UIFont systemFontOfSize:13];
        _detailTitleL.numberOfLines = 3;
        _detailTitleL.text = [self.delegate detailTitleStringInAJMessageView:self index:0];
        _detailTitleL.backgroundColor = [UIColor clearColor];
        _detailTitleL.tag = i+30;
        [self.scrollView addSubview:_detailTitleL];
    }
    
//    UIView *titleBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30)];
//    titleBgView.backgroundColor = [UIColor blackColor];
//    titleBgView.alpha = 0.4;
//    [self addSubview:titleBgView];

    self.pageControl = [[UIPageControl alloc]init];
    self.pageControl.pageIndicatorTintColor = Gray_Color;
    self.pageControl.currentPageIndicatorTintColor = Orange_Color;
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    
}


- (void)touchClick:(UITapGestureRecognizer *)gesture {
    
    if ([self.delegate respondsToSelector:@selector(messageView:didSelectIndex:)]) {
        [self.delegate messageView:self didSelectIndex:_sIndex];
    }
}


- (void)initScrollViewSubViewsWithSelectNum:(NSInteger)num{
    if (num == 2) {
        _sIndex++;
    }
    else if (num == 0){
        _sIndex--;
    }
    [self index2calculate];
    UIImageView *v1 = (UIImageView *)[self.scrollView viewWithTag:10];
    UIImageView *v2 = (UIImageView *)[self.scrollView viewWithTag:11];
    UIImageView *v3 = (UIImageView *)[self.scrollView viewWithTag:12];
    int nexttag  = (_sIndex+1)>([self.delegate numberInAJMessageView:self]-1) ? 0 : (_sIndex+1);
    int lasttag  = (_sIndex-1)<0 ? (int)([self.delegate numberInAJMessageView:self] -1) : (_sIndex-1);
    
    [v2 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAJMessageView:self index:_sIndex]]] placeholderImage:[UIImage imageNamed:DefineMessageImage]];
    [v1 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAJMessageView:self index:lasttag]]] placeholderImage:[UIImage imageNamed:DefineMessageImage]];
    [v3 sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.delegate imageUrlInAJMessageView:self index:nexttag]]] placeholderImage:[UIImage imageNamed:DefineMessageImage]];
    
    self.pageControl.currentPage = _sIndex;
    
    UILabel *_titleL1 = (UILabel *)[self.scrollView viewWithTag:20];
    UILabel *_titleL2 = (UILabel *)[self.scrollView viewWithTag:21];
    UILabel *_titleL3 = (UILabel *)[self.scrollView viewWithTag:22];
    
//    UILabel *_titleL = (UILabel *)[self.scrollView viewWithTag:_sIndex + 20];
    _titleL1.text = [self.delegate titleStringInAJMessageView:self index:_sIndex];
    _titleL2.text = [self.delegate titleStringInAJMessageView:self index:lasttag];
    _titleL3.text = [self.delegate titleStringInAJMessageView:self index:nexttag];
//    NSLog(@"_titleL.text: %@",_titleL.text);
    
    UILabel *_detailTitleL1 = (UILabel *)[self.scrollView viewWithTag:30];
    UILabel *_detailTitleL2 = (UILabel *)[self.scrollView viewWithTag:31];
    UILabel *_detailTitleL3 = (UILabel *)[self.scrollView viewWithTag:32];
    
    _detailTitleL1.text = [self.delegate detailTitleStringInAJMessageView:self index:_sIndex];
    _detailTitleL2.text = [self.delegate detailTitleStringInAJMessageView:self index:lasttag];
    _detailTitleL3.text = [self.delegate detailTitleStringInAJMessageView:self index:nexttag];
    
//    UILabel *_detailTitleL = (UILabel *)[self.scrollView viewWithTag:_sIndex + 30];
//    _detailTitleL.text = [self.delegate detailTitleStringInAJMessageView:self index:_sIndex];
    
    
    [self.scrollView setContentOffset:CGPointMake(self.width, 0)];
}

- (void)index2calculate{
    if (_sIndex>([self.delegate numberInAJMessageView:self] - 1)) {
        _sIndex = 0;
    }
    else if (_sIndex<0) {
        _sIndex = (int)[self.delegate numberInAJMessageView:self] - 1;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int index = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    self.pageControl.currentPage = index;
//    [self initScrollViewSubViewsWithSelectNum:index];
}


- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    [self reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
