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
    RegisterYZMViewController *yzmVC = [[RegisterYZMViewController alloc] init];
    yzmVC.phoneStr = self.phoneTF.text;
    [self.navigationController pushViewController:yzmVC animated:YES];
}

- (IBAction)mianzeAction:(id)sender {
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
