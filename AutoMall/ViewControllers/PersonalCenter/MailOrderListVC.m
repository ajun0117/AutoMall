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
#import "InvoiceManageVC.h"
#import "MallOrderInvoiceDetailVC.h"

@interface MailOrderListVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *orderArray;
    int currentpage;
    NSMutableDictionary *selectedInvoiceDic;    //选中的需要开发票的订单
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderSingleCell" bundle:nil] forCellReuseIdentifier:@"mailOrderSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderMultiCell" bundle:nil] forCellReuseIdentifier:@"mailOrderMultiCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    orderArray = [NSMutableArray array];
    currentpage = 0;
    selectedInvoiceDic = [NSMutableDictionary dictionary];
    
    if ([self.orderStatus isEqualToString:@"0"]) {
        [self daifuAction:self.daifuBtn];
    }
    else if ([self.orderStatus isEqualToString:@"1"]) {
        [self yifuAction:self.yifuBtn];
    }
    else if ([self.orderStatus isEqualToString:@"-1"]) {   //已取消
        [self cancelAction:self.cancelBtn];
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
    self.navigationItem.rightBarButtonItem = nil;
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:YES andView:self.daifuView withColor:Red_BtnColor];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.cancelBtn withBool:NO andView:self.cancelView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
    [self requestGetMallOrderList];
}

- (IBAction)yifuAction:(id)sender {
    _orderStatus = @"1";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 2, 60, 40);
    [btn setTitle:@"开发票" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toInvoiceManageVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backBtn;
    
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
    [self setButton:self.yifuBtn withBool:YES andView:self.yifuView withColor:Red_BtnColor];
    [self setButton:self.cancelBtn withBool:NO andView:self.cancelView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
    [self requestGetMallOrderList];
}

- (IBAction)cancelAction:(id)sender {
    _orderStatus = @"-1";
    self.navigationItem.rightBarButtonItem = nil;
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.cancelBtn withBool:YES andView:self.cancelView withColor:Red_BtnColor];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
    [self requestGetMallOrderList];
}

- (IBAction)allAction:(id)sender {
    _orderStatus = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [orderArray removeAllObjects];
    [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.cancelBtn withBool:NO andView:self.cancelView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:YES andView:self.allView withColor:Red_BtnColor];
    [self requestGetMallOrderList];
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
        btn.selected = bo;
        view.backgroundColor = color;
}

#pragma mark - 复选框开发票
-(void)checkToInvoice:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSInteger section = btn.tag - 100;
    NSDictionary *dic = orderArray [section];
    if (btn.selected) {
        [selectedInvoiceDic setObject:dic forKey:dic[@"id"]];
    }
    else {
        [selectedInvoiceDic removeObjectForKey:dic[@"id"]];
    }
    NSLog(@"selectedInvoiceDic: %@",selectedInvoiceDic)
}

