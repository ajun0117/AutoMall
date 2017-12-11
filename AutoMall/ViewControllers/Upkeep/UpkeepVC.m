//
//  FirstViewController.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepVC.h"
#import "AutoCheckVC.h"
#import "CarInfoListVC.h"
#import "LoginViewController.h"
#import "BaoyangHistoryVC.h"
#import "UpkeepHomeCollectionCell.h"
#import "LoginViewController.h"
#import "AutoCheckCarInfoVC.h"

@interface UpkeepVC ()
{
    NSArray *typeAry; //类别数组
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *selectedCarDic;    //选择的保养车辆Dic
    NSString *mobileUserType;     //登录用户类别 0：手机普通用户 1：门店老板 2: 门店员工
}
//@property (strong, nonatomic) IBOutlet UIButton *carOwnerBtn;
//@property (strong, nonatomic) IBOutlet UIButton *hairdressingBtn;
//@property (strong, nonatomic) IBOutlet UIButton *customBtn;
//@property (strong, nonatomic) IBOutlet UIButton *quickBtn;
//@property (strong, nonatomic) IBOutlet UIButton *upkeepBtn;
//@property (strong, nonatomic) IBOutlet UIButton *synthesizeBtn;
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;


@end

@implementation UpkeepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"保养服务";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"carList"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toCarOwner:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    self.myCollectionView.alwaysBounceVertical = YES;
    
    [self.myCollectionView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
    [self requestGetChecktypeList];
    
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    
    [self requestGetPhoneInfo];
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

#pragma mark - 下拉刷新
-(void)headerRefreshing {
    NSLog(@"下拉刷新");
    [self requestGetChecktypeList];
}

#pragma mark - 选择车辆
-(void)toCarOwner:(UIButton *)btn {
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if (mobileUserType.length > 0) {    //已登录用户
        //注册选择车辆通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedCar:) name:@"DidSelectedCar" object:nil];
        
        CarInfoListVC *listVC = [[CarInfoListVC alloc] init];
//        listVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
//            selectedCarDic = carDic;
//            self.title = carDic[@"plateNumber"]; 
//            NSLog(@"selectedCarDic: %@",selectedCarDic);
//        };
        listVC.carId = selectedCarDic[@"id"];
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    else {
        _networkConditionHUD.labelText = @"登录后才能查看！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - 网络请求结果数据
-(void) didSelectedCar:(NSNotification *)notification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidSelectedCar" object:nil];
    if (notification.userInfo) {
        selectedCarDic = notification.userInfo;
        self.title = selectedCarDic[@"plateNumber"];
        NSLog(@"selectedCarDic: %@",selectedCarDic);
    }
    else {      //清空已选的车辆信息
        selectedCarDic = nil;
        self.title = @"保养服务";
    }
    
}

#pragma mark - UICollectionViewDelegate
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [typeAry count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UpkeepHomeCollectionCell *collCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"upkeepHomeCollectionCell" forIndexPath:indexPath];
//    collCell.layer.borderColor = RGBCOLOR(239, 239, 239).CGColor;
//    collCell.layer.borderWidth = 1;
//    collCell.layer.cornerRadius = 5;
    NSDictionary *dic = [typeAry objectAtIndex:indexPath.item];
    [collCell.img sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];      //  IMG(@"check_default")
    collCell.titleL.text = dic [@"name"];
    
    return collCell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if (mobileUserType.length > 0) {    //已登录用户
        NSDictionary *dic = [typeAry objectAtIndex:indexPath.item];
        BOOL requireAuth = [dic[@"requireAuth"] boolValue];
        if (requireAuth) {  //需要权限，且登录身份为老板或员工
            if ([mobileUserType isEqualToString:@"0"]) {
                _networkConditionHUD.labelText = @"认证后才能查看！";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            }
            else {
                if (selectedCarDic) {
//                    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
//                    checkVC.checktypeID = dic[@"id"];
//                    checkVC.carDic = selectedCarDic;
//                    checkVC.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:checkVC animated:YES];
                    
                    AutoCheckCarInfoVC *infoVC = [[AutoCheckCarInfoVC alloc] init];
                    infoVC.checktypeID = dic[@"id"];
                    infoVC.carDic = selectedCarDic;
                    infoVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:infoVC animated:YES];
                    
                }   else {
                    _networkConditionHUD.labelText = @"请先在右上角选择需要保养的车辆！";
                    [_networkConditionHUD show:YES];
                    [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                }
            }
        }
        else {
            if (selectedCarDic) {
//                if ([dic[@"id"] intValue] == 10) {
//                    _networkConditionHUD.labelText = @"暂未开放！";
//                    [_networkConditionHUD show:YES];
//                    [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//                } else {
//                    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
//                    checkVC.checktypeID = dic[@"id"];
//                    checkVC.carDic = selectedCarDic;
//                    checkVC.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:checkVC animated:YES];
                AutoCheckCarInfoVC *infoVC = [[AutoCheckCarInfoVC alloc] init];
                infoVC.checktypeID = dic[@"id"];
                infoVC.carDic = selectedCarDic;
                infoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:infoVC animated:YES];
//                }
            } else {
                _networkConditionHUD.labelText = @"请先在右上角选择需要保养的车辆！";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            }
        }
    }
    else {
        _networkConditionHUD.labelText = @"登录后才能查看！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.isPresented = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barTintColor = [UIColor whiteColor];
        [self presentViewController:nav animated:YES completion:nil];
    }

}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH-20) / 3 - 4, ((SCREEN_WIDTH-20) / 3 - 4)*349/221);
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
//    else if ([mobileUserType isEqualToString:@"0"]) {   //普通用户
//        [self requestGetApprovalStatus];     //请求门店审批状态
//    }
    
    [self requestPostUserGetInfo];      //刷新用户信息
}

