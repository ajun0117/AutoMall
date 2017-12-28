//
//  UpkeepOrderVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/30.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepOrderVC.h"
#import "AJSegmentedControl.h"
//#import "BaoyangHistoryCell.h"
#import "UpkeepOrderListCell.h"
#import "AutoCheckResultVC.h"
#import "AutoCheckOrderPayModeVC.h"
#import "AutoCheckOrderVC.h"
#import "AutoCheckOrderCompleteVC.h"
#import "AutoCheckOrderWorkingVC.h"

@interface UpkeepOrderVC () <AJSegmentedControlDelegate,UIScrollViewDelegate>
{
    AJSegmentedControl *mySegmentedControl;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    int currentpage;
    NSMutableArray *orderAry;    //订单列表
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation UpkeepOrderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务订单";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepOrderListCell" bundle:nil] forCellReuseIdentifier:@"upkeepOrderListCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    orderAry = [NSMutableArray array];
    
    [self createSegmentControlWithTitles:@[@{@"name":@"检查完成"}, @{@"name":@"已确认"}, @{@"name":@"已完工"}, @{@"name":@"已付款"}, @{@"name":@"已完成"},@{@"name":@"全部"}]];
    
    if (! self.orderStatus) {
        self.orderStatus = @"";
        [mySegmentedControl changeSegmentedControlWithIndex:5];
    } else {
        [mySegmentedControl changeSegmentedControlWithIndex:[self.orderStatus intValue]];
    }
    
    [self requestGetHistoryList];
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

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [orderAry removeAllObjects];
    [self requestGetHistoryList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetHistoryList];
}

#pragma mark - 自定义segmented
- (void)createSegmentControlWithTitles:(NSArray *)titls
{
    mySegmentedControl = [[AJSegmentedControl alloc] initWithOriginY:64 Titles:titls delegate:self];
    [self.view addSubview:mySegmentedControl];
}

