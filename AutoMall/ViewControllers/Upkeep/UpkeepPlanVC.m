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
#import "UpkeepPlanSignCell.h"
#import "AutoCheckResultDetailVC.h"
#import "AutoCheckServicesVC.h"
#import "BJTSignView.h"
#import "ServiceAndDiscountsVC.h"
#import "AddServicesVC.h"
#import "LXActivity.h"
#import "ShareTool.h"

@interface UpkeepPlanVC () <UIAlertViewDelegate,LXActivityDelegate>
{ 
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *serviceContentAry;
    NSArray *selectedPackageAry;
    NSMutableArray *removeAry;      //去除重复的方案
     NSMutableArray *lineationAry;     //记录已选择的方案数组
    NSDictionary *thePackageDic;    //存储下级页面已选择的套餐
    NSArray *selectedServices;    //选择的门店服务
    NSDictionary *theServicesDic;   //存储下级页面已选择的门店服务
    NSArray *selectedDiscounts;    //选择的优惠
    NSDictionary *theDiscountDic;   //存储下级页面已选择的优惠
    float serVicePrice;            //方案总价
    float packagePrice;     //套餐价
    float discountPrice;    //优惠的价格（实际需要减掉的价格）
    float selectedServicePrice;    //门店服务的价格（实际需要加上的价格）
    float addedServicePrice;    //增加服务的价格（实际需要加上的价格）
    NSMutableArray *unnormalAry;
    UIImage *signImg;       //签名图片
    NSString *signImgStr;   //签名图片地址
    NSMutableDictionary *serviceNumberDic;     //记录选择的服务方案的数量
    NSMutableDictionary *storeServiceNumberDic;     //记录门店服务的数量
    NSMutableDictionary *discountsNumberDic;     //记录优惠的数量
    NSMutableArray *addedServicesAry;       //记录已增加的服务
    NSDictionary *shareDic;     //分享文案
    LXActivity *lxActivity;
    NSString *order_code;   //服务方案订单号
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *signBgView;
@property (strong, nonatomic) IBOutlet BJTSignView *signView;

@end

@implementation UpkeepPlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务方案";
    // 设置导航栏按钮和标题颜色
//    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain target:self action:@selector(toFirst)];
    self.navigationItem.leftBarButtonItem = backBtn;
    self.navigationItem.leftBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
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
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanSignCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanSignCell"];
    self.myTableView.tableFooterView = [UIView new];

