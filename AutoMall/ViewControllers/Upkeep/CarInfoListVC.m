//
//  CarInfoListVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CarInfoListVC.h"
#import "CarInfoListCell.h"
#import "CarInfoSearchVC.h"
#import "BaoyangHistoryVC.h"

@interface CarInfoListVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *carArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UITableView *infoTableView;

@end

@implementation CarInfoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"车辆信息";
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CarInfoListCell" bundle:nil] forCellReuseIdentifier:@"carInfoCell"];
    self.infoTableView.tableFooterView = [UIView new];
    
    [self.infoTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.infoTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    carArray = [NSMutableArray array];
    
    [self.infoTableView headerBeginRefreshing];
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
    [carArray removeAllObjects];
    [self requestGetCarList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetCarList];
}

-(void) toSearch {  //搜索车辆保养记录
    CarInfoSearchVC *searchVC = [[CarInfoSearchVC alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return carArray.count;
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
    CarInfoListCell *cell = (CarInfoListCell *)[tableView dequeueReusableCellWithIdentifier:@"carInfoCell"];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = carArray[indexPath.row];
    cell.plateNumberL.text = dic[@"plateNumber"];
    cell.ownerL.text = dic[@"owner"];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"updateTime"] doubleValue]/1000];
    NSString *string = [formater stringFromDate:creatDate];
    cell.dateL.text = string;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        BaoyangHistoryVC *detailVC = [[BaoyangHistoryVC alloc] init];
//        detailVC.userID = userArray[indexPath.section][@"id"];
//        detailVC.isDrink = self.isDrink;
//        detailVC.slidePlaceDetail = self.slidePlaceDetail;
        [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestGetCarList { //获取车辆信息列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarListOrSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarListOrSearch, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?pageNo=%d",UrlPrefix(CarListOrSearch),currentpage];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.infoTableView headerEndRefreshing];
    [self.infoTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:CarListOrSearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarListOrSearch object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            [carArray addObjectsFromArray:responseObject[@"data"]];
            [self.infoTableView reloadData];
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
