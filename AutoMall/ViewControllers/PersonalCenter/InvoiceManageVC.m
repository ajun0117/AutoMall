//
//  InvoiceManageVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/31.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "InvoiceManageVC.h"
#import "InvoiceListCell.h"
#import "AddInvoiceVC.h"

@interface InvoiceManageVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
//    int currentpage;
    NSMutableArray *listAry;    //发票列表
    NSMutableArray *orderAry;   //待开发票订单列表
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
    self.navigationItem.rightBarButtonItem.tintColor = RGBCOLOR(0, 191, 243);
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"InvoiceListCell" bundle:nil] forCellReuseIdentifier:@"invoiceListCell"];
    self.myTableView.tableFooterView = [UIView new];
    
//    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
//    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
//    currentpage = 0;
    listAry = [NSMutableArray array];
    if (self.orderDic) {
        self.navigationItem.rightBarButtonItem = nil;
        orderAry = [NSMutableArray array];
        NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
        for (NSDictionary *dic in [self.orderDic allValues]) {
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.orderType,@"orderType",dic[@"code"],@"orderNo",userId,@"userId",dic[@"money"],@"price", nil];
            [orderAry addObject:muDic];
        }
        NSLog(@"orderAry: %@",orderAry);
    }
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
- (IBAction)addInvoiceAction:(id)sender {
    AddInvoiceVC *addVC = [[AddInvoiceVC alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
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
    NSDictionary *dic = listAry[indexPath.section];
    if (self.orderDic) {  //用于选择后开发票
        for (NSMutableDictionary *muDic in orderAry) {
            [muDic setObject:dic[@"province"] forKey:@"province"];
            [muDic setObject:dic[@"city"] forKey:@"city"];
            [muDic setObject:dic[@"addr"] forKey:@"addr"];
            [muDic setObject:dic[@"type"] forKey:@"type"];
            [muDic setObject:dic[@"head"] forKey:@"head"];
            [muDic setObject:dic[@"realName"] forKey:@"realName"];
            [muDic setObject:dic[@"phone"] forKey:@"phone"];
            [muDic setObject:dic[@"email"] forKey:@"email"];
            [muDic setObject:@"0" forKey:@"status"];    //固定值，0 待审核，1 通过，2 拒绝
            [muDic setObject:dic[@"taxpayerCode"] forKey:@"taxpayerCode"];
        }
        NSLog(@"orderAry: %@",orderAry);
        [self toInvoiceWithAry:orderAry];
    } else {
        AddInvoiceVC *editVC = [[AddInvoiceVC alloc] init];
        editVC.isEdit = YES;
        editVC.invoiceDic = dic;
        [self.navigationController pushViewController:editVC animated:YES];
    }
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
        [self deleTheInvoiceWithId:listAry [indexPath.row] [@"id"]];
        [listAry removeObjectAtIndex:indexPath.row];//移除数据源的数据
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];//移除tableView中的数据
    }
}

#pragma mark - 发送请求
-(void)requestPostInvoiceList { //发票管理列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:InvoiceManageList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:InvoiceManageList, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@",UrlPrefixNew(InvoiceManageList),userId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)deleTheInvoiceWithId:(NSString *)iid {     //删除某个发票
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DeleInvoice object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DeleInvoice, @"op", nil];
//    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefixNew(DeleInvoice),iid];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)toInvoiceWithAry:(NSArray *)ary {      //开发票
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:OrderInvoiceHis object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:OrderInvoiceHis, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:ary,@"list", nil];
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefixNew(OrderInvoiceHis) delegate:nil params:pram info:infoDic];
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
            [listAry removeAllObjects];     //未做分页
            [listAry addObjectsFromArray: responseObject[@"body"][@"list"]];
            [self.myTableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:DeleInvoice]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleInvoice object:nil];
        
        if ([responseObject[@"meta"][@"msg"] isEqualToString:@"success"]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:OrderInvoiceHis]) {  //开发票
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OrderInvoiceHis object:nil];
        
        if ([responseObject[@"meta"][@"msg"] isEqualToString:@"success"]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.navigationController popViewControllerAnimated:YES];
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
