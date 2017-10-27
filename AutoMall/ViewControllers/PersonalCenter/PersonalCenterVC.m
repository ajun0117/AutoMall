//
//  PersonalCenterVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/1.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "PersonalCenterVC.h"
#import "HeadNameCell.h"
#import "CenterNormalCell.h"
#import "CenterOrderCell.h"
#import "CustomServiceVC.h"
#import "ApplyAuthenticationVC.h"
#import "EmployeeListVC.h"
#import "ShopGradeVC.h"
#import "MailOrderListVC.h"
#import "MailCollectionVC.h"
#import "FindPWDViewController.h"
#import "ReceiveAddressViewController.h"
#import "UpkeepStatementVC.h"
#import "LoginViewController.h"
#import "BaoyangDiscountsVC.h"
#import "MessageListVC.h"

@interface PersonalCenterVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *mobileUserType;     //登录用户类别 0：手机普通用户 1：门店老板 2: 门店员工
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation PersonalCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    self.title = @"个人中心";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
//    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    setBtn.frame = CGRectMake(0, 0, 44, 44);
//    [setBtn setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
//    [setBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [setBtn addTarget:self action:@selector(toSet) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *setBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
//    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, setBtnBarBtn, nil];
    
    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    msgBtn.frame = CGRectMake(0, 0, 44, 44);
    [msgBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
    [msgBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [msgBtn addTarget:self action:@selector(toMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *msgBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:msgBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, msgBtnBarBtn, nil];
    
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"HeadNameCell" bundle:nil] forCellReuseIdentifier:@"headNameCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterNormalCell" bundle:nil] forCellReuseIdentifier:@"centerNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterOrderCell" bundle:nil] forCellReuseIdentifier:@"centerOrderCell"];
    
//    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
//    [self.myTableView reloadData];
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
    
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    [self.myTableView reloadData];
    if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        [self requestPostStoreGetInfo];     //请求门店详情数据
    }
}

-(void) toSet {
//    LoginViewController *loginVC = [[LoginViewController alloc] init];
//    loginVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:loginVC animated:YES];
}

