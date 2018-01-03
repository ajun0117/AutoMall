//
//  MailCollectionVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailCollectionVC.h"
#import "MailCollectionCell.h"
#import "CommodityDetailVC.h"

@interface MailCollectionVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *collectArray;
    int currentpage;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的收藏";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editMyFavoriteList:)];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailCollectionCell" bundle:nil] forCellReuseIdentifier:@"mailCollectionCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    collectArray = [NSMutableArray array];
    currentpage = 0;
    
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

    [self requestPostCollectionList];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [collectArray removeAllObjects];
    [self requestPostCollectionList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestPostCollectionList];
}

#pragma mark -
#pragma mark 点击按钮相应事件
//编辑收藏列表
-(void) editMyFavoriteList:(UIBarButtonItem *)sender{
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setTitle:@"确认"];
        [self.myTableView setEditing:YES animated:YES];
    }else{
        sender.tag = 0;
        [sender setTitle:@"编辑"];
        [self.myTableView setEditing:NO animated:YES];
        
    }
//    [self.myTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"adfadsf: %lu",(unsigned long)collectArray.count);
    return collectArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        return 10;
//    }
//    return 1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 10;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = collectArray[indexPath.section][@"resource"];
    MailCollectionCell *cell = (MailCollectionCell *)[tableView dequeueReusableCellWithIdentifier:@"mailCollectionCell"];
    [cell.goodsIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
    cell.goodsName.text = dic[@"name"]; 
    
    NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
    if ([mobileUserType isEqualToString:@"1"]) {    //老板
        if ([dic[@"discount"] intValue] > 0) {
            cell.goodsprice.text = [NSString stringWithFormat:@"￥%@",dic[@"discount"]];
            cell.costPriceStrikeL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
//            cell.zhekouL.hidden = NO;
        } else {
            cell.goodsprice.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
            cell.costPriceStrikeL.text = @"";
//            cell.zhekouL.hidden = YES;
        }
    }
    else {
        if ([dic[@"discount"] intValue] > 0) {
            cell.goodsprice.text = @"￥--";
            cell.costPriceStrikeL.text = @"￥--";
//            cell.zhekouL.hidden = NO;
        } else {
            cell.goodsprice.text = @"￥--";
            cell.costPriceStrikeL.text = @"";
//            cell.zhekouL.hidden = YES;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self requestPostDecollectFavoriteWithId:collectArray[indexPath.section][@"id"]];    //发起取消收藏请求
        [collectArray removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = collectArray[indexPath.section];
    if ([dic[@"resource"][@"approvalStatus"] intValue] == 11) {
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
        detailVC.commodityId = dic[@"resourceId"];
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        _networkConditionHUD.labelText = @"抱歉，该商品已下架！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

#pragma mark - 发送请求
-(void)requestPostCollectionList { //收藏列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:FavoriteList object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:FavoriteList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(FavoriteList) delegate:nil params:pram info:infoDic];
}

-(void)requestPostDecollectFavoriteWithId:(NSString *)cid { //取消收藏
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:FavoriteDecollect object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:FavoriteDecollect, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:cid,@"id", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(FavoriteDecollect) delegate:nil params:pram info:infoDic];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:FavoriteList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FavoriteList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //验证码正确
            [collectArray addObjectsFromArray:responseObject[@"data"]];
            [self.myTableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:FavoriteDecollect]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FavoriteDecollect object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            
        }
        _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
