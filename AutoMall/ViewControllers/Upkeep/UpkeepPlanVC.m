//
//  UpkeepPlanVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepPlanVC.h"
//#import "UpkeepPlanInfoCell.h"
#import "UpkeepPlanNormalCell.h"
#import "ServicePackageVC.h"
#import "BaoyangDiscountsVC.h"
#import "UpkeepCarInfoVC.h"
#import "AutoCheckOrderPayModeVC.h"
#import "ServiceContentDetailVC.h"
#import "AutoCheckDisountsVC.h"

@interface UpkeepPlanVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *serviceContentAry;
    NSMutableArray *packageAry;
    NSArray *selectedPackageAry;
    NSMutableArray *removeAry;  //去除重复的方案
    NSMutableDictionary *thePackageDic;
    NSArray *selectedDiscounts;    //选择的优惠
    NSDictionary *theDiscountDic;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation UpkeepPlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务方案";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
//    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"套餐" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
//    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanInfoCell" bundle:nil] forCellReuseIdentifier:@"planInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];

    packageAry = [NSMutableArray array];
    removeAry = [NSMutableArray array];
    thePackageDic = [NSMutableDictionary dictionary];
//    theDiscountDic =  [NSMutableDictionary dictionary];
    
    [self requestGetCarUpkeepServiceContent];   //请求服务方案列表
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

- (void) toPackage {
    ServicePackageVC *serviceVC = [[ServicePackageVC alloc] init];
    serviceVC.selectedDic = thePackageDic;
    serviceVC.SelecteServicePackage = ^(NSMutableDictionary *packageDic) {
        [thePackageDic setValuesForKeysWithDictionary: packageDic];
        selectedPackageAry = [packageDic allValues];
        NSLog(@"selectedPackageAry: %@",selectedPackageAry);
        NSArray * array = [NSArray arrayWithArray: removeAry];
        for (NSDictionary *dic1 in selectedPackageAry) {
            NSArray *serviceContents = dic1[@"serviceContents"];
            for (NSDictionary *dic2 in serviceContents) {
                int serviceId = [dic2[@"id"] intValue];
                for (NSDictionary *dic3 in array) {
                    if ([dic3[@"id"] intValue] == serviceId) {
                        [removeAry removeObject:dic3];
                    }
                }
            }
        }

        [self.myTableView reloadData];
    };
    [self.navigationController pushViewController:serviceVC animated:YES];
}

- (IBAction)confirmAction:(id)sender {
    [self requestPostCarUpkeepConfirm];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        switch (section) {
            case 0:
                return 4;
                break;
                
            case 1:
                return removeAry.count;
                break;
                
            case 2:
                return selectedPackageAry.count;
                break;
                
            case 3:
                return 1;
                break;
                
            case 4:
                return selectedDiscounts.count;
                break;
                
            case 5:
                return 1;
                break;
                
            default:
                return 1;
                break;
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
            switch (indexPath.section) {
                case 0: {
                    return 44;
                    break;
                }
                    
                default:
                    return 44;
                    break;
            }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        switch (section) {
            case 0:
                return 44;
                break;
                
            case 1:
                return 44;
                break;
                
            case 2:
                return 44;
                break;
                
            case 4:
                return 44;
                break;
                
            default:
                return 1;
                break;
        }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
        switch (section) {
            case 0:{
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = RGBCOLOR(249, 250, 251);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"车辆信息";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 24, 15, 8, 13);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(carInfo) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 1: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = RGBCOLOR(249, 250, 251);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"方案明细";
                
//                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
//                img.frame = CGRectMake(SCREEN_WIDTH - 24, 15, 8, 13);
//                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
//                [btn addTarget:self action:@selector(carInfo) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
//                [view addSubview:img];
//                [view addSubview:btn];
                return view;
                break;
            }
                
            case 2: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = RGBCOLOR(249, 250, 251);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"服务套餐";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 24, 15, 8, 13);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 4: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = RGBCOLOR(249, 250, 251);
//                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"优惠";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 24, 15, 8, 13);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(carDiscounts) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            default:
                return nil;
                break;
        }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        switch (indexPath.section) {
            case 0: {
                switch (indexPath.row) {
                    case 0: {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textLabel.text = self.carDic[@"plateNumber"];
                        return cell;
                        break;
                    }
                    case 1: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.text = @"车主";
                        cell.contentL.text = self.carDic[@"owner"];
                        return cell;
                        break;
                    }
                    case 2: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.text = @"品牌";
                        cell.contentL.text = self.carDic[@"brand"];;
                        return cell;
                        break;
                    }
                    case 3: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.text = @"车型";
                        cell.contentL.text = STRING(self.carDic[@"model"]);
                        return cell;
                        break;
                    }
                        
                    default: {
                        return nil;
                        break;
                    }
                }
                break;
            }
                
            case 1: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                NSDictionary *dic = removeAry[indexPath.row];
                cell.declareL.text = dic[@"name"];
                cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                return cell;
                break;
            }
                
            case 2: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSDictionary *dic = selectedPackageAry[indexPath.row];
                cell.declareL.text = dic[@"name"];
                cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                return cell;
                break;
            }
                
            case 3: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.text = @"总价";
                cell.contentL.text = @"￥6000";
                return cell;
                break;
            }
                
            case 4: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                NSDictionary *dic = selectedDiscounts[indexPath.row];
                cell.declareL.text = dic[@"item"];
                if (dic[@"money"]) {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"money"]];
                }
                return cell;
                break;
            }
                
            case 5: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.text = @"折后价";
                cell.contentL.text = @"￥5500";
                return cell;
                break;
            }
                
            default:
                return nil;
                break;
        }
 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch (indexPath.section) {
                
            case 1: {
                ServiceContentDetailVC *detailVC = [[ServiceContentDetailVC alloc] init];
                detailVC.serviceDic = removeAry[indexPath.row];
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            default:
                break;
        }
 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"添加" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        cell.declareL.strikeThroughEnabled = NO;
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        cell.declareL.strikeThroughEnabled = YES;
        tableView.editing = NO;
    }];
    
    if (cell.declareL.strikeThroughEnabled) {
        return @[action0];
    }
    return @[action1];
}

