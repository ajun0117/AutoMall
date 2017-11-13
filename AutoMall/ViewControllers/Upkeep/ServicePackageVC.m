//
//  ServicePackageVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/15.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ServicePackageVC.h"
#import "ServicePackageCell.h"
#import "UpkeepPlanNormalHeadCell.h"
//#import "JSONKit.h"

@interface ServicePackageVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *packageArray; 
    int currentpage;
    NSMutableDictionary *selectDic;     //已选择的服务数组
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ServicePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择服务套餐";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ServicePackageCell" bundle:nil] forCellReuseIdentifier:@"servicePackageCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalHeadCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanNormalHeadCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    [self requestGetServicepackageList];
    
    selectDic = [NSMutableDictionary dictionary];
    [selectDic setValuesForKeysWithDictionary:self.selectedDic];
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

- (IBAction)confirmAction:(id)sender {      //传递到上个界面
    self.SelecteServicePackage(selectDic);
    [self.navigationController popViewControllerAnimated:YES];
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
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        cell.textLabel.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
        UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 20, 30)];
        noticeL.font = [UIFont boldSystemFontOfSize:15];
        noticeL.text = @"￥";
        [cell.contentView addSubview:noticeL];
        UITextField *priceTF = [[UITextField alloc] initWithFrame:CGRectMake(32, 7, 200, 30)];
        priceTF.font = [UIFont boldSystemFontOfSize:15];

        if ([dic[@"customized"] boolValue]) {
            priceTF.text = [NSString stringWithFormat:@"%@",STRING(dic[@"customizedPrice"])];
        } else {
            priceTF.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
        }
    
        priceTF.tag = 10;
        priceTF.userInteractionEnabled = NO;
        [cell.contentView addSubview:priceTF];
        return cell;
    }
    else {
        ServicePackageCell *cell = (ServicePackageCell *)[tableView dequeueReusableCellWithIdentifier:@"servicePackageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dicc = arr[indexPath.row - 1];
        cell.declareL.text = dicc[@"name"];
        if ([dicc[@"customized"] boolValue]) {
            cell.contentL.text = [NSString stringWithFormat:@"￥%@",STRING(dicc[@"customizedPrice"])];
        } else {
            cell.contentL.text = [NSString stringWithFormat:@"￥%@",dicc[@"price"]];
        }
        
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
            [selectDic setObject:dic forKey:dic[@"id"]];     //以id为key
        }
        else {
            [selectDic removeObjectForKey:dic[@"id"]];
        }
        NSLog(@"selectDic: %@",selectDic);
    }
}

#pragma mark - 发起网络请求
-(void)requestGetServicepackageList { //检查单相关的服务套餐
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ServicepackageList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ServicepackageList, @"op", nil];
    NSString *storeId = [[GlobalSetting shareGlobalSettingInstance] storeId];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&checkTypeId=%@&storeId=%@",UrlPrefix(ServicepackageList),self.carUpkeepId,self.checktypeID,storeId];    //测试时固定传id=1的检查单
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
    if ([notification.name isEqualToString:ServicepackageList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ServicepackageList object:nil];
        NSLog(@"ServicepackageList: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            packageArray = responseObject [@"data"];
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }

}

- (void)toPopVC:(NSString *)carId {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