    removeAry = [NSMutableArray array];
    serviceNumberDic = [NSMutableDictionary dictionary];
    storeServiceNumberDic = [NSMutableDictionary dictionary];
    discountsNumberDic = [NSMutableDictionary dictionary];
    lineationAry = [NSMutableArray array];
    unnormalAry = [NSMutableArray array];
    addedServicesAry = [NSMutableArray array];
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

-(void)toFirst {        //返回首页
    NSLog(@"返回首页");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认回到首页吗？" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
    alert.tag = 200;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 300) {    //是否分享
        if (buttonIndex == 1) {
            [self requestGetShareInfo];
        }
        else {
            [self performSelector:@selector(toPushVC:) withObject:order_code afterDelay:HUDDelay];
        }
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
        
        [serviceNumberDic removeAllObjects];
        for (NSDictionary *dicc in removeAry) {     //遍历赋初始值，都为1
            [serviceNumberDic setObject:@"1" forKey:dicc[@"id"]];     //object:数量，key:服务方案id
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
        
        [storeServiceNumberDic removeAllObjects];
        for (NSDictionary *dicc in selectedServices) {     //遍历赋初始值，都为1
            [storeServiceNumberDic setObject:@"1" forKey:dicc[@"id"]];     //object:数量，key:服务方案id
        }

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


-(void)toAddServices {
    AddServicesVC *addVC = [[AddServicesVC alloc] init];
    addVC.titleStr = @"增加服务";
    addVC.AddedDiscount = ^(NSDictionary *addedDic) {
        [addedServicesAry addObject:addedDic];
        
        addedServicePrice = 0.0;
        for (NSDictionary *dic in addedServicesAry) {
            float money = [dic[@"money"] floatValue];
            addedServicePrice += money;
        }
        
        [self.myTableView reloadData];
    };
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

-(void)carDiscounts {       //选择优惠
    AutoCheckDisountsVC *discountsVC = [[AutoCheckDisountsVC alloc] init];
    discountsVC.selectedDic = theDiscountDic;
    discountsVC.SelecteDiscount = ^(NSMutableDictionary *discountDic) {
        theDiscountDic = [NSDictionary dictionaryWithDictionary:discountDic];
        selectedDiscounts = [discountDic allValues];
        
        [discountsNumberDic removeAllObjects];
        for (NSDictionary *dicc in selectedDiscounts) {     //遍历赋初始值，都为1
            [discountsNumberDic setObject:@"1" forKey:dicc[@"id"]];     //object:数量，key:服务方案id
        }
        
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
    int num = [serviceNumberDic[dic[@"id"]] intValue];
    btn.selected = ! btn.selected;
    if (btn.selected) {
        [lineationAry addObject:dic];
        if ([dic[@"customized"] boolValue])  {
            serVicePrice += [dic[@"customizedPrice"] floatValue] * num;
        } else {
            serVicePrice += [dic[@"price"] floatValue] * num;
        }
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:7] withRowAnimation:UITableViewRowAnimationLeft];
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:9] withRowAnimation:UITableViewRowAnimationLeft];
    }
    else {
        [lineationAry removeObject:dic];
        if ([dic[@"customized"] boolValue])  {
            serVicePrice -= [dic[@"customizedPrice"] floatValue] * num;
        } else {
            serVicePrice -= [dic[@"price"] floatValue] * num;
        }
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:7] withRowAnimation:UITableViewRowAnimationLeft];
        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:9] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


