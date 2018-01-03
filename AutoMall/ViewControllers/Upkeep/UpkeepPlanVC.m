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
#import "UpkeepCarInfoVC.h"
#import "AutoCheckOrderPayModeVC.h"
#import "ServiceContentDetailVC.h"
#import "AutoCheckDisountsVC.h"
//#import "UpKeepPlanServiceCell.h"
#import "UpkeepPlanSelectServiceCell.h"
#import "CheckResultSingleCell.h"
#import "CheckResultMultiCell.h"
#import "AutoCheckResultDetailVC.h"
#import "AutoCheckServicesVC.h"

@interface UpkeepPlanVC ()
{ 
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *serviceContentAry;
    NSArray *selectedPackageAry;
    NSMutableArray *removeAry;      //去除重复的方案
     NSMutableArray *lineationAry;     //记录划线的方案数组
    NSDictionary *thePackageDic;    //存储下级页面已选择的套餐
    NSArray *selectedServices;    //选择的门店服务
    NSDictionary *theServicesDic;   //存储下级页面已选择的门店服务
    NSArray *selectedDiscounts;    //选择的优惠
    NSDictionary *theDiscountDic;   //存储下级页面已选择的优惠
    float serVicePrice;            //方案总价
    float packagePrice;     //套餐价
    float discountPrice;    //优惠的价格（实际需要减掉的价格）
    float selectedServicePrice;    //门店服务的价格（实际需要加上的价格）
    NSMutableArray *unnormalAry;
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
    
//    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    searchBtn.frame = CGRectMake(0, 0, 44, 44);
////    searchBtn.contentMode = UIViewContentModeRight;
//    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    [searchBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
//    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [searchBtn setTitle:@"套餐" forState:UIControlStateNormal];
//    [searchBtn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
//    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
//    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanInfoCell" bundle:nil] forCellReuseIdentifier:@"planInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanSelectServiceCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanSelectServiceCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
    self.myTableView.tableFooterView = [UIView new];

    removeAry = [NSMutableArray array];
    lineationAry = [NSMutableArray array];
    unnormalAry = [NSMutableArray array];
    
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
    
    if (! serviceContentAry) {
        [self requestGetCarUpkeepServiceContent];   //请求服务方案列表
    }
    if (unnormalAry.count == 0) {
        [self requestGetAllUnnormal];
    }

}

- (void) toPackage {
    ServicePackageVC *serviceVC = [[ServicePackageVC alloc] init];
    serviceVC.carUpkeepId = self.carUpkeepId;
    serviceVC.checktypeID = self.checktypeID;
    serviceVC.selectedDic = thePackageDic;
    serviceVC.SelecteServicePackage = ^(NSMutableDictionary *packageDic) {
        thePackageDic = [NSDictionary dictionaryWithDictionary:packageDic];
        selectedPackageAry = [packageDic allValues];
        [removeAry removeAllObjects];       //重置removeAry数组
        [removeAry addObjectsFromArray:serviceContentAry];
        
        packagePrice = 0;
        for (NSDictionary *dic1 in selectedPackageAry) {
            if ([dic1[@"customized"] boolValue])  {
                packagePrice += [dic1[@"customizedPrice"] floatValue];
            } else {
                packagePrice += [dic1[@"price"] floatValue];
            }
            
            NSLog(@"packagePrice: %.2f",packagePrice);
            NSArray *serviceContents = dic1[@"serviceContents"];
            for (NSDictionary *dic2 in serviceContents) {
                int serviceId = [dic2[@"id"] intValue];
                for (NSDictionary *dic3 in serviceContentAry) {
                    if ([dic3[@"id"] intValue] == serviceId) {
                        [removeAry removeObject:dic3];
                    }
                }
            }
        }
        [lineationAry removeAllObjects];
        [lineationAry addObjectsFromArray:removeAry];
        serVicePrice = 0;     //初始化价格
        for (NSDictionary *dic in lineationAry) {
            if ([dic[@"customized"] boolValue]) {
                serVicePrice += [dic[@"customizedPrice"] floatValue];
            } else {
                serVicePrice += [dic[@"price"] floatValue];
            }
            
        }
        
        [self.myTableView reloadData];
    };
    [self.navigationController pushViewController:serviceVC animated:YES];
}

-(void)carInfo {
    UpkeepCarInfoVC *infoVC = [[UpkeepCarInfoVC alloc] init];
    infoVC.carDic = self.carDic;
    infoVC.mileage = self.mileage;
    infoVC.fuelAmount = self.fuelAmount;
    infoVC.lastEndTime = self.lastEndTime;
    infoVC.lastMileage = self.lastMileage;
    infoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoVC animated:YES];
}

