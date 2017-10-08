//
//  ApplyAuthenticationVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/4.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ApplyAuthenticationVC.h"

@interface ApplyAuthenticationVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation ApplyAuthenticationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.title = @"申请认证";
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
