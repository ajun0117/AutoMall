//
//  AutoCheckDisountsVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckDisountsVC.h"
#import "AutoCheckDiscountCell.h"

@interface AutoCheckDisountsVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *discountArray;
    int currentpage;
    NSMutableDictionary *selectedDis;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckDisountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择优惠";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"AutoCheckDiscountCell" bundle:nil] forCellReuseIdentifier:@"autoCheckDiscountCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    currentpage = 0;
    discountArray = [NSMutableArray array];
    selectedDis = [NSMutableDictionary dictionary];
    [selectedDis setValuesForKeysWithDictionary:self.selectedDic];
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
    
    currentpage = 0;
    [discountArray removeAllObjects];
    [self requestPostDiscountList];
}
- (IBAction)affirmAction:(id)sender {
    self.SelecteDiscount(selectedDis);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [discountArray removeAllObjects];
    [self requestPostDiscountList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestPostDiscountList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return discountArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AutoCheckDiscountCell *cell = (AutoCheckDiscountCell *)[tableView dequeueReusableCellWithIdentifier:@"autoCheckDiscountCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = discountArray[indexPath.row];
    cell.nameL.text = dic[@"item"];
    if (dic[@"money"]) {
        cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"money"]];
    }
    [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
    NSArray *keys = [selectedDis allKeys];
    if ([keys containsObject:dic[@"id"]]) {
        cell.radioBtn.selected = YES;
    } else {
        cell.radioBtn.selected = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AutoCheckDiscountCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.radioBtn.selected = !cell.radioBtn.selected;
    NSDictionary *dic = discountArray[indexPath.row];
    if (cell.radioBtn.selected) {
        [selectedDis setObject:dic forKey:dic[@"id"]];     //以id为key
    }
    else {
        [selectedDis removeObjectForKey:dic[@"id"]];
    }
    NSLog(@"selectedDis: %@",selectedDis);

}

#pragma mark - 发送请求
-(void)requestPostDiscountList { //优惠列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DiscountList object:nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DiscountList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:storeId,@"storeId",[NSNumber numberWithInt:currentpage],@"pageNo", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(DiscountList) delegate:nil params:pram info:infoDic];
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
    NSLog(@"DiscountList: %@",responseObject);
    if ([notification.name isEqualToString:DiscountList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DiscountList object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //验证码正确
            [discountArray addObjectsFromArray:responseObject[@"data"]];
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
