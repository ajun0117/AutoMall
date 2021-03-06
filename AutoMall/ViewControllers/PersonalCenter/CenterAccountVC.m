//
//  CenterAccountVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CenterAccountVC.h"
#import "CartTool.h"

@interface CenterAccountVC () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *textFieldArray;
}

@property (weak, nonatomic) IBOutlet UILabel *accountL;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTF;
@property (weak, nonatomic) IBOutlet UITextField *wechatTF;
@property (weak, nonatomic) IBOutlet UILabel *jifenL;
@property (weak, nonatomic) IBOutlet UILabel *expireJifenL;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewHeightCon;

@end

@implementation CenterAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"个人信息";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 110, 40)];
    titleL.text = @"个人信息";
    titleL.font = [UIFont boldSystemFontOfSize:17];
    titleL.textAlignment = NSTextAlignmentRight;
    [view addSubview:titleL];
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(110, 2, 40, 40);
    [photoBtn setImage:[UIImage imageNamed:@"logOut"] forState:UIControlStateNormal];
    //    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [photoBtn addTarget:self action:@selector(toLogOut) forControlEvents:UIControlEventTouchUpInside];
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if ([mobileUserType isEqualToString:@"2"]) {  //门店员工
        [view addSubview:photoBtn];
    }
    self.navigationItem.titleView = view;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    //    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"退出" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toExit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    self.accountL.text = self.infoDic[@"phone"];
    self.nickNameTF.text = STRING(self.infoDic[@"nickname"]);
    self.wechatTF.text = STRING(self.infoDic[@"wechat"]);
    
    if ([mobileUserType isEqualToString:@"1"]) {  //门店老板
        self.viewHeightCon.constant = 178;
        self.jifenL.text = [NSString stringWithFormat:@"%@大卡",NSStringWithNumberNULL(self.infoDic[@"integral"])];
        self.expireJifenL.text = [NSString stringWithFormat:@"%@大卡",NSStringWithNumberNULL(self.infoDic[@"expiredIntegral"])];
    }
    else {
        self.viewHeightCon.constant = 133;
    }
    
    [self requestPostUserGetInfo];  //刷新个人信息
    
    [self setTextFieldInputAccessoryViewWithTF:self.nickNameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.wechatTF];
    textFieldArray = @[self.nickNameTF,self.wechatTF];
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

-(void) toExit {    //清空本地数据，退出登录
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认注销" message:@"确定要退出当前账号吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认注销", nil];
    alert.delegate = self;
    alert.tag = 1001;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 1001) {
        [[GlobalSetting shareGlobalSettingInstance] removeUserDefaultsValue];
        [[CartTool sharedManager] removeAllCartItems];      //清空本地购物车数据
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectedCar" object:nil userInfo:nil];  //通知清空已选的车辆信息
        self.UpdateLoginStatus();
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex == 1 && alertView.tag == 1002) {
        [self requestLogOut];       //注销员工身份请求
    }
}

- (IBAction)saveInfoAction:(id)sender {
    [self requestPostUpdateNickNameAndWechat];
}

-(void)toLogOut {   //注销员工身份
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注销员工身份？" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.delegate = self;
    alert.tag = 1002;
    [alert show];
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
-(void)requestPostUserGetInfo { //获取登录用户信息
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetUserInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetUserInfo, @"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(GetUserInfo) delegate:nil params:nil info:infoDic];
}

-(void)requestPostUpdateNickNameAndWechat { //修改资料
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChangeNickName object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChangeNickName, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nickNameTF.text,@"nickname",self.wechatTF.text,@"wechat", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ChangeNickName) delegate:nil params:pram info:infoDic];
}

-(void)requestLogOut { //注销员工身份
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserLogOut object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserLogOut, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",UrlPrefixNew(UserLogOut),userId];
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
    
    if ([notification.name isEqualToString:GetUserInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetUserInfo object:nil];
        NSLog(@"GetUserInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            self.infoDic = responseObject[@"data"];
            NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
            self.accountL.text = self.infoDic[@"phone"];
            self.nickNameTF.text = STRING(self.infoDic[@"nickname"]);
            self.wechatTF.text = STRING(self.infoDic[@"wechat"]);
            if ([mobileUserType isEqualToString:@"1"]) {  //门店老板
                self.viewHeightCon.constant = 178;
                self.jifenL.text = [NSString stringWithFormat:@"%@大卡",NSStringWithNumberNULL(self.infoDic[@"integral"])];
                self.expireJifenL.text = [NSString stringWithFormat:@"%@大卡",NSStringWithNumberNULL(self.infoDic[@"expiredIntegral"])];
            }
            else {
                self.viewHeightCon.constant = 133;
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    
    if ([notification.name isEqualToString:ChangeNickName]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ChangeNickName object:nil];
        NSLog(@"ChangeNickName: %@",responseObject);
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
    
    if ([notification.name isEqualToString:UserLogOut]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogOut object:nil];
        NSLog(@"UserLogOut: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = STRING(responseObject[@"meta"][@"msg"]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self performSelector:@selector(toPopLogOutVC:) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING(responseObject[@"meta"][@"msg"]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC:(NSString *)string {
    self.UpdateUserInfo(nil);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toPopLogOutVC:(NSString *)string {
    [[GlobalSetting shareGlobalSettingInstance] removeUserDefaultsValue];
    [[CartTool sharedManager] removeAllCartItems];      //清空本地购物车数据
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectedCar" object:nil userInfo:nil];  //通知清空已选的车辆信息
    self.UpdateLoginStatus();
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
