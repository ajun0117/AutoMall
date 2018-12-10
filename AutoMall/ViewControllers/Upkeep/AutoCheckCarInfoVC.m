//
//  AutoCheckCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/16.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckCarInfoVC.h"
#import "AutoCheckVC.h"
#import "AddPicViewController.h"

@interface AutoCheckCarInfoVC () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *textFieldArray;
    int whichImg;   //标识是哪个图片
    NSString *mileageImgUrl;
    NSString *fuelAmountImgUrl;
    NSArray *remarkPhotos;      //备注图片
    id activeField;
    BOOL keyboardShown; //键盘是否弹出
    CGRect scrollViewFrame;       //记录初始frame
}

@property (strong, nonatomic) IBOutlet UIScrollView *myScrollV;
@property (strong, nonatomic) IBOutlet UITextField *lastMileageTF;
@property (strong, nonatomic) IBOutlet UITextField *mileageTF;
@property (strong, nonatomic) IBOutlet UITextField *fuelAmountTF;
@property (weak, nonatomic) IBOutlet WPImageView *mileageImgView;
//@property (weak, nonatomic) IBOutlet UILabel *mileageL;
@property (weak, nonatomic) IBOutlet WPImageView *fuelAmountImgView;
@property (strong, nonatomic) IBOutlet UITextView *remarkTV;
//@property (weak, nonatomic) IBOutlet UILabel *fuelAmountL;

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
    [self setTextViewInputAccessoryViewWithTV:self.remarkTV];
    textFieldArray = @[self.mileageTF, self.fuelAmountTF, self.remarkTV];
    
    mileageImgUrl = self.mileageAndfuelAmountDic[@"mileageImg"];
    fuelAmountImgUrl = self.mileageAndfuelAmountDic[@"fuelAmountImg"];
    
    [self requestGetLastMileage];       //获取最新的上次保养里程数
//    if ([self.carDic[@"carUpKeeps"] count] > 0) {
//        self.lastMileageTF.text = [NSString stringWithFormat:@"%@",[self.carDic[@"carUpKeeps"] firstObject][@"lastMileage"]];
//    }
    
    
//    //******先载入当天输入过的里程数
//    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"yyyy-MM-dd"];
//    NSDate *today = [NSDate date];
//    NSString *stringS = [formater stringFromDate:today];
//    NSString *todayStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayMileageDate"];
//    if (todayStr && [todayStr isEqualToString:stringS]) {   //今日，读取相关数据
//        self.mileageTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayMileage"];
//    } else {    //否则删除老的数据
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"todayMileage"];
//         [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"todayMileageDate"];
//    }
    
    remarkPhotos = @[];
    
    if (self.mileageAndfuelAmountDic) {
        self.mileageTF.text = self.mileageAndfuelAmountDic[@"mileage"];
        self.fuelAmountTF.text = self.mileageAndfuelAmountDic[@"fuelAmount"];
        self.remarkTV.text = self.mileageAndfuelAmountDic[@"remark"];
        if (mileageImgUrl.length > 0) {
            [self.mileageImgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.mileageAndfuelAmountDic[@"mileageImg"])]];
        }
        if (fuelAmountImgUrl.length > 0) {
            [self.fuelAmountImgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.mileageAndfuelAmountDic[@"fuelAmountImg"])]];
        }
        if(remarkPhotos.count > 0) {
            remarkPhotos = self.mileageAndfuelAmountDic[@"remarkImages"];
        }
    }
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mileagePhotoAction)];
    [self.mileageImgView addGestureRecognizer:tap0];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fuelAmountPhotoAction)];
    [self.fuelAmountImgView addGestureRecognizer:tap1];

    self.remarkTV.textContainerInset = UIEdgeInsetsMake(10.0f, 13.0f, 10.0f, 13.0f);
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
//    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    scrollViewFrame = [self.myScrollV frame];
    NSLog(@"scrollViewFrame: %@",NSStringFromCGRect(scrollViewFrame));
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
//    if (keyboardShown)
//        return;
    
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"keyBoardRect: %@",NSStringFromCGRect(keyBoardRect));
    CGRect viewFrame = scrollViewFrame;
    viewFrame.size.height -= keyBoardRect.size.height;
    self.myScrollV.frame = viewFrame;
    NSLog(@"self.myScrollV.frame: %@",NSStringFromCGRect(self.myScrollV.frame));
    
    CGRect textFieldRect = [activeField frame];
    [ self.myScrollV scrollRectToVisible:textFieldRect animated:YES];
    
