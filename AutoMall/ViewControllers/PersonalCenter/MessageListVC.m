//
//  MessageListVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/9.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MessageListVC.h"
#import "MessageListCell.h"

@interface MessageListVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *messageAry;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MessageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MessageListCell" bundle:nil] forCellReuseIdentifier:@"messageListCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    
    messageAry = [NSMutableArray array];
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
    
    [self requestPostMessageList];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新信息");
//    currentpage = 0;
    [self requestPostMessageList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messageAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height + 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = messageAry[indexPath.row];
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:@"messageListCell"];
    if([dic[@"status"] boolValue]) {
        cell.ReadIM.hidden = YES;
//        cell.nameL.textColor = [UIColor lightGrayColor];
//        cell.contentL.textColor = [UIColor lightGrayColor];
    } else {
        cell.ReadIM.hidden = NO;
//        cell.nameL.textColor = [UIColor darkGrayColor];
//        cell.contentL.textColor = [UIColor darkGrayColor];
    }
    cell.nameL.text = dic[@"title"];
    cell.contentL.text = dic[@"content"];
    cell.contentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 76;
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[dic[@"createTime"] doubleValue]/1000];
    float secs = creatDate.timeIntervalSinceNow;
    if (secs > -86400) {
        [formater setDateFormat:@"HH:mm"];
    } else {
        [formater setDateFormat:@"MM月dd日"];
    }
    NSString *string = [formater stringFromDate:creatDate];
    cell.timeL.text = string;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self requestDelMessage:messageAry[indexPath.row][@"id"]];    //发起删除消息请求
        [messageAry removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self requestReadMessageOK:messageAry[indexPath.row][@"id"]];
}

#pragma mark - 发送请求
-(void)requestPostMessageList { //消息列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MessageList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MessageList, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(MessageList) delegate:nil params:pram info:infoDic];
}

-(void)requestReadMessageOK:(NSString *)mid { //消息已读
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ReadMsgOk object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ReadMsgOk, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefixNew(ReadMsgOk),mid];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestDelMessage:(NSString *)mid { //消息删除
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DelMsgOk object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DelMsgOk, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefixNew(DelMsgOk),mid];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
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
    if ([notification.name isEqualToString:MessageList]) {
        NSLog(@"MessageList: %@",responseObject[@"data"]);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [messageAry removeAllObjects];
            [messageAry addObjectsFromArray:responseObject[@"data"]];
            [self.myTableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:ReadMsgOk]) {
        NSLog(@"ReadMsgOk: %@",responseObject);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ReadMsgOk object:nil];
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            [self requestPostMessageList];  //刷新列表
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:DelMsgOk]) {
        NSLog(@"DelMsgOk: %@",responseObject);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DelMsgOk object:nil];
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
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
