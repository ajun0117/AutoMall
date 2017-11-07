//
//  AutoCheckCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/16.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckCarInfoVC.h"

@interface AutoCheckCarInfoVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *textFieldArray;
    int whichImg;   //标识是哪个图片
    NSString *mileageImgUrl;
    NSString *fuelAmountImgUrl;
}

@property (strong, nonatomic) IBOutlet UITextField *mileageTF;
@property (strong, nonatomic) IBOutlet UITextField *fuelAmountTF;
@property (weak, nonatomic) IBOutlet WPImageView *mileageImgView;
@property (weak, nonatomic) IBOutlet UILabel *mileageL;
@property (weak, nonatomic) IBOutlet WPImageView *fuelAmountImgView;
@property (weak, nonatomic) IBOutlet UILabel *fuelAmountL;

@end

@implementation AutoCheckCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.carDic[@"plateNumber"];
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self setTextFieldInputAccessoryViewWithTF:self.mileageTF];
    [self setTextFieldInputAccessoryViewWithTF:self.fuelAmountTF];
    textFieldArray = @[self.mileageTF, self.fuelAmountTF];
    
    mileageImgUrl = self.mileageAndfuelAmountDic[@"mileageImg"];
    fuelAmountImgUrl = self.mileageAndfuelAmountDic[@"fuelAmountImg"];
    
    if (self.mileageAndfuelAmountDic) {
        self.mileageTF.text = self.mileageAndfuelAmountDic[@"mileage"];
        [self.mileageImgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.mileageAndfuelAmountDic[@"mileageImg"])]];
        
        self.fuelAmountTF.text = self.mileageAndfuelAmountDic[@"fuelAmount"];
        [self.fuelAmountImgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.mileageAndfuelAmountDic[@"fuelAmountImg"])]];
    }
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mileagePhotoAction)];
    [self.mileageImgView addGestureRecognizer:tap0];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuelAmountPhotoAction)];
    [self.fuelAmountImgView addGestureRecognizer:tap1];
    
    if (mileageImgUrl.length > 0) {
        self.mileageL.hidden = YES;
    }
    if (fuelAmountImgUrl.length > 0) {
        self.fuelAmountL.hidden = YES;
    }
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

- (IBAction)saveAction:(id)sender {
    if (self.mileageTF.text == nil || [self.mileageTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"总里程数必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (self.fuelAmountTF.text == nil || [self.fuelAmountTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"燃油量必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    self.GoBackSubmitLicheng(@{@"mileage":self.mileageTF.text,@"mileageImg":STRING_Nil(mileageImgUrl),@"fuelAmount":self.fuelAmountTF.text,@"fuelAmountImg":STRING_Nil(fuelAmountImgUrl)});
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)mileagePhotoAction {
    whichImg = 0;
    [self selectThePhotoOrCamera];
}

- (void)fuelAmountPhotoAction {
    whichImg = 1;
    [self selectThePhotoOrCamera];
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
            self.mileageImgView.image = image;
            self.mileageL.hidden = YES;
            [self requestUploadImgFile:self.mileageImgView];
            break;
        }
        case 1: {
            self.fuelAmountImgView.image = image;
            self.fuelAmountL.hidden = YES;
            [self requestUploadImgFile:self.fuelAmountImgView];
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


-(void)requestUploadImgFile:(WPImageView *)image {
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
    NSLog(@"responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        if ([responseObject[@"result"] boolValue]) {
            switch (whichImg) {
                case 0: {
                    mileageImgUrl = urlStr;
                    break;
                }
                case 1: {
                    fuelAmountImgUrl = urlStr;
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
