//
//  UpkeepOrderVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/30.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepOrderVC.h"
#import "AJSegmentedControl.h"
#import "BaoyangHistoryCell.h"

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
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"BaoyangHistoryCell" bundle:nil] forCellReuseIdentifier:@"historyCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    orderAry = [NSMutableArray array];
    
    if (! self.orderStatus) {
        self.orderStatus = @"0";
    }
    [self requestGetHistoryList];
    
    [self createSegmentControlWithTitles:@[@{@"name":@"检查完成"}, @{@"name":@"订单确认"}, @{@"name":@"施工完成"}, @{@"name":@"已付款"}, @{@"name":@"已完成"}]];
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
            self.orderStatus = @"4";
            break;
        }
//        case 5: {
//            self.orderStatus = @"";
//            break;
//        }
            
        default:
            break;
    }
    [self requestGetHistoryList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return orderAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
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
    NSDictionary *dic = orderAry[indexPath.row];
    cell.lichengL.text = [NSString stringWithFormat:@"%@公里",dic[@""]];
    cell.ranyouL.text = [NSString stringWithFormat:@"%@L",dic[@""]];
    cell.ownerL.text = dic[@"carOwnerName"];
    cell.dateL.text = dic[@"endTime"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestGetHistoryList { //获取车辆保养历史信息记录
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
