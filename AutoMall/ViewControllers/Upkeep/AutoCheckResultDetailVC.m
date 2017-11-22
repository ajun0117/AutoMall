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
#import "HZPhotoBrowser.h"

@interface AutoCheckResultDetailVC () <AJAdViewDelegate, HZPhotoBrowserDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    AJAdView *_adView;
    NSArray *_adArray;   //广告图数组
    NSDictionary *contentResultDic;
    NSArray *images;        //图片数组
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckResultDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ResultCheckContentDetailCell" bundle:nil] forCellReuseIdentifier:@"resultCheckContentDetailCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ResultDetailHazardCell" bundle:nil] forCellReuseIdentifier:@"resultDetailHazardCell"];
    
    
//    _adView = [[AJAdView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_WIDTH/3)];
//    _adView.delegate = self;
//    self.myTableView.tableHeaderView = _adView;
//    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""}];
//    [_adView reloadData];
    
    [self requestGetCarUpkeepCheckTerm];
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
    
//    _adArray = @[@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/57381ddf-052a-4eba-928e-0b54bd6d12e1.png",@"content":@"广告1",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep/uploads/2017/09/5abeb351-d881-4f08-b582-fa73fd8a509e.jpg",@"content":@"广告2",@"thirdPartyUrl":@""},@{@"image":@"http://119.23.227.246/carupkeep//uploads/2017/09/093d2e04-7040-4d9d-afe4-4739c1674c40.png",@"content":@"广告3",@"thirdPartyUrl":@""}];
//    [_adView reloadData];
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
        NSArray *ary = contentResultDic[@"carUpkeepCheckContentEntities"];
        return ary.count + 2;
    }
    else if (section == 1) {
        return 1;
    }else if (section == 2) {
        NSArray *ary = contentResultDic[@"serviceContents"];
        return ary.count;
    }
    
    return 0;
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
    switch (section) {
        case 0:
            return 10;
            break;
            
        case 1:
            return 44;
            break;
            
        case 2:
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
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 12, 150, 20)];
            label.font = [UIFont boldSystemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"潜在问题与危害";
            
            [view addSubview:label];
            return view;
            break; 
        }
            
        case 2: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = [UIColor whiteColor];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 12, 100, 20)];
            label.font = [UIFont boldSystemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"服务内容";
            
            [view addSubview:label];
            return view;
            break;
        }
            
        default:
            return nil;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.textLabel.text = [NSString stringWithFormat:@"检查内容：%@",STRING_Nil(contentResultDic[@"name"])];
            return cell;
        }
        else if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.text = @"检查结果：";
            return cell;
        }
        ResultCheckContentDetailCell *cell = (ResultCheckContentDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"resultCheckContentDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dic = contentResultDic[@"carUpkeepCheckContentEntities"][indexPath.row-2];
        if ([contentResultDic[@"group"] isKindOfClass:[NSString class]]) {  //多个位置
            cell.checkContentL.text = STRING(dic[@"dPosition"]);
            cell.resultL.text = STRING(dic[@"describe"]);
            cell.levelL.text =  STRING(dic[@"result"]);
            cell.levelL.layer.cornerRadius = 4;
            int levelInt = [dic[@"level"] intValue];
            if (levelInt == 1) {
                cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
            }
            else if (levelInt == 2) {
                cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
            }
            else if (levelInt == 3) {
                cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
            }
        }
        else {
            cell.checkContentL.text = STRING(contentResultDic[@"name"]);
            cell.levelL.text =  STRING(dic[@"result"]);
            cell.levelL.layer.cornerRadius = 4;
            int levelInt = [dic[@"level"] intValue];
            if (levelInt == 1) {
                cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
            }
            else if (levelInt == 2) {
                cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
            }
            else if (levelInt == 3) {
                cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
            }
        }
        cell.photoBtn.tag = 100 + indexPath.row;
        [cell.photoBtn addTarget:self action:@selector(toPhoto:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (indexPath.section == 1){
        ResultDetailHazardCell *cell = (ResultDetailHazardCell *)[tableView dequeueReusableCellWithIdentifier:@"resultDetailHazardCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hazardContentL.text = contentResultDic[@"risk"];
        cell.hazardContentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 24;
        return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        NSArray *ary = contentResultDic[@"serviceContents"];
        cell.textLabel.text = ary[indexPath.row][@"name"];
        return cell;
    }
}

-(void)toPhoto:(UIButton *)btn {
//    ResultCheckContentDetailCell *cell = (ResultCheckContentDetailCell *)btn.superview.superview;
//    NSIndexPath *index = [self.myTableView indexPathForCell:cell];
    int row = (int)btn.tag - 100;
    NSArray *ary = contentResultDic[@"carUpkeepCheckContentEntities"];
    NSDictionary *dic = ary[row - 2];
    images = dic[@"minorImages"];
    if (images.count > 0) {
        [self clickImageWithIndex:row - 2];
    }
    else {
        _networkConditionHUD.labelText = @"没有相关图片";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

-(void)clickImageWithIndex:(NSInteger)index {
    //启动图片浏览器
    HZPhotoBrowser *browserVC = [[HZPhotoBrowser alloc] init];
    browserVC.sourceImagesContainerView = self.view; // 原图的父控件
    NSArray *ary = contentResultDic[@"carUpkeepCheckContentEntities"];
    NSDictionary *dic = ary[index];
    images = dic[@"minorImages"];
    browserVC.imageCount = images.count; // 图片总数 imagesAry.count
    browserVC.currentImageIndex = 0;
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
    NSDictionary *dic = images[index];
    NSString *urlStr = UrlPrefix(dic[@"relativePath"]);
    return [NSURL URLWithString:urlStr];
}

- (NSString *)photoBrowser:(HZPhotoBrowser *)browser titleStringForIndex:(NSInteger)index {
    //    NSDictionary *dic = _typeImgsArray [index];
    //    NSString *titleStr = dic [@"content"];
    return @"";
}

#pragma mark - 发送请求
-(void)requestGetCarUpkeepCheckTerm { //检查单具体检查部位下检查结果详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepCheckTerm object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepCheckTerm, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&checkTermId=%@&checkContentId=%@",UrlPrefix(CarUpkeepCheckTerm),self.checkId,self.checkTermId,self.checkContentId];    //测试时固定传id=1的检查单
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
    if ([notification.name isEqualToString:CarUpkeepCheckTerm]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepCheckTerm object:nil];
        NSLog(@"CarUpkeepCategory: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            self.title = responseObject[@"data"][@"name"];
            contentResultDic = [responseObject[@"data"][@"checkContentVos"] firstObject];
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
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
