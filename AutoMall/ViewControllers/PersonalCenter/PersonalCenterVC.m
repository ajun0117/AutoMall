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
#import "CenterEmployeeCell.h"
#import "CenterEmployeeAuthCell.h"
#import "WebViewController.h"
#import "CenterAccountVC.h"
#import "UpkeepOrderVC.h"
#import "EmployeeEditIntroduceVC.h"
#import "EmployeeSkillListVC.h"
#import "AboutUsVC.h"
#import "StoreServiceVC.h"

@interface PersonalCenterVC () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *mobileUserType;     //登录用户类别 0：手机普通用户 1：门店老板 2: 门店员工
    NSDictionary *shopDic;  //店铺信息
    NSDictionary *userInfoDic;  //用户信息字典
//    int approvalStatus;
    NSDictionary *approvalStatusDic;    //审核状态字典
    WPImageView *head;      //头像
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
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    setBtn.frame = CGRectMake(0, 0, 44, 44);
    [setBtn setImage:[UIImage imageNamed:@"usInfo"] forState:UIControlStateNormal];
    [setBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [setBtn addTarget:self action:@selector(toAboutUs) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *setBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:setBtn];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, setBtnBarBtn, nil];
    
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
//    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterEmployeeCell" bundle:nil] forCellReuseIdentifier:@"centerEmployeeCell"];
//    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterEmployeeAuthCell" bundle:nil] forCellReuseIdentifier:@"centerEmployeeAuthCell"];
    
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    NSLog(@"mobileUserType: %@",mobileUserType);
    
    if (mobileUserType) {   //登录状态
        if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
            [self requestPostStoreGetInfo];     //请求门店详情数据
        }
        else if ([mobileUserType isEqualToString:@"2"]) {
            [self requestPostUserGetStoreInfo];     //员工请求门店详情数据
        }
        else if ([mobileUserType isEqualToString:@"0"]) {   //普通用户
            [self requestGetApprovalStatus];     //请求门店审批状态
        }
        
        [self requestPostUserGetInfo];      //刷新用户信息
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
    
    if (! mobileUserType) {   //未登录状态监听登录事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:@"LoginSuccess" object:nil];
    }
}

-(void) toAboutUs {
    AboutUsVC *aboutVC = [[AboutUsVC alloc] init];
    aboutVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aboutVC animated:YES];
}

-(void) toMessage {
    if (mobileUserType.length > 0) {    //已登录用户
        MessageListVC *msgVC = [[MessageListVC alloc] init];
        msgVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:msgVC animated:YES];
    }
    else {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:@"LoginSuccess" object:nil];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        return 4;
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        return 6;
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
                return 7;
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
//                return 3;
                return 2;
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
                    return 70;
                }
                return 44;
                break;
            }
            case 2: {
                if (indexPath.row == 1) {
                    return 70;
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
                return 44;
                break;
            }
            case 2: {
                if (indexPath.row == 1) {
                    return 70;
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
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (indexPath.section) {
            case 0: {
                HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.headIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(STRING(userInfoDic[@"image"]))] placeholderImage:IMG(@"center_profile")];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserHead:)];
                [cell.headIMG addGestureRecognizer:tap];
                
                cell.loginL.hidden = YES;
                cell.arrowsIM.hidden = NO;
                cell.accountBtn.hidden = NO;
                if (userInfoDic[@"nickname"] && [userInfoDic[@"nickname"]  isKindOfClass:[NSString class]]) {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"nickname"]) forState:UIControlStateNormal];
                } else {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"phone"]) forState:UIControlStateNormal];
                }
                [cell.accountBtn addTarget:self action:@selector(toAccountView) forControlEvents:UIControlEventTouchUpInside];
                cell.applyBtn.hidden =NO;
                NSLog(@"approvalStatusDic: %@",approvalStatusDic);
                if (approvalStatusDic) {   //数据存在
                    if ([approvalStatusDic[@"approvalStatus"] intValue] == 0) {
                        [cell.applyBtn setTitle:@"门店等待审核中" forState:UIControlStateNormal];
                    }
                    else if ([approvalStatusDic[@"approvalStatus"] intValue] == -1) {
                        [cell.applyBtn setTitle:@"申请门店认证被拒绝，点击重新申请" forState:UIControlStateNormal];
                    }
                }
                [cell.applyBtn addTarget:self action:@selector(toApplyView) forControlEvents:UIControlEventTouchUpInside];
                cell.shopNameBtn.hidden = YES;
                cell.shopLevelIM.hidden= YES;
                cell.shopNameIM.hidden = NO;
                cell.jifenL.hidden = YES;
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
                [cell.headIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(STRING(userInfoDic[@"image"]))] placeholderImage:IMG(@"center_profile")];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserHead:)];
                [cell.headIMG addGestureRecognizer:tap];

                cell.loginL.hidden = YES;
                cell.arrowsIM.hidden = NO;
                cell.accountBtn.hidden = NO;
                if (userInfoDic[@"nickname"] && [userInfoDic[@"nickname"]  isKindOfClass:[NSString class]]) {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"nickname"]) forState:UIControlStateNormal];
                } else {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"phone"]) forState:UIControlStateNormal];
                }
                [cell.accountBtn addTarget:self action:@selector(toAccountView) forControlEvents:UIControlEventTouchUpInside];
                cell.applyBtn.hidden = YES;
                cell.shopNameBtn.hidden = NO;
                [cell.shopNameBtn setTitle:STRING(shopDic[@"name"]) forState:UIControlStateNormal];
                [cell.shopNameBtn addTarget:self action:@selector(toApplyView) forControlEvents:UIControlEventTouchUpInside];
                cell.shopLevelIM.hidden= NO;
                int rankLevel = [shopDic[@"rankLevel"] intValue];
                if (rankLevel == 1) {
                    cell.shopLevelIM.image = IMG(@"bronzeBadge");
                }
                else if(rankLevel == 2) {
                    cell.shopLevelIM.image = IMG(@"silverBadge");
                }
                else if(rankLevel == 3) {
                    cell.shopLevelIM.image = IMG(@"goldBadge");
                }
                cell.shopNameIM.hidden = NO;
                cell.jifenL.hidden = YES;
