//
//  AddressInfoEditVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/7.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddressInfoEditVC.h"
#import "ChooseLocationView.h" 
#import "CitiesDataTool.h"

@interface AddressInfoEditVC () <NSURLSessionDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@end

@implementation AddressInfoEditVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加/编辑地址";
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    [self.addressBtn setTitle:@"广东省 广州市 白云区" forState:UIControlStateNormal];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keybordDown)];
//    [self.view addGestureRecognizer:tap];
    
    if (self.isEdit) {
        self.uNameTF.text = self.addrDic [@"name"];
        self.phoneTF.text = self.addrDic [@"phone"];
        NSString *proStr = [NSString stringWithFormat:@"%@ %@ %@",self.addrDic [@"province"],self.addrDic [@"city"],self.addrDic [@"county"]];
        [self.addressBtn setTitle:proStr forState:UIControlStateNormal];
        self.addDetailTF.text = self.addrDic [@"address"];
        BOOL preferred = [self.addrDic [@"preferred"] boolValue];
        self.defaultSW.on = preferred;
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

-(void) keybordDown {
    [self.uNameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.addDetailTF resignFirstResponder];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.uNameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.addDetailTF resignFirstResponder];
}

- (IBAction)selectAddressAction:(id)sender {
//    [UIView animateWithDuration:0.25 animations:^{
//        self.view.transform =CGAffineTransformMakeScale(0.95, 0.95);
//    }];
    self.cover.hidden = !self.cover.hidden;
    self.chooseLocationView.hidden = self.cover.hidden;
}

- (IBAction)defaultAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    sw.on = !sw.on;
}

- (IBAction)saveAction:(id)sender {
    if ([self checkPhoneNumWithPhone:self.phoneTF.text]) {
        if (self.isEdit) {
            [self editAddress];
        }
        else {
            [self addAddress];
        }
    }
    else {
        _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

#pragma mark -
#pragma mark 手机号码及验证码格式初步验证
-(BOOL) checkPhoneNumWithPhone:(NSString *)phone {
    /**
     *  是否纯数字
     */
    BOOL isDigit = NO;
    NSString *regEX = @"^[0-9]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:phone]) {
        isDigit = YES;
    } else {
        isDigit = NO;
    }
    
    if (isDigit && [phone length] == 11 && [phone hasPrefix:@"1"]) {
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_chooseLocationView.frame, point)){
        return NO;
    }
    return YES;
}


- (void)tapCover:(UITapGestureRecognizer *)tap{
    
    if (_chooseLocationView.chooseFinish) {
        _chooseLocationView.chooseFinish();
    }
}

- (ChooseLocationView *)chooseLocationView{
    
    if (!_chooseLocationView) {
        _chooseLocationView = [[ChooseLocationView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350)];
        
    }
    return _chooseLocationView;
}

- (UIView *)cover{
    
    if (!_cover) {
        _cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_cover addSubview:self.chooseLocationView];
        __weak typeof (self) weakSelf = self;
        _chooseLocationView.chooseFinish = ^{
//            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf.addressBtn setTitle:weakSelf.chooseLocationView.address forState:UIControlStateNormal];
//                weakSelf.view.transform = CGAffineTransformIdentity;
                weakSelf.cover.hidden = YES;
//            }];
        };
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCover:)];
        [_cover addGestureRecognizer:tap];
        tap.delegate = self;
        _cover.hidden = YES;
    }
    return _cover;
}

#pragma mark - 发送请求
-(void)addAddress {
    //    [_addressArray removeAllObjects];
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ConsigneeAdd object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ConsigneeAdd, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSArray *addrAry = [self.chooseLocationView.address componentsSeparatedByString:@" "];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@&name=%@&phone=%@&province=%@&city=%@&county=%@&address=%@&preferred=%@",UrlPrefix(ConsigneeAdd),userId,self.uNameTF.text,self.phoneTF.text,addrAry[0],addrAry[1],addrAry[2],self.addDetailTF.text,[NSNumber numberWithBool:self.defaultSW.on]];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)editAddress {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ConsigneeEdit object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ConsigneeEdit, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSArray *addAry = [self.chooseLocationView.address componentsSeparatedByString:@" "];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@&id=%@&name=%@&phone=%@&province=%@&city=%@&county=%@&address=%@&preferred=%@",UrlPrefix(ConsigneeEdit),userId,self.addrDic[@"id"],self.uNameTF.text,self.phoneTF.text,addAry[0],addAry[1],addAry[2],self.addDetailTF.text,[NSNumber numberWithBool:self.defaultSW.on]];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}


#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!self.networkConditionHUD) {
            self.networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.networkConditionHUD];
        }
        self.networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        self.networkConditionHUD.mode = MBProgressHUDModeText;
        self.networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        self.networkConditionHUD.margin = HUDMargin;
        [self.networkConditionHUD show:YES];
        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:ConsigneeAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ConsigneeAdd object:nil];

        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:ConsigneeEdit]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ConsigneeEdit object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
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
