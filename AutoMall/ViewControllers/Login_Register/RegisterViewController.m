//
//  RegisterViewController.m
//  YMYL
//
//  Created by ljyon 15/8/21.
//  Copyright (c) 2015年 ljy. All rights reserved.
//

#import "RegisterViewController.h"
#import "WebViewController.h"

#define LEFTTIME    120   //120秒限制

@interface RegisterViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"快速注册";
    
    self.completeBtn.layer.cornerRadius = 5;
    self.completeBtn.layer.masksToBounds = YES;
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

- (IBAction)confirmAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.nicknameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
    
    if (! self.radioBtn.selected) {
        _networkConditionHUD.labelText = @"您同意《用户行为规范及免责声明》后才能注册！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    [self requestMemberRegister];
}

- (IBAction)radioAction:(id)sender {
    self.radioBtn.selected = ! self.radioBtn.selected;
}

- (IBAction)protocolAction:(id)sender {
    WebViewController *web = [[WebViewController alloc] init];
    web.webUrlStr = RequestURL(Statement);
    web.titleStr = @"免责声明";
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"text: %@",text);
//    if (textField == self.phoneTF) {
//        if ([text length] >= 11) {
//            self.reSendBtn.enabled = YES;
////            [self.reSendBtn setBackgroundColor:Red_BtnColor];
//        }
//        else {
//            self.reSendBtn.enabled = NO;
////            [self.reSendBtn setBackgroundColor:Gray_BtnColor];
//        }
//    }
//    
////    else if (textField == self.codeNumTF) {
////        if ([text length] >= 4) {
////            self.checkBtn.enabled = YES;
////            [self.checkBtn setBackgroundColor:Red_BtnColor];
////        }
////        else {
////            self.checkBtn.enabled = NO;
////            [self.checkBtn setBackgroundColor:Gray_BtnColor];
////        }
////    }
//    
////    else if (textField == self.rePasswordTF) {
////        if ([text length] >= 6) {
////            self.confirmBtn.enabled = YES;
////            [self.confirmBtn setBackgroundColor:Red_BtnColor];
////        }
////        else {
////            self.confirmBtn.enabled = NO;
////            [self.confirmBtn setBackgroundColor:Gray_BtnColor];
////        }
////    }
//
//    return YES;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.passwordTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    if ([textField isEqual:self.rePasswordTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    if ([textField isEqual:self.emailTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -55, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    if ([textField isEqual:self.phoneTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -85, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.phoneTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.nicknameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
    
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.nicknameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.phoneTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.nicknameTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
    }
}

#pragma mark - 发送请求
-(void)requestMemberRegister { //注册
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Register object:nil];
    
    NSString *mixStr = [NSString stringWithFormat:@"%@%@",@"jw134#%pqNLVfn",self.passwordTF.text];
    mixStr = [GlobalSetting md5HexDigest:mixStr];   //第一次加密
    NSString *pwdMD5 = [GlobalSetting md5HexDigest:mixStr];     //第二次加密
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:Register, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nicknameTF.text,@"nickName",pwdMD5,@"password", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(Register) delegate:nil params:pram info:infoDic];
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
    NSLog(@"_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:Register]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:Register object:nil];
        if ([responseObject[@"result"] boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1000;
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
