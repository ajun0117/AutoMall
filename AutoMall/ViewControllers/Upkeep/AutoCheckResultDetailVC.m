//
//  AutoCheckResultDetailVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckResultDetailVC.h"
#import "ResultCheckContentDetailCell.h"
#import "ResultDetailHazardCell.h"
#import "AJAdView.h"
#import "WebViewController.h"

@interface AutoCheckResultDetailVC () <AJAdViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    AJAdView *_adView;
    NSArray *_adArray;   //广告图数组
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckResultDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"水箱水";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ResultCheckContentDetailCell" bundle:nil] forCellReuseIdentifier:@"resultCheckContentDetailCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ResultDetailHazardCell" bundle:nil] forCellReuseIdentifier:@"resultDetailHazardCell"];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    else if (section == 1) {
        return 1;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return  44;
    }
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 1;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"检查内容：冰点";
            return cell;
        }
        else if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"检查结果：";
            return cell;
        }
        ResultCheckContentDetailCell *cell = (ResultCheckContentDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"resultCheckContentDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 1){
        ResultDetailHazardCell *cell = (ResultDetailHazardCell *)[tableView dequeueReusableCellWithIdentifier:@"resultDetailHazardCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hazardContentL.text = @"潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 潜在危害内容 ";
        cell.hazardContentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 24;
        return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"建议服务方案A";
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
//    [self.navigationController pushViewController:detailVC animated:YES];
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
