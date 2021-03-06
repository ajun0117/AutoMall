//
//  AutoCheckOrderCompleteVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckOrderCompleteVC.h"
#import "AutoCheckResultVC.h"
#import "BaoyangHistoryDetailVC.h"

@interface AutoCheckOrderCompleteVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UIView *contentV;
@property (strong, nonatomic) IBOutlet UILabel *orderNumberL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet UILabel *chepaiL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;
@property (weak, nonatomic) IBOutlet UIButton *baogaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *fanganBtn;

@end

@implementation AutoCheckOrderCompleteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单已完成";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC)];
    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toCheckResultVC)];
//    [self.contentV addGestureRecognizer:tap];
    
    self.baogaoBtn.layer.cornerRadius = 5;
    self.baogaoBtn.layer.borderWidth = 1;
    self.baogaoBtn.layer.borderColor = Cell_sepLineColor.CGColor;
    
    self.fanganBtn.layer.cornerRadius = 5;
    self.fanganBtn.layer.borderWidth = 1;
    self.fanganBtn.layer.borderColor = Cell_sepLineColor.CGColor;
    
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

- (IBAction)baogaoAction:(id)sender {
    AutoCheckResultVC *resultVC = [[AutoCheckResultVC alloc] init];
    resultVC.carUpkeepId = self.checkOrderId;
    resultVC.checktypeID = self.infoDic[@"checktypeID"];
    resultVC.isFromAffirm = YES;
    resultVC.isFromList = YES;
    [self.navigationController pushViewController:resultVC animated:YES];
}
- (IBAction)fanganAction:(id)sender {
    BaoyangHistoryDetailVC *detailVC = [[BaoyangHistoryDetailVC alloc] init];
    detailVC.carUpkeepId = self.checkOrderId;
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void) toCheckResultVC {
    AutoCheckResultVC *resultVC = [[AutoCheckResultVC alloc] init];
    resultVC.carUpkeepId = self.checkOrderId;
    resultVC.checktypeID = self.infoDic[@"checktypeID"];
    resultVC.isFromAffirm = YES;
    resultVC.isFromList = YES;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (IBAction)confirmAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.checkOrderId,@"id",@"5",@"status", self.statusFlow,@"statusFlow",nil]; //已完成
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
            [self.navigationController popToRootViewControllerAnimated:YES];    //返回root
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