- (IBAction)confirmAction:(id)sender {
    if (! signImgStr || signImgStr.length == 0) {
        _networkConditionHUD.labelText = @"请车主确认服务方案并签名";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice > 0) {
        [self requestPostCarUpkeepConfirm];
    }
    else {
        _networkConditionHUD.labelText = @"没有选择服务方案";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}
- (IBAction)clearSign:(id)sender {
    [self.signView clearSignature];
}
- (IBAction)cancelSign:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.signBgView.alpha = 0;
    }];
}
- (IBAction)completeSign:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        self.signBgView.alpha = 0;
    }];
    
    UpkeepPlanSignCell *cell = (UpkeepPlanSignCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:10]];
    UIImage *image  =  [self.signView getSignatureImage];
    signImg = image;
    cell.signImgView.image = image;
    
    [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:10] withRowAnimation:UITableViewRowAnimationNone];
    
    [self requestUploadImgFile:cell.signImgView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        return 11;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        switch (section) {
            case 0:
                return 4;
                break;
                
            case 1:
                return 1;
            break;
                
            case 2:
                return unnormalAry.count;
                break;
                
            case 3:
                return removeAry.count;
                break;
                
            case 4:
                return selectedPackageAry.count;
                break;
                
            case 5:
                return selectedServices.count;
                break;
                
            case 6:
                return addedServicesAry.count;
            break;
                
            case 7:
                return 1;
                break;
                
            case 8:
                return selectedDiscounts.count;
                break;
                
            case 9:
                return 1;
                break;
                
            case 10:
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
                    
                case 2: {
                    NSDictionary *dic = unnormalAry[indexPath.row];
                    if ([dic[@"checkContentVos"][@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                        NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
                        return 43 + 30*entities.count;
                    }
                    return 50;
                    break;
                }
                    
                case 10: {
                    return 200;
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
                
            case 2:
                return 44;
                break;
                
            case 3:
                return 44;
                break;
                
            case 4:
                return 44;
                break;
                
            case 5:
                return 44;
                break;
                
            case 6:
                return 44;
                break;
                
            case 8:
                return 44;
                break;
                
            case 10:
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
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 11, 20);
                
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
                
            case 2: {
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
                
            case 3: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"方案明细";
                
                [view addSubview:label];
                return view;
                break;
            }
                
            case 4: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"服务套餐";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 11, 20);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 5: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                //                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"门店服务";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 11, 20);
                
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
                label.text = @"增加服务";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 11, 20);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(toAddServices) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 8: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
//                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"优惠";
                
                UIImageView *img = [[UIImageView alloc] initWithImage:IMG(@"arrows")];
                img.frame = CGRectMake(SCREEN_WIDTH - 26, 16, 11, 20);
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
                [btn addTarget:self action:@selector(carDiscounts) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
                [view addSubview:img];
                [view addSubview:btn];
                return view;
                break;
            }
                
            case 10: {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
                view.backgroundColor = [UIColor whiteColor];
                //                view.backgroundColor = RGBCOLOR(239, 239, 239);
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 200, 20)];
                label.font = [UIFont boldSystemFontOfSize:15];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"车主确认服务方案签名";
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                btn.frame = CGRectMake(SCREEN_WIDTH - 16 - 80, 0, 80 , 44);
//                btn.titleLabel.font = [UIFont systemFontOfSize:15];
//                [btn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
//                [btn setTitle:@"确认签名" forState:UIControlStateNormal];
//                [btn addTarget:self action:@selector(signConfirm) forControlEvents:UIControlEventTouchUpInside];
                
                [view addSubview:label];
//                [view addSubview:btn];
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
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                cell.declareL.text = @"检查类别";
                cell.declareL.font = [UIFont boldSystemFontOfSize:15];
                cell.contentL.text = self.checktypeName;    //检查类别名称
                cell.contentL.font = [UIFont boldSystemFontOfSize:15];
                cell.contentL.textColor = RGBCOLOR(104, 104, 104);
                return cell;
                break;
            }
                
            case 2: {
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
                
            case 3: {
                UpkeepPlanSelectServiceCell *cell = (UpkeepPlanSelectServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanSelectServiceCell"];
            
                NSDictionary *dic = removeAry[indexPath.row];

                if ([lineationAry containsObject:dic]) {    //如果包含，则勾选
                    cell.checkBtn.selected = YES;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                } else {
                    cell.checkBtn.selected = NO;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.checkBtn.tag = indexPath.row + 100;
                [cell.checkBtn addTarget:self action:@selector(checkService:) forControlEvents:UIControlEventTouchUpInside];
                cell.declareL.text = dic[@"name"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                NSString *numStr = serviceNumberDic[dic[@"id"]];
                if ([dic[@"customized"] boolValue]) {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@ *%@",STRING(dic[@"customizedPrice"]),numStr];
                } else {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@ *%@",dic[@"price"],numStr];
                }
                
                return cell;
                break;
            }
                
            case 4: {
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
                
            case 5: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = selectedServices[indexPath.row];
                cell.declareL.text = dic[@"item"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                NSString *numStr = storeServiceNumberDic[dic[@"id"]];
                if (dic[@"money"]) {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%@ *%@",dic[@"money"],numStr];
                } else {
                    cell.contentL.text = @"";
                }
                cell.contentL.textColor = [UIColor blackColor];
                cell.contentL.font = [UIFont systemFontOfSize:15];
                return cell;
                break;
            }
                
            case 6: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = addedServicesAry[indexPath.row];
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
                
            case 7: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                cell.declareL.text = @"总价";
                cell.declareL.font = [UIFont boldSystemFontOfSize:15];
                cell.contentL.text = [NSString stringWithFormat:@"￥%.2f",serVicePrice + packagePrice + selectedServicePrice + addedServicePrice];
                cell.contentL.font = [UIFont boldSystemFontOfSize:16];
                cell.contentL.textColor = [UIColor blackColor];
                return cell;
                break;
            }
                
            case 8: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.declareL.strikeThroughEnabled = NO;
                NSDictionary *dic = selectedDiscounts[indexPath.row];
                cell.declareL.text = dic[@"item"];
                cell.declareL.font = [UIFont systemFontOfSize:15];
                NSString *numStr = discountsNumberDic[dic[@"id"]];
                if (dic[@"money"]) {
                    cell.contentL.text = [NSString stringWithFormat:@"-￥%@ *%@",dic[@"money"],numStr];
                } else {
                    cell.contentL.text = @"";
                }
                cell.contentL.textColor = RGBCOLOR(234, 33, 45);
                cell.contentL.font = [UIFont systemFontOfSize:15];
                return cell;
                break;
            }
                
            case 9: {
                UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.declareL.strikeThroughEnabled = NO;
                cell.declareL.text = @"折后价";
                cell.declareL.font = [UIFont boldSystemFontOfSize:15];
                NSLog(@"serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice:  %.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice);
                if (serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice < 0) {
                    cell.contentL.text = @"￥0";
                } else {
                    cell.contentL.text = [NSString stringWithFormat:@"￥%.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice];
                }
                cell.contentL.font = [UIFont boldSystemFontOfSize:16];
                cell.contentL.textColor = [UIColor blackColor];
                return cell;
                break;
            }
                
            case 10: {
                UpkeepPlanSignCell *cell = (UpkeepPlanSignCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanSignCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                if (signImg) {
                    cell.noticeL.text = @"";
                    cell.signImgView.image = signImg;
                }
                
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
                
            case 2: {
                NSDictionary *dic = unnormalAry[indexPath.row];
                AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
                detailVC.checkId = self.carUpkeepId;
                detailVC.checkTermId = dic[@"id"];
                detailVC.checkContentId = dic[@"checkContentVos"][@"id"];
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            case 3: {
                NSDictionary *dic = removeAry[indexPath.row];
                if ([lineationAry containsObject:dic]) {    //如果包含，则勾
                    ServiceContentDetailVC *detailVC = [[ServiceContentDetailVC alloc] init];
                    detailVC.serviceDic = dic;
                    id key = dic[@"id"];
                    detailVC.numStr = serviceNumberDic[key];
                    detailVC.SelecteServiceNumber = ^(NSString *numStr) {
                        [serviceNumberDic setObject:numStr forKey:key];
                        
                        serVicePrice = 0;     //初始化价格
                        for (NSDictionary *dic in lineationAry) {
                            int num = [serviceNumberDic[dic[@"id"]] intValue];
                            if ([dic[@"customized"] boolValue]) {
                                serVicePrice += [dic[@"customizedPrice"] floatValue] * num;
                            } else {
                                serVicePrice += [dic[@"price"] floatValue] * num;
                            }
                            
                        }
                        
                        [self.myTableView reloadData];
                    };
                    [self.navigationController pushViewController:detailVC animated:YES];
                }

                break;
            }
                
            case 5: {
                ServiceAndDiscountsVC *detailVC = [[ServiceAndDiscountsVC alloc] init];
                detailVC.titleStr = @"门店服务详情";
                detailVC.theDic = selectedServices[indexPath.row];
                id key = selectedServices[indexPath.row][@"id"];
                detailVC.numStr = storeServiceNumberDic[key];
                detailVC.SelecteTheNumber = ^(NSString *numStr) {
                    [storeServiceNumberDic setObject:numStr forKey:key];
                    
                    selectedServicePrice = 0;
                    for (NSDictionary *dic in selectedServices) {
                        if (dic[@"money"]) {
                            int num = [storeServiceNumberDic[dic[@"id"]] intValue];
                            selectedServicePrice += [dic[@"money"] floatValue] * num;
                        }
                    }
                    NSLog(@"selectedServicePrice: %.2f",selectedServicePrice);
                    
                    [self.myTableView reloadData];
                };
                
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            case 6: {
                AddServicesVC *addVC = [[AddServicesVC alloc] init];
                addVC.titleStr = @"服务详情";
                addVC.serviceDic = addedServicesAry[indexPath.row];
                addVC.AddedDiscount = ^(NSDictionary *addedDic) {
                    [addedServicesAry replaceObjectAtIndex:indexPath.row withObject:addedDic];  //修改
//                    [addedServicesAry addObject:addedDic];
                    
                    addedServicePrice = 0.0;
                    for (NSDictionary *dic in addedServicesAry) {
                        float money = [dic[@"money"] floatValue];
                        addedServicePrice += money;
                    }
                    
                    [self.myTableView reloadData];
                };
                addVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addVC animated:YES];
                break;
            }
                
            case 8: {
                ServiceAndDiscountsVC *detailVC = [[ServiceAndDiscountsVC alloc] init];
                detailVC.titleStr = @"优惠详情";
                detailVC.theDic = selectedDiscounts[indexPath.row];
                id key = selectedDiscounts[indexPath.row][@"id"];
                detailVC.numStr = discountsNumberDic[key];
                detailVC.SelecteTheNumber = ^(NSString *numStr) {
                    [discountsNumberDic setObject:numStr forKey:key];
                    
                    discountPrice = 0;
                    for (NSDictionary *dic in selectedDiscounts) {
                        if (dic[@"money"]) {
                            int num = [discountsNumberDic[dic[@"id"]] intValue];
                            discountPrice += [dic[@"money"] floatValue] * num;
                        }
                    }
                    NSLog(@"discountPrice: %.2f",discountPrice);
                    
                    [self.myTableView reloadData];
                };
                

                
                [self.navigationController pushViewController:detailVC animated:YES];
                break;
            }
                
            case 10: {
                [UIView animateWithDuration:0.3 animations:^{
                    self.signBgView.alpha = 1;
                }];
                
                break;
            }
                
            default:
                break;
        }
 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 6) {
        return YES;
    }
    return NO;
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSDictionary *dic = addedServicesAry[indexPath.row];
        float money = [dic[@"money"] floatValue];
        addedServicePrice -= money;
        [addedServicesAry removeObjectAtIndex:indexPath.row];
        tableView.editing = NO;
        [self.myTableView reloadData];
        
    }];
    
//    if (cell.declareL.strikeThroughEnabled) {
//        return @[action0];
//    }
    return @[action1];
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

#pragma mark -  分享相关

//创建分享视图
-(void)createShareView{
    NSArray *shareButtonTitleArray = [[NSArray alloc] init];
    NSArray *shareButtonImageNameArray = [[NSArray alloc] init];
    
    /**
     *  李俊阳修改的分享模块
     */
    shareButtonTitleArray = @[@"微信好友",@"微信朋友圈"];
    shareButtonImageNameArray = @[@"share_wx",@"share_pyq"];
    
    if (!lxActivity) {
        lxActivity = [[LXActivity alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消分享" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    }
}

-(void)shareClicked {
    [lxActivity show];
}

#pragma mark -
#pragma mark - LXActivityDelegate

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES]; //显示加载中
    NSUInteger index = (NSUInteger)imageIndex;
    NSLog(@"%ld",(long)index);
    
    /**
     *  李俊阳添加的调用原生WX分享的代码
     */
    int scene = (int)index;
    
    NSString *title = shareDic [@"shareTitle"];
    if ([title isEqualToString:@""]) {
        title = @"检查结果分享";
    }
    
    NSString *imgUrlStr = shareDic [@"shareImage"];
    if (! [shareDic [@"storeLogo"] isKindOfClass:[NSNull class]] && [shareDic [@"storeLogo"] length] > 0) {
        imgUrlStr = UrlPrefix(shareDic [@"storeLogo"]);
    }
    NSString *url = shareDic [@"shareUrl"];
    //    if ([url isEqualToString:@""]) {
    //        url = @"";
    //    }
    NSString *defaultContent = shareDic [@"shareTitle"];
    if ([defaultContent isEqualToString:@""]) {
        defaultContent = @"i爱检车";
    }
    
    //    NSString *content = [NSString stringWithFormat:@"%@\n%@",title,url];
    NSString *content = @"门店名称";
    if (! [shareDic [@"storeName"] isKindOfClass:[NSNull class]] && [shareDic [@"storeName"] length] > 0) {
        content = shareDic [@"storeName"];
    }
    
    NSString *urlStr = nil;
    if ([imgUrlStr hasPrefix:@"http://"]) {//网络url
        urlStr = imgUrlStr;
    }else{
        urlStr = [[NSBundle mainBundle] pathForResource:@"icon80" ofType:@"png"];
    }
    
    if (scene == 1) { //微信好友会话
        defaultContent = title;
    }
    
    [ShareTool ShareToWxWithScene:scene andTitle:defaultContent andDescription:content andThumbImageUrlStr:urlStr andWebUrlStr:url];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - 发起网络请求
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
            dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"name"],@"name",dic[@"customizedPrice"],@"price",serviceNumberDic[dic[@"id"]],@"number", nil];
        } else {
            dicc = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"name"],@"name",dic[@"price"],@"price",serviceNumberDic[dic[@"id"]],@"number", nil];
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
        NSDictionary *dicc2 = [NSDictionary dictionaryWithObjectsAndKeys:dic2[@"id"],@"id",dic2[@"item"],@"item",dic2[@"money"],@"money",discountsNumberDic[dic2[@"id"]],@"number", nil];
        [discounts addObject:dicc2];
    }
    
    NSMutableArray *servicesMul = [NSMutableArray array];
    for (NSDictionary *dic3 in selectedServices) {
        NSDictionary *dicc3 = [NSDictionary dictionaryWithObjectsAndKeys:dic3[@"id"],@"id",dic3[@"item"],@"item",dic3[@"money"],@"money",storeServiceNumberDic[dic3[@"id"]],@"number", nil];
        [servicesMul addObject:dicc3];
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.carUpkeepId, @"id", [NSString stringWithFormat:@"%.2f",serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice],@"money",signImgStr,@"signImage", serviceContents,@"serviceContents",servicePackages,@"servicePackages",addedServicesAry,@"customerServices",discounts,@"discounts",servicesMul,@"services", nil];
    
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(CarUpkeepConfirm) delegate:nil params:pram info:infoDic];
}

-(void)requestUploadImgFile:(WPImageView *)image {  //上传图片
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}

-(void)requestGetShareInfo { //获取分享文案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepShareService object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepShareService, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepShareService),self.carUpkeepId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
            
            [serviceNumberDic removeAllObjects];
            for (NSDictionary *dicc in removeAry) {     //遍历赋初始值，都为1
                [serviceNumberDic setObject:@"1" forKey:dicc[@"id"]];     //object:数量，key:服务方案id
            }
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
            
            order_code = responseObject[@"data"][@"code"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否分享？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alert.tag = 300;
            [alert show];
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
            signImgStr = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CarUpkeepShareService]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepShareService object:nil];
        NSLog(@"CarUpkeepShareService: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            shareDic = responseObject[@"data"];
            [self shareClicked];
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
    NSNumber *moneyN = [NSNumber numberWithFloat:serVicePrice + packagePrice - discountPrice + selectedServicePrice + addedServicePrice];
    NSDictionary *dic = @{@"orderId":[NSString stringWithFormat:@"%@",orderId],@"money":moneyN,@"plateNumber":STRING(self.carDic[@"plateNumber"]),@"owner":STRING(self.carDic[@"owner"]),@"checktypeID":self.checktypeID};
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