//     keyboardShown = YES;
}

#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myScrollV.frame = scrollViewFrame;
//    keyboardShown = NO;
}


- (IBAction)remarkPhotoAction:(id)sender {
    AddPicViewController *photoVC = [[AddPicViewController alloc] init];
    photoVC.maxCount = 2;
    photoVC.GoBackUpdate = ^(NSMutableArray *array) {
        remarkPhotos = array;
        NSLog(@"remarkPhotos: %@",remarkPhotos);
    };
    photoVC.localImgsArray = remarkPhotos;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (IBAction)saveAction:(id)sender {
    if (self.mileageTF.text == nil || [self.mileageTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"总里程表必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
//    if (self.fuelAmountTF.text == nil || [self.fuelAmountTF.text isEqualToString:@""]) {
//        _networkConditionHUD.labelText = @"燃油量必须填写！";
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        return;
//    }
    if ([self.fuelAmountTF.text intValue] > 100) {
        _networkConditionHUD.labelText = @"燃油量百分比不能超过100%！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if ([self.mileageTF.text intValue] < [self.lastMileageTF.text intValue]) {
        _networkConditionHUD.labelText = @"当前里程不能小于上次保养里程！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
//    if (mileageImgUrl==nil || mileageImgUrl.length == 0) {
//        _networkConditionHUD.labelText = @"总里程表图片必须上传！";
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        return;
//    }
//    if (fuelAmountImgUrl==nil || fuelAmountImgUrl.length == 0) {
//        _networkConditionHUD.labelText = @"燃油量图片必须上传！";
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        return;
//    }
    NSLog(@"self.mileageTF.text: %@,mileageImg%@",self.mileageTF.text,STRING_Nil(mileageImgUrl)); self.GoBackSubmitLicheng(@{@"mileage":self.mileageTF.text,@"mileageImg":STRING_Nil(mileageImgUrl),@"fuelAmount":STRING_Nil(self.fuelAmountTF.text),@"fuelAmountImg":STRING_Nil(fuelAmountImgUrl),@"remark":STRING_Nil(self.remarkTV.text),@"remarkImages":remarkPhotos});
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [NSDate date];
    NSString *stringS = [formater stringFromDate:today];
//    NSString *todayStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayMileageDate"];
//    NSDictionary *carMileageDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayMileageDic"];
//    NSString *carId1 = carMileageDic[@"carId"];
//    if (![stringS isEqualToString:todayStr] || [self.carDic[@"id"] intValue] != [carId1 intValue]) {   //非今日，更新相关数据
    
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setValuesForKeysWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"todayMileageMuDic"]];
    NSString *cId = [NSString stringWithFormat:@"%@",self.carDic[@"id"]];
    [muDic setObject:self.mileageTF.text forKey:cId];
    NSDictionary *dataDic = [NSDictionary dictionaryWithDictionary:muDic];
    [[NSUserDefaults standardUserDefaults] setObject:stringS forKey:@"todayMileageDate"];
    [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:@"todayMileageMuDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
//    checkVC.checktypeID = self.checktypeID;
//    checkVC.carDic = self.carDic;
//    checkVC.lichengDic = @{@"mileage":self.mileageTF.text,@"mileageImg":STRING_Nil(mileageImgUrl),@"fuelAmount":self.fuelAmountTF.text,@"fuelAmountImg":STRING_Nil(fuelAmountImgUrl)};
//    [self.navigationController pushViewController:checkVC animated:YES];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.fuelAmountTF) {
        if ([textField.text intValue] > 100) {
            _networkConditionHUD.labelText = @"燃油量百分比不能超过100%！"; 
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//            self.fuelAmountTF.text = @"";   //清空
            return NO;
        }
    }
    else if(textField == self.mileageTF) {
        if ([textField.text intValue] < [self.lastMileageTF.text intValue]) {
            _networkConditionHUD.labelText = @"当前里程不能小于上次保养里程！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            return NO;
        }
    }
    return YES;
}


//设置当前激活的文本框或文本域
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"请在此处录入备注"]) {
        textView.textColor = [UIColor blackColor];
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length < 1) {
        textView.textColor = RGBCOLOR(170, 170, 170);
        textView.text = @"请在此处录入备注";
    }
}

