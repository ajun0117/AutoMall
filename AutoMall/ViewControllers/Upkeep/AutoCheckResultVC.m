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
    [shareBtn addTarget:self action:@selector(toFillLicheng) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, shareBtnBarBtn, nil];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopInfoCell" bundle:nil] forCellReuseIdentifier:@"shopInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultCell" bundle:nil] forCellReuseIdentifier:@"checkResultCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultTechnicianCell" bundle:nil] forCellReuseIdentifier:@"checkResultTechnicianCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultQRCell" bundle:nil] forCellReuseIdentifier:@"checkResultQRCell"];
    
    _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_WIDTH/3)];
    _adView.delegate = self;
    self.myTableView.tableHeaderView = _adView;
    
    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/5abeb351-d881-4f08-b582-fa73fd8a509e.jpg",@"content":@"广告2",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep//uploads/2017/09/093d2e04-7040-4d9d-afe4-4739c1674c40.png",@"content":@"广告3",@"thirdPartyUrl":@""}];
    [_adView reloadData];
    
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

-(void)toFillLicheng {
}

-(void)toMark {
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
    [self.navigationController pushViewController:planVC animated:YES];
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
            return 3;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return 60;
            break;
        }
        case 1: {
            return 220;
            break;
        }
        case 2: {
            if (indexPath.row == 2) {
                return  206;
            }
            return 44;
            break;
        }
        case 3: {
            return 200;
            break;
        }
        case 4: {
            if (indexPath.row == 0) {
                return 44;
            }
            else if (indexPath.row == 3) {
                return 44;
            }
            return 60;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 1: {
            CheckResultCell *cell = (CheckResultCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultCell"];
            [cell.carBodybtn addTarget:self action:@selector(carBodyAction) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 2: {
            if (indexPath.row == 2) {
                CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
                if (! label) {
                    for (int i=0; i<4; ++i) {
                        UILabel *position = [[UILabel alloc] initWithFrame:CGRectMake(0, 36*i , 80, 22)];
                        position.text = @"左前";
                        position.tag = 100 + i;
                        position.textColor = [UIColor grayColor];
                        position.font = [UIFont systemFontOfSize:14];
                        
                        UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(90, 36*i , 80, 22)];
                        result.text = @"262kpa";
                        result.textColor = [UIColor grayColor];
                        result.font = [UIFont systemFontOfSize:14];
                        
                        UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 84 - 50 - 18, 36*i , 50, 22)];
                        level.text = @"正常";
                        level.textAlignment = NSTextAlignmentCenter;
                        level.textColor = [UIColor whiteColor];
                        level.backgroundColor = RGBCOLOR(0, 166, 59);
                        level.font = [UIFont systemFontOfSize:13];
                        level.layer.cornerRadius = 4;
                        level.clipsToBounds = YES;
                        
                        [cell.positionView addSubview:position];
                        [cell.positionView addSubview:result];
                        [cell.positionView addSubview:level];
                    }
                }
                return cell;
            }
            else {
                CheckResultSingleCell *cell = (CheckResultSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultSingleCell"];
                cell.levelL.layer.cornerRadius = 4;
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
                UIImageView *carImg = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 200 - 16)];
                carImg.image = IMG(@"carMark");
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
                cell.textLabel.text = @"技师：张三";
                return cell;
            }
            else if(indexPath.row == 3) {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIButton *label = (UIButton *)[cell.contentView viewWithTag:101];
                if (! label) {
                    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn1.tag = 101;
                    btn1.frame = CGRectMake(8, 2, (SCREEN_WIDTH - 16 - 10)/2, 40);
                    [btn1 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [btn1 setImage:IMG(@"center_servicesConfirmed") forState:UIControlStateNormal];
                    [btn1 setTitle:@"查看完整报告" forState:UIControlStateNormal];
                    btn1.layer.cornerRadius = 5;
                    btn1.clipsToBounds = YES;
                    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                    [btn1 addTarget:self action:@selector(fullReport) forControlEvents:UIControlEventTouchUpInside];
                    
                    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn2.tag = 102;
                    btn2.frame = CGRectMake(VIEW_BX(btn1) + 5, 2, (SCREEN_WIDTH - 16 - 10)/2, 40);
                    [btn2 setBackgroundColor:RGBCOLOR(253, 182, 49)];
                    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                    [btn2 setImage:IMG(@"center_contact") forState:UIControlStateNormal];
                    [btn2 setTitle:@"专家解读报告" forState:UIControlStateNormal];
                    btn2.layer.cornerRadius = 5;
                    btn2.clipsToBounds = YES;
                    btn2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
                    [btn2 addTarget:self action:@selector(fullReport) forControlEvents:UIControlEventTouchUpInside];
                    
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//车身检查结果
-(void)carBodyAction {
    AutoCheckResultProblemVC *problemVC = [[AutoCheckResultProblemVC alloc] init];
    [self.navigationController pushViewController:problemVC animated:YES];
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
