//
//  AutoCheckOrderVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckOrderVC.h"
#import "AutoCheckOrderWorkingVC.h"
#import "AutoCheckOrderCompleteVC.h"

@interface AutoCheckOrderVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UILabel *orderNumberL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet UILabel *chepaiL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;

@property (strong, nonatomic) IBOutlet UIView *qrCodeView;
@property (strong, nonatomic) IBOutlet UIButton *alipayBtn;
@property (strong, nonatomic) IBOutlet UIButton *weixinpayBtn;

@end

@implementation AutoCheckOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.statusFlow isEqualToString:@"0"]) {
        self.title = @"先付款后开工";
    }
    else {
        self.title = @"已完工，付款中";
    }
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

- (IBAction)verifyPaidAction:(id)sender {
//    [self requestPostUpdateStatus];
    if ([self.statusFlow isEqualToString:@"0"]) {   //先付款，付款完成，至施工
        AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
        workingVC.statusFlow = self.statusFlow;
        workingVC.orderId = self.orderId;
        [self.navigationController pushViewController:workingVC animated:YES];
    }
    else if ([self.statusFlow isEqualToString:@"1"]) {      //先施工，付款完成，至完工页
        AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
        completeVC.statusFlow = self.statusFlow;
        completeVC.orderId = self.orderId;
        [self.navigationController pushViewController:completeVC animated:YES];
    }
}

#pragma mark - 发送请求
-(void)requestPostUpdateStatus {       //更新订单状态
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUpdate object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUpdate, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.orderId,@"id",@"3",@"status", self.statusFlow,@"statusFlow",nil]; //已付款
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarUpkeepUpdate) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:CarUpkeepUpdate]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepUpdate object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //接口正确
            if ([self.statusFlow isEqualToString:@"0"]) {   //先付款，付款完成，至施工
                AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
                workingVC.statusFlow = self.statusFlow;
                workingVC.orderId = self.orderId;
                [self.navigationController pushViewController:workingVC animated:YES];
            }
            else if ([self.statusFlow isEqualToString:@"1"]) {      //先施工，付款完成，至完工页
                AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
                completeVC.statusFlow = self.statusFlow;
                completeVC.orderId = self.orderId;
                [self.navigationController pushViewController:completeVC animated:YES];
            }
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