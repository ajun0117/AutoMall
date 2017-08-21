//
//  CommodityListVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CommodityListVC.h"
#import "MJRefresh.h"
#import "CommodityListCell.h"
#import "CommodityDetailVC.h"

@interface CommodityListVC ()
{
    IBOutlet UIView *topView;
    IBOutlet UIButton *xiangmuBtn;
    IBOutlet UIButton *sortBtn;
    IBOutlet UIButton *tagBtn;
    UIView *selectBgView;
    UITableView *selectTableView;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CommodityListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商品列表";
    
    [self adjustLeftBtnFrameWithTitle:@"项目" andButton:xiangmuBtn];
    [self adjustLeftBtnFrameWithTitle:@"排列方式" andButton:sortBtn];
    [self adjustLeftBtnFrameWithTitle:@"标签" andButton:tagBtn];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityListCell" bundle:nil] forCellReuseIdentifier:@"commodityListCell"];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
//    currentpage = 1;
//    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
//    [self requestGetShopList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
//    currentpage ++;
//    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
//    [self requestGetShopList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == selectTableView) {
        return 1;
    }
//    return [shopArray count];
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == selectTableView) {
        return 44;
    }
    return 115;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 1;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == selectTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        //        cell.backgroundColor = RGBCOLOR(238, 238, 238);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        if (pingfenBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"由低到高";
//            }
//            else {
//                cell.textLabel.text = @"由高到低";
//            }
//        }
//        else if (priceBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"由低到高";
//            }
//            else {
//                cell.textLabel.text = @"由高到低";
//            }
//        }
//        else if (distanceBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"5公里";
//            }
//            else if (indexPath.row == 1) {
//                cell.textLabel.text = @"10公里";
//            }
//            else {
//                cell.textLabel.text = @"全部";
//            }
//        }
//        else if (youhuiBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"优惠商家";
//            }
//            else {
//                cell.textLabel.text = @"全部";
//            }
//        }
        return  cell;
    }
    else {
        CommodityListCell *cell = (CommodityListCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityListCell"];
        
//        cell.shopIM.layer.cornerRadius = 5;
//        cell.shopIM.clipsToBounds = YES;
//        
//        cell.tuijianL.layer.cornerRadius = 9;
//        cell.tuijianL.clipsToBounds = YES;
//        cell.youhuiL.layer.cornerRadius = 9;
//        cell.youhuiL.clipsToBounds = YES;
//        cell.jifenL.layer.cornerRadius = 9;
//        cell.jifenL.clipsToBounds = YES;
//        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        NSDictionary *dic = shopArray [indexPath.section];
//        
//        [cell.shopIM sd_setImageWithURL:[NSURL URLWithString:dic[@"image"]] placeholderImage:IMG(@"squareImageDefault")];
//        cell.shopNameL.text = dic [@"name"];
//        
//        if ([dic [@"integral"] boolValue]) {  //返积分
//            cell.jifenWidthCons.constant = 41;
//        }
//        else {
//            cell.jifenWidthCons.constant = 0.0;
//        }
//        
//        if (dic [@"coupons"] !=nil && [dic [@"coupons"] floatValue] > 0) {  //有优惠
//            cell.youhuiWidthCons.constant = 41;
//        }
//        else {
//            cell.youhuiWidthCons.constant = 0.0;
//        }
//        
//        if (dic [@"recommendation"] !=nil && [dic [@"recommendation"] floatValue] > 0) {  //有推荐
//            cell.tuijianWidthCons.constant = 41;
//        }
//        else {
//            cell.tuijianWidthCons.constant = 0.0;
//        }
//        
//        cell.scoreL.text = NSStringZeroWithNumber(dic[@"scorex"]);
//        cell.consumptionL.text =  dic[@"consumption"]==nil?@"未知":[NSString stringWithFormat:@"￥%@",dic[@"consumption"]];
//        cell.distanceL.text = dic[@"distance"]==nil?@"未知":[NSString stringWithFormat:@"距离%.1f公里",[dic[@"distance"] floatValue]];
//        cell.addressL.text = dic [@"address"];
//        //    cell.contactL.text = [NSString stringWithFormat:@"电话：%@ / 微信：%@ / QQ：%@ / QQ群：%@ / 经理：%@",dic[@"phone"],dic[@"wechat"],dic[@"qq"],dic[@"qqGroup"],dic[@"manager"]];
//        //    电话：13838888888 / 微信：阿俊 / QQ：123456789 / QQ群：123456 / 经理：刘经理
//        
//        //        NSString *text = [NSString stringWithFormat:@"<font color=\"lightGray\">电话：<font color=\"black\">%@<font color=\"lightGray\"> / 微信：<font color=\"black\">%@<font color=\"lightGray\"> / QQ：<font color=\"black\">%@<font color=\"lightGray\"> / QQ群：<font color=\"black\">%@<font color=\"lightGray\"> / 经理：<font color=\"black\">%@",dic[@"phone"],dic[@"wechat"],dic[@"qq"],dic[@"qqGroup"],dic[@"manager"]];
//        //        MarkupParser *p = [[MarkupParser alloc] init];
//        //        NSAttributedString *attString = [p attrStringFromMarkup:text];
//        //        [cell.contactL setNeedsDisplay];
//        //        [cell.contactL setAttString:attString];
//        //        [cell.contactL sizeToFit];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == selectTableView) {
//        UITableViewCell *cell = [selectTableView cellForRowAtIndexPath:indexPath];
//        if (pingfenBtn.selected) {
//            if (indexPath.row == 0) {
//                [sortDic setObject:@"asc" forKey:@"score"];
//            }
//            else {
//                [sortDic setObject:@"desc" forKey:@"score"];
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:pingfenBtn];
//            //            [pingfenBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (priceBtn.selected) {
//            if (indexPath.row == 0) {
//                [sortDic setObject:@"asc" forKey:@"consumption"];
//            }
//            else {
//                [sortDic setObject:@"desc" forKey:@"consumption"];
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:priceBtn];
//            //            [priceBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (distanceBtn.selected) {
//            if (indexPath.row == 0) {
//                distanceStr = @"5";
//            }
//            else if (indexPath.row == 1) {
//                distanceStr = @"10";
//            }
//            else {
//                distanceStr = @"";
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:distanceBtn];
//            //            [distanceBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (youhuiBtn.selected) {
//            if (indexPath.row == 0) {
//                isCoupons = @"1";
//            }
//            else {
//                isCoupons = @"";
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:youhuiBtn];
//            //            [youhuiBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        
//        [self cancelSelect];
//        currentpage = 1;
//        [self requestGetShopList];
    }
    else {
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
//        detailVC.shopID = shopArray[indexPath.section][@"id"];
//        detailVC.slidePlaceDetail = self.slidePlaceDetail;
//        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}


-(void)adjustLeftBtnFrameWithTitle:(NSString *)str andButton:(UIButton *)btn {
    NSDictionary *attributes = @{NSFontAttributeName : btn.titleLabel.font};
    CGSize size = [str sizeWithAttributes:attributes];
    NSLog(@"size: %@",NSStringFromCGSize(size));
    //    float rate = btn.frame.size.width / size.width;
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, size.width+25, 0, 0)];
    [btn setTitle:str forState:UIControlStateNormal];
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
