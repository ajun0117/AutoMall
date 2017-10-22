//
//  ApplyAuthenticationVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/4.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ApplyAuthenticationVC.h"
#import "ChooseLocationView.h"
#import "CitiesDataTool.h"
#import "GTMBase64.h"
#import "openssl_wrapper.h"

@interface ApplyAuthenticationVC () <UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;
@property (strong, nonatomic) IBOutlet WPImageView *gongzhongImg;

@end

@implementation ApplyAuthenticationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.title = @"申请认证";
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    self.addressTF.text = @"广东省 广州市 白云区";
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setTextFieldInputAccessoryViewWithTF:self.nameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.shortNameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.detailAddressTF];
    [self setTextFieldInputAccessoryViewWithTF:self.phoneTF];
    [self setTextFieldInputAccessoryViewWithTF:self.recommendCodeTF];
    [self setTextFieldInputAccessoryViewWithTF:self.wechatNameTF];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGongzhonghao:)];
    [self.gongzhongImg addGestureRecognizer:tap];
    
    self.gongzhongImg.image = IMG(@"check_default");
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

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)tapGongzhonghao:(UITapGestureRecognizer *)tap {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    
    [self requestUploadImg:self.gongzhongImg imageName:fileName];
}


#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithTF:(UITextField *)field{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTintColor:[UIColor grayColor]];
    doneBtn.layer.cornerRadius = 2;
    doneBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    doneBtn.layer.borderWidth = 0.5;
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceBtn,doneBtnItem,nil];
    [topView setItems:buttonsArray];
    [field setInputAccessoryView:topView];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height);
//    self.myScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.myScrollView.frame) - keyBoardRect.size.height);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
}

- (IBAction)replayAction:(id)sender {
    [self requestPostStoreRegister];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.addressTF) {
//        [self.nameTF resignFirstResponder];
//        [self.shortNameTF resignFirstResponder];
//        [self.detailAddressTF resignFirstResponder];
//        [self.phoneTF resignFirstResponder];
//        [self.recommendCodeTF resignFirstResponder];
//        [self.wechatNameTF resignFirstResponder];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        self.cover.hidden = !self.cover.hidden;
        self.chooseLocationView.hidden = self.cover.hidden;
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_chooseLocationView.frame, point)){
        return NO;
    }
    return YES;
}


- (void)tapCover:(UITapGestureRecognizer *)tap{
    
    if (_chooseLocationView.chooseFinish) {
        _chooseLocationView.chooseFinish();
    }
}

- (ChooseLocationView *)chooseLocationView{
    
    if (!_chooseLocationView) {
        _chooseLocationView = [[ChooseLocationView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350)];
        
    }
    return _chooseLocationView;
}

- (UIView *)cover{
    
    if (!_cover) {
        _cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_cover addSubview:self.chooseLocationView];
        __weak typeof (self) weakSelf = self;
        _chooseLocationView.chooseFinish = ^{
            //            [UIView animateWithDuration:0.25 animations:^{
            weakSelf.addressTF.text = weakSelf.chooseLocationView.address;
            //                weakSelf.view.transform = CGAffineTransformIdentity;
            weakSelf.cover.hidden = YES;
            //            }];
        };
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCover:)];
        [_cover addGestureRecognizer:tap];
        tap.delegate = self;
        _cover.hidden = YES;
    }
    return _cover;
}

#pragma mark - 发起网络请求
#pragma mark - 发送请求
-(void)requestUploadImg:(WPImageView *)image imageName:(NSString *)name {
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadUploadImg,@"op", nil];
    
    //data=data
    UIImage *im = IMG(@"picture_1");
    NSData *imageData = UIImageJPEGRepresentation(im, 1);
    NSInteger length = imageData.length;
    if (length > 1048) {
        CGFloat packRate = 1048.0/length;
        imageData = UIImageJPEGRepresentation(im, packRate);
    }
    //    NNSData* originData = [originStr dataUsingEncoding:NSASCIIStringEncoding];
    
//    imageData= [GTMBase64 encodeData:imageData];
//    NSString *baseStr = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
    
    NSString* baseStr = [imageData base64EncodedStringWithOptions:0];
    //    NSLog(@"baseString:%@",baseString);
    
//    NSString * baseStr = base64StringFromData(imageData);
    
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:baseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
    [self.licenseImgBtn setBackgroundImage:decodedImage forState:UIControlStateNormal];
    
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"txt"];
//    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    NSDictionary *paramsDic = [[NSDictionary alloc] initWithObjectsAndKeys:baseStr,@"img",name,@"fileName", nil];
    NSLog(@"paramsDic: %@",paramsDic);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UploadUploadImg) delegate:nil params:paramsDic info:infoDic];
    //    [[DataRequest sharedDataRequest] uploadImageWithUrl:RequestURL(ImageUpload) params:paramsDic target:image delegate:delegate info:infoDic];
}

-(void)requestPostStoreRegister { //门店认证
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreRegister object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreRegister, @"op", nil];
    NSArray *addrAry = [self.addressTF.text componentsSeparatedByString:@" "];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameTF.text,@"name",self.shortNameTF.text,@"shortName",addrAry[0],@"province",addrAry[1],@"city",addrAry[2],@"county",self.detailAddressTF.text,@"address",self.phoneTF.text,@"phone",self.licenseImgBtn.currentImage,@"licenseImg",self.cardImgABtn.currentImage,@"cardImgA",self.cardImgBBtn.currentImage,@"cardImgB",self.recommendCodeTF.text,@"presenter.recommendCode",self.wechatNameTF.text,@"wechatName",self.wechatImgBtn.currentImage,@"wechatImg", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StoreRegister) delegate:nil params:pram info:infoDic];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:StoreRegister]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreRegister object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
