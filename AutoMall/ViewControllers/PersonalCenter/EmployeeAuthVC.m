//
//  EmployeeAuthVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/9/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeAuthVC.h"

@interface EmployeeAuthVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@property (strong, nonatomic) IBOutlet UILabel *nameL;
@property (strong, nonatomic) IBOutlet UILabel *introduceL;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIView *revieweView;
@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;

@end

@implementation EmployeeAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"技能认证";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.nameL.text = self.skillDic[@"name"];
    self.introduceL.text = self.skillDic[@"remark"];;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(self.skillDic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
    
    switch (self.approvalStatus) {
        case 0:{
            self.rejectBtn.hidden = YES;
            self.revieweView.hidden = NO;
            break;
        }
        case 1:{
            [self.rejectBtn setTitle:@"已通过" forState:UIControlStateNormal];
            [self.rejectBtn setBackgroundColor:[UIColor grayColor]];
            self.rejectBtn.hidden = NO;
            self.revieweView.hidden = YES;
            break;
        }
        case -1:{
            [self.rejectBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
            [self.rejectBtn setBackgroundColor:[UIColor grayColor]];
            self.rejectBtn.hidden = NO;
            self.revieweView.hidden = YES;
            break;
        }
            
        default:
            break;
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
}

- (IBAction)pass:(id)sender {
    [self requestApprovalStatus:@"1"];
}

- (IBAction)reject:(id)sender {
    [self requestApprovalStatus:@"-1"];
}

#pragma mark - 发起请求
-(void)requestApprovalStatus:(NSString *)approvalStatus { //审核员工技能
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreApproveSkill object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreApproveSkill, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.skillDic[@"id"],@"skillId",approvalStatus,@"approvalStatus", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StoreApproveSkill) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:StoreApproveSkill]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreApproveSkill object:nil];
        NSLog(@"StoreApproveSkill: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self performSelector:@selector(toPopVC:) withObject:nil afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}


- (void)toPopVC:(NSString *)string {
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
