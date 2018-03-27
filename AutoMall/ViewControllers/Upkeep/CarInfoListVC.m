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
#import "CarInfoAddVC.h"

@interface CarInfoListVC () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *carArray;
    int currentpage;
    NSString *paramsUrl;
}
@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet UITableView *infoTableView;

@end

@implementation CarInfoListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"车辆列表";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 110, 40)];
    titleL.text = @"车辆列表";
    titleL.font = [UIFont boldSystemFontOfSize:17];
    titleL.textAlignment = NSTextAlignmentRight;
    [view addSubview:titleL];
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(110, 2, 40, 40);
    [photoBtn setImage:[UIImage imageNamed:@"downloadCarInfo"] forState:UIControlStateNormal];
    //    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [photoBtn addTarget:self action:@selector(toDownloadCarInfo) forControlEvents:UIControlEventTouchUpInside];
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if ([mobileUserType isEqualToString:@"1"]) {  //门店老板
        [view addSubview:photoBtn];
    }
    self.navigationItem.titleView = view;
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 2, 80, 40);
    [addBtn setTitle:@"新增车辆" forState:UIControlStateNormal];
    [addBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(toRegisterNewCarInfo) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
//    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"新增车辆" style:UIBarButtonItemStylePlain target:self action:@selector(toRegisterNewCarInfo)];
    self.navigationItem.rightBarButtonItem = addBtnBarBtn;
//    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
    
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
//
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchBtn.frame = CGRectMake(0, 0, 30, 30);
//    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
////    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, addBtnBarBtn, searchBtnBarBtn, nil];
    
    [self.infoTableView registerNib:[UINib nibWithNibName:@"CarInfoListCell" bundle:nil] forCellReuseIdentifier:@"carInfoCell"];
    self.infoTableView.tableFooterView = [UIView new];
    
    [self.infoTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.infoTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
//    currentpage = 0;
//    carArray = [NSMutableArray array];
//    [self requestGetCarList];
//    [self.infoTableView headerBeginRefreshing];
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
    
    currentpage = 0;
    carArray = [NSMutableArray array];
    [self requestGetCarList];
}

-(void) toDownloadCarInfo {
//    [self requestPostDownLoadCarList];
    NSLog(@"toDownloadCarInfo");
//    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSString *paramsUrlStr = UrlPrefix(paramsUrl);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在电脑浏览器中输入以下网址下载数据" message:paramsUrlStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"复制", nil];
    alert.tag = 1002;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 1002) {
        //下面方法可以将文本复制到剪切板
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = alertView.message;
        
        _networkConditionHUD.labelText = @"已复制到剪切板";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void) toRegisterNewCarInfo {
    CarInfoAddVC *addVC = [[CarInfoAddVC alloc] init];
//    addVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//        self.GoBackSelectCarDic(carDic);
//        self.carId = carDic[@"id"];
//        [self.infoTableView headerBeginRefreshing];
//    };
//    addVC.GoBackAddedCarDic = ^{
//        [self.infoTableView headerBeginRefreshing];
//    };
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - 搜索条
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    CarInfoSearchVC *searchVC = [[CarInfoSearchVC alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];
    return NO;
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
//    searchVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//        self.GoBackSelectCarDic(carDic);      //传参至保养首页
//        self.carId = carDic[@"id"];
//        [self.infoTableView reloadData];
//    };
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
    if (carArray.count > 0) {
        NSDictionary *dic = carArray[indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
        cell.plateNumberL.text = dic[@"plateNumber"];
        cell.ownerL.text = dic[@"owner"];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd"];
        NSDate *creatDate;
        NSArray *carUpKeepsAry = dic[@"carUpKeeps"];
        if (carUpKeepsAry.count == 1) {
            creatDate = [NSDate dateWithTimeIntervalSince1970:[[carUpKeepsAry firstObject][@"lastEndTime"] doubleValue]/1000];
            NSString *string = [formater stringFromDate:creatDate];
            cell.dateL.text = string;
        }
        else {
            cell.dateL.text = @"";
        }
        
        cell.selectBtn.tag = indexPath.row + 100;
        [cell.selectBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [cell.selectBtn addTarget:self action:@selector(selectTheCar:) forControlEvents:UIControlEventTouchUpInside];
        if ([dic[@"id"] intValue] == [self.carId intValue]) {
            cell.selectBtn.selected = YES;
        }
        else {
            cell.selectBtn.selected = NO;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = carArray[indexPath.row];
    CarInfoAddVC *editVC = [[CarInfoAddVC alloc] init];
    editVC.carDic = dic;
//    editVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//        self.GoBackSelectCarDic(carDic);
//        self.carId = carDic[@"id"];
//        [self.infoTableView reloadData];
//    };
//    editVC.GoBackAddedCarDic = ^{
//        [self.infoTableView headerBeginRefreshing];
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
-(void)requestGetCarList { //获取车辆信息列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarListOrSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarListOrSearch, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?pageNo=%d",UrlPrefix(CarListOrSearch),currentpage];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo", nil];
//    NSLog(@"pram: %@",pram);
//    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarListOrSearch) delegate:nil params:pram info:infoDic];
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
        NSLog(@"CarListOrSearch: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            [carArray addObjectsFromArray:responseObject[@"data"]];
            if (! [responseObject[@"params"] isKindOfClass:[NSNull class]]) {
                paramsUrl = responseObject[@"params"][@"exportCarUrl"];
            }
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
