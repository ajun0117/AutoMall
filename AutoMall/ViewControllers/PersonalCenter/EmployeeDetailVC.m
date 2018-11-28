//
//  EmployeeDetailVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeDetailVC.h"
#import "EmployeeDetailTopCell.h"
#import "EmployeeDetailCell.h"
#import "EmployeeAuthVC.h"

@interface EmployeeDetailVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *skillAry;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EmployeeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.staffDic[@"nickname"];
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    skillAry = [NSMutableArray array];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailTopCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailTopCell"];

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
    
    [self requestGetStaffList];
}

//-(void) toCheck {   //进行审核操作
//    EmployeeAuthVC *authVC = [[EmployeeAuthVC alloc] init];
//    [self.navigationController pushViewController:authVC animated:YES];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    return [skillAry count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    }
    else if (indexPath.section == 1) {
        EmployeeDetailTopCell *cell = (EmployeeDetailTopCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 1;
    }
    
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
        bgView.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.myTableView.bounds), 44)];
        //                view.backgroundColor = RGBCOLOR(249, 250, 251);
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"账号";
        [view addSubview:label];
        [bgView addSubview:view];
        return bgView;
    }
    else if (section == 1) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
        bgView.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.myTableView.bounds), 44)];
        //                view.backgroundColor = RGBCOLOR(249, 250, 251);
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"特长介绍";
        [view addSubview:label];
        [bgView addSubview:view];
        return bgView;
    }
    else {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
        bgView.backgroundColor = [UIColor clearColor];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.myTableView.bounds), 44)];
        //                view.backgroundColor = RGBCOLOR(249, 250, 251);
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
        label.font = [UIFont boldSystemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"技能认证";
        [view addSubview:label];
        [bgView addSubview:view];
        return bgView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"employeeListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.text = STRING(self.staffDic[@"phone"]);
        return cell;
    }
    else if (indexPath.section == 1) {
        EmployeeDetailTopCell *cell = (EmployeeDetailTopCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailTopCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self.staffDic[@"remark"] isKindOfClass:[NSNull class]] || [self.staffDic[@"remark"] isEqualToString:@""]) {
            cell.contentL.text = @"员工还未填写特长介绍";
        } else {
            cell.contentL.text = STRING(self.staffDic[@"remark"]);
        }
        cell.contentL.preferredMaxLayoutWidth = CGRectGetWidth(self.myTableView.bounds) - 24;
        return cell;
    }
    
    else {
        NSDictionary *dic = skillAry[indexPath.row];
        EmployeeDetailCell *cell = (EmployeeDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailCell"];
        cell.nameL.text = dic[@"name"];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
        switch ([dic[@"approvalStatus"] intValue]) {
            case 0:{
                 [cell.daishenBtn setBackgroundColor:RGBCOLOR(234, 0, 24)];
                [cell.daishenBtn setTitle:@"等待审核" forState:UIControlStateNormal];
                break;
            }
            case 1:{
                 [cell.daishenBtn setBackgroundColor:RGBCOLOR(234, 0, 24)];
                [cell.daishenBtn setTitle:@"已通过" forState:UIControlStateNormal];
                break;
            }
            case -1:{
               
                [cell.daishenBtn setBackgroundColor:[UIColor grayColor]];
                [cell.daishenBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
                break;
            }
                
            default:
                break;
        }
//        [cell.daishenBtn addTarget:self action:@selector(toCheck) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSDictionary *dic = skillAry[indexPath.row];
        if ([dic[@"approvalStatus"] intValue]) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSDictionary *dic = skillAry[indexPath.row];
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self requestDeleteStaffSkill:NSStringWithNumber(dic[@"id"])];
            [skillAry removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        NSDictionary *dic = skillAry[indexPath.row];
        EmployeeAuthVC *authVC = [[EmployeeAuthVC alloc] init];
        int approvalStatus = [dic[@"approvalStatus"] intValue];
        authVC.approvalStatus = approvalStatus;
        authVC.skillDic = dic;      //技能字典
        [self.navigationController pushViewController:authVC animated:YES];
    }
}

#pragma mark - 发起请求
-(void)requestGetStaffList { //员工技能列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StaffSkillList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StaffSkillList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.staffDic[@"id"],@"id", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StaffSkillList) delegate:nil params:pram info:infoDic];
}

-(void)requestDeleteStaffSkill:(NSString *)skillId { //删除员工某个技能
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreDelStaffSkill object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreDelStaffSkill, @"op", nil];
    NSString *url = [NSString stringWithFormat:@"%@/%@",UrlPrefixNew(StoreDelStaffSkill),skillId];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.staffDic[@"id"],@"userId", nil];
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:url delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:StaffSkillList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StaffSkillList object:nil];
        NSLog(@"StaffSkillList: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [skillAry removeAllObjects];
            [skillAry addObjectsFromArray:responseObject[@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:StoreDelStaffSkill]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreDelStaffSkill object:nil];
        NSLog(@"StoreDelStaffSkill: %@",responseObject);
            if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
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
