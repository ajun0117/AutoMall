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
#import "AutoCheckResultVC.h"

@interface AutoCheckOrderPayModeVC () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *statusFlow;   //状态流程方式 1：先付款   0：先施工
}
@property (strong, nonatomic) IBOutlet UIView *contentV;
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
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC)];
//    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
    if (! self.isFromList) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC)];
        self.navigationItem.leftBarButtonItem = backBtn;
        self.navigationItem.leftBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toCheckResultVC)];
    [self.contentV addGestureRecognizer:tap];
    
//    NSDictionary *dic = @{@"orderId":orderId,@"money":moneyN,@"plateNumber":STRING(self.carDic[@"plateNumber"]),@"owner":STRING(self.carDic[@"owner"])};
    self.orderNumberL.text = self.infoDic[@"orderId"];
    self.moneyL.text = [NSString stringWithFormat:@"￥%.2f",[self.infoDic[@"money"] floatValue]];
    self.chepaiL.text = self.infoDic[@"plateNumber"];
    self.ownerL.text = self.infoDic[@"owner"];
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

-(void) toCheckResultVC {
    AutoCheckResultVC *resultVC = [[AutoCheckResultVC alloc] init];
    resultVC.carUpkeepId = self.checkOrderId;
    resultVC.checktypeID = self.infoDic[@"checktypeID"];
    resultVC.isFromAffirm = YES;
    resultVC.isFromList = YES;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (IBAction)payFirstAction:(id)sender {
    statusFlow = @"1";          //先付款
//    [self requestPostUpdateStatus];
    AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
    orderVC.statusFlow = statusFlow;
    orderVC.checkOrderId = self.checkOrderId;
    orderVC.infoDic = self.infoDic;
    [self.navigationController pushViewController:orderVC animated:YES];
}

- (IBAction)upkeepFirstAction:(id)sender {
    statusFlow = @"0";          //先施工
//    [self requestPostUpdateStatus];
    AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
    workingVC.statusFlow = statusFlow;
    workingVC.checkOrderId = self.checkOrderId;
    workingVC.infoDic = self.infoDic;
    [self.navigationController pushViewController:workingVC animated:YES];
}

-(void) popToRootVC {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认回到首页吗？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
    alert.tag = 200;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 发送请求
-(void)requestPostUpdateStatus { //更新订单状态
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUpdate object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUpdate, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.checkOrderId,@"id",@"2",@"status", statusFlow,@"statusFlow",nil]; //此界面只有一个施工操作
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
            if ([statusFlow isEqualToString:@"1"]) {    //先付款
                AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
                orderVC.statusFlow = statusFlow;
                orderVC.checkOrderId = self.checkOrderId;
                orderVC.infoDic = self.infoDic;
                [self.navigationController pushViewController:orderVC animated:YES];
            }
            else if ([statusFlow isEqualToString:@"0"]) {   //先施工
                AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
                workingVC.statusFlow = statusFlow;
                workingVC.checkOrderId = self.checkOrderId;
                workingVC.infoDic = self.infoDic;
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
