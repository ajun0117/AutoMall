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
    NSArray *skillAry;
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
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailTopCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailTopCell"];
     
    [self requestGetStaffList];
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

-(void) toCheck {   //进行审核操作
    EmployeeAuthVC *authVC = [[EmployeeAuthVC alloc] init];
    authVC.isReviewed = NO;
    [self.navigationController pushViewController:authVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [skillAry count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EmployeeDetailTopCell *cell = (EmployeeDetailTopCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 1;
    }
    return 66;
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
    if (indexPath.section == 0) {
        EmployeeDetailTopCell *cell = (EmployeeDetailTopCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailTopCell"];
        cell.contentL.text = STRING(self.staffDic[@"remark"]);
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
                cell.daishenBtn.hidden = NO;
                [cell.daishenBtn setTitle:@"等待审核" forState:UIControlStateNormal];
                break;
            }
            case 1:{
                cell.daishenBtn.hidden = YES;
//                [cell.daishenBtn setTitle:@"已通过" forState:UIControlStateNormal];
                break;
            }
            case -1:{
                cell.daishenBtn.hidden = NO;
                [cell.daishenBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
                break;
            }
                
            default:
                break;
        }
        [cell.daishenBtn addTarget:self action:@selector(toCheck) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NSDictionary *dic = skillAry[indexPath.row];
        EmployeeAuthVC *authVC = [[EmployeeAuthVC alloc] init];
        authVC.isReviewed = NO;
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
            skillAry = responseObject[@"data"];
            [self.myTableView reloadData];
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
