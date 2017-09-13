//
//  RegisterViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterYZMViewController.h"

@interface RegisterViewController ()
{
     IBOutlet UIButton *mimaEyeBtn;
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
    self.registerBtn.layer.cornerRadius = 5;
    self.registerBtn.layer.masksToBounds = YES;
    
    
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

- (IBAction)registerAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    
    if ([self checkPhoneNumWithPhone:self.phoneTF.text]) {
        RegisterYZMViewController *yzmVC = [[RegisterYZMViewController alloc] init];
        yzmVC.phoneStr = self.phoneTF.text;
        [self.navigationController pushViewController:yzmVC animated:YES];
    }
    else {
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

- (IBAction)mianzeAction:(id)sender {
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
