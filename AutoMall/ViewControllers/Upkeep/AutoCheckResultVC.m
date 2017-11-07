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

@interface AutoCheckResultVC () <AJAdViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    AJAdView *_adView;
    NSArray *_adArray;   //广告图数组
    NSDictionary *carUpkeepDic;     //检查单数据
    NSMutableArray *checkResultArray;       //重组后的检查结果数组
    int sections;   //块数
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
    negativeSpacer.width = -6;
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 44, 44);
    [shareBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    shareBtn.contentMode = UIViewContentModeScaleAspectFit;
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(toShare) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, shareBtnBarBtn, nil];
    
    sections = 5;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopInfoCell" bundle:nil] forCellReuseIdentifier:@"shopInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultCell" bundle:nil] forCellReuseIdentifier:@"checkResultCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultTechnicianCell" bundle:nil] forCellReuseIdentifier:@"checkResultTechnicianCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultQRCell" bundle:nil] forCellReuseIdentifier:@"checkResultQRCell"];
    
    _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_WIDTH*9/16)];
    _adView.delegate = self;
    self.myTableView.tableHeaderView = _adView;
    
    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""}];
    [_adView reloadData];
    
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
    
    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/5abeb351-d881-4f08-b582-fa73fd8a509e.jpg",@"content":@"广告2",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep//uploads/2017/09/093d2e04-7040-4d9d-afe4-4739c1674c40.png",@"content":@"广告3",@"thirdPartyUrl":@""}];
    [_adView reloadData];
}

-(void)toShare {
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
    NSDictionary *dic = _adArray [index];
    if (dic[@"thirdPartyUrl"] && [dic[@"thirdPartyUrl"] length]>0) {
        WebViewController *web = [[WebViewController alloc] init];
        web.webUrlStr = dic [@"thirdPartyUrl"];     //跳转链接
        web.titleStr = dic [@"content"];
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:YES];
    }
}


