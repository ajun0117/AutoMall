//
//  MetodPaymentVC.m
//  HSH
//
//  Created by kangshibiao on 16/5/23.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "MetodPaymentVC.h"
#import "Order.h"
#import "RSADataSigner.h"
#import <AlipaySDK/AlipaySDK.h>

@interface MetodPaymentVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *payModeStr;   //支付方式
    NSDictionary *aliPayDic;    //支付宝参数字典
}
@property (weak, nonatomic) IBOutlet UILabel *orderNumberL;
@property (weak, nonatomic) IBOutlet UILabel *moneyL;

@end

@implementation MetodPaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =@"付款中";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    payModeStr = @"2";   //默认使用微信
    self.orderNumberL.text = [NSString stringWithFormat:@"您的订单编号：%@",self.orderNumber];
    self.moneyL.text = [NSString stringWithFormat:@"应付金额：￥%.2f",self.money];
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
- (IBAction)confirmAction:(id)sender {
    [self getChoosePayMode];    //选择支付方式
}

#pragma mark -
#pragma mark   ==============点击订单模拟支付行为==============
//
//选中商品调用支付宝极简支付
//
- (void)doAlipayPay
{
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *appID = AliPay_AppId;
    
    // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
    // 如果商户两个都设置了，优先使用 rsa2PrivateKey
    // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
    // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
    // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
    NSString *rsa2PrivateKey = Alipay_Rsa2PrivateKey;
    NSString *rsaPrivateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        ([rsa2PrivateKey length] == 0 && [rsaPrivateKey length] == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
//    // NOTE: 当前时间点
//    NSDateFormatter* formatter = [NSDateFormatter new];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    order.timestamp = [formatter stringFromDate:[NSDate date]];
    order.timestamp = aliPayDic[@"timestamp"];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = aliPayDic[@"body"];
    order.biz_content.subject = aliPayDic[@"subject"];
    order.biz_content.out_trade_no = self.orderNumber; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
//    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", 0.01]; //商品价格
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", self.money]; //商品价格
    order.biz_content.seller_id = @"2088721713116140";
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    NSLog(@"signedString: %@",signedString);
//     NOTE: 如果加签成功，则继续执行支付
//    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"AliPay2017101609335037";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",orderInfoEncoded, aliPayDic[@"sign"]];
    
//        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",orderInfoEncoded, signedString];
        NSLog(@"signedString2:   %@",orderString);
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            //发送支付宝支付完成通知
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult", resultDic, @"RespData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayNotification" object:nil userInfo:userInfo];
            
        }];
//    }
}


-(void)doWxPay {
    
}

#pragma mark - 支付完成后回调通知
-(void) completePayNotification:(NSNotification *)notification{
    if ([notification.name isEqualToString:@"AliPayNotification"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AliPayNotification" object:nil];
        
        NSDictionary *resultDic = [notification.userInfo objectForKey:@"RespData"];
        NSString *payresultStr = nil;
        int resultStatus = [resultDic [@"resultStatus"] intValue];
        if (resultStatus == 6001) {
            //            _networkConditionHUD.labelText = @"用户中途取消";
            payresultStr = @"cancel";
        }
        else if (resultStatus == 9000) {
            //            _networkConditionHUD.labelText = @"订单支付成功";
            [self requestOrderPaySuccess];
            payresultStr = @"success";
        }
        else if (resultStatus == 8000) {
            //            _networkConditionHUD.labelText = @"订单正在处理中，请稍后查看订单状态";
            [self requestOrderPaySuccess];
            payresultStr = @"success";
        }
        else if (resultStatus == 4000) {
            //            _networkConditionHUD.labelText = @"订单支付失败";
            payresultStr = @"failure";
        }
        else if (resultStatus == 6002) {
            //            _networkConditionHUD.labelText = @"网络连接出错";
            payresultStr = @"failure";
        }
    }
//    if ([notification.name isEqualToString:WxPayNotification]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:WxPayNotification object:nil];
//        
//        PayResp *resp = [notification.userInfo objectForKey:@"RespData"];
//        
//        //        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
//        //        NSString *strTitle;
//        //支付返回结果，实际支付结果需要去微信服务器端查询
//        //        strTitle = [NSString stringWithFormat:@"支付结果"];
//        
//        switch (resp.errCode) {
//            case WXSuccess:
//                //                strMsg = @"支付结果：成功！";
//                //                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
//                
//                [self performSelectorOnMainThread:@selector(wxpayBack:) withObject:@"success" waitUntilDone:NO];
//                
//                break;
//                
//            default:
//                //                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
//                //                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
//                
//                [self performSelectorOnMainThread:@selector(wxpayBack:) withObject:@"failure" waitUntilDone:NO];
//                
//                break;
//        }
//        /***调试信息***/
//        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        //        [alert show];
//    }
    
} 

#pragma mark - 发送请求
-(void)requestGetIntegralAs1Yuan {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetIntegralAs1Yuan object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetIntegralAs1Yuan, @"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(GetIntegralAs1Yuan) delegate:nil params:nil info:infoDic];
}
-(void)getChoosePayMode {       //发起支付方式选择请求
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderChoosePayMode object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderChoosePayMode, @"op", nil];
        NSString *urlString = [NSString stringWithFormat:@"%@?code=%@&payMode=%@",UrlPrefix(MallOrderChoosePayMode),self.orderNumber,payModeStr];
        [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestOrderPaySuccess {     //支付成功回调
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderPaySuccess object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderPaySuccess, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?code=%@",UrlPrefix(MallOrderPaySuccess),self.orderNumber];
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
    if ([notification.name isEqualToString:MallOrderChoosePayMode]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderChoosePayMode object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {   //支付宝
            if ([payModeStr isEqualToString:@"1"]) {
                aliPayDic = responseObject[@"data"];
                [self doAlipayPay];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePayNotification:) name:@"AliPayNotification" object:nil];
            }else if ([payModeStr isEqualToString:@"2"]) {    //微信
                
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:MallOrderPaySuccess]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderPaySuccess object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {   //支付宝
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.navigationController popToRootViewControllerAnimated:YES];
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
