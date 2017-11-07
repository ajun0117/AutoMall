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

@interface ApplyAuthenticationVC () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    int whichImg;   //标识是哪个图片
    NSString *shopImgUrl;
    NSString *licenseImgUrl;
    NSString *cardAImgUrl;
    NSString *cardBImgUrl;
    NSString *gongzhongImgUrl; 
    NSString *aliPayCollectionImgUrl;
    NSString *wechatCollectionImgUrl;
    NSArray *textFieldArray;
}
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@end

@implementation ApplyAuthenticationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.infoDic) {
        self.title = @"门店信息";
        [self.shopImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"image"])]];
        if (self.shopImg.image) {
            self.shopImgL.hidden = YES;
        }
        self.nameTF.text =  STRING(self.infoDic[@"name"]);
        self.shortNameTF.text = STRING(self.infoDic[@"shortName"]);
        self.addressTF.text = [NSString stringWithFormat:@"%@ %@ %@",self.infoDic[@"province"],self.infoDic[@"city"],self.infoDic[@"county"]];
        self.detailAddressTF.text = STRING(self.infoDic[@"address"]);
        self.phoneTF.text = STRING(self.infoDic[@"phone"]);
        self.recommendCodeTF.text = STRING(self.infoDic[@"recommendCode"]);
        
        [self.licenseImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"licenseImg"])]];
        if (self.licenseImg.image) {
            self.licenseImg.hidden = YES;
        }
        [self.cardAImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"cardImgA"])]];
        if (self.cardAImg.image) {
            self.cardAImg.hidden = YES;
        }
        [self.cardBImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"cardImgB"])]];
        if (self.cardBImg.image) {
            self.cardBImg.hidden = YES;
        }

        self.wechatNameTF.text = STRING(self.infoDic[@"wechatName"]);
        [self.gongzhongImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"wechatImg"])]];
        if (self.gongzhongImg.image) {
            self.gongzhongImg.hidden = YES;
        }
        [self.aliPayCollectionImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"alipayImg"])]];
        if (self.aliPayCollectionImg.image) {
            self.aliPayCollectionImg.hidden = YES;
        }
        [self.wechatCollectionImg sd_setImageWithURL:[NSURL URLWithString:STRING(self.infoDic[@"wechatpayImg"])]];
        if (self.wechatCollectionImg.image) {
            self.wechatCollectionImg.hidden = YES;
        }
    }
    else {
        self.title = @"申请认证";
    }
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
//    self.chooseLocationView.address = @"广东省 广州市 白云区";
//    self.chooseLocationView.areaCode = @"440104";
//    self.addressTF.text = @"广东省 广州市 白云区";
    
    [self setTextFieldInputAccessoryViewWithTF:self.nameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.shortNameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.detailAddressTF];
    [self setTextFieldInputAccessoryViewWithTF:self.phoneTF];
    [self setTextFieldInputAccessoryViewWithTF:self.recommendCodeTF];
    [self setTextFieldInputAccessoryViewWithTF:self.wechatNameTF];
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShopHead:)];
    [self.shopImg addGestureRecognizer:tap0];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLicense:)];
    [self.licenseImg addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCardA:)];
    [self.cardAImg addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCardB:)];
    [self.cardBImg addGestureRecognizer:tap3];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGongzhonghao:)];
    [self.gongzhongImg addGestureRecognizer:tap4];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAliPay:)];
    [self.aliPayCollectionImg addGestureRecognizer:tap5];
    UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWechat:)];
    [self.wechatCollectionImg addGestureRecognizer:tap6];
    
    textFieldArray = @[self.nameTF,self.shortNameTF,self.addressTF,self.detailAddressTF,self.phoneTF,self.recommendCodeTF,self.wechatNameTF];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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

-(void)tapShopHead:(UITapGestureRecognizer *)tap {
    whichImg = 0;
    [self selectThePhotoOrCamera];
}

-(void)tapLicense:(UITapGestureRecognizer *)tap {
    whichImg = 1;
    [self selectThePhotoOrCamera];
}

-(void)tapCardA:(UITapGestureRecognizer *)tap {
    whichImg = 2;
    [self selectThePhotoOrCamera];
}