- (void)textViewShouldBeginEditing:(UITextView *)textView
{
    activeField = textView;
}

- (void)textViewShouldEndEditing:(UITextView *)textView
{
    activeField = nil;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == self.remarkTV) {
        NSInteger kMaxLength = 100;
        NSString *toBeString = textView.text;
        NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage; //ios7之前使用[UITextInputMode currentInputMode].primaryLanguage
        if ([lang isEqualToString:@"zh-Hans"]) { //中文输入
            UITextRange *selectedRange = [textView markedTextRange];
            //获取高亮部分
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            if (!position) {// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
                if (toBeString.length > kMaxLength) {
                    textView.text = [toBeString substringToIndex:kMaxLength];
                    _networkConditionHUD.labelText = @"字数不能超过100！";
                    [_networkConditionHUD show:YES];
                    [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                }
            }
            else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            }
        }else{//中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            if (toBeString.length > kMaxLength) {
                textView.text = [toBeString substringToIndex:kMaxLength];
            }
        }
    }
}

#pragma mark - 添加完成按钮的toolBar工具栏

- (void)setTextViewInputAccessoryViewWithTV:(UITextView *)textView{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [lastBtn setTitle:@"上一项" forState:UIControlStateNormal];
    lastBtn.tag = textView.tag;
    lastBtn.frame = CGRectMake(2, 5, 60, 25);
    [lastBtn addTarget:self action:@selector(lastField:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lastBtnItem = [[UIBarButtonItem alloc]initWithCustomView:lastBtn];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:lastBtnItem, spaceBtn, doneBtnItem,nil];
    [topView setItems:buttonsArray];
    [textView setInputAccessoryView:topView];
    [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}


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
    id textField = textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex < [textFieldArray count] - 1)
    {
        id nextTextField = [textFieldArray objectAtIndex:(textFieldIndex + 1)];
        [nextTextField becomeFirstResponder];
    }
}

-(void)lastField:(UIButton *)lastBtn {
    NSInteger textFieldIndex = lastBtn.tag;
    id textField = textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex > 0)
    {
        id lastTextField = [textFieldArray objectAtIndex:(textFieldIndex - 1)];
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
//            self.mileageL.hidden = YES;
            [self requestUploadImgFile:self.mileageImgView];
            break;
        }
        case 1: {
            self.fuelAmountImgView.image = image;
//            self.fuelAmountL.hidden = YES;
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

-(void)requestGetLastMileage {  //获取上次保养里程数
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepLastMileage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepLastMileage, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",UrlPrefixNew(CarUpkeepLastMileage),self.carDic[@"id"]];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
    
    if ([notification.name isEqualToString:CarUpkeepLastMileage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepLastMileage object:nil];
        NSLog(@"CarUpkeepLastMileage: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            self.lastMileageTF.text = [NSString stringWithFormat:@"%@",responseObject[@"body"]];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
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
