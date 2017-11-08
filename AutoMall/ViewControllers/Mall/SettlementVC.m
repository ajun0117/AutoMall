//
//  SettlementVC.m
//  HSH
//
//  Created by kangshibiao on 16/5/20.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "SettlementVC.h"
#import "ShoppingCartModel.h"
#import "SettlementAddressCell.h"
#import "SettlementBeizhuCell.h"
#import "ReceiveAddressViewController.h"
#import "MetodPaymentVC.h"
#import "JSONKit.h"

@interface SettlementVC () <SelectAddress,UITextFieldDelegate>
{
    SettlementFootView *_footView;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *defaultAddressDic;    //默认收货地址字段
    NSString *remarkStr;    //备注
}
@end

@implementation SettlementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"结算";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    
    [self initTab];
  
    [self getMyAddress];
//    [self setLeftWithImage:nil action:@selector(backGo)];
    
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

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.GoBack();
}

- (void)backGo{
    
    self.GoBack();
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initTab{
    self.title = @"结算";
    [self.myTableView registerNib:[UINib nibWithNibName:@"SettlementCell" bundle:nil] forCellReuseIdentifier:@"SettlementCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"SettlementFootView" bundle:nil] forCellReuseIdentifier:@"SettlementFootView"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"SettlementAddressCell" bundle:nil] forCellReuseIdentifier:@"settlementAddressCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"SettlementBeizhuCell" bundle:nil] forCellReuseIdentifier:@"settlementBeizhuCell"];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    SettlementBeizhuCell *cell = (SettlementBeizhuCell *)[self.myTableView cellForRowAtIndexPath:index];
    [cell.beizhuTF resignFirstResponder];
}

-(void)selectReceiveAddress:(NSDictionary *)dic {
    defaultAddressDic = dic;
    [self.myTableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    remarkStr = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    return self.datasArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SettlementAddressCell *cell = (SettlementAddressCell *)[tableView dequeueReusableCellWithIdentifier:@"settlementAddressCell"];
        if (defaultAddressDic) {  //存在默认地址
            cell.addView.hidden = YES;
            cell.addressView.hidden = NO;
            cell.nameL.text = defaultAddressDic [@"name"];
            cell.phoneL.text = defaultAddressDic [@"phone"];
            NSString *pro = defaultAddressDic [@"province"];
            NSString *city = defaultAddressDic [@"city"];
            NSString *county = defaultAddressDic [@"county"];
            cell.addressL.text = [NSString stringWithFormat:@"%@-%@-%@-%@",pro,city,county,defaultAddressDic [@"address"]];
        }else {
            cell.addView.hidden = NO;
            cell.addressView.hidden = YES;
        }
        return cell;
    }
    else if (indexPath.section == 1) {
        SettlementBeizhuCell *cell = (SettlementBeizhuCell *)[tableView dequeueReusableCellWithIdentifier:@"settlementBeizhuCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.beizhuTF.delegate = self;
        return cell;
    }
    else {
        SettlementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettlementCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.addBtn addTarget:self action:@selector(addBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        cell.addBtn.tag = indexPath.row;
        cell.deleteBtn.tag = indexPath.row;
        cell.data = self.datasArr [indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }
    else if (indexPath.section == 2) {
        return 60;
    }
    return KS_H(44);
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        KS_H(55);
    }
    return 1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
     if (section == 2) {
        _footView = [SettlementFootView initFootView];
        _footView.money.text = [NSString stringWithFormat:@"￥%.2f",[ShoppingCartModel moneyOrderShoopingCart:self.datasArr]];
        _footView.numbers.text = [NSString stringWithFormat:@"共计%ld件",(long)[ShoppingCartModel orderShoppingCartr:self.datasArr]];
        _footView.yunfeiL.text = [NSString stringWithFormat:@"配送费:￥%.2f",[ShoppingCartModel shippingFeeShopingCart:self.datasArr]];
        return _footView;
     }
    return nil;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        ReceiveAddressViewController *addrVC = [[ReceiveAddressViewController alloc] init];
        addrVC.addrDelegate = self;
        addrVC.isSelected = YES;
        [self.navigationController pushViewController:addrVC animated:YES];
    }
}

#pragma mark -- confirmOrderClock
- (IBAction)confirmOrderClick:(id)sender {
    [self requestPostAddOrder]; //提交订单
}

#pragma markl -- 加加
- (void)addBtn:(UIButton *)sender{
    [self updatesContNumber:sender addAndDele:YES];
}

#pragma mark -- 减减
- (void)deleteBtn:(UIButton *)sender{
    [self updatesContNumber:sender addAndDele:NO];
}
- (void)updatesContNumber:(UIButton *)indexPath addAndDele:(BOOL)isAD{
    
    //    ShoppingCartCell *cell = [self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.tag inSection:0]];
    SettlementCell * cell = (SettlementCell *)indexPath.superview.superview;
    NSIndexPath *indx = [self.myTableView indexPathForCell:cell];
    int num = [cell.number.text intValue];
    if (isAD) {
        num ++;
    }
    else{
        num --;
    }
    cell.number.text = [NSString stringWithFormat:@"%d",num];
    NSMutableDictionary * data  = self.datasArr[indx.row];
    [data setObject:@(num) forKey:@"orderCont"];
    if (num == 0) {
        [self.datasArr removeObject:data];
        [self.myTableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:0];
    }
    
    _footView.money.text = [NSString stringWithFormat:@"￥%.2f",[ShoppingCartModel moneyOrderShoopingCart:self.datasArr]];
    _footView.numbers.text = [NSString stringWithFormat:@"共计%ld件",(long)[ShoppingCartModel orderShoppingCartr:self.datasArr]];
    _footView.yunfeiL.text = [NSString stringWithFormat:@"配送费:￥%.2f",[ShoppingCartModel shippingFeeShopingCart:self.datasArr]];
    
}

#pragma mark - 发送请求
-(void)getMyAddress {       //获取收货地址
    //    [_addressArray removeAllObjects];
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ConsigneeList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ConsigneeList, @"op", nil];
    //    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@",UrlPrefix(ConsigneeList),@"1"];
    //    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ConsigneeList) delegate:nil params:pram info:infoDic];
}

