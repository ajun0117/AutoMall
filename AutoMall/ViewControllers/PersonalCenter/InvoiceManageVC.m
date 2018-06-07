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
    
    listAry = [NSMutableArray array];
    
    if (self.orderDic) {  //用于选择后开发票
        self.title = @"选择发票";
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InvoiceListCell *cell = (InvoiceListCell *)[tableView dequeueReusableCellWithIdentifier:@"invoiceListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (listAry.count > 0) {
        NSDictionary *dic = listAry[indexPath.row];
        cell.taitouL.text = dic [@"head"];
        NSString *name = dic [@"realName"];
        NSString *phone = dic [@"phone"];
        NSString *email = dic [@"email"];
        cell.detailL.text = [NSString stringWithFormat:@"%@/%@/%@",name,phone,email];
        
        NSString *typeStr;
        switch ([dic[@"type"] intValue]) {
            case 0:
                typeStr = @"个人普通发票";
                break;
                
            case 1:
                typeStr = @"企业普通发票";
                break;
                
            case 2:
                typeStr = @"增值税专用发票";
                break;
                
            default:
                typeStr = @"";
                break;
        }
        cell.typeL.text = [NSString stringWithFormat:@"发票类型（%@）",typeStr];
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
    NSDictionary *dic = listAry[indexPath.row];
    if (self.orderDic) {  //用于选择后开发票
        [self toInvoiceWithDic:dic];
    } else {
        AddInvoiceVC *editVC = [[AddInvoiceVC alloc] init];
        editVC.isEdit = YES;
        editVC.invoiceDic = dic;
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
        return YES;
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

-(void)toInvoiceWithDic:(NSDictionary *)dic {      //批量开发票
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:OrderInvoiceCreat object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:OrderInvoiceCreat, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSArray *values = [self.orderDic allValues];
    NSMutableArray *codes = [NSMutableArray array];
    for (NSDictionary *dic in values) {
        [codes addObject:dic[@"code"]];
    }
    NSString *orderNosStr = [codes componentsJoinedByString:@","];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId",self.orderType,@"orderType",orderNosStr,@"orderNos",dic[@"province"],@"province",dic[@"city"],@"city",dic[@"area"],@"area",dic[@"addr"],@"addr",dic[@"type"],@"type",dic[@"head"],@"head",dic[@"realName"],@"realName",dic[@"phone"],@"phone",dic[@"email"],@"email",@"0",@"status",dic[@"taxpayerCode"],@"taxpayerCode",dic[@"registAddr"],@"registAddr",dic[@"registPhone"],@"registPhone",dic[@"depositBank"],@"depositBank",dic[@"bankAccount"],@"bankAccount", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefixNew(OrderInvoiceCreat) delegate:nil params:pram info:infoDic];
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
        NSLog(@"InvoiceManageList_responseObject: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            [listAry removeAllObjects];     //未做分页
            [listAry addObjectsFromArray: responseObject[@"body"][@"list"]];
            [self.myTableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:responseObject[@"meta"][@"msg"] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:DeleInvoice]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleInvoice object:nil];
         NSLog(@"DeleInvoice_responseObject: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:OrderInvoiceCreat]) {  //批量开发票
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OrderInvoiceCreat object:nil];
        NSLog(@"OrderInvoiceCreat_responseObject: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self performSelector:@selector(toPopVC) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }

    
}

- (void)toPopVC {
        [self.navigationController popViewControllerAnimated:YES];
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
