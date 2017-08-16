//
//  LoginViewController.m
//  YMYL
//
//  Created by ljy on 15/8/21.
//  Copyright (c) 2015年 ljy. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

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
    
    [self.phoneTF setLeftView:@"login_user" placeholder:@"昵称"];
    [self.passwordTF setLeftView:@"login_key" placeholder:@"密码"];
    
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
    [self requestMemberLogin];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}


#pragma mark - 发送请求
-(void)requestMemberLogin { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Login object:nil];
    
    NSString *mixStr = [NSString stringWithFormat:@"%@%@",@"jw134#%pqNLVfn",self.passwordTF.text];
    mixStr = [GlobalSetting md5HexDigest:mixStr];   //第一次加密
    NSString *pwdMD5 = [GlobalSetting md5HexDigest:mixStr];     //第二次加密
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:Login, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"nickName",pwdMD5,@"password", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(Login) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:Login]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Login object:nil];
        if ([responseObject[@"result"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[@"item"];
            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.passwordTF.text]; //存储登录密码
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic [@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"token"]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"nickName"]];

            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
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