-(void)toSelectServices {  //选择门店服务
    AutoCheckServicesVC *servicesVC = [[AutoCheckServicesVC alloc] init];
    servicesVC.selectedDic = theServicesDic;
    servicesVC.SelecteSerices = ^(NSMutableDictionary *servicesDic) {
        theServicesDic = [NSDictionary dictionaryWithDictionary:servicesDic];
        selectedServices = [servicesDic allValues];

        selectedServicePrice = 0;
        for (NSDictionary *dic in selectedServices) {
            if (dic[@"money"]) {
                selectedServicePrice += [dic[@"money"] floatValue];
            }
        }
        NSLog(@"selectedServicePrice: %.2f",selectedServicePrice);
        [self.myTableView reloadData];
    };
    servicesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:servicesVC animated:YES];
}


-(void)carDiscounts {       //选择优惠
    AutoCheckDisountsVC *discountsVC = [[AutoCheckDisountsVC alloc] init];
    discountsVC.selectedDic = theDiscountDic;
    discountsVC.SelecteDiscount = ^(NSMutableDictionary *discountDic) {
        theDiscountDic = [NSDictionary dictionaryWithDictionary:discountDic];
        selectedDiscounts = [discountDic allValues];
        
        discountPrice = 0;
        for (NSDictionary *dic in selectedDiscounts) {
            if (dic[@"money"]) {
                discountPrice += [dic[@"money"] floatValue];
            }
        }
        NSLog(@"discountPrice: %.2f",discountPrice);
        [self.myTableView reloadData];
    };
    discountsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:discountsVC animated:YES];
}

-(void)checkService:(UIButton *)btn {
    int row = (int)btn.tag - 100;
    NSDictionary *dic = removeAry[row];
    btn.selected = ! btn.selected;
    if (btn.selected) {
        [lineationAry addObject:dic];
        if ([dic[@"customized"] boolValue])  {
            serVicePrice += [dic[@"customizedPrice"] floatValue];
        } else {
            serVicePrice += [dic[@"price"] floatValue];
        }
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationLeft];
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:7] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else {
        [lineationAry removeObject:dic];
        if ([dic[@"customized"] boolValue])  {
            serVicePrice -= [dic[@"customizedPrice"] floatValue];
        } else {
            serVicePrice -= [dic[@"price"] floatValue];
        }
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationLeft];
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:7] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


- (IBAction)confirmAction:(id)sender {
    [self requestPostCarUpkeepConfirm];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        switch (section) {
            case 0:
                return 4;
                break;
                
            case 1:
                return unnormalAry.count;
                break;
                
            case 2:
                return removeAry.count;
                break;
                
            case 3:
                return selectedPackageAry.count;
                break;
                
            case 4:
                return selectedServices.count;
                break;
                
            case 5:
                return 1;
                break;
                
            case 6:
                return selectedDiscounts.count;
                break;
                
            case 7:
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
                    
                case 1: {
                    NSDictionary *dic = unnormalAry[indexPath.row];
                    if ([dic[@"checkContentVos"][@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                        NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
                        return 43 + 30*entities.count;
                    }
                    return 50;
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
                return 54;
                break;
                
            case 1:
                return 44;
                break;
                
            case 2:
                return 44;
                break;
                
            case 3:
                return 44;
                break;
                
            case 4:
                return 44;
                break;
                
            case 6:
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
                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
                bgView.backgroundColor = [UIColor clearColor];
                
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.myTableView.bounds), 44)];
//                view.backgroundColor = RGBCOLOR(249, 250, 251);
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"车辆信息";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 7, 11);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(carInfo) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                [bgView addSubview:view];
                return bgView;
                break;
            }
                
            case 1: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"检查结果";
                
                [view addSubview:label];
                return view;
                break;
            }
                
            case 2: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
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
                
            case 3: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"服务套餐";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 7, 11);
                
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
                view.backgroundColor = [UIColor whiteColor];
                //                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"门店服务";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 6, 11);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(toSelectServices) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 6: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
