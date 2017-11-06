//
//  SecondViewController.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "InformationVC.h"
#import "InformationCell.h"
#import "WebViewController.h"

@interface InformationVC () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *zixunArray;
    NSMutableArray *jiaochengArray;
    int zixunCurrentpage;
    int jiaochengCurrentpage;
}

@property (strong, nonatomic) IBOutlet UIButton *zixunBtn;
@property (strong, nonatomic) IBOutlet UIButton *jiaochengBtn;
@property (strong, nonatomic) IBOutlet UIView *zixunView;
@property (strong, nonatomic) IBOutlet UIView *jiaochengView;
//@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UITableView *zixunTV;
@property (strong, nonatomic) UITableView *jiaochengTV;

@end

@implementation InformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"资讯";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    [self.myTableView registerNib:[UINib nibWithNibName:@"InformationCell" bundle:nil] forCellReuseIdentifier:@"inforCell"];
//    self.myTableView.tableFooterView = [UIView new];
//    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
////    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 44, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 49)];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT - 64 - 44 - 49);
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.delegate = self;
    [self.view addSubview:self.mainScrollView];
    
    self.zixunTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 49) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.zixunTV];
    self.zixunTV.delegate = self;
    self.zixunTV.dataSource = self;
    [self.zixunTV registerNib:[UINib nibWithNibName:@"InformationCell" bundle:nil] forCellReuseIdentifier:@"inforCell"];
    self.zixunTV.tableFooterView = [UIView new];
    [self.zixunTV addHeaderWithTarget:self action:@selector(zixunHeaderRefreshing)];
    [self.zixunTV addFooterWithTarget:self action:@selector(zixunFooterLoadData)];
    
    self.jiaochengTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44 - 49) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.jiaochengTV];
    self.jiaochengTV.delegate = self;
    self.jiaochengTV.dataSource = self;
    [self.jiaochengTV registerNib:[UINib nibWithNibName:@"InformationCell" bundle:nil] forCellReuseIdentifier:@"inforCell"];
    self.jiaochengTV.tableFooterView = [UIView new];
    [self.jiaochengTV addHeaderWithTarget:self action:@selector(jiaochengHeaderRefreshing)];
    [self.jiaochengTV addFooterWithTarget:self action:@selector(jiaochengFooterLoadData)];
    
    zixunCurrentpage = 0; //默认首页
    zixunArray = [[NSMutableArray alloc] init];
    
    jiaochengCurrentpage = 0; //默认首页
    jiaochengArray = [[NSMutableArray alloc] init];
    
    [self requestGetMyMessage];
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
    
//    [self.zixunTV headerBeginRefreshing];
}

- (IBAction)zixunAction:(id)sender {
    [self setButton:self.zixunBtn withBool:YES andView:self.zixunView withColor:Red_BtnColor];
    [self setButton:self.jiaochengBtn withBool:NO andView:self.jiaochengView withColor:[UIColor clearColor]];
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    if ([zixunArray count] == 0) {
        zixunCurrentpage = 0;
        [self requestGetMyMessage];
    }
}

- (IBAction)jiaochengAction:(id)sender {
    [self setButton:self.zixunBtn withBool:NO andView:self.zixunView withColor:[UIColor clearColor]];
    [self setButton:self.jiaochengBtn withBool:YES andView:self.jiaochengView withColor:Red_BtnColor];
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
    if ([jiaochengArray count] == 0) {
        jiaochengCurrentpage = 0;
        [self requestGetCourseList];
    }
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
    btn.selected = bo;
    view.backgroundColor = color;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        CGFloat offsetX = scrollView.contentOffset.x;
        NSLog(@"offsetX: %f",offsetX);
        if (offsetX >= SCREEN_WIDTH) {
            [self jiaochengAction:self.jiaochengBtn];
        }
        else {
            [self zixunAction:self.zixunBtn];
        }
    }
}

#pragma mark - 下拉刷新,上拉加载
-(void)zixunHeaderRefreshing {
    NSLog(@"下拉刷新个人信息");
    zixunCurrentpage = 0;
    [zixunArray removeAllObjects];
    [self requestGetMyMessage];
}

-(void)zixunFooterLoadData {
    NSLog(@"上拉加载数据");
    zixunCurrentpage ++;
    [self requestGetMyMessage];
}

-(void)jiaochengHeaderRefreshing {
    NSLog(@"下拉刷新个人信息");
    jiaochengCurrentpage = 0;
    [jiaochengArray removeAllObjects];
    [self requestGetCourseList];
}

-(void)jiaochengFooterLoadData {
    NSLog(@"上拉加载数据");
    jiaochengCurrentpage ++;
    [self requestGetCourseList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.zixunTV) {
        return [zixunArray count];
    }
    return [jiaochengArray count];
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 5;
//    }
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 5;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.zixunTV) {
        InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"inforCell"];
        NSDictionary *dic = zixunArray[indexPath.section];
        [cell.zixunIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage: IMG(@"placeholderPictureSquare")];
        cell.zixunTitle.text = STRING(dic[@"title"]);
        cell.zixunContent.text = STRING(dic[@"shortContent"]);
        return cell;
    }
    else {
        InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"inforCell"];
        NSDictionary *dic = jiaochengArray[indexPath.section];
        [cell.zixunIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage: IMG(@"placeholderPictureSquare")];
        cell.zixunTitle.text = STRING(dic[@"title"]);
        cell.zixunContent.text = STRING(dic[@"shortContent"]);
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WebViewController *webVC = [[WebViewController alloc] init];
    if (tableView == self.zixunTV) {
        webVC.webUrlStr = [NSString stringWithFormat:@"%@/%@",UrlPrefix(InformationDetail),zixunArray[indexPath.section][@"id"]];
        webVC.titleStr = STRING(zixunArray[indexPath.section][@"title"]);
    } else {
        webVC.webUrlStr = [NSString stringWithFormat:@"%@/%@",UrlPrefix(CourseDetail),jiaochengArray[indexPath.section][@"id"]];
        webVC.titleStr = STRING(jiaochengArray[indexPath.section][@"title"]);
    }
    webVC.canShare = NO;
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
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
    NSString *urlString = [NSString stringWithFormat:@"%@?pageNo=%d",UrlPrefix(InformationList),zixunCurrentpage];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestGetCourseList { //获取教程列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CourseList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CourseList, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?pageNo=%d",UrlPrefix(CourseList),jiaochengCurrentpage];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.zixunTV headerEndRefreshing];
    [self.zixunTV footerEndRefreshing];
    [self.jiaochengTV headerEndRefreshing];
    [self.jiaochengTV footerEndRefreshing];
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
            [zixunArray addObjectsFromArray:responseObject [@"data"]];
            [self.zixunTV reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
//        [self.zixunTV reloadData];
    }
    if ([notification.name isEqualToString:CourseList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [jiaochengArray addObjectsFromArray:responseObject [@"data"]];
            [self.jiaochengTV reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
//        [self.jiaochengTV reloadData];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
