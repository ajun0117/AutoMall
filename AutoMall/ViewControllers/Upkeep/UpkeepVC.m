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


@interface UpkeepVC ()
{
    NSArray *typeAry; //类别数组
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
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
    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"cars"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toCarOwner:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
//    [self makeLayerWithButton:self.carOwnerBtn];
//    [self makeLayerWithButton:self.hairdressingBtn];
//    [self makeLayerWithButton:self.quickBtn];
//    [self makeLayerWithButton:self.upkeepBtn];
//    [self makeLayerWithButton:self.synthesizeBtn];
//    [self makeLayerWithButton:self.customBtn];
    
//    typeAry = @[@{@"name":@"美容检查",@"id":@"1"},@{@"name":@"保养检查",@"id":@"8"},@{@"name":@"快速检查",@"id":@"9"}];
//    [self.myCollectionView reloadData];
    
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


//-(void) makeLayerWithButton:(UIButton *)btn {
//    btn.layer.cornerRadius = btn.frame.size.height / 2;
//    btn.layer.borderWidth = 1;
//    btn.layer.borderColor = RGBCOLOR(244, 245, 246).CGColor;
//}

-(void)toCarOwner:(UIButton *)btn {
    BaoyangHistoryVC *historyVC = [[BaoyangHistoryVC alloc] init];
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (IBAction)toCheckAutoAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)toLoginAction:(id)sender {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)carInfoListAction:(id)sender {
    CarInfoListVC *listVC = [[CarInfoListVC alloc] init];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

- (IBAction)quickAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)upkeepAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)synthesizeAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)customAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

#pragma mark - UICollectionViewDelegate
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [typeAry count] + 1;
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
//    collCell.layer.borderColor = RGBCOLOR(234, 33, 45).CGColor;
    collCell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    collCell.layer.borderWidth = 1;
    collCell.layer.cornerRadius = 5;
    NSLog(@"typeAry: %@",typeAry);
    if (indexPath.item == [typeAry count]) {
        [collCell.img setImage:IMG(@"timg-2")];
        collCell.titleL.text = @"自定义检查";
        return collCell;
    }
    NSDictionary *dic = [typeAry objectAtIndex:indexPath.item];
    [collCell.img sd_setImageWithURL:[NSURL URLWithString:ImagePrefixURL(dic[@"image"])] placeholderImage:IMG(@"timg-2")];
    collCell.titleL.text = dic [@"name"];
    
    //    collCell.exchangeBtn.tag = indexPath.item + 1000;
    //    [collCell.exchangeBtn addTarget:self action:@selector(exchangeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return collCell;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

//    int typeInt = [dic [@"type"] intValue];
//    if (typeInt == 1) {  //商家
//        ShopListViewController *shopListVC = [[ShopListViewController alloc] init];
//        shopListVC.hidesBottomBarWhenPushed = YES;
//        shopListVC.viewTitleStr = dic[@"name"];
//        shopListVC.serviceId = dic [@"id"];
//        shopListVC.slidePlaceList = NSStringWithNumber(dic [@"slidePlaceList"]);
//        shopListVC.slidePlaceDetail = NSStringWithNumber(dic [@"slidePlaceDetail"]);
//        [self.navigationController pushViewController:shopListVC animated:YES];
//    }
    
    if (indexPath.item == [typeAry count]) {
        CarInfoListVC *listVC = [[CarInfoListVC alloc] init];
        listVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listVC animated:YES];
        return;
    }
    else {
        NSDictionary *dic = [typeAry objectAtIndex:indexPath.item];
        AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
        checkVC.checktypeID = dic[@"id"];
        checkVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:checkVC animated:YES];
    }
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    if (kind == UICollectionElementKindSectionHeader) {
//        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
//        headerView.backgroundColor = [UIColor clearColor];
//        if (! _adView) {
//            _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH - 20 , (SCREEN_WIDTH - 20)/2)];
//            _adView.delegate = self;
//            _adView.isHomeAd = YES;
//            [_adView initSubViews];
//            [headerView addSubview:_adView];
//        }
//        return headerView;
//    }
//    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
//    footerView.backgroundColor = [UIColor whiteColor];
//    footerView.layer.cornerRadius = 5;
//    footerView.layer.masksToBounds = YES;
//    if (! _messageView) {
//        _messageView = [[AJMessageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20 , 100)];
//        _messageView.delegate = self;
//        //        _messageView.layer.cornerRadius = 5;
//        //        _messageView.layer.masksToBounds = YES;
//        [_messageView initSubViews];
//        [footerView addSubview:_messageView];
//    }
//    return footerView;
//}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH-20) / 3 - 8, ((SCREEN_WIDTH-20) / 3 - 8)*349/221);
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    return CGSizeMake(SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20)/2 + 10);
//}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    if (_messageArray.count == 0) {
//        return CGSizeZero;
//    }
//    return CGSizeMake(SCREEN_WIDTH, 100);
//}

#pragma mark - 发送请求
-(void)requestGetChecktypeList { //获取分类列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktypeList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktypeList, @"op", nil];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(ChecktypeList) delegate:nil params:nil info:infoDic];
    
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