-(void)tapCardB:(UITapGestureRecognizer *)tap {
    whichImg = 3;
    [self selectThePhotoOrCamera];
}

-(void)tapGongzhonghao:(UITapGestureRecognizer *)tap {
    whichImg = 4;
    [self selectThePhotoOrCamera];
}

-(void)tapAliPay:(UITapGestureRecognizer *)tap {
    whichImg = 5;
    [self selectThePhotoOrCamera];
}

-(void)tapWechat:(UITapGestureRecognizer *)tap {
    whichImg = 6;
    [self selectThePhotoOrCamera];
}


#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithTF:(UITextField *)field{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitle:@"下一项" forState:UIControlStateNormal];
    nextBtn.tag = field.tag;
    nextBtn.frame = CGRectMake(2, 5, 60, 25);
    [nextBtn addTarget:self action:@selector(nextField:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBtnItem = [[UIBarButtonItem alloc]initWithCustomView:nextBtn];
    
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [lastBtn setTitle:@"上一项" forState:UIControlStateNormal];
    lastBtn.tag = field.tag;
    lastBtn.frame = CGRectMake(2, 5, 60, 25);
    [lastBtn addTarget:self action:@selector(lastField:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lastBtnItem = [[UIBarButtonItem alloc]initWithCustomView:lastBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:lastBtnItem, nextBtnItem, spaceBtn, doneBtnItem,nil];
    [topView setItems:buttonsArray];
    [field setInputAccessoryView:topView];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

-(void)nextField:(UIButton *)nextBtn {
    NSInteger textFieldIndex = nextBtn.tag;
    UITextField *textField = (UITextField *)textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex < [textFieldArray count] - 1)
    {
        UITextField *nextTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex + 1)];
        [nextTextField becomeFirstResponder];
    }
}

-(void)lastField:(UIButton *)lastBtn {
    NSInteger textFieldIndex = lastBtn.tag;
    UITextField *textField = (UITextField *)textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex > 0)
    {
        UITextField *lastTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex - 1)];
        [lastTextField becomeFirstResponder];
    }
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger textFieldIndex = textField.tag;
    [textField resignFirstResponder];
    if (textFieldIndex < [textFieldArray count] - 1)
    {
        UITextField *nextTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex + 1)];
        [nextTextField becomeFirstResponder];
    }
    return YES;
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
    if (licenseImgUrl && cardAImgUrl && cardBImgUrl) {
        [self requestPostStoreRegister];
    }  else {
        _networkConditionHUD.labelText = @"请将证件上传齐全，否则将影响您的审核！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
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

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    return YES;
//}

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

-(void)selectThePhotoOrCamera {
    UIActionSheet *actionSheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    actionSheet.tag = 1000;
    [actionSheet showInView:self.view];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //来源:相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //来源:相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置导航栏背景颜色
        imagePickerController.navigationBar.barTintColor = [UIColor whiteColor];
        //设置右侧取消按钮的字体颜色
        imagePickerController.navigationBar.tintColor = [UIColor blackColor];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
}

//#pragma mark - UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    [picker dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//    
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    self.headImage.image = image;
//}

// 拍照完成回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //图片存入相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    switch (whichImg) {
        case 0: {
            self.shopImg.image = image;
            self.shopImgL.hidden = YES;
            [self requestUploadImgFile:self.shopImg];
            break;
        }
        case 1: {
            self.licenseImg.image = image;
            self.licenseImgL.hidden = YES;
            [self requestUploadImgFile:self.licenseImg];
            break;
        }
        case 2: {
            self.cardAImg.image = image;
            self.cardAImgL.hidden = YES;
            [self requestUploadImgFile:self.cardAImg];
            break;
        }
        case 3: {
            self.cardBImg.image = image;
            self.cardBImgL.hidden = YES;
            [self requestUploadImgFile:self.cardBImg];
            break;
        }
        case 4: {
            self.gongzhongImg.image = image;
            self.gongzhongImgL.hidden = YES;
            [self requestUploadImgFile:self.gongzhongImg];
            break;
        }
        case 5: {
            self.aliPayCollectionImg.image = image;
            self.aliPayImgL.hidden = YES;
            [self requestUploadImgFile:self.aliPayCollectionImg];
            break;
        }
        case 6: {
            self.wechatCollectionImg.image = image;
            self.wechatImgL.hidden = YES;
            [self requestUploadImgFile:self.wechatCollectionImg];
            break;
        }
            
        default:
        break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 发起网络请求
//-(void)requestUploadImg:(WPImageView *)image imageName:(NSString *)name {
//    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadUploadImg,@"op", nil];
//    //data=data
//    UIImage *im = IMG(@"indicator");
//    NSData *imageData = UIImageJPEGRepresentation(im, 1.0f);
////    NSInteger length = imageData.length;
////    if (length > 1048) {
////        CGFloat packRate = 1048.0/length;
////        imageData = UIImageJPEGRepresentation(im, packRate);
////    }
//    
//    NSString *baseStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    
////    NSString *newString = (__bridge_transfer id)(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)baseStr, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
//////    NSLog(@"newString: %@",newString);
////    
//    
////    NSString* baseStr = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
////    NSString *baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
////                                                                                                                (CFStringRef)baseStr,
////                                                                                                                NULL,
////                                                                                                                CFSTR(":/?#[]@!$&’()*+,;="),
////                                                                                                                kCFStringEncodingUTF8);
////    baseString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
////                                                                               (CFStringRef)baseString,
////                                                                               NULL,
////                                                                               CFSTR(":/?#[]@!$&’()*+,;="),
////                                                                               kCFStringEncodingUTF8);
////    NSLog(@"baseString:%@",baseString);
//
//    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:baseStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
//    [self.licenseImgBtn setBackgroundImage:decodedImage forState:UIControlStateNormal];
//    
//    NSDictionary *paramsDic = [[NSDictionary alloc] initWithObjectsAndKeys:baseStr,@"img",nil];
//    NSLog(@"paramsDic: %@",paramsDic);
//    NSString *urlStr = [NSString stringWithFormat:@"%@?fileName=indicator.png",UrlPrefix(UploadUploadImg)];
//    [[DataRequest sharedDataRequest] postDataWithUrl:urlStr delegate:nil params:paramsDic info:infoDic];
//    //    [[DataRequest sharedDataRequest] uploadImageWithUrl:RequestURL(ImageUpload) params:paramsDic target:image delegate:delegate info:infoDic];
//}

-(void)requestUploadImgFile:(WPImageView *)image {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}

-(void)requestPostStoreRegister { //门店认证
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreRegister object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreRegister, @"op", nil];
    NSArray *addrAry = [self.addressTF.text componentsSeparatedByString:@" "];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameTF.text,@"name",shopImgUrl,@"image",self.shortNameTF.text,@"shortName",addrAry[0],@"province",addrAry[1],@"city",addrAry[2],@"county",self.detailAddressTF.text,@"address",self.phoneTF.text,@"phone",licenseImgUrl,@"licenseImg",cardAImgUrl,@"cardImgA",cardBImgUrl,@"cardImgB",STRING_Nil(self.recommendCodeTF.text),@"presenter.recommendCode",STRING_Nil(self.wechatNameTF.text),@"wechatName",STRING_Nil(gongzhongImgUrl),@"wechatImg",STRING_Nil(aliPayCollectionImgUrl),@"alipayImg",STRING_Nil(wechatCollectionImgUrl),@"wechatpayImg", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(StoreRegister) delegate:nil params:pram info:infoDic];
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
    NSLog(@"responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        if ([responseObject[@"result"] boolValue]) {
            switch (whichImg) {
                case 0: {
                    shopImgUrl = urlStr;
                    break;
                }
                case 1: {
                    licenseImgUrl = urlStr;
                    break;
                }
                case 2: {
                    cardAImgUrl = urlStr;
                    break;
                }
                case 3: {
                    cardBImgUrl = urlStr;
                    break;
                }
                case 4: {
                    gongzhongImgUrl = urlStr;
                    break;
                }
                case 5: { 
                    aliPayCollectionImgUrl = urlStr;
                    break;
                }
                case 6: {
                    wechatCollectionImgUrl = urlStr;
                    break;
                }
                    
                default:
                    break;
            }
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:StoreRegister]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreRegister object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            self.replayBtn.enabled = NO;
            [self.replayBtn setTitle:@"审核中..." forState:UIControlStateDisabled];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
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
