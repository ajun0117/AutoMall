//
//  RegisterYZMViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "RegisterYZMViewController.h"

@interface RegisterYZMViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UILabel *phoneL;

@end

@implementation RegisterYZMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.phoneL.text = self.phoneStr;
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

#pragma mark - 发送请求
-(void)requestGetSMS { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetSMS object:nil];
    
//    NSString *mixStr = [NSString stringWithFormat:@"%@%@",@"jw134#%pqNLVfn",self.passwordTF.text];
//    mixStr = [GlobalSetting md5HexDigest:mixStr];   //第一次加密
//    NSString *pwdMD5 = [GlobalSetting md5HexDigest:mixStr];     //第二次加密
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetSMS, @"op", nil];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"nickName",pwdMD5,@"password", nil];
//    NSLog(@"pram: %@",pram);
    NSString *urlString = [NSString stringWithFormat:@"%@?phone=%@",UrlPrefix(GetSMS),self.phoneL.text];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
        if ([responseObject[@"result"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
//            NSDictionary *dic = responseObject[@"item"];
//            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.passwordTF.text]; //存储登录密码
//            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
//            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",dic [@"id"]]];
//            [[GlobalSetting shareGlobalSettingInstance] setToken:dic [@"token"]];
//            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"nickName"]];
//            
//            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
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
