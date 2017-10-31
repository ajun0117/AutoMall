//
//  MailOrderListVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailOrderListVC.h"
#import "MailOrderSingleCell.h"
#import "MailOrderMultiCell.h"
#import "MailOrderDetailVC.h"

@interface MailOrderListVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *orderArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商城订单";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderSingleCell" bundle:nil] forCellReuseIdentifier:@"mailOrderSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderMultiCell" bundle:nil] forCellReuseIdentifier:@"mailOrderMultiCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    orderArray = [NSMutableArray array];
    currentpage = 0;
    
    if ([self.orderStatus isEqualToString:@"0"]) {
        [self daifuAction:self.daifuBtn];
    }
    else if ([self.orderStatus isEqualToString:@"1"]) {
        [self yifuAction:self.yifuBtn];
    }
    else {
        [self allAction:self.allBtn];
    }
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
    [orderArray removeAllObjects];
    [self requestGetMallOrderList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetMallOrderList];
}


- (IBAction)daifuAction:(id)sender {
    _orderStatus = @"0";
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:YES andView:self.daifuView withColor:Red_BtnColor];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
    [self requestGetMallOrderList];
}

- (IBAction)yifuAction:(id)sender {
    _orderStatus = @"1";
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
    [self setButton:self.yifuBtn withBool:YES andView:self.yifuView withColor:Red_BtnColor];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
    [self requestGetMallOrderList];
}

- (IBAction)allAction:(id)sender {
    _orderStatus = nil;
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:YES andView:self.allView withColor:Red_BtnColor];
    [self requestGetMallOrderList];
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
        btn.selected = bo;
        view.backgroundColor = color;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return orderArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 178;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = orderArray[indexPath.section];
    NSArray *goodsAry = dic[@"orderDetails"];
    if (goodsAry.count > 1) {   //多商品订单
        MailOrderMultiCell *cell = (MailOrderMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderMultiCell"];
        cell.picScrollView.contentSize = CGSizeMake((60+10) * 3, 60);
        int amount = 0;
        for (int i = 0; i < goodsAry.count; ++i) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(i*(60+10), 0, 60, 60)];
            [img sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(goodsAry[i][@"commodityImage"])] placeholderImage:IMG(@"default")];
            [cell.picScrollView addSubview:img];
            amount += [goodsAry[i][@"commodityAmount"] intValue];
        }
        int status = [dic[@"orderStatus"] intValue];
        if (status == 0) {
            cell.statusL.text = @"待付款";
            [cell.btn setTitle:@"去付款" forState:UIControlStateNormal];
        } else if (status == 1) {
            cell.statusL.text = @"已付款";
            [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
        }
        else {
            cell.statusL.text = @"已完成";
            [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
        }
        cell.numberL.text = [NSString stringWithFormat:@"%d",amount];
        cell.allMoneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"totalPrice"]];
        return cell;
    }
    
    MailOrderSingleCell *cell = (MailOrderSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderSingleCell"];
    NSDictionary *detailDic = [goodsAry firstObject];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(detailDic[@"commodityImage"])] placeholderImage:IMG(@"default")];
    cell.nameL.text = detailDic[@"commodityName"];
    cell.UnitPriceL.text = [NSString stringWithFormat:@"￥%@", detailDic[@"actualPrice"]];
    cell.numL.text = [NSString stringWithFormat:@"x%@", detailDic[@"commodityAmount"]];
    int amount = 0;
    for (int i = 0; i < goodsAry.count; ++i) {
        amount += [goodsAry[i][@"commodityAmount"] intValue];
    }
    int status = [dic[@"orderStatus"] intValue];
    if (status == 0) {
        cell.statusL.text = @"待付款";
        [cell.btn setTitle:@"去付款" forState:UIControlStateNormal];
    } else if (status == 1) {
        cell.statusL.text = @"已付款";
        [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
    }
    else {
        cell.statusL.text = @"已完成";
        [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
    }
    cell.numberL.text = [NSString stringWithFormat:@"%d",amount];
    cell.allMoneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"totalPrice"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MailOrderDetailVC *detailVC = [[MailOrderDetailVC alloc] init];
    detailVC.orderId = orderArray[indexPath.section][@"id"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestGetMallOrderList { //获取商城订单列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderList object:nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderList, @"op", nil];
//    NSString *urlString = [NSString stringWithFormat:@"%@?clientId=%@&pageNo=%d",UrlPrefix(MallOrderList),userId,currentpage];
//    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"clientId",[NSNumber numberWithInt:currentpage],@"pageNo",_orderStatus,@"orderStatus", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(MallOrderList) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:MallOrderList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderList object:nil];
        NSLog(@"MallOrderList: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [orderArray addObjectsFromArray:responseObject [@"data"]];
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
