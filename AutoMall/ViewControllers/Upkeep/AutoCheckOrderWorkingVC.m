//
//  AutoCheckOrderWorkingVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckOrderWorkingVC.h"
#import "AutoCheckOrderVC.h"
#import "AutoCheckOrderCompleteVC.h"

@interface AutoCheckOrderWorkingVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UILabel *orderNumberL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet UILabel *chepaiL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;

@end

@implementation AutoCheckOrderWorkingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.statusFlow isEqualToString:@"0"]) {   //先施工
        self.title = @"施工中，未付款";
    }
    else {
        self.title = @"已付款，未完工";
    }
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC)];
    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
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


- (IBAction)completeAction:(id)sender {
    [self requestPostUpdateStatus];
}

-(void) popToRootVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 发送请求
-(void)requestPostUpdateStatus {       //更新订单状态
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUpdate object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUpdate, @"op", nil];
    
    NSString *statusStr;
    if ([self.statusFlow isEqualToString:@"1"]) {   //先付款，施工完成，至完成页
        statusStr = @"2";    //完工
    }
    else if ([self.statusFlow isEqualToString:@"0"]) {  //先施工，施工完成，至付款页
        statusStr = @"2";   //施工完成
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.checkOrderId,@"id",statusStr,@"status", self.statusFlow,@"statusFlow",nil]; //施工完成
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
            if ([self.statusFlow isEqualToString:@"1"]) {   //先付款，施工完成，至完成页
                AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
                completeVC.statusFlow = self.statusFlow;
                completeVC.checkOrderId = self.checkOrderId;
                completeVC.infoDic = self.infoDic;
                [self.navigationController pushViewController:completeVC animated:YES];
            }
            else if ([self.statusFlow isEqualToString:@"0"]) {  //先施工，施工完成，至付款页
                AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
                orderVC.statusFlow = self.statusFlow;
                orderVC.checkOrderId = self.checkOrderId;
                orderVC.infoDic = self.infoDic;
                [self.navigationController pushViewController:orderVC animated:YES];
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
