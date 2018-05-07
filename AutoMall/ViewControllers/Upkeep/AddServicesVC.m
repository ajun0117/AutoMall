//
//  AddServicesVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/7.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "AddServicesVC.h"

@interface AddServicesVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UITextField *servicesNameTF;
@property (strong, nonatomic) IBOutlet UITextField *servicesMoneyTF;

@end

@implementation AddServicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"增加服务";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    addedServiceAry = [NSMutableArray array];
//    [addedServiceAry addObjectsFromArray:self.addedAry];
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
    if (! self.servicesNameTF.text || self.servicesNameTF.text.length == 0) {
        _networkConditionHUD.labelText = @"服务名称必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if ([self checkCodeNumWithCode:self.servicesMoneyTF.text]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.servicesNameTF.text,@"item",self.servicesMoneyTF.text,@"money", nil];
        self.AddedDiscount(dic);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        _networkConditionHUD.labelText = @"输入的金额格式有误，请重新输入";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

#pragma mark -
#pragma mark 手机号码及验证码格式初步验证
-(BOOL) checkCodeNumWithCode:(NSString *)code {
    /**
     *  是否纯数字
     */
    BOOL isDigit = NO;
    NSString *regEX = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:code]) {
        isDigit = YES;
    } else {
        isDigit = NO;
    }
    
    if (isDigit && [code length] > 0) {
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.servicesNameTF resignFirstResponder];
    [self.servicesMoneyTF resignFirstResponder];
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