- (void)ajSegmentedControlSelectAtIndex:(NSInteger)index
{
    NSLog(@"index: %ld",(long)index);
    switch (index) {
        case 0: {
            self.orderStatus = @"0";
            break;
        }
        case 1: {
            self.orderStatus = @"1";
            break;
        }
        case 2: {
            self.orderStatus = @"2";
            break;
        }
        case 3: {
            self.orderStatus = @"3";
            break;
        }
        case 4: {
            self.orderStatus = @"5";
            break;
        }
        case 5: {
            self.orderStatus = @"";
            break;
        }
            
        default:
            break;
    }
    currentpage = 0;
    [orderAry removeAllObjects];
    [self requestGetHistoryList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return orderAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UpkeepOrderListCell *cell = (UpkeepOrderListCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepOrderListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = orderAry[indexPath.section];

    int status = [dic[@"paymentStatus"] intValue];
    if (status == 0) {
        cell.statusL.text = @"检查完成";
        [cell.btn setTitle:@"查看报告" forState:UIControlStateNormal];
    } else if (status == 1) {
        cell.statusL.text = @"已确认";
        [cell.btn setTitle:@"下一步" forState:UIControlStateNormal];
    }else if (status == 2) {
        cell.statusL.text = @"已完工";
        [cell.btn setTitle:@"去付款" forState:UIControlStateNormal];
    }else if (status == 3) {
        cell.statusL.text = @"已付款";
        [cell.btn setTitle:@"去施工" forState:UIControlStateNormal];
    }else if (status == 5) {
        cell.statusL.text = @"已完成";
        [cell.btn setTitle:@"去查看" forState:UIControlStateNormal];
    }
    else {
        cell.statusL.text = @"已完成";
        [cell.btn setTitle:@"去查看" forState:UIControlStateNormal];
    }
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"car"][@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
    cell.orderNumberL.text = [NSString stringWithFormat:@"订单号: %@",dic[@"code"]];
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"enterTime"] doubleValue]/1000];
    NSString *string = [formater stringFromDate:creatDate];
    cell.dateL.text = string;

    cell.plateNumberL.text = STRING(dic[@"car"][@"plateNumber"]);
    cell.ownerL.text = STRING(dic[@"car"][@"owner"]);
    cell.allMoneyL.text = dic[@"money"]==[NSNull null] ? @"待确认":[NSString stringWithFormat:@"￥%@",dic[@"money"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = orderAry[indexPath.section];
    int paymentStatusInt = [dic[@"paymentStatus"] intValue];
    if (paymentStatusInt == 0) {   //检查完成
        if (! [dic[@"checkTypeId"] isKindOfClass:[NSNull class]]) {
            AutoCheckResultVC *resultVC = [[AutoCheckResultVC alloc] init];
            resultVC.carUpkeepId = dic[@"id"];
            resultVC.checktypeID = dic[@"checkTypeId"];
            [self.navigationController pushViewController:resultVC animated:YES];
        }
        else {
            _networkConditionHUD.labelText = @"此订单是老数据，因数据不全，不能跳转！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    else if (paymentStatusInt == 1) {   //已确认订单
        AutoCheckOrderPayModeVC *orderVC = [[AutoCheckOrderPayModeVC alloc] init];
        orderVC.checkOrderId = dic[@"id"];
        NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
        orderVC.infoDic = dicc;
        [self.navigationController pushViewController:orderVC animated:YES];
    }
    
    else if (paymentStatusInt == 2) {   //已完工
//        if (! [dic[@"statusFlow"] isKindOfClass:[NSNull class]]) {
//            if ([dic[@"statusFlow"] intValue] == 0) {  //已完工，付款中
                AutoCheckOrderVC *orderVC = [[AutoCheckOrderVC alloc] init];
                orderVC.statusFlow = @"0";
                orderVC.checkOrderId = dic[@"id"];
                NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
                orderVC.infoDic = dicc;
                [self.navigationController pushViewController:orderVC animated:YES];
//            }
//            else if ([dic[@"statusFlow"] intValue] == 1) {  //已完成页面
//                AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
//                completeVC.statusFlow = @"1";
//                completeVC.checkOrderId = dic[@"id"];
//                NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
//                completeVC.infoDic = dicc;
//                [self.navigationController pushViewController:completeVC animated:YES];
//            }
//        }
    }
    
    else if (paymentStatusInt == 3) {   //已付款
//        if (! [dic[@"statusFlow"] isKindOfClass:[NSNull class]]) {
//            if ([dic[@"statusFlow"] intValue] == 1) {  //已付款，施工中
                AutoCheckOrderWorkingVC *workingVC = [[AutoCheckOrderWorkingVC alloc] init];
                workingVC.statusFlow = @"1";
                workingVC.checkOrderId = dic[@"id"];
                NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
                workingVC.infoDic = dicc;
                [self.navigationController pushViewController:workingVC animated:YES];
//            }
//            else if ([dic[@"statusFlow"] intValue] == 0) {  //已完成页面
//                AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
//                completeVC.statusFlow = @"1";
//                completeVC.checkOrderId = dic[@"id"];
//                NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
//                completeVC.infoDic = dicc;
//                [self.navigationController pushViewController:completeVC animated:YES];
//            }
 //       }
    }
    
    else if (paymentStatusInt == 5) {   //已完成
            AutoCheckOrderCompleteVC *completeVC = [[AutoCheckOrderCompleteVC alloc] init];
            completeVC.statusFlow = @"1";
            completeVC.checkOrderId = dic[@"id"];
            NSDictionary *dicc = @{@"orderId":[NSString stringWithFormat:@"%@",dic[@"code"]],@"money":dic[@"money"],@"plateNumber":STRING(dic[@"carPlateNumber"]),@"owner":STRING(dic[@"carOwnerName"])};
            completeVC.infoDic = dicc;
            [self.navigationController pushViewController:completeVC animated:YES];
    }

}

#pragma mark - 发送请求
-(void)requestGetHistoryList { //获取员工保养订单列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepSearch, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@&pageNo=%d&paymentStatus=%@",UrlPrefix(CarUpkeepSearch),userId, currentpage,self.orderStatus];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:CarUpkeepSearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepSearch object:nil];
        NSLog(@"CarUpkeepSearch: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            [orderAry addObjectsFromArray:responseObject[@"data"]];
            [self.myTableView reloadData];
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
