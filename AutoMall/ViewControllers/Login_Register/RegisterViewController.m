//
//  RegisterViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterYZMViewController.h"
#import "WebViewController.h"

@interface RegisterViewController ()
{
     IBOutlet UIButton *mimaEyeBtn;
    __weak IBOutlet UIButton *reMimaEyeBtn;
    IBOutlet UIButton *radioBtn;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"快速注册";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.registerBtn.layer.cornerRadius = 5;
    self.registerBtn.layer.masksToBounds = YES;
    
    
    [mimaEyeBtn setImage:[UIImage imageNamed:@"mimaEye_close"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [reMimaEyeBtn setImage:[UIImage imageNamed:@"mimaEye_close"] forState:UIControlStateSelected | UIControlStateHighlighted];
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
- (IBAction)rePwdTextSwitch:(id)sender {
    UIButton *eyeBtn = (UIButton *)sender;
    eyeBtn.selected = !eyeBtn.selected;
    
    if (eyeBtn.selected) { // 按下去了就是暗文
        NSString *tempPwdStr = self.rePasswordTF.text;
        self.rePasswordTF.text = @""; // 这句代码可以防止切换的时候光标偏移
        self.rePasswordTF.secureTextEntry = YES;
        self.rePasswordTF.text = tempPwdStr;
        
    } else { // 明文
        NSString *tempPwdStr = self.rePasswordTF.text;
        self.rePasswordTF.text = @"";
        self.rePasswordTF.secureTextEntry = NO;
        self.rePasswordTF.text = tempPwdStr;
    }
}

- (IBAction)registerAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    
    if (! [self.passwordTF.text isEqualToString:self.rePasswordTF.text]) {
        _networkConditionHUD.labelText = @"两次输入的密码不同，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    else if (! [self checkPhoneNumWithPhone:self.phoneTF.text]){
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    else {
        [self requestVerifyMobile];
    }
}

- (IBAction)mianzeAction:(id)sender {
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.webUrlStr = ServiceInfo;
    webVC.titleStr = @"服务条款";
    webVC.canShare = NO;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
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

#pragma mark - 发送请求
-(void)requestVerifyMobile { //验证是否已注册
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:PhoneCheckup object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:PhoneCheckup, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?phone=%@",UrlPrefix(PhoneCheckup),self.phoneTF.text];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:PhoneCheckup]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PhoneCheckup object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            RegisterYZMViewController *yzmVC = [[RegisterYZMViewController alloc] init];
            yzmVC.phoneStr = self.phoneTF.text;
            yzmVC.passwordStr = self.passwordTF.text;
            [self.navigationController pushViewController:yzmVC animated:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
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
