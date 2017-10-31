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


@interface UpkeepVC ()
{
    NSArray *typeAry; //类别数组
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *selectedCarDic;    //选择的保养车辆Dic
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
    negativeSpacer.width = -6;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"cars"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toCarOwner:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    self.myCollectionView.alwaysBounceVertical = YES;
    
    [self.myCollectionView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
    [self requestGetChecktypeList];
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

#pragma mark - 下拉刷新
-(void)headerRefreshing {
    NSLog(@"下拉刷新");
    [self requestGetChecktypeList];
}

#pragma mark - 选择车辆
-(void)toCarOwner:(UIButton *)btn {
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if (mobileUserType.length > 0) {    //已登录用户
        CarInfoListVC *listVC = [[CarInfoListVC alloc] init];
        listVC.GoBackSelectCarDic = ^(NSDictionary *carDic) {
            selectedCarDic = carDic;
            self.title = carDic[@"plateNumber"];
            NSLog(@"selectedCarDic: %@",selectedCarDic);
        };
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
    [collCell.img sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"default")];      //  IMG(@"check_default")
    collCell.titleL.text = dic [@"name"];
    
    return collCell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
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
                    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
                    checkVC.checktypeID = dic[@"id"];
                    checkVC.carDic = selectedCarDic;
                    checkVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:checkVC animated:YES];
                }   else {
                    _networkConditionHUD.labelText = @"请先在右上角选择需要保养的车辆！";
                    [_networkConditionHUD show:YES];
                    [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                }
            }
        }
        else {
            if (selectedCarDic) {
                AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
                checkVC.checktypeID = dic[@"id"];
                checkVC.carDic = selectedCarDic;
                checkVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:checkVC animated:YES];
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

#pragma mark - 发送请求
-(void)requestGetChecktypeList { //获取分类列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktypeList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktypeList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?pageSize=20",UrlPrefix(ChecktypeList)];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
