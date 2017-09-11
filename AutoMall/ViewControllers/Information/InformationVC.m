//
//  SecondViewController.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "InformationVC.h"
#import "InformationCell.h"

@interface InformationVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *inforArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *topSegment;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation InformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    self.title = @"资讯";
    [self.myTableView registerNib:[UINib nibWithNibName:@"InformationCell" bundle:nil] forCellReuseIdentifier:@"inforCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
//    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 1; //默认首页
    inforArray = [[NSMutableArray alloc] init];
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
    
    [self.myTableView headerBeginRefreshing];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
//    currentpage = 1;
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    [inforArray removeAllObjects];
    [self requestGetMyMessage];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
//    currentpage ++;
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    [self requestGetMyMessage];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [inforArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    return height + 1;
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"inforCell"];
    NSDictionary *dic = inforArray[indexPath.section];
    //    cell.zixunIMG.image = IMG(@"personalCenter");
    [cell.zixunIMG sd_setImageWithURL:[NSURL URLWithString:ImagePrefixURL(dic[@"image"])] placeholderImage: IMG(@"baoyang_history")];
    cell.zixunTitle.text = STRING(dic[@"title"]);
    cell.zixunContent.text = STRING(dic[@"content"]);
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)changeChannel:(id)sender {
    [inforArray removeAllObjects];
    if (self.topSegment.selectedSegmentIndex == 0) {
        [self requestGetMyMessage];
    }
    else {
        [self requestGetCourseList];
    }
}

#pragma mark - 网络请求
-(void)requestGetMyMessage { //获取我的消息列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:InformationList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:InformationList, @"op", nil];
    
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"page",@"10",@"limit", nil];
//    NSLog(@"pram: %@",pram);
//    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MessageList) delegate:nil params:pram info:infoDic];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(InformationList) delegate:nil params:nil info:infoDic];
}

-(void)requestGetCourseList { //获取教程列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CourseList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CourseList, @"op", nil];
    
    //    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"page",@"10",@"limit", nil];
    //    NSLog(@"pram: %@",pram);
    //    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MessageList) delegate:nil params:pram info:infoDic];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(CourseList) delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:InformationList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:InformationList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [inforArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        [self.myTableView reloadData];
    }
    if ([notification.name isEqualToString:CourseList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [inforArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        [self.myTableView reloadData];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
