//
//  StoreServiceVC.m
//  AutoMall
//
//  Created by LYD on 2017/11/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "StoreServiceVC.h"
#import "UpKeepPlanServiceCell.h"
#import "AddStoreServiceVC.h"

@interface StoreServiceVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *serviceArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation StoreServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"门店服务";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    //    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"添加" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toAddDiscounts) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpKeepPlanServiceCell" bundle:nil] forCellReuseIdentifier:@"upKeepPlanServiceCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    serviceArray = [NSMutableArray array];
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
    
//    [self.myTableView headerBeginRefreshing];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [serviceArray removeAllObjects];
//    [self requestPostDiscountList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
//    [self requestPostDiscountList];
}


-(void) toAddDiscounts {
    AddStoreServiceVC *addVC = [[AddStoreServiceVC alloc] init];
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

//- (IBAction)saveAction:(id)sender {
//
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return serviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UpKeepPlanServiceCell *cell = (UpKeepPlanServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"upKeepPlanServiceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = serviceArray[indexPath.row];
    cell.declareL.text = dic[@"item"];
    if (dic[@"money"]) {
        cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"money"]];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dic = serviceArray[indexPath.row];
        [self deleteDiscountWithId:dic[@"id"]];
        [serviceArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
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
-(void)requestPostDiscountList { //优惠列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DiscountList object:nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DiscountList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:storeId,@"storeId",[NSNumber numberWithInt:currentpage],@"pageNo", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(DiscountList) delegate:nil params:pram info:infoDic];
}

-(void)deleteDiscountWithId:(NSString *)did {     //删除优惠
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DiscountDel object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DiscountDel, @"op", nil];
    //    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    //    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId",aid,@"id", nil];
    //    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ConsigneeDele) delegate:nil params:pram info:infoDic];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(DiscountDel),did];
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
    if ([notification.name isEqualToString:DiscountList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DiscountList object:nil];
        NSLog(@"DiscountList: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [serviceArray addObjectsFromArray:responseObject[@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:DiscountDel]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DiscountDel object:nil];
        NSLog(@"DiscountDel: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
