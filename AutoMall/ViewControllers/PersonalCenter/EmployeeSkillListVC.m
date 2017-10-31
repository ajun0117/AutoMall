//
//  EmployeeSkillListVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeSkillListVC.h"
#import "EmployeeDetailCell.h"
#import "EmployeeEditSkillCertificationVC.h"

@interface EmployeeSkillListVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *skillAry;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EmployeeSkillListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我的技能认证";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    //    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:RGBCOLOR(129, 129, 129) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"添加" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toAddSkill) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailCell"];
    
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

-(void)toAddSkill {
    EmployeeEditSkillCertificationVC *editVC = [[EmployeeEditSkillCertificationVC alloc] init];
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [skillAry count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = skillAry[indexPath.section];
    EmployeeDetailCell *cell = (EmployeeDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailCell"];
    cell.nameL.text = dic[@"name"];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"default")];
//    [cell.daishenBtn addTarget:self action:@selector(toCheck) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = skillAry[indexPath.section];
    EmployeeEditSkillCertificationVC *editVC = [[EmployeeEditSkillCertificationVC alloc] init];
    editVC.skillDic = dic;
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - 发起请求
-(void)requestGetStaffList { //员工技能列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StaffSkillList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StaffSkillList, @"op", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StaffSkillList) delegate:nil params:nil info:infoDic];
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
