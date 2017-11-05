//
//  MailSearchVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/17.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailSearchVC.h"
#import "CommodityListCell.h"
#import "CommodityDetailVC.h"

@interface MailSearchVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    int currentpage;
    NSMutableArray *resultArray;
}
@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商品搜索";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityListCell" bundle:nil] forCellReuseIdentifier:@"commodityListCell"];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    resultArray = [NSMutableArray array];
    currentpage = 0;
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
    [resultArray removeAllObjects];
    [self requestSearchCommodityList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestSearchCommodityList];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    currentpage = 0;
    [resultArray removeAllObjects];
    [self requestSearchCommodityList];
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [resultArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommodityListCell *cell = (CommodityListCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = resultArray [indexPath.section];
    [cell.goodsIM sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"default")];
    cell.goodsNameL.text = dic [@"name"];
    //        cell.baokuanL.text =
    //        cell.tuijianL.text =
    //        cell.zhekouL.text =
    cell.pingxingView.rate = [dic [@"starLevel"] floatValue] / 2;
    cell.xiaoliangL.text = [NSString stringWithFormat:@"月销%@单",dic [@"salesVolume"]];
    cell.jifenL.text =  [NSString stringWithFormat:@"%@积分",dic[@"integral"]];
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if ([mobileUserType isEqualToString:@"1"]) {    //老板
        if ([dic[@"discount"] intValue] > 0) {
            cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"discount"]];
            cell.costPriceStrikeL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
        } else {
            cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
            cell.costPriceStrikeL.text = @"";
            cell.zhekouL.hidden = YES;
        }
        cell.yunfeiL.text = [NSString stringWithFormat:@"配送费%@元",dic[@"shippingFee"]];
    }
    else {
        if ([dic[@"discount"] intValue] > 0) {
            cell.moneyL.text = @"￥--";
            cell.costPriceStrikeL.text = @"￥--";
        } else {
            cell.moneyL.text = @"￥--";
            cell.costPriceStrikeL.text = @"";
            cell.zhekouL.hidden = YES;
        }
        cell.yunfeiL.text = @"配送费--元";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
    detailVC.commodityId = resultArray[indexPath.section][@"id"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestSearchCommodityList { //搜索商品列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CommoditySearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CommoditySearch, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo",self.mySearchBar.text,@"tagOrName", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CommoditySearch) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:CommoditySearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CommoditySearch object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [resultArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
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
