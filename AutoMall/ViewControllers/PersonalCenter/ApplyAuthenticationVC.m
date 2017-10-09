//
//  ApplyAuthenticationVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/4.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ApplyAuthenticationVC.h"
#import "ChooseLocationView.h"
#import "CitiesDataTool.h"

@interface ApplyAuthenticationVC () <UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@end

@implementation ApplyAuthenticationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.title = @"申请认证";
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    self.addressTF.text = @"广东省 广州市 白云区";
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

- (IBAction)replayAction:(id)sender {
    [self requestPostStoreRegister];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.nameTF resignFirstResponder];
    [self.shortNameTF resignFirstResponder];
    [self.detailAddressTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.recommendCodeTF resignFirstResponder];
    [self.wechatNameTF resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.cover.hidden = !self.cover.hidden;
    self.chooseLocationView.hidden = self.cover.hidden;
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
            weakSelf.addressTF.text = weakSelf.chooseLocationView.address;
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

#pragma mark - 发起网络请求
-(void)requestPostStoreRegister { //门店认证
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:StoreRegister object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:StoreRegister, @"op", nil];
    NSArray *addrAry = [self.addressTF.text componentsSeparatedByString:@" "];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.nameTF.text,@"name",self.shortNameTF.text,@"shortName",addrAry[0],@"province",addrAry[1],@"city",addrAry[2],@"county",self.detailAddressTF.text,@"address",self.phoneTF.text,@"phone",self.licenseImgBtn.currentImage,@"licenseImg",self.cardImgABtn.currentImage,@"cardImgA",self.cardImgBBtn.currentImage,@"cardImgB",self.recommendCodeTF.text,@"presenter.recommendCode",self.wechatNameTF.text,@"wechatName",self.wechatImgBtn.currentImage,@"wechatImg", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(StoreRegister) delegate:nil params:pram info:infoDic];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:StoreRegister]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:StoreRegister object:nil];
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