//                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"优惠";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 6, 11);
                
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
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.strikeThroughEnabled = NO;
                        cell.declareL.text = @"车牌";
                        cell.declareL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.text = STRING(self.carDic[@"plateNumber"]);
                        cell.contentL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.textColor = [UIColor blackColor];
                        return cell;
                        break;
                    }
                    case 1: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.strikeThroughEnabled = NO;
                        cell.declareL.text = @"车主";
                        cell.declareL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.text = STRING(self.carDic[@"owner"]);
                        cell.contentL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.textColor = [UIColor blackColor];
                        return cell;
                        break;
                    }
                    case 2: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.strikeThroughEnabled = NO;
                        cell.declareL.text = @"品牌";
                        cell.declareL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.text = STRING(self.carDic[@"brand"]);
                        cell.contentL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.textColor = [UIColor blackColor];
                        return cell;
                        break;
                    }
                    case 3: {
                        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.declareL.strikeThroughEnabled = NO;
                        cell.declareL.text = @"车型";
                        cell.declareL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.text = STRING(self.carDic[@"model"]);
                        cell.contentL.font = [UIFont systemFontOfSize:15];
                        cell.contentL.textColor = [UIColor blackColor];
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
                NSDictionary *dic = unnormalAry[indexPath.row];

                if ([dic[@"checkContentVos"][@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                    CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.positionL.text = dic[@"name"];
                    cell.checkContentL.text = dic[@"checkContentVos"][@"name"];
                    NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
                    
                    for (UIView *subViews in cell.positionView.subviews) {
                        [subViews removeFromSuperview];
                    }
                    
                    for (int i=0; i < entities.count; ++i) {
                        NSDictionary *dic1 = entities[i];
                        UILabel *position = [[UILabel alloc] initWithFrame:CGRectMake(0, 30*i , 80, 22)];
                        position.text = STRING(dic1[@"dPosition"]);
                        position.tag = 100 + i;
                        position.textColor = [UIColor grayColor];
                        position.font = [UIFont systemFontOfSize:14];
                        
                        UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 106 - 8 - 16 - 55 - 15 - 80, 30*i , 80, 22)];
                        result.text = STRING(dic1[@"describe"]);
                        result.textColor = [UIColor grayColor];
                        result.font = [UIFont systemFontOfSize:14];
                        
                        UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 106 - 8 - 16 - 55 , 30*i , 55, 22)];
                        level.text = STRING(dic1[@"result"]);
                        level.minimumFontSize = 8;
                        level.textAlignment = NSTextAlignmentCenter;
                        level.textColor = [UIColor whiteColor];
                        level.backgroundColor = RGBCOLOR(0, 166, 59);
                        level.font = [UIFont systemFontOfSize:13];
                        level.layer.cornerRadius = 4;
                        level.clipsToBounds = YES;
                        int levelInt = [dic1[@"level"] intValue];
                        if (levelInt == 1) {
                            level.backgroundColor = RGBCOLOR(250, 69, 89);
                        }
                        else if (levelInt == 2) {
                            level.backgroundColor = RGBCOLOR(249, 182, 48);
                        }
                        else if (levelInt == 3) {
                            level.backgroundColor = RGBCOLOR(71, 188, 92);
                        }
                        [cell.positionView addSubview:position];
                        [cell.positionView addSubview:result];
                        [cell.positionView addSubview:level];
                    }
                    
                    return cell;
                }
                else {
                    CheckResultSingleCell *cell = (CheckResultSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultSingleCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.levelL.layer.cornerRadius = 4;
                    cell.positionL.text = dic[@"name"];
                    cell.checkContentL.text = dic[@"checkContentVos"][@"name"];
                    cell.resultL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"describe"]);
                    int level = [[dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"level"] intValue];
                    cell.levelL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"result"]);
                    if (level == 1) {
                        cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
                    }
                    else if (level == 2) {
                        cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
                    }
                    else if (level == 3) {
                        cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
                    }
                    
                    return cell;
                }
                break;
            }
                
            case 2: {
                UpkeepPlanSelectServiceCell *cell = (UpkeepPlanSelectServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanSelectServiceCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                NSDictionary *dic = removeAry[indexPath.row];

                if ([lineationAry containsObject:dic]) {    //如果包含，则勾选
                    cell.checkBtn.selected = YES;
                } else {
                    cell.checkBtn.selected = NO;
                }
                cell.checkBtn.tag = indexPath.row + 100;
                [cell.checkBtn addTarget:self action:@selector(checkService:) forControlEvents:UIControlEventTouchUpInside];
                cell.declareL.text = dic[@"name"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                if ([dic[@"customized"] boolValue]) {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@",STRING(dic[@"customizedPrice"])];
                } else {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                }
                
                return cell;
                break;
            }
                
            case 3: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = selectedPackageAry[indexPath.row];
                cell.declareL.text = dic[@"name"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                if ([dic[@"customized"] boolValue]) {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%@",STRING(dic[@"customizedPrice"])];
                } else {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                }
                cell.contentL.textColor = [UIColor blackColor];
                
                return cell;
                break;
            }
                
            case 4: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = selectedServices[indexPath.row];
                cell.declareL.text = dic[@"item"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                if (dic[@"money"]) {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%@",dic[@"money"]];
                } else {
                    cell.contentL.text = @"";
                }
                cell.contentL.textColor = [UIColor blackColor];
                cell.contentL.font = [UIFont systemFontOfSize:15];
                return cell;
                break;
            }
                
            case 5: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                cell.declareL.text = @"总价";
                cell.declareL.font = [UIFont boldSystemFontOfSize:15];
                cell.contentL.text = [NSString stringWithFormat:@"￥%.2f",serVicePrice + packagePrice + selectedServicePrice];
                cell.contentL.font = [UIFont boldSystemFontOfSize:16];
                cell.contentL.textColor = [UIColor blackColor];
                return cell;
                break;
            }
                
            case 6: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = selectedDiscounts[indexPath.row];
                cell.declareL.text = dic[@"item"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                if (dic[@"money"]) {
                    cell.contentL.text = [NSString stringWithFormat:@"-￥%@",dic[@"money"]];
                } else {
                    cell.contentL.text = @"";
                }
                cell.contentL.textColor = RGBCOLOR(234, 33, 45);
                cell.contentL.font = [UIFont systemFontOfSize:15];
                return cell;
                break;
            }
                
            case 7: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                cell.declareL.text = @"折后价";
                cell.declareL.font = [UIFont boldSystemFontOfSize:15];
                NSLog(@"serVicePrice + packagePrice - discountPrice + selectedServicePrice:  %.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice);
                if (serVicePrice + packagePrice - discountPrice + selectedServicePrice < 0) {
                    cell.contentL.text = @"￥0";
                } else {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice];
                }
                cell.contentL.font = [UIFont boldSystemFontOfSize:16];
                cell.contentL.textColor = [UIColor blackColor];
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
                NSDictionary *dic = unnormalAry[indexPath.row];
                AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
                detailVC.checkId = self.carUpkeepId;
                detailVC.checkTermId = dic[@"id"];
                detailVC.checkContentId = dic[@"checkContentVos"][@"id"];
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            case 2: {
                ServiceContentDetailVC *detailVC = [[ServiceContentDetailVC alloc] init];
                detailVC.serviceDic = removeAry[indexPath.row];
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            default:
                break;
        }
 
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 2) {
//        return YES;
//    }
//    return NO;
//}

///**
// *  左滑cell时出现什么按钮
// */
//- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"添加" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        cell.declareL.strikeThroughEnabled = NO;
//        NSDictionary *dic = removeAry[indexPath.row];
//        [lineationAry addObject:dic];
//        tableView.editing = NO;
//        
//        if ([dic[@"customized"] boolValue])  {
//            serVicePrice += [dic[@"customizedPrice"] floatValue];
//        } else {
//            serVicePrice += [dic[@"price"] floatValue];
//        }
//        
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationLeft];
//    }];
//    
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        cell.declareL.strikeThroughEnabled = YES;
//        NSDictionary *dic = removeAry[indexPath.row];
//        [lineationAry removeObject:dic];
//        tableView.editing = NO;
//        
//        if ([dic[@"customized"] boolValue])  {
//            serVicePrice -= [dic[@"customizedPrice"] floatValue];
//        } else {
//            serVicePrice -= [dic[@"price"] floatValue];
//        }
//        
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:6] withRowAnimation:UITableViewRowAnimationLeft];
////        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3,5)] withRowAnimation:UITableViewRowAnimationFade];
//    }];
//    
//    if (cell.declareL.strikeThroughEnabled) {
//        return @[action0];
//    }
//    return @[action1];
//}


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
-(void)requestGetAllUnnormal { //获取所有异常
    [_hud show:YES];
    //注册通知 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUnnormal object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUnnormal, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepUnnormal),self.carUpkeepId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestGetCarUpkeepServiceContent { //检查单相关的服务方案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepServiceContent, @"op", nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&checkTypeId=%@&storeId=%@",UrlPrefix(CarUpkeepServiceContent),self.carUpkeepId,self.checktypeID,storeId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestPostCarUpkeepConfirm { //确认服务方案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepConfirm object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepConfirm, @"op", nil];
    
    NSMutableArray *serviceContents = [NSMutableArray array];
    for (NSDictionary *dic in lineationAry) {   //只提交没有划线的
        NSDictionary *dicc;
        if ([dic[@"customized"] boolValue])  {
            dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"name"],@"name",dic[@"customizedPrice"],@"price", nil];
        } else {
            dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"name"],@"name",dic[@"price"],@"price", nil];
        }
        [serviceContents addObject:dicc];
    }
    
    NSMutableArray *servicePackages = [NSMutableArray array];
    for (NSDictionary *dic1 in selectedPackageAry) {
        NSDictionary *dicc1;
        if ([dic1[@"customized"] boolValue])  {
            dicc1 = [NSDictionary dictionaryWithObjectsAndKeys:dic1[@"id"],@"id",dic1[@"name"],@"name",dic1[@"customizedPrice"],@"price", nil];
        } else {
            dicc1 = [NSDictionary dictionaryWithObjectsAndKeys:dic1[@"id"],@"id",dic1[@"name"],@"name",dic1[@"price"],@"price", nil];
        }
        
        [servicePackages addObject:dicc1];
    }
    
    NSMutableArray *discounts = [NSMutableArray array];
    for (NSDictionary *dic2 in selectedDiscounts) {
        NSDictionary *dicc2 = [NSDictionary dictionaryWithObjectsAndKeys:dic2[@"id"],@"id",dic2[@"item"],@"item",dic2[@"money"],@"money", nil];
        [discounts addObject:dicc2];
    }
    
    NSMutableArray *servicesMul = [NSMutableArray array];
    for (NSDictionary *dic3 in selectedServices) {
        NSDictionary *dicc3 = [NSDictionary dictionaryWithObjectsAndKeys:dic3[@"id"],@"id",dic3[@"item"],@"item",dic3[@"money"],@"money", nil];
        [servicesMul addObject:dicc3];
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.carUpkeepId, @"id", [NSString stringWithFormat:@"%.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice],@"money", serviceContents,@"serviceContents",servicePackages,@"servicePackages",discounts,@"discounts",servicesMul,@"services", nil];
    
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
    
    if ([notification.name isEqualToString:CarUpkeepUnnormal]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepUnnormal object:nil];
        NSLog(@"CarUpkeepUnnormal: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            NSArray *checkTermVos = responseObject[@"data"];
            
            for (NSDictionary *dic1 in checkTermVos) {
                NSMutableArray *checkContentVosAry = [NSMutableArray array];
                NSLog(@"dic1: %@",dic1);
                NSArray *checkContentVos = dic1[@"checkContentVos"];
                for (NSDictionary *dic2 in checkContentVos) {
                    NSLog(@"dic1name%@",dic1[@"name"]);
                    NSDictionary *dic3 = @{@"id":dic1[@"id"],@"name":dic1[@"name"],@"checkContentVos":dic2};
                    [checkContentVosAry addObject:dic3];
                }
                [unnormalAry addObjectsFromArray:checkContentVosAry];
            }
            NSLog(@"unnormalAry: %@",unnormalAry);
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CarUpkeepServiceContent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepServiceContent object:nil];
        NSLog(@"CarUpkeepCategory: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            serviceContentAry = responseObject[@"data"];
            [removeAry addObjectsFromArray:serviceContentAry];
            [lineationAry addObjectsFromArray:removeAry];
            serVicePrice = 0;     //初始化价格
            for (NSDictionary *dic in lineationAry) {
                if ([dic[@"customized"] boolValue]) {
                    serVicePrice += [dic[@"customizedPrice"] floatValue];
                } else {
                    serVicePrice += [dic[@"price"] floatValue];
                }
                
            }
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
            [self performSelector:@selector(toPushVC:) withObject:responseObject[@"data"][@"code"] afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}


- (void)toPushVC:(NSString *)orderId {
    AutoCheckOrderPayModeVC *orderVC = [[AutoCheckOrderPayModeVC alloc] init];
    orderVC.checkOrderId = self.carUpkeepId;
    NSNumber *moneyN = [NSNumber numberWithFloat:serVicePrice + packagePrice - discountPrice + selectedServicePrice];
    NSDictionary *dic = @{@"orderId":[NSString stringWithFormat:@"%@",orderId],@"money":moneyN,@"plateNumber":STRING(self.carDic[@"plateNumber"]),@"owner":STRING(self.carDic[@"owner"])};
    orderVC.infoDic = dic;
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