-(void)toInvoiceManageVC {      //去开发票页面
    if ([[selectedInvoiceDic allKeys] count] > 0) {
        InvoiceManageVC *invoiceVC = [[InvoiceManageVC alloc] init];
        invoiceVC.orderType = @"0";     //0 商城订单,1 保养订单
        invoiceVC.orderDic = selectedInvoiceDic;
        [self.navigationController pushViewController:invoiceVC animated:YES];
    } else {
        _networkConditionHUD.labelText = @"请先勾选需要开发票的订单！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void)toInvoiceetailVC:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSInteger section = btn.tag - 200;
    NSDictionary *dic = orderArray[section];
    MallOrderInvoiceDetailVC *detailVC = [[MallOrderInvoiceDetailVC alloc] init];
    detailVC.orderId = dic[@"id"];
    [self.navigationController pushViewController:detailVC animated:YES];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.checkboxBtn.hidden = YES;
        cell.picScrollView.contentSize = CGSizeMake((60+10) * goodsAry.count, 60);
        int amount = 0;
        for (int i = 0; i < goodsAry.count; ++i) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(i*(60+10), 0, 60, 60)];
            [img sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(goodsAry[i][@"commodityImage"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            [cell.picScrollView addSubview:img];
            amount += [goodsAry[i][@"commodityAmount"] intValue];
        }
        int status = [dic[@"orderStatus"] intValue];
        if (status == 0) {
            cell.statusL.text = @"待付款";
            cell.btn.hidden = NO;
            [cell.btn setTitle:@"去付款" forState:UIControlStateNormal];
        } else if (status == 1) {
            cell.statusL.text = @"已付款";
            cell.btn.hidden = YES;
//            [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
            cell.checkboxBtn.hidden = NO;
            if ([dic[@"invoiced"] boolValue]) {     //如果已开发票
                cell.invoicedBtn.hidden = NO;
                cell.invoicedBtn.tag = indexPath.section + 200;
                [cell.invoicedBtn addTarget:self action:@selector(toInvoiceetailVC:) forControlEvents:UIControlEventTouchUpInside];
                cell.checkboxBtn.enabled = NO;
            }
            else {
                cell.invoicedBtn.hidden = YES;
                cell.checkboxBtn.enabled = YES;
                cell.checkboxBtn.tag = indexPath.section + 100;
                [cell.checkboxBtn addTarget:self action:@selector(checkToInvoice:) forControlEvents:UIControlEventTouchUpInside];
                NSArray *keys = [selectedInvoiceDic allKeys];
                if ([keys containsObject:dic[@"id"]]) {
                    cell.checkboxBtn.selected = YES;
                } else {
                    cell.checkboxBtn.selected = NO;
                }
            }
        } else if (status == -1) {
            cell.statusL.text = @"已取消";
            cell.btn.hidden = YES;
            //            [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
        }
        else {
            cell.statusL.text = @"已完成";
            cell.btn.hidden = YES;
//            [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
        }
        cell.numberL.text = [NSString stringWithFormat:@"%d",amount];
        cell.allMoneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"totalPrice"]];
        return cell;
    }
    
    MailOrderSingleCell *cell = (MailOrderSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderSingleCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.checkboxBtn.hidden = YES;
    NSDictionary *detailDic = [goodsAry firstObject];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(detailDic[@"commodityImage"])] placeholderImage:IMG(@"placeholderPictureSquare")];
    cell.nameL.text = detailDic[@"commodityName"];
    if ([detailDic[@"actualPrice"] intValue] > 0) {
        cell.UnitPriceL.text = [NSString stringWithFormat:@"￥%@", detailDic[@"actualPrice"]];
    } else {
        cell.UnitPriceL.text = [NSString stringWithFormat:@"￥%@", detailDic[@"commodityPrice"]];
    }
    
    cell.numL.text = [NSString stringWithFormat:@"x%@", detailDic[@"commodityAmount"]];
    int amount = 0;
    for (int i = 0; i < goodsAry.count; ++i) {
        amount += [goodsAry[i][@"commodityAmount"] intValue];
    }
    int status = [dic[@"orderStatus"] intValue];
    if (status == 0) {
        cell.statusL.text = @"待付款";
        cell.btn.hidden = NO;
        [cell.btn setTitle:@"去付款" forState:UIControlStateNormal];
    } else if (status == 1) {
        cell.statusL.text = @"已付款";
        cell.btn.hidden = YES;
//        [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
        cell.checkboxBtn.hidden = NO;
        if ([dic[@"invoiced"] boolValue]) {     //如果已开发票
            cell.invoicedBtn.hidden = NO;
            cell.invoicedBtn.tag = indexPath.section + 200;
            [cell.invoicedBtn addTarget:self action:@selector(toInvoiceetailVC:) forControlEvents:UIControlEventTouchUpInside];
            cell.checkboxBtn.enabled = NO;
        }
        else {
            cell.invoicedBtn.hidden = YES;
            cell.checkboxBtn.enabled = YES;
            cell.checkboxBtn.tag = indexPath.section + 100;
            [cell.checkboxBtn addTarget:self action:@selector(checkToInvoice:) forControlEvents:UIControlEventTouchUpInside];
            NSArray *keys = [selectedInvoiceDic allKeys];
            if ([keys containsObject:dic[@"id"]]) {
                cell.checkboxBtn.selected = YES;
            } else {
                cell.checkboxBtn.selected = NO;
            }
        }
    } else if (status == -1) {
        cell.statusL.text = @"已取消";
        cell.btn.hidden = YES;
        //        [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
    }
    else {
        cell.statusL.text = @"已完成";
        cell.btn.hidden = YES;
//        [cell.btn setTitle:@"再次购买" forState:UIControlStateNormal];
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
            if (orderArray.count == 0) {
                _networkConditionHUD.labelText = @"暂无相关订单";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            }
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
