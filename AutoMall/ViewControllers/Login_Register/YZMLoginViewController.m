//
//  YZMLoginViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/17.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "YZMLoginViewController.h"

@interface YZMLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextF;
@property (weak, nonatomic) IBOutlet UITextField *codeTextF;
@property (weak, nonatomic) IBOutlet UIButton *sendMSMBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property NSInteger leftTime;//重新发送后剩余的时间
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation YZMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"验证码登录";
    
    [self initViews];
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
    if (self.leftTime == 0) {
        self.sendMSMBtn.enabled = YES;
        [self.timer invalidate];
        NSString *string = [NSString stringWithFormat:@"重新发送"];
        [self.sendMSMBtn setBackgroundColor:[UIColor colorWithRed:1.000 green:0.643 blue:0.173 alpha:1.000]];
        [self.sendMSMBtn setTitle:string forState:UIControlStateNormal];
        return;
    }
    self.leftTime --;
    NSString *string = [NSString stringWithFormat:@"%ld秒",(long)self.leftTime];
    //    [self.sendMSMBtn.titleLabel setText:string];
    [self.sendMSMBtn setTitle:string forState:UIControlStateDisabled];
}


/**
 *  重新发送验证码
 *
 */
- (IBAction)sendMSMAction:(id)sender {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:REQUEST_GET_SENDPHONECODE object:nil];
//    if ([self checkPhoneNumWithPhone:self.userNameTextF.text]) {
//        //发送短信
//        [[RequestManager sharedRequestManager] sendPhoneCodeWithPhoneNum:self.userNameTextF.text ipAddress:self.ipAddress];
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

/**
 *  点击登录按钮
 *
 */
- (IBAction)loginAction:(id)sender {
    NSLog(@"登录");
    [self.view endEditing:YES];
//    if ([self checkPhoneNumWithPhone:self.userNameTextF.text]) {
//        if ([self checkCodeNumWithCode:self.codeTextF.text]) {
//            if ([[GlobalSetting shareGlobalSettingInstance] csrfToken]) {
//                [self.hud show:YES];
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:REQUEST_POST_PHONELOGIN object:nil];
//                [[RequestManager sharedRequestManager] requestLoginWithUserName:self.userNameTextF.text password:self.codeTextF.text ip:self.ipAddress];
//                [[GlobalSetting shareGlobalSettingInstance] setLoginName:self.userNameTextF.text];
//            } else {
//                //获取tooken
//                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:REQUEST_GET_CSRFTOKEN object:nil];
//                [[RequestManager sharedRequestManager] getCsrfToken];
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"登录失败请重试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//            }
//        }
//        else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"验证码格式不正确" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//    }
//    else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手机号码格式不正确" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    
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
