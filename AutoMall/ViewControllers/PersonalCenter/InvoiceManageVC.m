//
//  InvoiceManageVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/31.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "InvoiceManageVC.h"
#import "InvoiceListCell.h"

@interface InvoiceManageVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
//    int currentpage;
    NSArray *listAry;    //订单列表
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation InvoiceManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发票管理";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editInvoice)];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"InvoiceListCell" bundle:nil] forCellReuseIdentifier:@"invoiceListCell"];
    self.myTableView.tableFooterView = [UIView new];
    
//    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
//    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
//    currentpage = 0;
//    listAry = [NSMutableArray array];
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
    
    [self requestPostInvoiceList];
}

-(void)editInvoice {
    NSLog(@"去编辑！");
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        self.myTableView.editing = YES;
        return;
    }
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    self.myTableView.editing = NO;
}

//#pragma mark - 下拉刷新,上拉加载
//-(void)headerRefreshing {
//    NSLog(@"下拉刷新个人信息");
//    currentpage = 0;
//    [orderAry removeAllObjects];
//    [self requestGetHistoryList];
//}
//
//-(void)footerLoadData {
//    NSLog(@"上拉加载数据");
//    currentpage ++;
//    [self requestGetHistoryList];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InvoiceListCell *cell = (InvoiceListCell *)[tableView dequeueReusableCellWithIdentifier:@"invoiceListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (listAry.count > 0) {
        NSDictionary *dic = listAry[indexPath.section];
        cell.taitouL.text = dic [@"head"];
        NSString *name = dic [@"realName"];
        NSString *phone = dic [@"phone"];
        NSString *email = dic [@"email"];
        cell.detailL.text = [NSString stringWithFormat:@"%@/%@/%@",name,phone,email];
        BOOL preferred = [dic [@"def"] boolValue];
        if (preferred) {
            cell.defaultL.hidden = NO;
        }
        else {
            cell.defaultL.hidden = YES;
        }
    }
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row: %ld",(long)indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //先删除相应的地址
//        [self deleteAddress:_addressArray [indexPath.row] [@"id"]];
//        [_addressArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
    }
}

#pragma mark - 发送请求
-(void)requestPostInvoiceList { //发票管理列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:InvoiceManageList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:InvoiceManageList, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",UrlPrefix(InvoiceManageList),userId];
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
    if ([notification.name isEqualToString:InvoiceManageList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:InvoiceManageList object:nil];
        if ([responseObject[@"meta"][@"msg"] isEqualToString:@"success"]) {
            listAry = responseObject[@"data"];
            [self.myTableView reloadData];
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
