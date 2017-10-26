//
//  AutoCheckResultVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/26.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckResultVC.h"
#import "AJAdView.h"
#import "ShopInfoCell.h"
#import "WebViewController.h"

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
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(0, 0, 24, 24);
    infoBtn.contentMode = UIViewContentModeScaleAspectFit;
    [infoBtn setImage:[UIImage imageNamed:@"mark"] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(toFillLicheng) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 24, 24);
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn setImage:[UIImage imageNamed:@"mark"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toMark) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, searchBtnBarBtn, infoBtnBarBtn, nil];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopInfoCell" bundle:nil] forCellReuseIdentifier:@"shopInfoCell"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20)/4+10)];
    view.backgroundColor = [UIColor clearColor];
    self.myTableView.tableHeaderView = view;
    _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH - 20 , (SCREEN_WIDTH - 20)/4)];
    _adView.delegate = self;
    [view addSubview:_adView];
    
    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/5abeb351-d881-4f08-b582-fa73fd8a509e.jpg",@"content":@"广告2",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep//uploads/2017/09/093d2e04-7040-4d9d-afe4-4739c1674c40.png",@"content":@"广告3",@"thirdPartyUrl":@""}];
}

-(void)toFillLicheng {
}

-(void)toMark {
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
    switch (indexPath.row) {
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
                return  160;
            }
            return 44;
            break;
        }
        case 3: {
            return 200;
            break;
        }
        case 4: {
            return 44;
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            ShopInfoCell *cell = (ShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"shopInfoCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case 1: {
            return nil;
            break;
        }
        case 2: {
            if (indexPath.row == 2) {
                return  nil;
            }
            return nil;
            break;
        }
        case 3: {
            return nil;
            break;
        }
        case 4: {
            return nil;
            break;
        }
        case 5: {
            return nil;
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
