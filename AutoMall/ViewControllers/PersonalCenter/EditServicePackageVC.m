//
//  EditServicePackageVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EditServicePackageVC.h"
#import "UpkeepPlanNormalCell.h"
#import "UpkeepPlanNormalHeadCell.h"
#import "JSONKit.h"

@interface EditServicePackageVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *packageArray;
    int currentpage;
    NSMutableDictionary *selectDic;     //已选择的服务数组
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EditServicePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务套餐";
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalHeadCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanNormalHeadCell"];
    self.myTableView.tableFooterView = [UIView new];
    
//    NSArray *arr = @[
//                     @{@"title":@"套餐A",@"allmoney":@"2200",@"data":@[@{@"name":@"机油更换1",@"money":@"333"},@{@"name":@"火花塞更换1",@"money":@"444"},@{@"name":@"机舱清洗保养1",@"money":@"555"}]},
//                     @{@"title":@"套餐B",@"allmoney":@"3000",@"data":@[@{@"name":@"机油更换2",@"money":@"333"},@{@"name":@"火花塞更换2",@"money":@"444"},@{@"name":@"机舱清洗保养2",@"money":@"555"},@{@"name":@"空调系统清洗2",@"money":@"666"}]}
//                     ];
    
    packageArray = [NSMutableArray array];
    currentpage = 0;
    [self requestPostListPackage];
    
    selectDic = [NSMutableDictionary dictionary];
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

- (IBAction)saveAction:(id)sender {
    [self requestPostCustomizeServicePackage];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [packageArray removeAllObjects];
    [self requestPostListPackage];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestPostListPackage];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [packageArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = packageArray[section];
    return [dic[@"serviceContents"] count] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐A";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        case 1: {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐B";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.text = @"￥2200";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        case 1: {
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"￥3000";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = packageArray[indexPath.section];
    NSArray *arr = dic[@"serviceContents"];
    if (indexPath.row == 0) {
        UpkeepPlanNormalHeadCell *cell = (UpkeepPlanNormalHeadCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanNormalHeadCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameL.text =  dic[@"name"];
        [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
        NSArray *keys = [selectDic allKeys];
        if ([keys containsObject:dic[@"id"]]) {
            cell.radioBtn.selected = YES;
        } else {
            cell.radioBtn.selected = NO;
        }
        return cell;
    }
    else if (indexPath.row == [arr count] + 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
        return cell;
    }
    else {
        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSDictionary *dicc = arr[indexPath.row - 1];
        cell.declareL.text = dicc[@"name"];
        cell.contentL.text = [NSString stringWithFormat:@"￥%@",dicc[@"price"]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UpkeepPlanNormalHeadCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.radioBtn.selected = !cell.radioBtn.selected;
        NSDictionary *dic = packageArray[indexPath.section];
        if (cell.radioBtn.selected) {
            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"price"],@"price", nil];
            [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
        }
        else {
            [selectDic removeObjectForKey:dic[@"id"]];
        }
        NSLog(@"selectDic: %@",selectDic);
    }
}

#pragma mark - 发起网络请求
-(void)requestPostListPackage { //定制服务套餐列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ListServicePackage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ListServicePackage, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo",@"20",@"pageSize", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ListServicePackage) delegate:nil params:pram info:infoDic];
}

-(void)requestPostCustomizeServicePackage { //提交定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CustomizeServicePackage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CustomizeServicePackage, @"op", nil];
    //    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:idAry,@"id",priceAry,@"price", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[[selectDic allValues] JSONString],@"data", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CustomizeServicePackage) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:ListServicePackage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ListServicePackage object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [packageArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CustomizeServicePackage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CustomizeServicePackage object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
