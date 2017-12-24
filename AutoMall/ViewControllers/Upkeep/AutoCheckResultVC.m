//
//  AutoCheckResultVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/26.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckResultVC.h"
#import "AJAdView.h"
#import "WebViewController.h"
#import "ShopInfoCell.h"
#import "CheckResultCell.h"
#import "CheckResultSingleCell.h"
#import "CheckResultMultiCell.h"
#import "CheckResultTechnicianCell.h"
#import "CheckResultQRCell.h"
#import "UpkeepPlanVC.h"
#import "AutoCheckResultProblemVC.h"
#import "AutoCheckResultDetailVC.h"
#import "HZPhotoBrowser.h"
#import "CheckResultOtherCell.h"
#import "ShareTool.h"
#import "LXActivity.h"

@interface AutoCheckResultVC () <AJAdViewDelegate, HZPhotoBrowserDelegate,LXActivityDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    AJAdView *_adView;
    NSArray *_adArray;   //广告图数组
    NSDictionary *carUpkeepDic;     //检查单数据
    NSMutableArray *checkResultArray;       //重组后的检查结果数组
    int sections;   //块数
    NSArray *images;
    NSString *mobileUserType;   //用户类别
    NSDictionary *shareDic;     //分享文案
    LXActivity *lxActivity;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"检查报告";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = - 16;
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 44, 44);
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    shareBtn.contentMode = UIViewContentModeScaleAspectFit;
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, shareBtnBarBtn, nil];
    
    mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        
    sections = 5;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopInfoCell" bundle:nil] forCellReuseIdentifier:@"shopInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultCell" bundle:nil] forCellReuseIdentifier:@"checkResultCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultTechnicianCell" bundle:nil] forCellReuseIdentifier:@"checkResultTechnicianCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultQRCell" bundle:nil] forCellReuseIdentifier:@"checkResultQRCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultOtherCell" bundle:nil] forCellReuseIdentifier:@"checkResultOtherCell"];
    
