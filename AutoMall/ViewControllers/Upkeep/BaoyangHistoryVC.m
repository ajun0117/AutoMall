//
//  BaoyangHistoryVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "BaoyangHistoryVC.h"
#import "BaoyangHistoryCell.h"
#import "BaoyangHistoryDetailVC.h"

@interface BaoyangHistoryVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *historyArray;
    int currentpage;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation BaoyangHistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.carDic[@"plateNumber"];
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"BaoyangHistoryCell" bundle:nil] forCellReuseIdentifier:@"historyCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    historyArray = [NSMutableArray array];
    
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
    [historyArray removeAllObjects];
    [self requestGetHistoryList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetHistoryList];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return historyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 99;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 10;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 1;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BaoyangHistoryCell *cell = (BaoyangHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (historyArray.count > 0) {
        NSDictionary *dic = historyArray[indexPath.row];
        cell.orderL.text = STRING(dic[@"code"]);
        cell.lichengL.text = [NSString stringWithFormat:@"%@公里", STRING(dic[@"mileage"])];
        NSArray  *ary = dic[@"technicians"];
        if ([ary isKindOfClass:[NSArray class]] && ary.count > 0) {
            cell.technicianName.text = [NSString stringWithFormat:@"%@",STRING([ary firstObject][@"nickname"])];
        }
        else {
            cell.technicianName.text = @"无数据";
        }
        cell.moneyL.text = [NSString stringWithFormat:@"%@ 元",STRING(dic[@"money"])];
        
        if (! [dic[@"enterTime"] isKindOfClass:[NSNull class]]) {
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"enterTime"] doubleValue]/1000];
            NSString *string = [formater stringFromDate:creatDate];
            cell.dateL.text = string;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = historyArray[indexPath.row];
    
    if (! [dic[@"checkTypeId"] isKindOfClass:[NSNull class]]) {
        BaoyangHistoryDetailVC *detailVC = [[BaoyangHistoryDetailVC alloc] init];
//        detailVC.carDic = dic[@"car"];
//        detailVC.mileage = dic[@"mileage"];
//        detailVC.fuelAmount = dic[@"fuelAmount"];
//        detailVC.lastEndTime = dic[@"lastEndTime"];
//        detailVC.lastMileage = STRING(dic[@"lastMileage"]);
        detailVC.carUpkeepId = dic[@"id"];
//        detailVC.checktypeID = dic[@"checkTypeId"];
//        detailVC.checktypeName = dic[@"checkTypeName"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else {
        _networkConditionHUD.labelText = @"此订单是老数据，因数据不全，不能跳转！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

#pragma mark - 发送请求
-(void)requestGetHistoryList { //获取车辆保养历史信息记录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepSearch, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?carId=%@&pageNo=%d&paymentStatus=1,2,3,4,5",UrlPrefix(CarUpkeepSearch),self.carDic[@"id"], currentpage];
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
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            if ([responseObject[@"data"] count] == 0) {
                _networkConditionHUD.labelText = @"没有更多了";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            }
            [historyArray addObjectsFromArray:responseObject[@"data"]];
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