#pragma mark - 发送请求
-(void)requestGetChecktypeList { //获取分类列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktypeList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktypeList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?pageSize=20",UrlPrefix(ChecktypeList)];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

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
    [self.myCollectionView headerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:ChecktypeList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ChecktypeList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            typeAry = responseObject [@"data"];
            [self.myCollectionView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:GetUserInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetUserInfo object:nil];
        NSLog(@"GetUserInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            NSDictionary *userInfoDic = responseObject[@"data"];
            
            [BPush setTag:[NSString stringWithFormat:@"%@",userInfoDic[@"id"]] withCompleteHandler:^(id result, NSError *error) {
                if (error.code == 0) {
                    NSLog(@"绑定推送成功！userId: %@",[NSString stringWithFormat:@"%@",userInfoDic[@"id"]]);
                }
            }];
            
            [[GlobalSetting shareGlobalSettingInstance] setUserID:[NSString stringWithFormat:@"%@",userInfoDic[@"id"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmMobile:[NSString stringWithFormat:@"%@",userInfoDic[@"phone"]]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:[NSString stringWithFormat:@"%@",STRING(userInfoDic[@"nickname"])]];
            [[GlobalSetting shareGlobalSettingInstance] setmHead:STRING(userInfoDic[@"image"])];
            [[GlobalSetting shareGlobalSettingInstance] setMobileUserType:[NSString stringWithFormat:@"%@",userInfoDic[@"mobileUserType"]]];

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
            NSDictionary *shopDic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setStoreId:STRING(shopDic[@"id"])];
            [[GlobalSetting shareGlobalSettingInstance] setAlipayImg:STRING(shopDic[@"alipayImg"])];
            [[GlobalSetting shareGlobalSettingInstance] setWechatImg:STRING(shopDic[@"wechatpayImg"])];
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
            NSDictionary *shopDic = responseObject[@"data"];
            [[GlobalSetting shareGlobalSettingInstance] setStoreId:STRING(shopDic[@"id"])];
            [[GlobalSetting shareGlobalSettingInstance] setAlipayImg:STRING(shopDic[@"alipayImg"])];
            [[GlobalSetting shareGlobalSettingInstance] setWechatImg:STRING(shopDic[@"wechatpayImg"])];
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
            [[GlobalSetting shareGlobalSettingInstance] setOfficialPhone:phoneStr];
//            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneStr];
//            UIWebView * callWebview = [[UIWebView alloc] init];
//            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//            [self.view addSubview:callWebview];
            
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


@end