//    _adArray = @[@{@"image":UrlPrefix(carUpkeepDic[@"store"][@"image"]),@"content":@"广告1",@"thirdPartyUrl":@""}];
//    [_adView reloadData];
    
    [self createShareView];
    
    checkResultArray = [NSMutableArray array];
    
    [self requestGetUpkeepInfo];
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
        lxActivity = [[LXActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消分享" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    }
}

-(void)toShare {
    [self requestGetShareInfo];
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
    if ([imgUrlStr isEqualToString:@""]) {
        imgUrlStr = @"http://119.23.227.246/carupkeep/image/carupkeep_share.png";
    }
    NSString *url = shareDic [@"shareUrl"];
//    if ([url isEqualToString:@""]) {
//        url = @"";
//    }
    NSString *defaultContent = shareDic [@"shareTitle"];
    if ([defaultContent isEqualToString:@""]) {
        defaultContent = @"i爱检车";
    }
    
    NSString *content = [NSString stringWithFormat:@"%@\n%@",title,url];
    
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

-(void)clickImageWithImageUrl:(NSString *)url {
    //启动图片浏览器
    HZPhotoBrowser *browserVC = [[HZPhotoBrowser alloc] init];
    browserVC.sourceImagesContainerView = self.view; // 原图的父控件
//    images = @[UrlPrefix(carUpkeepDic[@"image"])];
    images = @[UrlPrefix(url)];
    browserVC.imageCount = 1; // 图片总数 imagesAry.count
    browserVC.currentImageIndex = 0;
    browserVC.currentImageTitle = @"";
    browserVC.delegate = self;
    [browserVC show];
}

-(void)clickImageWithImagesArray:(NSArray *)imageAry andIndex:(NSInteger)index {
    //启动图片浏览器
    HZPhotoBrowser *browserVC = [[HZPhotoBrowser alloc] init];
    browserVC.sourceImagesContainerView = self.view; // 原图的父控件
//    images = @[UrlPrefix(carUpkeepDic[@"store"][@"image"])];
    images = imageAry;
    browserVC.imageCount = images.count; // 图片总数 imagesAry.count
    browserVC.currentImageIndex = (int)index;
    browserVC.currentImageTitle = @"";
    browserVC.delegate = self;
    [browserVC show];
}

#pragma mark - photobrowser代理方法
- (UIImage *)photoBrowser:(HZPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return IMG(@"whiteplaceholder");
}

- (NSURL *)photoBrowser:(HZPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = images[index];
    return [NSURL URLWithString:urlStr];
}

- (NSString *)photoBrowser:(HZPhotoBrowser *)browser titleStringForIndex:(NSInteger)index {
    //    NSDictionary *dic = _typeImgsArray [index];
    //    NSString *titleStr = dic [@"content"];
    return @"";
}

#pragma mark - AJAdViewDelegate
- (NSInteger)numberInAdView:(AJAdView *)adView{
    return [_adArray count];
}

- (NSString *)imageUrlInAdView:(AJAdView *)adView index:(NSInteger)index{
    return _adArray[index] [@"image"];
}

- (NSString *)titleStringInAdView:(AJAdView *)adView index:(NSInteger)index {
    return _adArray[index] [@"content"];
}

- (void)adView:(AJAdView *)adView didSelectIndex:(NSInteger)index{
    NSLog(@"--%ld--",(long)index);

    NSArray *imageUrlAry = carUpkeepDic[@"store"][@"minorImages"];
    NSMutableArray *mulAry = [NSMutableArray array];
    for (NSDictionary * dic in imageUrlAry) {
        [mulAry addObject:UrlPrefix(dic[@"relativePath"])];
    }
    [self clickImageWithImagesArray:mulAry andIndex:index];
}

- (IBAction)upkeepPlanAction:(id)sender {
    UpkeepPlanVC *planVC = [[UpkeepPlanVC alloc] init];
    planVC.carDic = carUpkeepDic[@"car"];
    planVC.mileage = carUpkeepDic[@"mileage"];
    planVC.fuelAmount = carUpkeepDic[@"fuelAmount"];
    planVC.lastEndTime = carUpkeepDic[@"lastEndTime"];
    planVC.lastMileage = STRING(carUpkeepDic[@"lastMileage"]);
    planVC.carUpkeepId = self.carUpkeepId;
    planVC.checktypeID = self.checktypeID;
    [self.navigationController pushViewController:planVC animated:YES];
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (sections == 7) {
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
                NSArray *ary = carUpkeepDic[@"checkContents"];
                return ary.count;
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
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 1;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    return staffSkillEntities.count + 2;
                }
                break;
            }
            case 6: {
                return 1;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else if (sections == 6) {
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
                NSArray *ary = carUpkeepDic[@"checkContents"];
                return ary.count;
                break;
            }
            case 3: {
                return 1;
                break;
            }
            case 4: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 1;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    return staffSkillEntities.count + 2;
                }
                break;
            }
            case 5: {
                return 1;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else {
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
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 1;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    return staffSkillEntities.count + 2;
                }
                break;
            }
            case 4: {
                return 1;
                break;
            }
            default:
                return 0;
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (sections == 7) {
        switch (indexPath.section) {
            case 0: {
                return 70;
                break;
            }
            case 1: {
                return 251;
                break;
            }
            case 2: {
                NSArray *ary = carUpkeepDic[@"checkContents"];
                NSDictionary *dic = ary[indexPath.row];
                if ([dic[@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                    NSArray *entities = dic[@"carUpkeepCheckContentEntities"];
                    return 43 + 30*entities.count;
                }
                return 50;
                break;
            }
            case 3: {
                return 270;
                break;
            }
                
            case 4: {
                return 212;
                break;
            }
            case 5: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 56;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        return 44;
                    }
                    else if (indexPath.row == staffSkillEntities.count + 1) {
                        return 56;
                    }
                    return 70;
                }
                break;
            }
            case 6: {
                return 200;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else if (sections == 6) {
        switch (indexPath.section) {
            case 0: {
                return 70;
                break;
            }
            case 1: {
                return 251;
                break;
            }
            case 2: {
                NSArray *ary = carUpkeepDic[@"checkContents"];
                NSDictionary *dic = ary[indexPath.row];
                if ([dic[@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                    NSArray *entities = dic[@"carUpkeepCheckContentEntities"];
                    return 43 + 30*entities.count;
                }
                return 50;
                break;
            }
            case 3: {
                return 270;
                break;
            }
            case 4: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 56;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        return 44;
                    }
                    else if (indexPath.row == staffSkillEntities.count + 1) {
                        return 56;
                    }
                    return 70;
                }
                break;
            }
            case 5: {
                return 200;
                break;
            }
            default:
                return 0;
                break;
        }
    }
    else {
        switch (indexPath.section) {
            case 0: {
                return 70;
                break;
            }
            case 1: {
                return 251;
                break;
            }
            case 2: {
                return 270;
                break;
            }
            case 3: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    return 56;
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        return 44;
                    }
                    else if (indexPath.row == staffSkillEntities.count + 1) {
                        return 56;
                    }
                    return 70;
                }
                break;
            }
            case 4: {
                return 200;
                break;
            }
            default:
                return 0;
                break;
        }

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (sections == 7) {
        switch (indexPath.section) {
            case 0: {
                ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.storeNameL.text = STRING_Nil(carUpkeepDic[@"storeName"]);
                cell.storePhoneL.text = STRING_Nil(carUpkeepDic[@"storePhone"]);
                cell.storeAddressL.text = STRING_Nil(carUpkeepDic[@"storeAddress"]);
                return cell;
                break;
            }
            case 1: {
                CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.chepaiL.text = STRING_Nil(carUpkeepDic[@"carPlateNumber"]);
                [cell.carImageBtn  addTarget:self action:@selector(carImageAction) forControlEvents:UIControlEventTouchUpInside];
                
                for (NSDictionary *dic in carUpkeepDic[@"categories"]) {
                    if ([dic[@"id"] intValue] == 1) { //车身
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.carBodyNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 2) { //车内
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.inCarNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.inCarBtn addTarget:self action:@selector(inCarAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 3) { //底盘
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.underpanNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.underpanBtn addTarget:self action:@selector(underpanAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 4) { //机舱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.engineNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.engineBtn addTarget:self action:@selector(engineAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 5) { //尾箱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.bootNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.bootBtn addTarget:self action:@selector(bootAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 0) { //轮胎刹车
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.tyreNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.tyreBtn addTarget:self action:@selector(tyreAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                }
                cell.allNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"inspectionItemsInTotal"])];
                cell.unusualNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"unnormal"])];
                [cell.unnormalBtn addTarget:self action:@selector(unnormalAction) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
                break;
            }
            case 2: {
                NSArray *ary = carUpkeepDic[@"checkContents"];
                NSDictionary *dic = ary[indexPath.row];
                
                if ([dic[@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                    CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.positionL.text = dic[@"checkTerm"][@"name"];
                    cell.checkContentL.text = dic[@"name"];
                    NSArray *entities = dic[@"carUpkeepCheckContentEntities"];
                    
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
                        result.textAlignment = NSTextAlignmentRight;
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
                    cell.levelL.layer.cornerRadius = 4;
                    cell.positionL.text = dic[@"checkTerm"][@"name"];
                    cell.checkContentL.text = dic[@"name"];
                    cell.resultL.text = STRING([dic[@"carUpkeepCheckContentEntities"] firstObject][@"describe"]);
                    int level = [[dic[@"carUpkeepCheckContentEntities"] firstObject][@"level"] intValue];
                    cell.levelL.text = STRING([dic[@"carUpkeepCheckContentEntities"] firstObject][@"result"]);
                    if (level == 1) {
                        cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
                    }
                    else if (level == 2) {
                        cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
                    }
                    else if (level == 3) {
                        cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
                
                break;
            }
                
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *carImg = (UIImageView *)[cell.contentView viewWithTag:101];
                if (! carImg) {
                    carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 270 - 16)];
                    carImg.clipsToBounds = YES;
                    carImg.contentMode = UIViewContentModeScaleAspectFill;
                }
                NSString *img = carUpkeepDic[@"image"];
                if (! [img isKindOfClass:[NSNull class]] && img.length  > 0) {
                    [carImg sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(img)] placeholderImage:IMG(@"CommplaceholderPicture")];
                } else {
                    carImg.image = IMG(@"carMark");;
                }
                carImg.contentMode = UIViewContentModeScaleAspectFill;
                carImg.tag = 101;
                [cell.contentView addSubview:carImg];
                return cell;
                break;
            }
                
            case 4: {
                CheckResultOtherCell *cell = (CheckResultOtherCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultOtherCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSDateFormatter* formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd"];
                if (! [carUpkeepDic[@"startTime"] isKindOfClass:[NSNull class]]) {
                    NSDate *checkDate = [NSDate dateWithTimeIntervalSince1970:[carUpkeepDic[@"startTime"] doubleValue]/1000];
                    NSString *checkDateString = [formater stringFromDate:checkDate];
                    cell.checkDateL.text = checkDateString;
                }
                if (! [carUpkeepDic[@"lastEndTime"] isKindOfClass:[NSNull class]]) {
                    NSDate *lastTimeCheckDate = [NSDate dateWithTimeIntervalSince1970:[carUpkeepDic[@"lastEndTime"] doubleValue]/1000];
                    NSString *lastTimeCheckDateString = [formater stringFromDate:lastTimeCheckDate];
                    cell.lastTimeCheckDateL.text = lastTimeCheckDateString;
                }
       
                cell.mileageL.text = [NSString stringWithFormat:@"%@",STRING(carUpkeepDic[@"mileage"])];
                [cell.mileageImageBtn  addTarget:self action:@selector(mileageImageAction) forControlEvents:UIControlEventTouchUpInside];
                cell.fuelAmountL.text = [NSString stringWithFormat:@"%@",STRING(carUpkeepDic[@"fuelAmount"])];
                [cell.fuelAmountImageBtn  addTarget:self action:@selector(fuelAmountImageAction) forControlEvents:UIControlEventTouchUpInside];
                cell.lastTimeMileageL.text = [NSString stringWithFormat:@"%@",STRING(carUpkeepDic[@"lastMileage"])];
                [cell.lastTimeMileageImageBtn  addTarget:self action:@selector(lastMileageImageAction) forControlEvents:UIControlEventTouchUpInside];
                cell.lastTimeFuelAmountL.text = [NSString stringWithFormat:@"%@",STRING(carUpkeepDic[@"lastFuelAmount"])];
                [cell.lastTimeFuelAmountImageBtn  addTarget:self action:@selector(lastFuelAmountImageAction) forControlEvents:UIControlEventTouchUpInside];
                return cell;
                break;
            }
                
            case 5: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                    if (! label) {
                        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn1.tag = 101;
                        btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        [btn1 setTitle:@"收起完整报告" forState:UIControlStateNormal];
                        btn1.layer.cornerRadius = 5;
                        btn1.clipsToBounds = YES;
                        btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                        
                        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn2.tag = 102;
                        btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                        [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                        btn2.layer.cornerRadius = 5;
                        btn2.clipsToBounds = YES;
                        btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:btn1];
                        [cell.contentView addSubview:btn2];
                    }
                    return cell;
                    
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textLabel.text = [NSString stringWithFormat:@"技师:%@",dic[@"nickname"]];
                        return cell;
                    }
                    else if(indexPath.row == staffSkillEntities.count + 1) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                        if (! label) {
                            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn1.tag = 101;
                            btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                            [btn1 setTitle:@"收起完整报告" forState:UIControlStateNormal];
                            btn1.layer.cornerRadius = 5;
                            btn1.clipsToBounds = YES;
                            btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn2.tag = 102;
                            btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                            [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                            btn2.layer.cornerRadius = 5;
                            btn2.clipsToBounds = YES;
                            btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:btn1];
                            [cell.contentView addSubview:btn2];
                        }
                        return cell;
                    }
                    else {
                        CheckResultTechnicianCell *cell = (CheckResultTechnicianCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultTechnicianCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        NSDictionary *staffSkillEntityDic = staffSkillEntities[indexPath.row - 1];
                        [cell.imageV sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(staffSkillEntityDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
                        cell.nameL.text = STRING(staffSkillEntityDic[@"name"]);
                        cell.contentL.text = STRING(staffSkillEntityDic[@"remark"]);
                        return cell;
                    }
                }

                break;
            }
            case 6: {
                CheckResultQRCell *cell = (CheckResultQRCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultQRCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            }
                
            default:
                return nil;
                break;
        }
    }
    
    else if (sections == 6) {
        switch (indexPath.section) {
            case 0: {
                ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.storeNameL.text = STRING_Nil(carUpkeepDic[@"storeName"]);
                cell.storePhoneL.text = STRING_Nil(carUpkeepDic[@"storePhone"]);
                cell.storeAddressL.text = STRING_Nil(carUpkeepDic[@"storeAddress"]);
                return cell;
                break;
            }
            case 1: {
                CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.chepaiL.text = STRING_Nil(carUpkeepDic[@"carPlateNumber"]);
                [cell.carImageBtn  addTarget:self action:@selector(carImageAction) forControlEvents:UIControlEventTouchUpInside];
                
                for (NSDictionary *dic in carUpkeepDic[@"categories"]) {
                    if ([dic[@"id"] intValue] == 1) { //车身
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.carBodyNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 2) { //车内
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.inCarNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.inCarBtn addTarget:self action:@selector(inCarAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 3) { //底盘
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.underpanNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.underpanBtn addTarget:self action:@selector(underpanAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 4) { //机舱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.engineNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.engineBtn addTarget:self action:@selector(engineAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 5) { //尾箱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.bootNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.bootBtn addTarget:self action:@selector(bootAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 0) { //轮胎刹车
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.tyreNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.tyreBtn addTarget:self action:@selector(tyreAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                }
                cell.allNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"inspectionItemsInTotal"])];
                cell.unusualNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"unnormal"])];
                [cell.unnormalBtn addTarget:self action:@selector(unnormalAction) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
                break;
            }
            case 2: {
                NSArray *ary = carUpkeepDic[@"checkContents"];
                NSDictionary *dic = ary[indexPath.row];
                
                if ([dic[@"group"] isKindOfClass:[NSString class]]) {  //多个位置
                    CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.positionL.text = dic[@"checkTerm"][@"name"];
                    cell.checkContentL.text = dic[@"name"];
                    NSArray *entities = dic[@"carUpkeepCheckContentEntities"];
                    
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
                        result.textAlignment = NSTextAlignmentRight;
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
                    cell.levelL.layer.cornerRadius = 4;
                    cell.positionL.text = dic[@"checkTerm"][@"name"];
                    cell.checkContentL.text = dic[@"name"];
                    cell.resultL.text = STRING([dic[@"carUpkeepCheckContentEntities"] firstObject][@"describe"]);
                    int level = [[dic[@"carUpkeepCheckContentEntities"] firstObject][@"level"] intValue];
                    cell.levelL.text = STRING([dic[@"carUpkeepCheckContentEntities"] firstObject][@"result"]);
                    if (level == 1) {
                        cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
                    }
                    else if (level == 2) {
                        cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
                    }
                    else if (level == 3) {
                        cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                }
                
                break;
            }
                
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *carImg = (UIImageView *)[cell.contentView viewWithTag:101];
                if (! carImg) {
                    carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 270 - 16)];
                    carImg.clipsToBounds = YES;
                    carImg.contentMode = UIViewContentModeScaleAspectFill;
                }
                NSString *img = carUpkeepDic[@"image"];
                if (! [img isKindOfClass:[NSNull class]] && img.length  > 0) {
                    [carImg sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(img)] placeholderImage:IMG(@"CommplaceholderPicture")];
                } else {
                    carImg.image = IMG(@"carMark");;
                }
                carImg.contentMode = UIViewContentModeScaleAspectFill;
                carImg.tag = 101;
                [cell.contentView addSubview:carImg];
                return cell;
                break;
            }
            case 5: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                    if (! label) {
                        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn1.tag = 101;
                        btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        [btn1 setTitle:@"收起完整报告" forState:UIControlStateNormal];
                        btn1.layer.cornerRadius = 5;
                        btn1.clipsToBounds = YES;
                        btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                        
                        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn2.tag = 102;
                        btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                        [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                        btn2.layer.cornerRadius = 5;
                        btn2.clipsToBounds = YES;
                        btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:btn1];
                        [cell.contentView addSubview:btn2];
                    }
                    return cell;
                    
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textLabel.text = [NSString stringWithFormat:@"技师:%@",dic[@"nickname"]];
                        return cell;
                    }
                    else if(indexPath.row == staffSkillEntities.count + 1) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                        if (! label) {
                            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn1.tag = 101;
                            btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                            [btn1 setTitle:@"收起完整报告" forState:UIControlStateNormal];
                            btn1.layer.cornerRadius = 5;
                            btn1.clipsToBounds = YES;
                            btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn2.tag = 102;
                            btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                            [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                            btn2.layer.cornerRadius = 5;
                            btn2.clipsToBounds = YES;
                            btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:btn1];
                            [cell.contentView addSubview:btn2];
                        }
                        return cell;
                    }
                    else {
                        CheckResultTechnicianCell *cell = (CheckResultTechnicianCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultTechnicianCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        NSDictionary *staffSkillEntityDic = staffSkillEntities[indexPath.row - 1];
                        [cell.imageV sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(staffSkillEntityDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
                        cell.nameL.text = STRING(staffSkillEntityDic[@"name"]);
                        cell.contentL.text = STRING(staffSkillEntityDic[@"remark"]);
                        return cell;
                    }
                }
                
                break;
            }
            case 6: {
                CheckResultQRCell *cell = (CheckResultQRCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultQRCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            }
                
            default:
                return nil;
                break;
        }
    }
    
    else {
        switch (indexPath.section) {
            case 0: {
                ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.storeNameL.text = STRING_Nil(carUpkeepDic[@"storeName"]);
                cell.storePhoneL.text = STRING_Nil(carUpkeepDic[@"storePhone"]);
                cell.storeAddressL.text = STRING_Nil(carUpkeepDic[@"storeAddress"]);
                return cell;
                break;
            }
            case 1: {
                CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.chepaiL.text = STRING_Nil(carUpkeepDic[@"carPlateNumber"]);
                [cell.carImageBtn  addTarget:self action:@selector(carImageAction) forControlEvents:UIControlEventTouchUpInside];
                
                for (NSDictionary *dic in carUpkeepDic[@"categories"]) {
                    if ([dic[@"id"] intValue] == 1) { //车身
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.carBodyNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 2) { //车内
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.inCarNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.inCarBtn addTarget:self action:@selector(inCarAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 3) { //底盘
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.underpanNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.underpanBtn addTarget:self action:@selector(underpanAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 4) { //机舱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.engineNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.engineBtn addTarget:self action:@selector(engineAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 5) { //尾箱
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.bootNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.bootBtn addTarget:self action:@selector(bootAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                    else if ([dic[@"id"] intValue] == 0) { //轮胎刹车
                        if ([dic[@"unnormal"] intValue] > 0) {
                            cell.tyreNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                            [cell.tyreBtn addTarget:self action:@selector(tyreAction) forControlEvents:UIControlEventTouchUpInside];
                        }
                    }
                }
                cell.allNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"inspectionItemsInTotal"])];
                cell.unusualNumL.text = [NSString stringWithFormat:@"%@项",STRING_Nil(carUpkeepDic[@"unnormal"])];
                [cell.unnormalBtn addTarget:self action:@selector(unnormalAction) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
                break;
            }
            case 2: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *carImg = (UIImageView *)[cell.contentView viewWithTag:101];
                if (! carImg) {
                    carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 270 - 16)];
                    carImg.clipsToBounds = YES;
                    carImg.contentMode = UIViewContentModeScaleAspectFill;
                }
                NSString *img = carUpkeepDic[@"image"];
                if (! [img isKindOfClass:[NSNull class]] && img.length  > 0) {
                    [carImg sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(img)] placeholderImage:IMG(@"CommplaceholderPicture")];
                } else {
                    carImg.image = IMG(@"carMark");
                }
                carImg.contentMode = UIViewContentModeScaleAspectFill;
                carImg.tag = 101;
                [cell.contentView addSubview:carImg];
                return cell;
                break;
            }
            case 3: {
                if ([mobileUserType isEqualToString:@"1"]) {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                    if (! label) {
                        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn1.tag = 101;
                        btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                        [btn1 setTitle:@"查看完整报告" forState:UIControlStateNormal];
                        btn1.layer.cornerRadius = 5;
                        btn1.clipsToBounds = YES;
                        btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                        
                        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn2.tag = 102;
                        btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                        [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                        [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                        btn2.layer.cornerRadius = 5;
                        btn2.clipsToBounds = YES;
                        btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                        [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [cell.contentView addSubview:btn1];
                        [cell.contentView addSubview:btn2];
                    }
                    return cell;
                    
                } else {
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    NSArray *staffSkillEntities = dic[@"staffSkillEntities"];
                    if (indexPath.row == 0) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textLabel.text = [NSString stringWithFormat:@"技师:%@",dic[@"nickname"]];
                        return cell;
                    }
                    else if(indexPath.row == staffSkillEntities.count + 1) {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                        if (! label) {
                            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn1.tag = 101;
                            btn1.frame = CGRectMake(8, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                            [btn1 setTitle:@"查看完整报告" forState:UIControlStateNormal];
                            btn1.layer.cornerRadius = 5;
                            btn1.clipsToBounds = YES;
                            btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn1 addTarget:self action:@selector(fullReport:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                            btn2.tag = 102;
                            btn2.frame = CGRectMake(VIEW_BX(btn1) + 16, 8, (SCREEN_WIDTH - 16 - 16)/2, 40);
                            [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                            [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            //                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                            [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                            btn2.layer.cornerRadius = 5;
                            btn2.clipsToBounds = YES;
                            btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                            [btn2 addTarget:self action:@selector(unscramble:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:btn1];
                            [cell.contentView addSubview:btn2];
                        }
                        return cell;
                    }
                    else {
                        CheckResultTechnicianCell *cell = (CheckResultTechnicianCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultTechnicianCell"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        NSDictionary *staffSkillEntityDic = staffSkillEntities[indexPath.row - 1];
                        [cell.imageV sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(staffSkillEntityDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
                        cell.nameL.text = STRING(staffSkillEntityDic[@"name"]);
                        cell.contentL.text = STRING(staffSkillEntityDic[@"remark"]);
                        return cell;
                    }
                }
                
                break;
            }
            case 4: {
                CheckResultQRCell *cell = (CheckResultQRCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultQRCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
                break;
            }
                
            default:
                return nil;
                break;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (sections == 7) {
        if (indexPath.section == 2) {
            NSArray *ary = carUpkeepDic[@"checkContents"];
            NSDictionary *dic = ary[indexPath.row];
            AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
            detailVC.checkId = self.carUpkeepId;
            detailVC.checkTermId = dic[@"checkTerm"][@"id"];
            detailVC.checkContentId = dic[@"id"];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        else if (indexPath.section == 3) {
            [self clickImageWithImageUrl:carUpkeepDic[@"image"]];
        }
    }
    else if (sections == 6) {
        if (indexPath.section == 2) {
            NSArray *ary = carUpkeepDic[@"checkContents"];
            NSDictionary *dic = ary[indexPath.row];
            AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
            detailVC.checkId = self.carUpkeepId;
            detailVC.checkTermId = dic[@"checkTerm"][@"id"];
            detailVC.checkContentId = dic[@"id"];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        else if (indexPath.section == 3) {
            [self clickImageWithImageUrl:carUpkeepDic[@"image"]];
        }
    }
    else if (sections == 5) {
        if (indexPath.section == 2) {
            [self clickImageWithImageUrl:carUpkeepDic[@"image"]];
        }
    }
}

-(void)fullReport:(UIButton *)btn {
    if (sections == 5) {
        sections = 6;
        [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationTop];
        sections = 7;
        [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationTop];
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
//        [btn setTitle:@"收起完整报告" forState:UIControlStateNormal];
    }
    else {
        sections = 6;
        [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationBottom];
        sections = 5;
        [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationBottom];
//        [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
//        [btn setTitle:@"查看完整报告" forState:UIControlStateNormal];
    }
} 

-(void)unscramble:(UIButton *)btn {
    NSString *phoneStr = [[GlobalSetting shareGlobalSettingInstance] officialPhone];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneStr];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

-(void) carImageAction {
//    [self clickImageWithImageUrl:STRING(carUpkeepDic[@"car"][@"image"])];
    NSMutableArray *ary = [NSMutableArray array];
    for (NSDictionary *dic in carUpkeepDic[@"carUpkeepImages"]) {
        [ary addObject:UrlPrefix(dic[@"relativePath"])];
    }
    if (ary.count > 0) {
        [self clickImageWithImagesArray:ary andIndex:0];
    } else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
}

-(void) mileageImageAction {
    if ([carUpkeepDic[@"mileageImage"] isKindOfClass:[NSString class]] && [carUpkeepDic[@"mileageImage"] length] > 0) {
        [self clickImageWithImageUrl:carUpkeepDic[@"mileageImage"]];
    } else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void) fuelAmountImageAction {
    if ([carUpkeepDic[@"fuelImage"] isKindOfClass:[NSString class]] && [carUpkeepDic[@"fuelImage"] length] > 0) {
        [self clickImageWithImageUrl:carUpkeepDic[@"fuelImage"]];
    } else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void) lastMileageImageAction {
    if ([carUpkeepDic[@"lastMileageImage"] isKindOfClass:[NSString class]] && [carUpkeepDic[@"lastMileageImage"] length] > 0) {
        [self clickImageWithImageUrl:carUpkeepDic[@"lastMileageImage"]];
    } else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
}

-(void) lastFuelAmountImageAction {
    if ([carUpkeepDic[@"lastFuelImage"] isKindOfClass:[NSString class]] && [carUpkeepDic[@"lastFuelImage"] length] > 0) {
        [self clickImageWithImageUrl:carUpkeepDic[@"lastFuelImage"]];
    } else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
}

//所有异常检查项目
-(void)unnormalAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.isUnnormal = YES;
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"1";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//车身检查结果
-(void)carBodyAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"1";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//车内检查结果
-(void)inCarAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"2";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//底盘检查结果
-(void)underpanAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"3";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//机舱检查结果
-(void)engineAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"4";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//尾箱检查结果
-(void)bootAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"5";
    [self.navigationController pushViewController:problemVC animated:YES];
}

//轮胎刹车检查结果
-(void)tyreAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    problemVC.isUnnormal = YES;
    problemVC.isTyre = YES;
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"0";
    [self.navigationController pushViewController:problemVC animated:YES];
}


//CarUpkeepInfo
#pragma mark - 发送请求
-(void)requestGetUpkeepInfo { //获取检查单详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepInfo, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepInfo),self.carUpkeepId];   
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 发送请求
-(void)requestGetShareInfo { //获取分享文案
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepShare object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepShare, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepShare),self.carUpkeepId];
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
    if ([notification.name isEqualToString:CarUpkeepInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepInfo object:nil];
        NSLog(@"CarUpkeepInfo: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            carUpkeepDic = responseObject[@"data"];
            NSArray *imageUrlAry = carUpkeepDic[@"store"][@"minorImages"];
            if (! [imageUrlAry isKindOfClass:[NSNull class]] && imageUrlAry.count > 0) {
                if (! _adView) {
                    _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_WIDTH*9/16)];
                    _adView.delegate = self;
                    self.myTableView.tableHeaderView = _adView;
                }
                NSMutableArray *mulAry = [NSMutableArray array];
                for (NSDictionary * dic in imageUrlAry) {
                    NSDictionary *dicc = @{@"image":UrlPrefix(dic[@"relativePath"])};
                    [mulAry addObject:dicc];
                }
                _adArray = [NSArray arrayWithArray:mulAry];
                [_adView reloadData];

            }
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CarUpkeepShare]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepShare object:nil];
        NSLog(@"CarUpkeepShare: %@",responseObject);
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
