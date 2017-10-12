//
//  MetodPaymentVC.m
//  HSH
//
//  Created by kangshibiao on 16/5/23.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "MetodPaymentVC.h"

@interface MetodPaymentVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *payModeStr;   //支付方式
}

@end

@implementation MetodPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =@"付款中";
    payModeStr = @"2";   //默认使用微信
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

- (IBAction)selectPay:(UIButton *)sender{
    if (sender.tag == 0) {
        self.wx.image = [UIImage imageNamed:@"checkbox_yes"];
        self.ailpay.image = [UIImage imageNamed:@"checkbox_no"];
        self.jifen.image = [UIImage imageNamed:@"checkbox_no"];
        payModeStr = @"2";
    }
    else if (sender.tag == 1){
        self.wx.image = [UIImage imageNamed:@"checkbox_no"];
        self.ailpay.image = [UIImage imageNamed:@"checkbox_yes"];
        self.jifen.image = [UIImage imageNamed:@"checkbox_no"];
        payModeStr = @"1";
    }
    else {
        self.wx.image = [UIImage imageNamed:@"checkbox_no"];
        self.ailpay.image = [UIImage imageNamed:@"checkbox_no"];
        self.jifen.image = [UIImage imageNamed:@"checkbox_yes"];
        payModeStr = @"3";
    }
}

#pragma mark - 发送请求
-(void)getMyAddress {       //获取收货地址
    //    [_addressArray removeAllObjects];
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderChoosePayMode object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderChoosePayMode, @"op", nil];
    //    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@",UrlPrefix(ConsigneeList),@"1"];
    //    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.orderNumber,@"code",payModeStr,@"payMode", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(MallOrderChoosePayMode) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:MallOrderChoosePayMode]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderChoosePayMode object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            
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
