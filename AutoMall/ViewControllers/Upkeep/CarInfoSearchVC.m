//
//  CarInfoSearchVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CarInfoSearchVC.h"
#import "CarInfoListCell.h"
//#import "AddCarInfoVC.h"
#import "CarInfoAddVC.h"

@interface CarInfoSearchVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *carArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;

@end

@implementation CarInfoSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"车辆搜索";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                       target:nil action:nil];
//    negativeSpacer.width = -6;
//    
//    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    addBtn.frame = CGRectMake(0, 0, 28, 28);
//    [addBtn setImage:[UIImage imageNamed:@"add_carInfo"] forState:UIControlStateNormal];
////    [addBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [addBtn addTarget:self action:@selector(toRegisterNewCarInfo) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *addBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, addBtnBarBtn, nil];
    
    [self.searchTableView registerNib:[UINib nibWithNibName:@"CarInfoListCell" bundle:nil] forCellReuseIdentifier:@"carInfoCell"];
    self.searchTableView.tableFooterView = [UIView new];
    
    [self.searchTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.searchTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    carArray = [NSMutableArray array];
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

-(void) toRegisterNewCarInfo {
    CarInfoAddVC *addVC = [[CarInfoAddVC alloc] init];
//    addVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//        self.GoBackSelectCarDic(carDic);
//    };
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [carArray removeAllObjects];
    [self requestSearchCarList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestSearchCarList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    currentpage = 0;
    [carArray removeAllObjects];
    [self requestSearchCarList];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    currentpage = 0;
    [carArray removeAllObjects];
    [self requestSearchCarList];
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
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
    cell.plateNumberL.text = dic[@"plateNumber"];
    cell.ownerL.text = dic[@"owner"];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"updateTime"] doubleValue]/1000];
    NSString *string = [formater stringFromDate:creatDate];
    cell.dateL.text = string;
    cell.selectBtn.tag = indexPath.row + 100;
    [cell.selectBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [cell.selectBtn addTarget:self action:@selector(selectTheCar:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.mySearchBar resignFirstResponder];
    
    NSDictionary *dic = carArray[indexPath.row];
    CarInfoAddVC *editVC = [[CarInfoAddVC alloc] init];
    editVC.carDic = dic;
//    editVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//        self.GoBackSelectCarDic(carDic);
//    };
//    editVC.GoBackAddedCarDic = ^{
//        self.GoBackSelectCarDic(nil);
//    };
    
    [self.navigationController pushViewController:editVC animated:YES];
}

-(void)selectTheCar:(UIButton *)btn {
    btn.selected = YES;
    NSInteger row = btn.tag - 100;
    NSDictionary *dic = carArray[row];
//    self.GoBackSelectCarDic(dic);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectedCar" object:nil userInfo:dic];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 发送请求
-(void)requestSearchCarList { //获取车辆信息列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarListOrSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarListOrSearch, @"op", nil];
//    NSString *urlString = [NSString stringWithFormat:@"%@?keyword=%@&pageNo=%d",UrlPrefix(CarListOrSearch),self.mySearchBar.text,currentpage];
//    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.mySearchBar.text,@"keyword",[NSNumber numberWithInt:currentpage],@"pageNo", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarListOrSearch) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.searchTableView headerEndRefreshing];
    [self.searchTableView footerEndRefreshing];
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
            [self.searchTableView reloadData];
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