-(void) toMessage {
    MessageListVC *msgVC = [[MessageListVC alloc] init];
    msgVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgVC animated:YES];
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        return 4;
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        return 5;
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        return 6;
    }
    return 2;   //未登录用户
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (section) {
            case 0: {
                return 1;
                break;
            }
            case 1: {
                return 1;
                break;
            }
            case 2: {
                return 1;
                break;
            }
            case 3: {
                return 2;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        switch (section) {
            case 0: {
                return 1;
                break;
            }
            case 1: {
                return 6;
                break;
            }
            case 2: {
                return 3;
                break;
            }
            case 3: {
                return 2;
                break;
            }
            case 4: {
                return 2;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        switch (section) {
            case 0: {
                return 1;
                break;
            }
            case 1: {
                return 2;
                break;
            }
            case 2: {
                return 3;
                break;
            }
            case 3: {
                return 1;
                break;
            }
            case 4: {
                return 1;
                break;
            }
            case 5: {
                return 2;
                break;
            }
                
            default:
                return 0;
                break;
        }
    }
    
    switch (section) {
        case 0: {
            return 1;
            break;
        }
        case 1: {
            return 2;
            break;
        }
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (indexPath.section) {
            case 0: {
                return 80;
                break;
            }
            case 1: {
                return 44;
                break;
            }
            case 2: {
                return 44;
                break;
            }
            case 3: {
                return 44;
                break;
            }
                
            default:
                return 0;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        switch (indexPath.section) {
            case 0: {
                return 80;
                break;
            }
            case 1: {
                if (indexPath.row == 1) {
                    return 80;
                }
                return 44;
                break;
            }
            case 2: {
                if (indexPath.row == 1) {
                    return 80;
                }
                return 44;
                break;
            }
            case 3: {
                return 44;
                break;
            }
            case 4: {
                return 44;
                break;
            }
                
            default:
                return 0;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        switch (indexPath.section) {
            case 0: {
                return 80;
                break;
            }
            case 1: {
                return 80;
                break;
            }
            case 2: {
                if (indexPath.row == 1) {
                    return 80;
                }
                return 44;
                break;
            }
            case 3: {
                return 44;
                break;
            }
            case 4: {
                return 44;
                break;
            }
            case 5: {
                return 44;
                break;
            }
                
            default:
                return 0;
                break;
        }
    }
    
    switch (indexPath.section) {
        case 0: {
            return 80;
            break;
        }
        case 1: {
            return 44;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (indexPath.section) {
            case 0: {
                HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
                cell.nameL.text = @"壳牌授权店";
                cell.nickNameL.text = @"店小二";
                cell.jifenL.text = [NSString stringWithFormat:@"  积分：%@分  ",@"80"];
                return cell;
                break;
            }
                
            case 1:{
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_fav");
                cell.nameL.text = @"商品收藏";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
                break;
            }
                
            case 2:{
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_changePW");
                cell.nameL.text = @"修改密码";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
                break;
            }
            case 3:{
                if (indexPath.row == 0) {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_disclaimer");
                    cell.nameL.text = @"免责声明";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                else {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_contact");
                    cell.nameL.text = @"联系我们";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                break;
            }
            default:
                return nil;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        switch (indexPath.section) {
            case 0: {
                HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
                cell.nameL.text = @"壳牌授权店";
                cell.nickNameL.text = @"店小二";
                cell.jifenL.text = [NSString stringWithFormat:@"  积分：%@分  ",@"80"];
                return cell;
                break;
            }
                
            case 1:{
                switch (indexPath.row) {
                    case 0: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"information_pressed");
                        cell.nameL.text = @"服务订单";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [cell.firstBtn setImage:IMG(@"center_inProgress") forState:UIControlStateNormal];
                        cell.firstL.text = @"检查完成";
                        [cell.secondBtn setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        cell.secondL.text = @"订单确认";
                        cell.thirdBtn.hidden = NO;
                        cell.thirdL.hidden = NO;
                        [cell.thirdBtn setImage:IMG(@"center_workDone") forState:UIControlStateNormal];
                        cell.thirdL.text = @"施工完成";
                        cell.fourthBtn.hidden = NO;
                        cell.fourthL.hidden = NO;
                        [cell.fourthBtn setImage:IMG(@"center_paid-checkup") forState:UIControlStateNormal];
                        cell.fourthL.text = @"已付款";
                        return cell;
                        break;
                    }
                    case 2: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_statistics");
                        cell.nameL.text = @"统计报表";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 3: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_customizedServices");
                        cell.nameL.text = @"定制服务";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 4: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_discount");
                        cell.nameL.text = @"优惠管理";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 5: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_staff");
                        cell.nameL.text = @"员工管理";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    default:
                        return nil;
                        break;
                }
                break;
            }
            case 2:{
                switch (indexPath.row) {
                    case 0: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"information_pressed");
                        cell.nameL.text = @"商城订单";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [cell.firstBtn setImage:IMG(@"center_toPay") forState:UIControlStateNormal];
                        [cell.firstBtn addTarget:self action:@selector(daifuAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.firstL.text = @"待付款";
                        [cell.secondBtn setImage:IMG(@"center_paid") forState:UIControlStateNormal];
                        [cell.secondBtn addTarget:self action:@selector(yifuAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.secondL.text = @"已付款";
                        return cell;
                        break;
                    }
                    case 2: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_fav");
                        cell.nameL.text = @"商品收藏";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    default:
                        return nil;
                        break;
                }
                break;
            }
                
            case 3:{
                if (indexPath.row == 0) {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_changePW");
                    cell.nameL.text = @"修改密码";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                else {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_address");
                    cell.nameL.text = @"地址管理";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                break;
            }
            case 4:{
                if (indexPath.row == 0) {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_disclaimer");
                    cell.nameL.text = @"免责声明";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                else {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_contact");
                    cell.nameL.text = @"联系我们";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                break;
            }
            default:
                return nil;
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        switch (indexPath.section) {
            case 0: {
                HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
                cell.nameL.text = @"壳牌授权店";
                cell.nickNameL.text = @"店小二";
                cell.jifenL.text = [NSString stringWithFormat:@"  积分：%@分  ",@"80"];
                return cell;
                break;
            }
            case 1:{
                switch (indexPath.row) {
                    case 0: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_changePw");
                        cell.nameL.text = @"技能特长";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_changePw");
                        cell.nameL.text = @"技能认证";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    default:
                        return nil;
                        break;
                }
                break;
            }
            case 2:{
                switch (indexPath.row) {
                    case 0: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"information_pressed");
                        cell.nameL.text = @"服务订单";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [cell.firstBtn setImage:IMG(@"information_pressed") forState:UIControlStateNormal];
                        cell.firstL.text = @"检查完成";
                        [cell.secondBtn setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        cell.secondL.text = @"订单确认";
                        cell.thirdBtn.hidden = NO;
                        cell.thirdL.hidden = NO;
                        [cell.thirdBtn setImage:IMG(@"center_workDone") forState:UIControlStateNormal];
                        cell.thirdL.text = @"施工完成";
                        cell.fourthBtn.hidden = NO;
                        cell.fourthL.hidden = NO;
                        [cell.fourthBtn setImage:IMG(@"center_paid-checkup") forState:UIControlStateNormal];
                        cell.fourthL.text = @"已付款";
                        return cell;
                        break;
                    }
                    case 2: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_statistics");
                        cell.nameL.text = @"统计报表";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    default:
                        return nil;
                        break;
                }
                break;
            }
            case 3:{
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_fav");
                cell.nameL.text = @"商品收藏";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
                break;
            }
            case 4:{
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_changePW");
                cell.nameL.text = @"修改密码";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
                break;
            }
            case 5:{
                if (indexPath.row == 0) {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_disclaimer");
                    cell.nameL.text = @"免责声明";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                else {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.img.image = IMG(@"center_contact");
                    cell.nameL.text = @"联系我们";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }
                break;
            }
            default:
                return nil;
                break;
        }
    }
    
    switch (indexPath.section) {
        case 0: {
            HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
            cell.nameL.text = @"壳牌授权店";
            cell.nickNameL.text = @"店小二";
            cell.jifenL.text = [NSString stringWithFormat:@"  积分：%@分  ",@"80"];
            return cell;
            break;
        }
        case 1:{
            if (indexPath.row == 0) {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_disclaimer");
                cell.nameL.text = @"免责声明";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            else {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.img.image = IMG(@"center_contact");
                cell.nameL.text = @"联系我们";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
            break;
        }
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (! mobileUserType) {
        _networkConditionHUD.labelText = @"登录后才能查看！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (indexPath.section) {
            case 0: {
                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
                applyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:applyVC animated:YES];
                break;
            }
            case 1: {
                MailCollectionVC *collectionVC = [[MailCollectionVC alloc] init];
                collectionVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:collectionVC animated:YES];
                break;
            }
            case 2: {
                FindPWDViewController *changeVC = [[FindPWDViewController alloc] init];
                changeVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:changeVC animated:YES];
                break;
            }
            case 3: {
                NSLog(@"联系我们");
                break;
            }
            default:
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        switch (indexPath.section) {
            case 0: {
                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
                applyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:applyVC animated:YES];
                break;
            }
            case 1: {
                switch (indexPath.row) {
                    case 2: {
                        UpkeepStatementVC *statementVC = [[UpkeepStatementVC alloc] init];
                        statementVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:statementVC animated:YES];
                        break;
                    }
                    case 3: {
                        CustomServiceVC *customVC = [[CustomServiceVC alloc] init];
                        customVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:customVC animated:YES];
                        break;
                    }
                    case 4: {
                        BaoyangDiscountsVC *disVC = [[BaoyangDiscountsVC alloc] init];
                        disVC.canEdit = YES;
                        disVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:disVC animated:YES];
                        break;
                    }
                    case 5: {
                        EmployeeListVC *listVC = [[EmployeeListVC alloc] init];
                        listVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:listVC animated:YES];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            case 2: {
                if (indexPath.row == 0) {
                    MailOrderListVC *listVC = [[MailOrderListVC alloc] init];
                    listVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:listVC animated:YES];
                }
                else if (indexPath.row == 2) {
                    MailCollectionVC *collectionVC = [[MailCollectionVC alloc] init];
                    collectionVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:collectionVC animated:YES];
                }
                break;
            }
            case 3: {
                if (indexPath.row == 0) {
                    FindPWDViewController *changeVC = [[FindPWDViewController alloc] init];
                    changeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:changeVC animated:YES];
                }
                else if (indexPath.row == 1) {
                    ReceiveAddressViewController *addressVC = [[ReceiveAddressViewController alloc] init];
                    addressVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:addressVC animated:YES];
                }
                break;
            }
            case 4: {
                NSLog(@"联系我们");
                break;
            }
            default:
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        switch (indexPath.section) {
            case 0: {
//                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
//                applyVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:applyVC animated:YES];
                _networkConditionHUD.labelText = @"门店员工不能修改店铺信息";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                break;
            }
            case 2: {
                switch (indexPath.row) {
                    case 2: {
                        UpkeepStatementVC *statementVC = [[UpkeepStatementVC alloc] init];
                        statementVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:statementVC animated:YES];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            case 3: {
                MailCollectionVC *collectionVC = [[MailCollectionVC alloc] init];
                collectionVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:collectionVC animated:YES];
                break;
            }
            case 4: {
                FindPWDViewController *changeVC = [[FindPWDViewController alloc] init];
                changeVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:changeVC animated:YES];
                break;
            }
            case 5: {
                NSLog(@"联系我们");
                break;
            }
            default:
                break;
        }
    }
    
    else {
        switch (indexPath.section) {
            case 0: {
                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
                applyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:applyVC animated:YES];
                break;
            }
            case 1: {
                NSLog(@"联系我们");
                break;
            }
                
            default:
                break;
        }
    }
}

-(void)daifuAction:(UIButton *)btn {
    MailOrderListVC *listVC = [[MailOrderListVC alloc] init];
    listVC.orderStatus = @"0";   //未付款
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

-(void)yifuAction:(UIButton *)btn {
    MailOrderListVC *listVC = [[MailOrderListVC alloc] init];
    listVC.orderStatus = @"1";   //已付款
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - 发起网络请求
-(void)requestPostStoreGetInfo { //获取门店详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreGetInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreGetInfo, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StoreGetInfo) delegate:nil params:nil info:infoDic];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:StoreGetInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreGetInfo object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
//            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
