//
//  YZMLoginViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/17.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "YZMLoginViewController.h"

#define LEFTTIME    120   //120秒限制

@interface YZMLoginViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    
    NSInteger leftTime;//重新发送后剩余的时间
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextF;
@property (weak, nonatomic) IBOutlet UITextField *codeTextF;
@property (weak, nonatomic) IBOutlet UIButton *sendMSMBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation YZMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"验证码登录";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self initViews];
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

/**
 *  初始化视图
 */
-(void) initViews{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [self.view addSubview:view];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
//    //用户名输入框
//    NSString *userName = [[GlobalSetting shareGlobalSettingInstance] loginName];
//    if (userName.length > 0) {
//        self.userNameTextF.text = userName;
//    }
    
    //发送验证码
    self.sendMSMBtn.layer.cornerRadius = 5;
    self.sendMSMBtn.layer.masksToBounds = YES;
    
    //登录
    self.loginBtn.layer.cornerRadius = 20; //半圆角
    self.loginBtn.layer.masksToBounds = YES;
}

/**
 *  改变剩余时间
 *
 */
-(void) changeLeftTime:(NSTimer *)timer{
    if (leftTime == 0) {
        self.sendMSMBtn.enabled = YES;
        [_timer invalidate];
        NSString *string = [NSString stringWithFormat:@"重新发送"];
        [self.sendMSMBtn setTitle:string forState:UIControlStateNormal];
        return;
    }
    leftTime --;
    NSString *string = [NSString stringWithFormat:@"%ld秒",(long)leftTime];
    //    [self.sendMSMBtn.titleLabel setText:string];
    [self.sendMSMBtn setTitle:string forState:UIControlStateDisabled];
}


/**
 *  重新发送验证码
 *
 */
- (IBAction)sendMSMAction:(id)sender {
    if ([self checkPhoneNumWithPhone:self.userNameTextF.text]) {
        //发送短信
        [self requestSendSMSVerifyCode];
    }
    else {
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

/**
 *  点击登录按钮
 *
 */
- (IBAction)loginAction:(id)sender {
    NSLog(@"登录");
    [self.view endEditing:YES];
    if ([self checkPhoneNumWithPhone:self.userNameTextF.text]) {
        if ([self checkCodeNumWithCode:self.codeTextF.text]) {
            [self requestMemberLogin];
        }
        else {
            _networkConditionHUD.labelText = @"验证码输入不正确，请重新输入。";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    else {
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
}

//隐藏键盘
-(void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer{
    [self.userNameTextF resignFirstResponder];
    [self.codeTextF resignFirstResponder];
}

#pragma mark -
#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];
    if (textField == self.userNameTextF) {
//        [[GlobalSetting shareGlobalSettingInstance] setLoginName:str];
    } else if (textField == self.codeTextF) {
//        [[GlobalSetting shareGlobalSettingInstance] setPassword:str];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _userNameTextF) {
        [_codeTextF becomeFirstResponder];
    }else{
        [self loginAction:nil];
    }
    
    return YES;
}

#pragma mark -
#pragma mark 手机号码及验证码格式初步验证
-(BOOL) checkPhoneNumWithPhone:(NSString *)phone {
    /**
     *  是否纯数字
     */
    BOOL isDigit = NO;
    NSString *regEX = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:phone]) {
        isDigit = YES;
    } else {
        isDigit = NO;
    }
    
    if (isDigit && [phone length] == 11 && [phone hasPrefix:@"1"]) {
        return YES;
    }
    return NO;
}

-(BOOL) checkCodeNumWithCode:(NSString *)code {
    /**
     *  是否纯数字
     */
    BOOL isDigit = NO;
    NSString *regEX = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:code]) {
        isDigit = YES;
    } else {
        isDigit = NO;
    }
    
    if (isDigit && [code length] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - 发送请求
-(void)requestSendSMSVerifyCode { //发送短信验证码
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetSMS object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetSMS, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?phone=%@",UrlPrefix(GetSMS),self.userNameTextF.text];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestMemberLogin { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserLogin object:nil];
    
    //    NSString *mixStr = [NSString stringWithFormat:@"%@%@",@"jw134#%pqNLVfn",self.passwordTF.text];
    //    mixStr = [GlobalSetting md5HexDigest:mixStr];   //第一次加密
    //    NSString *pwdMD5 = [GlobalSetting md5HexDigest:mixStr];     //第二次加密
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserLogin, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.userNameTextF.text,@"userName",self.codeTextF.text,@"code", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UserLogin) delegate:nil params:pram info:infoDic];
}

-(void)requestPostUserGetInfo { //获取登录用户信息
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetUserInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetUserInfo, @"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(GetUserInfo) delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:GetSMS]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetSMS object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            //验证码发送成功，开始倒计时
            self.sendMSMBtn.enabled = NO;
            leftTime = LEFTTIME;
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeLeftTime:) userInfo:nil repeats:YES];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:UserLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogin object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            //            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            _networkConditionHUD.labelText = @"登录成功！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"access_token"]];
            
            [self requestPostUserGetInfo];   //紧接着请求用户信息;
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:GetUserInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetUserInfo object:nil];
        NSLog(@"GetUserInfo_responseObject %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            NSDictionary *dic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic[@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setMobileUserType:[NSString stringWithFormat:@"%@",dic[@"mobileUserType"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmMobile:[NSString stringWithFormat:@"%@",dic[@"phone"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmHead:STRING(dic[@"image"])];
            //            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"userName"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];     //发送登录成功通知
            if (self.isPresented) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES]; //返回上级页面
            }
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
