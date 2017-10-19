//
//  AutoCheckOrderPayModeVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckOrderPayModeVC.h"
#import "AutoCheckOrderVC.h"
#import "AutoCheckOrderWorkingVC.h"

@interface AutoCheckOrderPayModeVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *statusFlow;   //状态流程方式 0：先付款   1：先施工
}
@property (strong, nonatomic) IBOutlet UILabel *orderNumberL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet UILabel *chepaiL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;

@end

@implementation AutoCheckOrderPayModeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单";
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

- (IBAction)payFirstAction:(id)sender {
    statusFlow = @"0";          //先付款
//    [self requestPostUpdateStatus];
    AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
    orderVC.statusFlow = statusFlow;
    orderVC.orderId = self.orderId;
    [self.navigationController pushViewController:orderVC animated:YES];
}

- (IBAction)upkeepFirstAction:(id)sender {
    statusFlow = @"1";          //先施工
//    [self requestPostUpdateStatus];
    AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
    workingVC.statusFlow = statusFlow;
    workingVC.orderId = self.orderId;
    [self.navigationController pushViewController:workingVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestPostUpdateStatus { //更新订单状态
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUpdate object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUpdate, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.orderId,@"id",@"1",@"status", statusFlow,@"statusFlow",nil]; //施工订单确认
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
            if ([statusFlow isEqualToString:@"0"]) {
                AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
                orderVC.statusFlow = statusFlow;
                orderVC.orderId = self.orderId;
                [self.navigationController pushViewController:orderVC animated:YES];
            }
            else if ([statusFlow isEqualToString:@"1"]) {
                AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
                workingVC.statusFlow = statusFlow;
                workingVC.orderId = self.orderId;
                [self.navigationController pushViewController:workingVC animated:YES];
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
