//
//  UpkeepCarMarkVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepCarMarkVC.h"
#import "WPImageView.h"
#import "AddPicViewController.h"

@interface UpkeepCarMarkVC ()
{
//    UIScrollView *_scrollview;
//    UIImageView *_imageview;
    UIImage *chooseImg;
    
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollV;
@property (strong, nonatomic) IBOutlet WPImageView *imageV;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHight;

@property (weak, nonatomic) IBOutlet UIButton *scratchBtn;
@property (weak, nonatomic) IBOutlet UIButton *dentBtn;
@property (weak, nonatomic) IBOutlet UIButton *dirtBtn;
@property (weak, nonatomic) IBOutlet UIButton *othersBtn;

@property (strong, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation UpkeepCarMarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"车身标记";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                       target:nil action:nil];
//    negativeSpacer.width = -6;
//    
//    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    addBtn.frame = CGRectMake(0, 0, 28, 28);
//    [addBtn setImage:[UIImage imageNamed:@"add_carInfo"] forState:UIControlStateNormal];
//    //    [addBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [addBtn addTarget:self action:@selector(toRegisterNewCarInfo) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *addBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
//    
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchBtn.frame = CGRectMake(0, 0, 30, 30);
//    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
//    //    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, addBtnBarBtn, searchBtnBarBtn, nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 110, 40)];
    titleL.text = @"车身标记";
    titleL.font = [UIFont boldSystemFontOfSize:17];
    titleL.textAlignment = NSTextAlignmentRight;
    [view addSubview:titleL];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(110, 2, 40, 40);
    [photoBtn setImage:[UIImage imageNamed:@"photoBtn"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [photoBtn addTarget:self action:@selector(toPhoto) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:photoBtn];
    
    self.navigationItem.titleView = view;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStylePlain target:self action:@selector(toReset:)];
    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
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
    
    if (self.imgUrl) {
        [self.imageV sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.imgUrl)] placeholderImage:IMG(@"CommplaceholderPicture")];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toMark:)];
    [self.imageV addGestureRecognizer:tap];
     //调用initWithImage:方法，它创建出来的imageview的宽高和图片的宽高一样
     //设置UIScrollView的滚动范围和图片的真实尺寸一致
     self.scrollV.contentSize = self.imageV.image.size;
     //设置实现缩放
     //设置最大伸缩比例
     self.scrollV.maximumZoomScale = 3.0;
     //设置最小伸缩比例
     self.scrollV.minimumZoomScale = 1.0;

    self.imageHight.constant = SCREEN_HEIGHT - 64;
    
    [self.scratchBtn setImage:[UIImage imageNamed:@"scratchRed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.dentBtn setImage:[UIImage imageNamed:@"dentRed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.dirtBtn setImage:[UIImage imageNamed:@"dirtRed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self.othersBtn setImage:[UIImage imageNamed:@"othersRed"] forState:UIControlStateSelected | UIControlStateHighlighted];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

#pragma mark - 重置
-(void)toReset:(UIButton *)btn {
    for (UIButton *btn in self.imageV.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn removeFromSuperview];
        }
    }
    self.imageV.image = IMG(@"carMark");
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
         return self.imageV;
}

-(void)toPhoto {
    AddPicViewController *photoVC = [[AddPicViewController alloc] init];
    photoVC.GoBackUpdate = ^(NSMutableArray *array) {
        self.imgs = array;
        NSLog(@"self.imgs: %@",self.imgs);
    };
    photoVC.localImgsArray = self.imgs;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (IBAction)dent:(id)sender {
    if (self.dentBtn.selected) {
        self.dentBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.dentBtn.selected = YES;
        self.scratchBtn.selected = NO;
        self.dirtBtn.selected = NO;
        self.othersBtn.selected = NO;
        chooseImg = self.dentBtn.currentImage;
    }
}

- (IBAction)scratch:(id)sender {
    if (self.scratchBtn.selected) {
        self.scratchBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.scratchBtn.selected = YES;
        self.dentBtn.selected = NO;
        self.dirtBtn.selected = NO;
        self.othersBtn.selected = NO;
        chooseImg = self.scratchBtn.currentImage;
    }
}

- (IBAction)dirt:(id)sender {
    if (self.dirtBtn.selected) {
        self.dirtBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.dirtBtn.selected = YES;
        self.dentBtn.selected = NO;
        self.scratchBtn.selected = NO;
        self.othersBtn.selected = NO;
        chooseImg = self.dirtBtn.currentImage;
    }
}

- (IBAction)others:(id)sender {
    if (self.othersBtn.selected) {
        self.othersBtn.selected = NO;
        chooseImg = nil;
    }
    else {
        self.othersBtn.selected = YES;
        self.dentBtn.selected = NO;
        self.scratchBtn.selected = NO;
        self.dirtBtn.selected = NO;
        chooseImg = self.othersBtn.currentImage;
    }
}

- (IBAction)save:(id)sender {
    self.scrollV.zoomScale = 1.0;
    UIImage *image = [self imageFromView:self.imageV];
    self.imageV.image = image;
    [self requestUploadImgFile:self.imageV];
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    self.GoBackCarPhoto(self.imgs);     //车图照片传递到上页
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
//    UIGraphicsBeginImageContext(theView.frame.size);
    UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);
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


#pragma mark - 发起网络请求
-(void)requestUploadImgFile:(WPImageView *)image {  //上传图片
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}
#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"UploadImgFile: %@",responseObject);
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        if ([responseObject[@"result"] boolValue]) {
            NSString *carImgUrl = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
            self.GoBackGet(carImgUrl);
            [self performSelector:@selector(toPopVC) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC {
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
