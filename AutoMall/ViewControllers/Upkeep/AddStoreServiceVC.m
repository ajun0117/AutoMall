//
//  AddStoreServiceVC.m
//  AutoMall
//
//  Created by LYD on 2017/11/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddStoreServiceVC.h"

@interface AddStoreServiceVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@property (strong, nonatomic) IBOutlet UITextField *servicesNameTF;
@property (strong, nonatomic) IBOutlet UITextField *servicesMoneyTF;

@end

@implementation AddStoreServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加门店服务";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
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

- (IBAction)saveAction:(id)sender {
    if (! self.servicesNameTF.text || self.servicesNameTF.text.length == 0) {
        _networkConditionHUD.labelText = @"服务名称必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }

    [self requestPostAddService];
}

#pragma mark -
#pragma mark 手机号码及验证码格式初步验证
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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.servicesNameTF resignFirstResponder];
    [self.servicesMoneyTF resignFirstResponder];
}

#pragma mark - 发起网络请求
-(void)requestPostAddService { //新增服务
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreserviceAdd object:nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreserviceAdd, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?storeId=%@",UrlPrefix(StoreserviceAdd),storeId];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.servicesNameTF.text,@"item", STRING_Nil(self.servicesMoneyTF.text), @"money", nil];
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:urlString delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:StoreserviceAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreserviceAdd object:nil];
        NSLog(@"StoreserviceAdd: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //验证码正确
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
}


- (void)toPopVC:(NSString *)carId {
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
