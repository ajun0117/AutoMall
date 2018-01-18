//
//  LoginViewController.m
//  YMYL
//
//  Created by ljy on 15/8/21.
//  Copyright (c) 2015年 ljy. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "FindPWDViewController.h"
#import "YZMLoginViewController.h"

@interface LoginViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    IBOutlet UIButton *mimaEyeBtn;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    if (self.isPresented) {
        [self setNavigationbar];
    }
    
//    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightButn.frame = CGRectMake(0, 0, 60, 26);
//    rightButn.contentMode = UIViewContentModeScaleAspectFit;
//    rightButn.titleLabel.font = [UIFont systemFontOfSize:13];
//    [rightButn setTitle:@"忘记密码" forState:UIControlStateNormal];
//    [rightButn addTarget:self action:@selector(findPWD) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
//    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.masksToBounds = YES;

    
    [mimaEyeBtn setImage:[UIImage imageNamed:@"mimaEye_close"] forState:UIControlStateSelected | UIControlStateHighlighted];
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

#pragma mark -
#pragma self Methods
/**
 *  设置导航条
 */
- (void)setNavigationbar
{
    //    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Right-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(backButnClicked:)];
    //
    //    self.navigationItem.leftBarButtonItem = back;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector((backButnClicked:)) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 52, 30);
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backButton setTitle:@"关闭" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [backButton setImage:[UIImage imageNamed:@"return_left"] forState:UIControlStateNormal];
    //    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)]; // 向左边移动
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)]; // 向右边移动
    [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    UIBarButtonItem *backButnItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButnItem;
}

-(void)backButnClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pwdTextSwitch:(id)sender {
    UIButton *eyeBtn = (UIButton *)sender;
    eyeBtn.selected = !eyeBtn.selected;
    
    if (eyeBtn.selected) { // 按下去了就是暗文
        NSString *tempPwdStr = self.passwordTF.text;
        self.passwordTF.text = @""; // 这句代码可以防止切换的时候光标偏移
        self.passwordTF.secureTextEntry = YES;
        self.passwordTF.text = tempPwdStr;
        
    } else { // 明文
        NSString *tempPwdStr = self.passwordTF.text;
        self.passwordTF.text = @"";
        self.passwordTF.secureTextEntry = NO;
        self.passwordTF.text = tempPwdStr;
    }
}

- (IBAction)loginAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    
    if ([self checkPhoneNumWithPhone:self.phoneTF.text]) {
        [self requestMemberLogin];
    }
    else {
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

- (IBAction)forgetAction:(id)sender {
    FindPWDViewController *findVC = [[FindPWDViewController alloc] init];
    [self.navigationController pushViewController:findVC animated:YES];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)yzmLoginAction:(id)sender {
    YZMLoginViewController *yzmVC = [[YZMLoginViewController alloc] init];
    yzmVC.isPresented = self.isPresented;
    [self.navigationController pushViewController:yzmVC animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
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
-(void)requestMemberLogin { //密码登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserLogin object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserLogin, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"userName",self.passwordTF.text,@"password", nil];
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
    
    if ([notification.name isEqualToString:UserLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserLogin object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
//            _networkConditionHUD.labelText = @"登录成功！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"access_token"]];
            
            [self requestPostUserGetInfo];   //紧接着请求用户信息;
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:GetUserInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetUserInfo object:nil];
        NSLog(@"GetUserInfo_responseObject %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            NSDictionary *dic = responseObject[@"data"];
            
            [BPush setTag:[NSString stringWithFormat:@"%@",dic[@"phone"]] withCompleteHandler:^(id result, NSError *error) {
                if (error.code == 0) {
                    NSLog(@"绑定推送成功！userId: %@",[NSString stringWithFormat:@"%@",dic[@"phone"]]);
                }
            }];
            
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic[@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setMobileUserType:[NSString stringWithFormat:@"%@",dic[@"mobileUserType"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmMobile:[NSString stringWithFormat:@"%@",dic[@"phone"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:[NSString stringWithFormat:@"%@",STRING(dic[@"nickname"])]];
            [[GlobalSetting shareGlobalSettingInstance] setmHead:STRING(dic[@"image"])];
            //            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"userName"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil];     //发送登录成功通知
            if (self.isPresented) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
            [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
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