-(void)carInfo {
    UpkeepCarInfoVC *infoVC = [[UpkeepCarInfoVC alloc] init];
    infoVC.carDic = self.carDic;
    infoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoVC animated:YES];
}

-(void)carDiscounts {
    AutoCheckDisountsVC *discountsVC = [[AutoCheckDisountsVC alloc] init];
    discountsVC.selectedDic = theDiscountDic;
    discountsVC.SelecteDiscount = ^(NSMutableDictionary *discountDic) {
        theDiscountDic = [NSDictionary dictionaryWithDictionary:discountDic];
        selectedDiscounts = [discountDic allValues];
        [self.myTableView reloadData];
    };
    discountsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:discountsVC animated:YES];
}


////指定编辑模式，插入，删除
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    //单插入
//    //return UITableViewCellEditingStyleInsert ;
//    //多选删除
//    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
//}
//
////触发编辑方法；根据editingStyle来判断时那种类型
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    //删除
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//    }
//    
//    if (editingStyle == UITableViewCellEditingStyleInsert) {
//        //先添加
//        
//    }
//}
//
////更改删除按钮上的文本
//- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return @"删掉我吧";
//}

#pragma mark - 发送请求
-(void)requestGetCarUpkeepServiceContent { //检查单相关的服务方案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepServiceContent, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&checkTypeId=%@&storeId=%@",UrlPrefix(CarUpkeepServiceContent),@"1",@"1",@"2"];    //测试时固定传id=1的检查单
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestPostCarUpkeepConfirm { //检查单相关的服务方案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepConfirm object:nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepConfirm, @"op", nil];
    
    NSMutableArray *serviceContents = [NSMutableArray array];
    for (NSDictionary *dic in removeAry) {
        NSDictionary *dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"name"],@"name",dic[@"price"],@"price", nil];
        [serviceContents addObject:dicc];
    }
    
    NSMutableArray *servicePackages = [NSMutableArray array];
    for (NSDictionary *dic1 in selectedPackageAry) {
        NSDictionary *dicc1 = [NSDictionary dictionaryWithObjectsAndKeys:dic1[@"id"],@"id",dic1[@"name"],@"name",dic1[@"price"],@"price", nil];
        [servicePackages addObject:dicc1];
    }
    
    NSArray *discounts = @[@{@"id":@"8",@"item":@"2",@"price":@"10"}];
    
    
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"3000",@"money", serviceContents,@"serviceContents",servicePackages,@"servicePackages",discounts,@"discounts", nil];
    
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(CarUpkeepConfirm) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:CarUpkeepServiceContent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepServiceContent object:nil];
        NSLog(@"CarUpkeepCategory: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            serviceContentAry = responseObject[@"data"];
            [removeAry addObjectsFromArray:serviceContentAry];
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CarUpkeepConfirm]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepConfirm object:nil];
        NSLog(@"CarUpkeepConfirm: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}


- (void)toPopVC:(NSString *)carId {
        AutoCheckOrderPayModeVC *orderVC = [[AutoCheckOrderPayModeVC alloc] init];
        [self.navigationController pushViewController:orderVC animated:YES];
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
