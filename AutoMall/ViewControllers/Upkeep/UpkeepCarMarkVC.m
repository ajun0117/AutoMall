//
//  UpkeepCarMarkVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepCarMarkVC.h"

@interface UpkeepCarMarkVC ()
{
//    UIScrollView *_scrollview;
//    UIImageView *_imageview;
    UIImage *chooseImg;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollV;
@property (strong, nonatomic) IBOutlet UIImageView *imageV;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHight;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UIButton *delBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation UpkeepCarMarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"车身标记";
    
    //1添加 UIScrollView
    //设置 UIScrollView的位置与屏幕大小相同
//     _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//     [self.view addSubview:_scrollview];
//     //2添加图片
//     //有两种方式
//     //(1)一般方式
// //    UIImageView  *imageview=[[UIImageView alloc]init];
// //    UIImage *image=[UIImage imageNamed:@"minion"];
// //    imageview.image=image;
// //    imageview.frame=CGRectMake(0, 0, image.size.width, image.size.height);
//
//     //(2)使用构造方法
//     UIImage *image = [UIImage imageNamed:@"carMark"];
//     _imageview = [[UIImageView alloc]initWithImage:image];
//    _imageview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
//    _imageview.contentMode = UIViewContentModeScaleAspectFit;
//    _imageview.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMark:)];
    [self.imageV addGestureRecognizer:tap];
     //调用initWithImage:方法，它创建出来的imageview的宽高和图片的宽高一样
     //设置UIScrollView的滚动范围和图片的真实尺寸一致
     self.scrollV.contentSize = self.imageV.image.size;
     //设置实现缩放
     //设置最大伸缩比例
     self.scrollV.maximumZoomScale = 2.0;
     //设置最小伸缩比例
     self.scrollV.minimumZoomScale = 1.0;

    self.imageHight.constant = SCREEN_HEIGHT - 64;
    
    [self.addBtn setImage:[UIImage imageNamed:@"goods_add"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.delBtn setImage:[UIImage imageNamed:@"goods_del"] forState:UIControlStateSelected | UIControlStateHighlighted];
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
         return self.imageV;
}

-(void) toChoose:(UIButton *)btn {
    chooseImg = btn.currentImage;
//    NSLog(@"theView.frame.size:  %@",NSStringFromCGSize(_imageview.frame.size));
}

- (IBAction)add:(id)sender {
//    UIButton *btn = (UIButton *)sender;
//    btn.selected = !btn.selected;
//    chooseImg = btn.currentImage;
    if (self.addBtn.selected) {
        self.addBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.addBtn.selected = YES;
        self.delBtn.selected = NO;
        chooseImg = self.addBtn.currentImage;
    }
}

- (IBAction)del:(id)sender {
    if (self.delBtn.selected) {
        self.delBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.delBtn.selected = YES;
        self.addBtn.selected = NO;
        chooseImg = self.delBtn.currentImage;
    }
}

- (IBAction)save:(id)sender {
    self.scrollV.zoomScale = 1.0;
    UIImage *image = [self imageFromView:self.imageV];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    self.GoBackGet(@"carImageURLString");
}

-(void) toMark:(UITapGestureRecognizer *)tap {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40, 30, 30);
    btn.center = [tap locationInView:self.imageV];
    [btn setImage:chooseImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toDel:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageV addSubview:btn];
}

//#pragma mark 双击
//- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
//{
//    //图片加载完之后才能响应双击放大
//    if (!self.hasLoadedImage) {
//        return;
//    }
//    CGPoint touchPoint = [recognizer locationInView:self];
//    if (self.scrollview.zoomScale <= 1.0) {
//        
//        CGFloat scaleX = touchPoint.x + self.scrollview.contentOffset.x;//需要放大的图片的X点
//        CGFloat sacleY = touchPoint.y + self.scrollview.contentOffset.y;//需要放大的图片的Y点
//        [self.scrollview zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
//        
//    } else {
//        [self.scrollview setZoomScale:1.0 animated:YES]; //还原
//    }
//    
//}

-(void) toDel:(UIButton *)btn {
    [btn removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 保存图像


//获得屏幕图像
- (UIImage *)imageFromView: (UIView *) theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


//- (void)saveImage
//{
//    _scrollview.zoomScale = 1.0;
//    UIImage *image = [self imageFromView:_imageview];
//    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    
////    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
////    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
////    indicator.center = self.view.center;
////    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
////    [indicator startAnimating];
//}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.50f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 60);
    label.center = self.view.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:21];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = @"保存失败";
    }   else {
        label.text = @"保存成功";
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
