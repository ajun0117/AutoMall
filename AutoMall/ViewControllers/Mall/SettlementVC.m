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

@interface SettlementVC ()
{
    SettlementFootView *_footView;
}
@end

@implementation SettlementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"结算";
    
    [self initTab];
  
//    [self setLeftWithImage:nil action:@selector(backGo)];
    
    
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
        return cell;
    }
    else if (indexPath.section == 1) {
        SettlementBeizhuCell *cell = (SettlementBeizhuCell *)[tableView dequeueReusableCellWithIdentifier:@"settlementBeizhuCell"];
        return cell;
    }
    else {
        SettlementCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettlementCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        [cell.addBtn addTarget:self action:@selector(addBtn:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        cell.addBtn.tag = indexPath.row;
        cell.deleteBtn.tag = indexPath.row;
        cell.data = self.datasArr [indexPath.row];
        return cell;
    }
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        ReceiveAddressViewController *addrVC = [[ReceiveAddressViewController alloc] init];
        [self.navigationController pushViewController:addrVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        
        return _footView;
     }
    return nil;
}

#pragma mark -- confirmOrderClock
- (IBAction)confirmOrderClock:(id)sender {
    MetodPaymentVC *pay = [MetodPaymentVC new];
    [self.navigationController pushViewController:pay animated:YES];
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
    
    NSMutableDictionary * data  =self.datasArr[indx.row];
    
    [data setObject:@(num) forKey:@"orderCont"];
    
    if (num == 0) {
        
        
        
        [self.datasArr removeObject:data];
        
        [self.myTableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:0];
    }
    
    _footView.money.text = [NSString stringWithFormat:@"￥%.2f",[ShoppingCartModel moneyOrderShoopingCart:self.datasArr]];
    _footView.numbers.text = [NSString stringWithFormat:@"共计%ld件",(long)[ShoppingCartModel orderShoppingCartr:self.datasArr]];
    _footView.yunfeiL.text = [NSString stringWithFormat:@"运费：￥%.2f",5.00];
    
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
