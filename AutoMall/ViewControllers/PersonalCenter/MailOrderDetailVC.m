//
//  MailOrderDetailVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailOrderDetailVC.h"
#import "MailOrderDetailTopCell.h"
#import "MailOrderDetailSendStyleCell.h"
#import "MailOrderDetailWaybillCell.h"
#import "MailOrderDetailReceiverInfoCell.h"
#import "MailOrderDetailGoodsCell.h"
#import "MailOrderDetailTotalMoneyCell.h"
#import "CommodityDetailVC.h"
#import "MetodPaymentVC.h"

@interface MailOrderDetailVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *orderDetailDic;
}
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation MailOrderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单详情";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.statusBtn.layer.cornerRadius = 2;
    self.statusBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.statusBtn.layer.borderWidth = 1;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailTopCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailTopCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailSendStyleCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailSendStyleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailWaybillCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailWaybillCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailReceiverInfoCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailReceiverInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailGoodsCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailGoodsCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderDetailTotalMoneyCell" bundle:nil] forCellReuseIdentifier:@"mailOrderDetailTotalMoneyCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self requestGetMallOrderDetail];   //获取订单详情数据
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

- (IBAction)statusAction:(id)sender {
    int status = [orderDetailDic[@"orderStatus"] intValue];
    if (status == 0) {  //未付款时隐藏物流信息
        MetodPaymentVC *pay = [[MetodPaymentVC alloc] init];
        pay.orderNumber = orderDetailDic[@"code"];
        pay.money = [orderDetailDic[@"actualPrice"] floatValue];
        [self.navigationController pushViewController:pay animated:YES];
    }
    else if (status == 1) {
    }
    else {
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
       detailVC.commodityId = orderDetailDic[@"orderDetails"][@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1: {
            int status = [orderDetailDic[@"orderStatus"] intValue];
            if (status == 0) {  //未付款时隐藏物流信息
                return 1;
            }
            else {
                return 4;
            }
            break;
        }
            
        case 2:
            return [orderDetailDic[@"orderDetails"] count];
            break;
            
        case 3:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return 44;
            break;
        }
        case 1: {
            int status = [orderDetailDic[@"orderStatus"] intValue];
            if (status == 0) {  //未付款时隐藏物流信息
                return 80;
            }
            else {
                if (indexPath.row == 3) {
                    return 80;
                }
                return 44;
            }
            break;
        }
        case 2: {
            return 75;
            break;
        }
        case 3: {
            if (indexPath.row == 2) {
                return 58;
            }
            return 44;
            break;
        }
        default:
            return 0;
            break;
    }
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
    switch (indexPath.section) {
        case 0: {
            MailOrderDetailTopCell *cell = (MailOrderDetailTopCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailTopCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.nameL.text = [NSString stringWithFormat:@"订单号：%@",orderDetailDic[@"code"]];
            int status = [orderDetailDic[@"orderStatus"] intValue];
            if (status == 0) {  //未付款时隐藏物流信息
                cell.contentL.text = @"待付款";
            }
            else if (status == 1) {
                cell.contentL.text = @"已付款";
            }
            else {
                cell.contentL.text = @"已完成";
            }
            return cell;
            break;
        }
        case 1: {
            int status = [orderDetailDic[@"orderStatus"] intValue];
            if (status == 0) {  //未付款时隐藏物流信息
                MailOrderDetailReceiverInfoCell *cell = (MailOrderDetailReceiverInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailReceiverInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameL.text = orderDetailDic[@"consigneeName"];
                cell.phoneL.text = NSStringWithNumber(orderDetailDic[@"consigneePhone"]);
                cell.addressL.text = [NSString stringWithFormat:@"%@%@%@%@",orderDetailDic[@"consigneeProvince"],orderDetailDic[@"consigneeCity"],orderDetailDic[@"consigneeCounty"],orderDetailDic[@"consigneeAddress"]];
                return cell;
            }
            else {
                if (indexPath.row == 0) {
                    MailOrderDetailSendStyleCell *cell = (MailOrderDetailSendStyleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailSendStyleCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.styleL.text = @"配送方式";
                    cell.contentL.text = orderDetailDic[@"deliveryMode"];
                    return cell;
                }
                else if (indexPath.row == 1) {
                    MailOrderDetailWaybillCell *cell = (MailOrderDetailWaybillCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailWaybillCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.nameL.text = @"物流公司: ";
                    cell.contentL.text = orderDetailDic[@"deliveryAgentName"];
                    return cell;
                }
                else if (indexPath.row == 2) {
                    MailOrderDetailWaybillCell *cell = (MailOrderDetailWaybillCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailWaybillCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.nameL.text = @"运单编号: ";
                    cell.contentL.text = NSStringWithNumber(orderDetailDic[@"code"]);   //收货人订单号
                    return cell;
                }
                else if (indexPath.row == 3) {
                    MailOrderDetailReceiverInfoCell *cell = (MailOrderDetailReceiverInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailReceiverInfoCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.nameL.text = orderDetailDic[@"consigneeName"];
                    cell.phoneL.text = NSStringWithNumber(orderDetailDic[@"consigneePhone"]);
                    cell.addressL.text = [NSString stringWithFormat:@"%@%@%@%@",orderDetailDic[@"consigneeProvince"],orderDetailDic[@"consigneeCity"],orderDetailDic[@"consigneeCounty"],orderDetailDic[@"consigneeAddress"]];
                    return cell;
                }
            }
            break;
        }
        case 2: {
            MailOrderDetailGoodsCell *cell = (MailOrderDetailGoodsCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailGoodsCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSArray *goodsAry = orderDetailDic[@"orderDetails"];
            NSDictionary *dic = goodsAry[indexPath.row];
            [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"commodityImage"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.nameL.text = dic[@"commodityName"];
            if ([dic[@"actualPrice"] intValue] > 0) {
                cell.UnitPriceL.text = [NSString stringWithFormat:@"￥%@", dic[@"actualPrice"]];
            } else {
                cell.UnitPriceL.text = [NSString stringWithFormat:@"￥%@", dic[@"commodityPrice"]];
            }
            
            cell.numL.text = [NSString stringWithFormat:@"x%@", dic[@"commodityAmount"]];
            return cell;
            break;
        }
        case 3: {
            if (indexPath.row == 0) {
                MailOrderDetailSendStyleCell *cell = (MailOrderDetailSendStyleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailSendStyleCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.styleL.text = @"支付方式";
                cell.contentL.text = orderDetailDic[@"pageMode"];
                return cell;
            }
            if (indexPath.row == 1) {
                MailOrderDetailTopCell *cell = (MailOrderDetailTopCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailTopCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameL.text = @"产品金额";
                cell.contentL.text = [NSString stringWithFormat:@"￥%@",orderDetailDic[@"totalPrice"]];
                return cell;
            }
            if (indexPath.row == 2) {
                MailOrderDetailTotalMoneyCell *cell = (MailOrderDetailTotalMoneyCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailTotalMoneyCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.actualPaymentL.text = [NSString stringWithFormat:@"￥%@",orderDetailDic[@"actualPrice"]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                // 设置时间格式
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[orderDetailDic[@"createTime"] doubleValue]/1000];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                NSString *str = [formatter stringFromDate:date];
                cell.dateL.text = str;
                return cell;
            }
            break;
        }
        default:
            return nil;
            break;
    }
    return nil;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //        [dataArray removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 发送请求
-(void)requestGetMallOrderDetail { //获取商城订单详情
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderGetInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderGetInfo, @"op", nil];
        NSString *urlString = [NSString stringWithFormat:@"%@/%@",UrlPrefix(MallOrderGetInfo),self.orderId];
        [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.orderId,@"id", nil];
//    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(MallOrderGetInfo) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:MallOrderGetInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderGetInfo object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            orderDetailDic = responseObject [@"data"];
            int status = [orderDetailDic[@"orderStatus"] intValue];
            if (status == 0) {  //未付款时隐藏物流信息
                self.bottomView.hidden = NO;
                [self.statusBtn setTitle:@"去付款" forState:UIControlStateNormal];
            }
            else {
                self.bottomView.hidden = YES;
//                [self.statusBtn setTitle:@"再次购买" forState:UIControlStateNormal];
            }
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
