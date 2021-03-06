//
//  EmployeeEditSkillCertificationVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeEditSkillCertificationVC.h"

@interface EmployeeEditSkillCertificationVC () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *textFieldArray;
    NSString *imgUrl;
}
@property (strong, nonatomic) IBOutlet UITextField *nameTF;
@property (strong, nonatomic) IBOutlet UITextField *contentTF;
@property (strong, nonatomic) IBOutlet UIImageView *uploadDefaultIM;
@property (strong, nonatomic) IBOutlet WPImageView *imgView;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
//@property (weak, nonatomic) IBOutlet UILabel *imgL;

@end

@implementation EmployeeEditSkillCertificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加技能认证";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.editBtn.hidden = YES;
    
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchBtn.frame = CGRectMake(0, 0, 70, 44);
//    //    searchBtn.contentMode = UIViewContentModeRight;
//    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [searchBtn setTitleColor:RGBCOLOR(129, 129, 129) forState:UIControlStateNormal];
//    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [searchBtn setTitle:@"提交审核" forState:UIControlStateNormal];
//    [searchBtn addTarget:self action:@selector(toSubmitSkill) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
//    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    [self setTextFieldInputAccessoryViewWithTF:self.nameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.contentTF];
    textFieldArray = @[self.nameTF,self.contentTF];
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [self.imgView addGestureRecognizer:tap0];
    
    if (self.skillDic) {
        imgUrl = self.skillDic[@"image"];
        if (imgUrl.length > 0) {
            [self.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.skillDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
            self.uploadDefaultIM.hidden = YES;
        } else {
            self.uploadDefaultIM.hidden = NO;
        }
        self.nameTF.text = self.skillDic[@"name"];
        self.contentTF.text = self.skillDic[@"remark"];
        
        if (self.approvalStatus == 0) {
            self.title = @"审批中";
            self.editBtn.hidden = YES;
            self.statusBtn.enabled = NO;
            [self.statusBtn setBackgroundColor:[UIColor grayColor]];
            [self.statusBtn setTitle:@"审批中，不能修改" forState:UIControlStateNormal];
            self.nameTF.enabled = NO;
            self.contentTF.enabled = NO;
            self.imgView.userInteractionEnabled = NO;
        }
        else if (self.approvalStatus == 1) {
            self.title = @"认证信息";
            self.editBtn.hidden = NO;
            self.statusBtn.enabled = YES;
            self.nameTF.enabled = NO;
            self.contentTF.enabled = NO;
            self.imgView.userInteractionEnabled = YES;
        }
        else if (self.approvalStatus == -1) {
            self.title = @"已拒绝";
            _networkConditionHUD.labelText = @"审核不通过";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            self.editBtn.hidden = NO;
            self.statusBtn.enabled = YES;
            self.nameTF.enabled = NO;
            self.contentTF.enabled = NO;
            self.imgView.userInteractionEnabled = YES;
        }
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

-(void)tapImageView:(UITapGestureRecognizer *)tap {
    [self selectThePhotoOrCamera];
}

//-(void)toSubmitSkill {
//    
//}
- (IBAction)editAction:(id)sender {
    self.editBtn.hidden = YES;
    self.nameTF.enabled = YES;
    self.contentTF.enabled = YES;
}

- (IBAction)toSubmitSkillAction:(id)sender {
    if (self.nameTF.text.length > 0 && self.contentTF.text.length > 0 && imgUrl.length > 0) {
        [self requestPostUserAddOrChangeSkill];
    }
    else {
        _networkConditionHUD.labelText = @"请填写完所有信息！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
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
    self.imgView.image = image;
    [self requestUploadImgFile:self.imgView];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 发送请求
#pragma mark - 发起网络请求
-(void)requestUploadImgFile:(WPImageView *)image {  //上传图片
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}

-(void)requestPostUserAddOrChangeSkill { //修改单个技能
    [_hud show:YES];
    //注册通知
     if (self.skillDic) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserChangeSkill object:nil];
        NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserChangeSkill, @"op", nil];
        NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.skillDic[@"id"],@"skillId",self.nameTF.text,@"skillName",self.contentTF.text,@"skillRemark", imgUrl, @"skillImage", nil];
         NSLog(@"pram: %@",pram);
        [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UserChangeSkill) delegate:nil params:pram info:infoDic];
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserAppendSkill object:nil];
        NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserAppendSkill, @"op", nil];
        NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameTF.text,@"skillName",self.contentTF.text,@"skillRemark", imgUrl, @"skillImage", nil];
        NSLog(@"pram: %@",pram);
        [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UserAppendSkill) delegate:nil params:pram info:infoDic];
    }
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
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        if ([responseObject[@"result"] boolValue]) {
            imgUrl = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }

    if ([notification.name isEqualToString:UserChangeSkill]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserChangeSkill object:nil];
        NSLog(@"UserChangeSkill: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self performSelector:@selector(toPopVC:) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:UserAppendSkill]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserAppendSkill object:nil];
        NSLog(@"UserAppendSkill: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self performSelector:@selector(toPopVC:) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC:(NSString *)string {
    [self.navigationController popViewControllerAnimated:YES];
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
