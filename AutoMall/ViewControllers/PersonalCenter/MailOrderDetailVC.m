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

@interface MailOrderDetailVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation MailOrderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单详情";
    
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
}

- (IBAction)statusAction:(id)sender {
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
            
        case 1:
            return 4;
            break;
            
        case 2:
            return 2;
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
            if (indexPath.row == 3) {
                return 80;
            }
            return 44;
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
            cell.nameL.text = @"订单号：8989878767";
            cell.contentL.text = @"待付款";
            return cell;
            break;
        }
        case 1: {
            if (indexPath.row == 0) {
                MailOrderDetailSendStyleCell *cell = (MailOrderDetailSendStyleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailSendStyleCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.styleL.text = @"配送方式";
                cell.contentL.text = @"物流配送11";
                return cell;
            }
            else if (indexPath.row == 1) {
                MailOrderDetailWaybillCell *cell = (MailOrderDetailWaybillCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailWaybillCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameL.text = @"物流公司: ";
                cell.contentL.text = @"中通快递";
                return cell;
            }
            else if (indexPath.row == 2) {
                MailOrderDetailWaybillCell *cell = (MailOrderDetailWaybillCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailWaybillCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameL.text = @"运单编号: ";
                cell.contentL.text = @"7686876876876876";
                return cell;
            }
            else if (indexPath.row == 3) {
                MailOrderDetailReceiverInfoCell *cell = (MailOrderDetailReceiverInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailReceiverInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            break;
        }
        case 2: {
            MailOrderDetailGoodsCell *cell = (MailOrderDetailGoodsCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailGoodsCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 3: {
            if (indexPath.row == 0) {
                MailOrderDetailSendStyleCell *cell = (MailOrderDetailSendStyleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailSendStyleCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.styleL.text = @"支付方式";
                cell.contentL.text = @"微信支付";
                return cell;
            }
            if (indexPath.row == 1) {
                MailOrderDetailTopCell *cell = (MailOrderDetailTopCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailTopCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.nameL.text = @"产品金额";
                cell.contentL.text = @"￥9999.00";
                return cell;
            }
            if (indexPath.row == 2) {
                MailOrderDetailTotalMoneyCell *cell = (MailOrderDetailTotalMoneyCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderDetailTotalMoneyCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