-(void)requestPostAddOrder { //新增订单
    if (defaultAddressDic) {
        [_hud show:YES];
        //注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MallOrderAdd object:nil];
        NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MallOrderAdd, @"op", nil];
        NSString *userid = [[GlobalSetting shareGlobalSettingInstance] userID];
    //    NSString *uname = [[GlobalSetting shareGlobalSettingInstance] mName];
        NSMutableArray *commAry = [NSMutableArray array];
        for (NSDictionary *dic in _datasArr) {
            NSDictionary *dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"commodityId",dic[@"orderCont"],@"commodityAmount", nil];
            [commAry addObject:dicc];
        }
        float totalPrice = [ShoppingCartModel moneyOrderShoopingCart:self.datasArr];
        float actualPrice = totalPrice + [ShoppingCartModel shippingFeeShopingCart:self.datasArr];
        NSString *phoneStr = [[GlobalSetting shareGlobalSettingInstance] mMobile];
        NSString *nickNameStr = [[GlobalSetting shareGlobalSettingInstance] mName];
        NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userid,@"clientId",nickNameStr,@"clientUsername",phoneStr,@"clientPhone",defaultAddressDic[@"id"],@"consigneeId",defaultAddressDic[@"name"],@"consigneeName",defaultAddressDic[@"phone"],@"consigneePhone",defaultAddressDic[@"province"],@"consigneeProvince",defaultAddressDic[@"city"],@"consigneeCity",defaultAddressDic[@"county"],@"consigneeCounty",defaultAddressDic[@"address"],@"consigneeAddress",[NSString stringWithFormat:@"%.2f",totalPrice],@"totalPrice",[NSString stringWithFormat:@"%.2f",actualPrice],@"actualPrice",STRING_Nil(remarkStr),@"remark",[commAry JSONString],@"detailJson", nil];
        [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(MallOrderAdd) delegate:nil params:pram info:infoDic];
    }
    else {
        _networkConditionHUD.labelText = @"请先选择收货地址！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:ConsigneeList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ConsigneeList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            NSArray *addressAry = responseObject [@"data"];
            if ([addressAry count]) {
                for (NSDictionary *dic in addressAry) {
                    if ([dic[@"preferred"] boolValue]) {  //找到默认地址
                        defaultAddressDic = dic;
                        [self.myTableView reloadData];
                    }
                }
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:MallOrderAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MallOrderAdd object:nil];
        NSLog(@"MallOrderAdd_responseObject: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            MetodPaymentVC *pay = [[MetodPaymentVC alloc] init];
            pay.orderNumber = responseObject[@"data"];
            pay.money = [ShoppingCartModel moneyOrderShoopingCart:self.datasArr] + [ShoppingCartModel shippingFeeShopingCart:self.datasArr];
            [self.navigationController pushViewController:pay animated:YES];
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
