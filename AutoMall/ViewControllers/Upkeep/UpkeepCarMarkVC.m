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
    UIScrollView *_scrollview;
    UIImageView *_imageview;
    UIImage *chooseImg;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollV;
@property (strong, nonatomic) IBOutlet UIImageView *imageV;
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
//
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
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMark:)];
//    [_imageview addGestureRecognizer:tap];
//     //调用initWithImage:方法，它创建出来的imageview的宽高和图片的宽高一样
//     [_scrollview addSubview:_imageview];
//
//     //设置UIScrollView的滚动范围和图片的真实尺寸一致
//     _scrollview.contentSize = image.size;
//
//     //设置实现缩放
//     //设置代理scrollview的代理对象
//     _scrollview.delegate = self;
//     //设置最大伸缩比例
//     _scrollview.maximumZoomScale = 2.0;
//     //设置最小伸缩比例
//     _scrollview.minimumZoomScale = 0.5;
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40, 30, 30);
//    [btn setImage:IMG(@"timg-2") forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(toChoose:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
//    
//    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    saveBtn.frame = CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT - 40, 40, 30);
//    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
//    [saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:saveBtn];
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
         return _imageview;
}

-(void) toChoose:(UIButton *)btn {
    chooseImg = btn.currentImage;
//    NSLog(@"theView.frame.size:  %@",NSStringFromCGSize(_imageview.frame.size));
}
- (IBAction)add:(id)sender {
}
- (IBAction)del:(id)sender {
}
- (IBAction)save:(id)sender {
}

-(void) toMark:(UITapGestureRecognizer *)tap {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40, 30, 30);
    btn.center = [tap locationInView:_imageview];
    [btn setImage:chooseImg forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(toSelect:) forControlEvents:UIControlEventTouchUpInside];
    [_imageview addSubview:btn];
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


- (void)saveImage
{
    _scrollview.zoomScale = 1.0;
    UIImage *image = [self imageFromView:_imageview];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
//    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    indicator.center = self.view.center;
//    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
//    [indicator startAnimating];
}

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