//                cell.jifenL.text = [NSString stringWithFormat:@"积分：%@分",@"80"];
                return cell;
                break;
            }
                
            case 1:{
                switch (indexPath.row) {
                    case 0: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_checkupOrder");
                        cell.nameL.text = @"服务订单";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [cell.firstBtn setImage:IMG(@"center_inProgress") forState:UIControlStateNormal];
                        [cell.firstBtn addTarget:self action:@selector(upkeepCheckCompleteAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.firstL.text = @"检查完成";
                        [cell.secondBtn setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        [cell.secondBtn addTarget:self action:@selector(upkeepServicesConfirmedAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.secondL.text = @"订单确认";
                        cell.thirdBtn.hidden = NO;
                        cell.thirdL.hidden = NO;
                        [cell.thirdBtn setImage:IMG(@"center_workDone") forState:UIControlStateNormal];
                        [cell.thirdBtn addTarget:self action:@selector(upkeepWorkDoneAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.thirdL.text = @"施工完成";
                        cell.fourthBtn.hidden = NO;
                        cell.fourthL.hidden = NO;
                        [cell.fourthBtn setImage:IMG(@"center_paid-checkup") forState:UIControlStateNormal];
                        [cell.fourthBtn addTarget:self action:@selector(upkeepPaidAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.fourthL.text = @"已付款";
                        cell.fiveBtn.hidden = NO;
                        cell.fiveL.hidden = NO;
                        [cell.fiveBtn setImage:IMG(@"center_finished") forState:UIControlStateNormal];
                        [cell.fiveBtn addTarget:self action:@selector(upkeepFinishedAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.fiveL.text = @"已完成";
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
                        cell.img.image = IMG(@"center_service");
                        cell.nameL.text = @"门店服务";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 5: {
                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                        cell.img.image = IMG(@"center_discount");
                        cell.nameL.text = @"优惠管理";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 6: {
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
                        cell.img.image = IMG(@"center_shopping");
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
                [cell.headIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(STRING(userInfoDic[@"image"]))] placeholderImage:IMG(@"center_profile")];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserHead:)];
                [cell.headIMG addGestureRecognizer:tap];
                
                cell.loginL.hidden = YES;
                cell.arrowsIM.hidden = NO;
                cell.accountBtn.hidden = NO;
                if (userInfoDic[@"nickname"] && [userInfoDic[@"nickname"]  isKindOfClass:[NSString class]]) {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"nickname"]) forState:UIControlStateNormal];
                } else {
                    [cell.accountBtn setTitle:STRING(userInfoDic[@"phone"]) forState:UIControlStateNormal];
                }
                [cell.accountBtn addTarget:self action:@selector(toAccountView) forControlEvents:UIControlEventTouchUpInside];
                cell.applyBtn.hidden = YES;
                cell.shopNameBtn.hidden = NO;
                [cell.shopNameBtn setTitle:STRING(shopDic[@"name"]) forState:UIControlStateNormal];
                [cell.shopNameBtn addTarget:self action:@selector(toApplyView) forControlEvents:UIControlEventTouchUpInside];
//                [cell.shopNameBtn setTitle:STRING(shopDic[@"name"]) forState:UIControlStateNormal];
                cell.shopLevelIM.hidden= NO;
                int rankLevel = [shopDic[@"rankLevel"] intValue];
                if (rankLevel == 1) {
                    cell.shopLevelIM.image = IMG(@"bronzeBadge");
                }
                else if(rankLevel == 2) {
                    cell.shopLevelIM.image = IMG(@"silverBadge");
                }
                else if(rankLevel == 3) {
                    cell.shopLevelIM.image = IMG(@"goldBadge");
                }
                cell.shopNameIM.hidden = YES;
                cell.jifenL.hidden = YES;
                return cell;
                break;
            }
            case 1:{
                switch (indexPath.row) {
                    case 0: {
//                        CenterEmployeeCell *cell = (CenterEmployeeCell *)[tableView dequeueReusableCellWithIdentifier:@"centerEmployeeCell"];
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                        cell.contentL.text = @"快修改技能描述，提升信誉度吧！";
//                        cell.contentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 50;
//                        return cell;
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.textLabel.font = [UIFont systemFontOfSize:16];
                        cell.textLabel.text = @"技能特长";
                        return cell;
                        break;
                    }
                    case 1: {
//                        CenterEmployeeAuthCell *cell = (CenterEmployeeAuthCell *)[tableView dequeueReusableCellWithIdentifier:@"centerEmployeeAuthCell"];
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                        cell.imgView.image = IMG(@"default");
//                        cell.titleL.text = @"技能认证";
//                        cell.contentL.text = @"技能认证描述 技能认证描述";
//                        cell.contentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 104;
//                        return cell;
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.textLabel.font = [UIFont systemFontOfSize:16];
                        cell.textLabel.text = @"技能认证";
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
                        cell.img.image = IMG(@"center_checkupOrder");
                        cell.nameL.text = @"服务订单";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        return cell;
                        break;
                    }
                    case 1: {
                        CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [cell.firstBtn setImage:IMG(@"center_inProgress") forState:UIControlStateNormal];
                        [cell.firstBtn addTarget:self action:@selector(upkeepCheckCompleteAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.firstL.text = @"检查完成";
                        [cell.secondBtn setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        [cell.secondBtn addTarget:self action:@selector(upkeepServicesConfirmedAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.secondL.text = @"订单确认";
                        cell.thirdBtn.hidden = NO;
                        cell.thirdL.hidden = NO;
                        [cell.thirdBtn setImage:IMG(@"center_workDone") forState:UIControlStateNormal];
                        [cell.thirdBtn addTarget:self action:@selector(upkeepWorkDoneAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.thirdL.text = @"施工完成";
                        cell.fourthBtn.hidden = NO;
                        cell.fourthL.hidden = NO;
                        [cell.fourthBtn setImage:IMG(@"center_paid-checkup") forState:UIControlStateNormal];
                        [cell.fourthBtn addTarget:self action:@selector(upkeepPaidAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.fourthL.text = @"已付款";
                        cell.fiveBtn.hidden = NO;
                        cell.fiveL.hidden = NO;
                        [cell.fiveBtn setImage:IMG(@"center_finished") forState:UIControlStateNormal];
                        [cell.fiveBtn addTarget:self action:@selector(upkeepFinishedAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.fiveL.text = @"已完成";
                        return cell;
                        break;
                    }
//                    case 2: {
//                        CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
//                        cell.img.image = IMG(@"center_statistics");
//                        cell.nameL.text = @"统计报表";
//                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                        return cell;
//                        break;
//                    }
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
            [cell.headIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(STRING(userInfoDic[@"image"]))] placeholderImage:IMG(@"center_profile")];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUserHead:)];
            [cell.headIMG addGestureRecognizer:tap];
            
            cell.loginL.hidden = NO;
            cell.arrowsIM.hidden = YES;
            cell.accountBtn.hidden = YES;
            cell.applyBtn.hidden = YES;
            cell.shopNameBtn.hidden = YES;
            cell.shopLevelIM.hidden= YES;
            cell.shopNameIM.hidden = YES;
            cell.jifenL.hidden = YES;
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
    if (! mobileUserType && indexPath.section == 0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:@"LoginSuccess" object:nil];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    if ([mobileUserType isEqualToString:@"0"]) {    //普通用户
        switch (indexPath.section) {
            case 0: {
//                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
////                applyVC.infoDic = shopInfoDic;
//                applyVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:applyVC animated:YES];
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
                if (indexPath.row == 0) {
                    WebViewController *webVC = [[WebViewController alloc] init];
                    webVC.webUrlStr = AgreementInfo;
//                    webVC.webUrlStr = @"http://119.23.227.246/carupkeep/api/agreement/info";
                    webVC.titleStr = @"免责声明";
                    webVC.canShare = NO;
                    webVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                if (indexPath.row == 1) {
                    NSLog(@"联系我们");
                    [self toTel];
                }
                break;
            }
            default:
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        switch (indexPath.section) {
            case 0: {
//                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
//                applyVC.infoDic = shopInfoDic;
//                applyVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:applyVC animated:YES];
                break;
            }
            case 1: {
                switch (indexPath.row) {
                    case 0: {
                        UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
                        orderVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:orderVC animated:YES];
                        break;
                    }
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
                        StoreServiceVC *serviceVC = [[StoreServiceVC alloc] init];
                        serviceVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:serviceVC animated:YES];
                        break;
                    }
                    case 5: {
                        BaoyangDiscountsVC *disVC = [[BaoyangDiscountsVC alloc] init];
                        disVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:disVC animated:YES];
                        break;
                    }
                    case 6: {
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
                if (indexPath.row == 0) {
                    WebViewController *webVC = [[WebViewController alloc] init];
                    webVC.webUrlStr = AgreementInfo;
                    webVC.titleStr = @"免责声明";
                    webVC.canShare = NO;
                    webVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                if (indexPath.row == 1) {
                    NSLog(@"联系我们");
                    [self toTel];
                }
                break;
            }
            default:
                break;
        }
    }
    else if ([mobileUserType isEqualToString:@"2"]) {    //门店员工
        switch (indexPath.section) {
            case 0: {
//                _networkConditionHUD.labelText = @"门店员工不能修改店铺信息";
//                [_networkConditionHUD show:YES];
//                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                break;
            }
            case 1: {
                if (indexPath.row == 0) {
                    EmployeeEditIntroduceVC *editVC = [[EmployeeEditIntroduceVC alloc] init];
                    editVC.introduceStr = STRING(userInfoDic[@"remark"]);
                    editVC.UpdateUserInfo = ^{
                        [self requestPostUserGetInfo];      //刷新用户信息
                    };
                    editVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:editVC animated:YES];
                }
                else {
                    EmployeeSkillListVC *editVC = [[EmployeeSkillListVC alloc] init];
                    editVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:editVC animated:YES];
                }
                break;
            }
            case 2: {
                switch (indexPath.row) {
                    case 0: {
                        UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
                        orderVC.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:orderVC animated:YES];
                        break;
                    }
//                    case 2: {
//                        UpkeepStatementVC *statementVC = [[UpkeepStatementVC alloc] init];
//                        statementVC.hidesBottomBarWhenPushed = YES;
//                        [self.navigationController pushViewController:statementVC animated:YES];
//                        break;
//                    }
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
                if (indexPath.row == 0) {
                    WebViewController *webVC = [[WebViewController alloc] init];
                    webVC.webUrlStr = AgreementInfo;
                    webVC.titleStr = @"免责声明";
                    webVC.canShare = NO;
                    webVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                if (indexPath.row == 1) {
                    NSLog(@"联系我们");
                    [self toTel];
                }
                break;
            }
            default:
                break;
        }
    }
    
    else {      //未登录
        switch (indexPath.section) {
            case 0: {
//                ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
//                applyVC.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:applyVC animated:YES];
                break;
            }
            case 1: {
                if (indexPath.row == 0) {
                    WebViewController *webVC = [[WebViewController alloc] init];
                    webVC.webUrlStr = AgreementInfo;
                    webVC.titleStr = @"免责声明";
                    webVC.canShare = NO;
                    webVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:webVC animated:YES];
                }
                if (indexPath.row == 1) {
                    NSLog(@"联系我们");
                    [self toTel];
                }
                
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - 保养订单
-(void)upkeepCheckCompleteAction:(UIButton *)btn {
    UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
    orderVC.orderStatus = @"0";
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC animated:YES];
}

-(void)upkeepServicesConfirmedAction:(UIButton *)btn {
    UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
    orderVC.orderStatus = @"1";
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC animated:YES];
}

-(void)upkeepWorkDoneAction:(UIButton *)btn {
    UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
    orderVC.orderStatus = @"2";
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC animated:YES];
}

-(void)upkeepPaidAction:(UIButton *)btn {
    UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
    orderVC.orderStatus = @"3";
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC animated:YES];
}

-(void)upkeepFinishedAction:(UIButton *)btn {
    UpkeepOrderVC *orderVC = [[UpkeepOrderVC alloc] init];
    orderVC.orderStatus = @"4";
    orderVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:orderVC animated:YES];
}

#pragma mark - 商城订单
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

-(void) toAccountView {     //去账户页面
    CenterAccountVC *accountVC = [[CenterAccountVC alloc] init];
    accountVC.infoDic = userInfoDic;
    accountVC.UpdateUserInfo = ^(NSDictionary *infoDic) {
        [self requestPostUserGetInfo];      //刷新用户信息
    };
    accountVC.UpdateLoginStatus = ^{
        userInfoDic = nil;
        mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        [self.myTableView reloadData];
    };
    accountVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:accountVC animated:YES];
}

-(void) toApplyView {   //去店铺信息页面
    if ([mobileUserType isEqualToString:@"2"]) {    //门店员工，禁止查看
        return;
    }
    else if ([mobileUserType isEqualToString:@"0"]) {    //普通注册用户
        if ([userInfoDic[@"registeredStore"] intValue] != 0) {   //申请过
            if ([approvalStatusDic[@"approvalStatus"] intValue] == 0) {
                _networkConditionHUD.labelText = STRING(approvalStatusDic[@"opinion"]);
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                return;
            }
            else if ([approvalStatusDic[@"approvalStatus"] intValue] == -1) {
                _networkConditionHUD.labelText = STRING(approvalStatusDic[@"opinion"]);
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                [self performSelector:@selector(toPushVC) withObject:nil afterDelay:HUDDelay];
                return;
            }
        }
    }
    ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
     if ([mobileUserType isEqualToString:@"1"]) {    //门店老板
        applyVC.infoDic = shopDic;
     }
    applyVC.UpdateStoreInfo = ^{
        mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
            [self requestPostStoreGetInfo];     //请求门店详情数据
        }
        else if ([mobileUserType isEqualToString:@"2"]) {
            [self requestPostUserGetStoreInfo];     //员工请求门店详情数据
        }
        else if ([mobileUserType isEqualToString:@"0"]) {   //普通用户
            [self requestPostUserGetInfo];      //刷新用户信息
            [self requestGetApprovalStatus];     //请求门店审批状态
        }
    };
    applyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:applyVC animated:YES];
}

-(void)tapUserHead:(UITapGestureRecognizer *)tap {
    if (mobileUserType.length > 0) {    //已登录用户
        head = (WPImageView *)tap.view;
        [self selectThePhotoOrCamera];
    }
    else {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccess) name:@"LoginSuccess" object:nil];
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)LoginSuccess {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccess" object:nil];
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if ([mobileUserType isEqualToString:@"1"]) {   //门店老板
        [self requestPostStoreGetInfo];     //请求门店详情数据
    }
    else if ([mobileUserType isEqualToString:@"2"]) {
        [self requestPostUserGetStoreInfo];     //员工请求门店详情数据
    }
    else if ([mobileUserType isEqualToString:@"0"]) {   //普通用户
        [self requestGetApprovalStatus];     //请求门店审批状态
    }
    
    [self requestPostUserGetInfo];      //刷新用户信息
}

-(void)selectThePhotoOrCamera {
    UIActionSheet *actionSheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    actionSheet.tag = 1000;
    [actionSheet showInView:self.view];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //来源:相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //来源:相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置导航栏背景颜色
        imagePickerController.navigationBar.barTintColor = [UIColor whiteColor];
        //设置右侧取消按钮的字体颜色
        imagePickerController.navigationBar.tintColor = [UIColor blackColor];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
}
// 拍照完成回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //图片存入相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    head.image = image;
    [self requestUploadImgFile:head];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)toTel {
    NSString *phoneStr = [[GlobalSetting shareGlobalSettingInstance] officialPhone];
    if (! phoneStr) {
        [self requestGetPhoneInfo];
    }
    else {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneStr];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

#pragma mark - 发起网络请求
-(void)requestPostUserGetInfo { //获取登录用户信息
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetUserInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetUserInfo, @"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(GetUserInfo) delegate:nil params:nil info:infoDic];
}

-(void)requestPostStoreGetInfo { //获取门店详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreGetInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreGetInfo, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StoreGetInfo) delegate:nil params:nil info:infoDic];
}

-(void)requestPostUserGetStoreInfo { //员工获取门店详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserGetStoreInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserGetStoreInfo, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UserGetStoreInfo) delegate:nil params:nil info:infoDic];
}

-(void)requestGetApprovalStatus { //获取门店审核状态
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetApprovalStatus object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetApprovalStatus, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(GetApprovalStatus) delegate:nil params:nil info:infoDic];
}

-(void)requestUploadImgFile:(WPImageView *)image {  //上传图片
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}

-(void)requestUserChangeImageWithImageUrl:(NSString *)url {     //修改个人头像
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UserChangeImage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UserChangeImage,@"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:url,@"image", nil];
    NSLog(@"pram:    %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(UserChangeImage) delegate:nil params:pram info:infoDic];
}

-(void)requestGetPhoneInfo {     //获取官网联系电话
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetPhoneInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetPhoneInfo,@"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(GetPhoneInfo) delegate:nil params:nil info:infoDic];
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
    
    if ([notification.name isEqualToString:GetUserInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetUserInfo object:nil];
        NSLog(@"GetUserInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            userInfoDic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",userInfoDic[@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmMobile:[NSString stringWithFormat:@"%@",userInfoDic[@"phone"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:[NSString stringWithFormat:@"%@",STRING(userInfoDic[@"nickname"])]];
            [[GlobalSetting shareGlobalSettingInstance] setmHead:STRING(userInfoDic[@"image"])];
            [[GlobalSetting shareGlobalSettingInstance] setMobileUserType:[NSString stringWithFormat:@"%@",userInfoDic[@"mobileUserType"]]];
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:StoreGetInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreGetInfo object:nil];
        NSLog(@"StoreGetInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            shopDic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setStoreId:STRING(shopDic[@"id"])];
            [[GlobalSetting shareGlobalSettingInstance] setAlipayImg:STRING(shopDic[@"alipayImg"])];
            [[GlobalSetting shareGlobalSettingInstance] setWechatImg:STRING(shopDic[@"wechatpayImg"])];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        } 
    }
    
    if ([notification.name isEqualToString:UserGetStoreInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserGetStoreInfo object:nil];
        NSLog(@"UserGetStoreInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            shopDic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setStoreId:STRING(shopDic[@"id"])];
            [[GlobalSetting shareGlobalSettingInstance] setAlipayImg:STRING(shopDic[@"alipayImg"])];
            [[GlobalSetting shareGlobalSettingInstance] setWechatImg:STRING(shopDic[@"wechatpayImg"])];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:GetApprovalStatus]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetApprovalStatus object:nil];
        NSLog(@"GetApprovalStatus: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
//            approvalStatus = [responseObject[@"data"][@"approvalStatus"] intValue];
            if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                approvalStatusDic = responseObject[@"data"];
                [self.myTableView reloadData];
            }
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        NSLog(@"UploadImgFile: %@",responseObject);
        if ([responseObject[@"result"] boolValue]) {
            NSString *relativePath = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
//            [head sd_setImageWithURL:[NSURL URLWithString:responseObject[@"url"]] placeholderImage:IMG(@"default")];
            [self requestUserChangeImageWithImageUrl:relativePath];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:UserChangeImage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UserChangeImage object:nil];
        NSLog(@"UserChangeImage: %@",responseObject);
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
    
    if ([notification.name isEqualToString:GetPhoneInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetPhoneInfo object:nil];
        NSLog(@"GetPhoneInfo: %@",responseObject);
         if ([responseObject[@"success"] isEqualToString:@"y"]) {    //拨打电话
            NSString *phoneStr = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setOfficialPhone:phoneStr];    //存储平台电话
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneStr];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebview];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }

}


- (void)toPushVC {
    ApplyAuthenticationVC *applyVC = [[ApplyAuthenticationVC alloc] init];
    applyVC.UpdateStoreInfo = ^{
        mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        [self requestGetApprovalStatus];     //请求门店审批状态
        [self requestPostUserGetInfo];      //刷新用户信息
    };
    applyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:applyVC animated:YES];
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