- (IBAction)upkeepPlanAction:(id)sender {
    UpkeepPlanVC *planVC = [[UpkeepPlanVC alloc] init];
    planVC.carDic = carUpkeepDic[@"car"];
    planVC.carUpkeepId = self.carUpkeepId;
    [self.navigationController pushViewController:planVC animated:YES];
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (sections == 6) {
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
                return 4;
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
                return 4;
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
    if (sections == 6) {
        switch (indexPath.section) {
            case 0: {
                return 70;
                break;
            }
            case 1: {
                return 250;
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
                return 250;
                break;
            }
            case 4: {
                if (indexPath.row == 0) {
                    return 44;
                }
                else if (indexPath.row == 3) {
                    return 56;
                }
                return 70;
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
                return 250;
                break;
            }
            case 2: {
                return 250;
                break;
            }
            case 3: {
                if (indexPath.row == 0) {
                    return 44;
                }
                else if (indexPath.row == 3) {
                    return 56;
                }
                return 70;
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (sections == 6) {
        switch (indexPath.section) {
            case 0: {
                ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.storeNameL.text = carUpkeepDic[@"storeName"];
                cell.storePhoneL.text = carUpkeepDic[@"storePhone"];
                cell.storeAddressL.text = carUpkeepDic[@"storeAddress"];
                return cell;
                break;
            }
            case 1: {
                CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.chepaiL.text = carUpkeepDic[@"carPlateNumber"];
                for (NSDictionary *dic in carUpkeepDic[@"categories"]) {
                    if ([dic[@"id"] intValue] == 1) { //车身
                        cell.carBodyNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 2) { //车内
                        cell.inCarNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.inCarBtn addTarget:self action:@selector(inCarAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 3) { //底盘
                        cell.underpanNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.underpanBtn addTarget:self action:@selector(underpanAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 4) { //机舱
                        cell.engineNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.engineBtn addTarget:self action:@selector(engineAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 5) { //尾箱
                        cell.bootNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.bootBtn addTarget:self action:@selector(bootAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 6) { //轮胎刹车
                        cell.tyreNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.tyreBtn addTarget:self action:@selector(tyreAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
                cell.unusualNumL.text = [NSString stringWithFormat:@"%@项",carUpkeepDic[@"unnormal"]];
                
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
                        
                        UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(90, 30*i , 80, 22)];
                        result.text = STRING(dic1[@"remark"]);
                        result.textColor = [UIColor grayColor];
                        result.font = [UIFont systemFontOfSize:14];
                        
                        UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 84 - 55 - 18 - 22, 30*i , 55, 22)];
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
                    cell.resultL.text = STRING([dic[@"carUpkeepCheckContentEntities"] firstObject][@"remark"]);
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
                    UIImageView *carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 250 - 16)];
                    carImg.image = IMG(@"carMark");
    //                [carImg sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(carUpkeepDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
                    carImg.contentMode = UIViewContentModeScaleAspectFit;
                    carImg.tag = 101;
                    [cell.contentView addSubview:carImg];
                }
                return cell;
                break;
            }
            case 4: {
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    cell.textLabel.text = [NSString stringWithFormat:@"技师:%@",dic[@"nickname"]];
                    return cell;
                }
                else if(indexPath.row == 3) {
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
                    return cell;
                }
                break;
            }
            case 5: {
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
                cell.storeNameL.text = carUpkeepDic[@"storeName"];
                cell.storePhoneL.text = carUpkeepDic[@"storePhone"];
                cell.storeAddressL.text = carUpkeepDic[@"storeAddress"];
                return cell;
                break;
            }
            case 1: {
                CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.chepaiL.text = carUpkeepDic[@"carPlateNumber"];
                for (NSDictionary *dic in carUpkeepDic[@"categories"]) {
                    if ([dic[@"id"] intValue] == 1) { //车身
                        cell.carBodyNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 2) { //车内
                        cell.inCarNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.inCarBtn addTarget:self action:@selector(inCarAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 3) { //底盘
                        cell.underpanNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.underpanBtn addTarget:self action:@selector(underpanAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 4) { //机舱
                        cell.engineNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.engineBtn addTarget:self action:@selector(engineAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 5) { //尾箱
                        cell.bootNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.bootBtn addTarget:self action:@selector(bootAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                    else if ([dic[@"id"] intValue] == 6) { //轮胎刹车
                        cell.tyreNumL.text = [NSString stringWithFormat:@"(%@)",dic[@"unnormal"]];
                        [cell.tyreBtn addTarget:self action:@selector(tyreAction) forControlEvents:UIControlEventTouchUpInside];
                    }
                }
                cell.unusualNumL.text = [NSString stringWithFormat:@"%@项",carUpkeepDic[@"unnormal"]];
                
                return cell;
                break;
            }
            case 2: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *carImg = (UIImageView *)[cell.contentView viewWithTag:101];
                if (! carImg) {
                    UIImageView *carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 250 - 16)];
                    carImg.image = IMG(@"carMark");
                    //                [carImg sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(carUpkeepDic[@"image"])] placeholderImage:IMG(@"CommplaceholderPicture")];
                    carImg.contentMode = UIViewContentModeScaleAspectFit;
                    carImg.tag = 101;
                    [cell.contentView addSubview:carImg];
                }
                return cell;
                break;
            }
            case 3: {
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSDictionary *dic = [carUpkeepDic[@"technicians"] firstObject];
                    cell.textLabel.text = [NSString stringWithFormat:@"技师:%@",dic[@"nickname"]];
                    return cell;
                }
                else if(indexPath.row == 3) {
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
                    return cell;
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
}

-(void)fullReport:(UIButton *)btn {
    if (sections == 5) {
        sections = 6;
        [self.myTableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationTop];
        [btn setTitle:@"收起完整报告" forState:UIControlStateNormal];
    }
    else {
        sections = 5;
        [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationTop];
        [btn setTitle:@"查看完整报告" forState:UIControlStateNormal];
    }
}

-(void)unscramble:(UIButton *)btn {
    
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
    problemVC.carUpkeepId = self.carUpkeepId;
    problemVC.categoryId = @"6";
    [self.navigationController pushViewController:problemVC animated:YES];
}


//CarUpkeepInfo
#pragma mark - 发送请求
-(void)requestGetUpkeepInfo { //获取检查单详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepInfo, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepInfo),self.carUpkeepId];    //测试时固定传id=1的检查单
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
    
            [self.myTableView reloadData];
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
