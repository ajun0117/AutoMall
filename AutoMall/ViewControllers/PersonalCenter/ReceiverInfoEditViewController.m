//
//  ReceiverInfoEditViewController.m
//  mobilely
//
//  Created by hn3l on 15/1/21.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "ReceiverInfoEditViewController.h"
//#import "LXSelectItemView.h"
//#import "PocketLYProvinceAndCityCoreObject.h"
#import "NSString+Check.h"

#define BoundColor [UIColor lightGrayColor]

@interface ReceiverInfoEditViewController ()<UIAlertViewDelegate>{
    NSDictionary *areaDic;
    NSDictionary *cityDic;
    
    NSArray *province;
    
    NSString *proId;
    NSString *citId;
    NSString *disId;
}
@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@end

@implementation ReceiverInfoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.isEdit) {
        self.title = @"修改地址";
        self.contentView.userInteractionEnabled = NO;  //初始不能编辑
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(editIt)];
        if ([self.addressDic [@"ause"] intValue] == 0) {
            self.confirmBtn.enabled = YES;
        }
        else {
            self.confirmBtn.enabled = NO;
        }
        [self.confirmBtn setTitle:@"设成默认地址" forState:UIControlStateNormal];
    }
    else {
        self.title = @"新增地址";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    if (proId == nil) {
        proId = @"11";//默认的省id-----11-----河南
//        province = [[NSArray alloc] initWithArray:[PocketLYProvinceAndCityCoreObject loadAllProvinceDataWithType:@"1"]];
    }
    
    //初始化视图
    [self initView];
}

/**
 *  根据省的名字初始化该省所有的市
 */
//-(NSArray*)selectCity:(NSString*)proName{
//    NSArray *city = [[NSArray alloc] initWithArray:[PocketLYProvinceAndCityCoreObject loadAllCityOrDistrictDataWithName:proName type:@"1"]];
//    return city;
//}

/**
 *  根据市的名字初始化该市所有的区
 */
//-(NSArray*)selectDistrict:(NSString*)cityName{
//    NSArray *district = [[NSArray alloc] initWithArray:[PocketLYProvinceAndCityCoreObject loadAllCityOrDistrictDataWithName:cityName type:@"2"]];
//    return district;
//}

/**
 *  初始化视图
 */
-(void)initView{
    
    if (self.isEdit) {
        self.nameTF.text = self.addressDic [@"rname"];
        self.numberTF.text = self.addressDic [@"mobile"];
        self.postcodeTF.text = self.addressDic [@"postcode"];
        proId = self.addressDic [@"provId"];
        citId = self.addressDic [@"cityId"];
        disId = self.addressDic [@"areaId"];
        self.detailAddressTV.text = self.addressDic [@"areadesc"];
        self.detailAddressTV.textColor = [UIColor blackColor];
    }
    
    if (proId == nil) {
        [_provinceBtn setTitle:@"请选择" forState:UIControlStateNormal];
        
    }
//    else{
//        [_provinceBtn setTitle:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:proId].name forState:UIControlStateNormal];
//        [_provinceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
    
    if (citId == nil) {
        [_cityBtn setTitle:@"请选择" forState:UIControlStateNormal];
    }
//    else{
//        [_cityBtn setTitle:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:citId].name forState:UIControlStateNormal];
//        [_cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
    if (disId == nil) {
        [_districtBtn setTitle:@"请选择" forState:UIControlStateNormal];
    }
//    else{
//        [_districtBtn setTitle:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:disId].name forState:UIControlStateNormal];
//        [_districtBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
}

/**
 *  触摸背景，已取消键盘响应
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger tag = textField.tag;
    if (tag == 0) {
        [_numberTF becomeFirstResponder];
    }else if (tag == 1){
        [_detailAddressTV becomeFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"请填写详细地址"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        textView.text = @"请填写详细地址";
        textView.textColor = [UIColor lightGrayColor];
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (textView.text.length + text.length > 140){//限制输入140个字符了
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    else if (location != NSNotFound){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark LXSelectItemViewDelegate
/**
 *  弹框选择后，回调
 */
//-(void)selectItemView:(LXSelectItemView *)selectItemView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (selectItemView.tag == 0) {
//        proId = [selectItemView.itemsDataSource[indexPath.row] pcid];
//        [_provinceBtn setTitle:[selectItemView.itemsDataSource[indexPath.row] name] forState:UIControlStateNormal];
//        
//        [_cityBtn setTitle:@"请选择" forState:UIControlStateNormal];
//        [_cityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//
//        [_districtBtn setTitle:@"请选择" forState:UIControlStateNormal];
//        [_districtBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    }else if (selectItemView.tag == 1){
//        citId = [selectItemView.itemsDataSource[indexPath.row] pcid];
//        [_cityBtn setTitle:[selectItemView.itemsDataSource[indexPath.row] name] forState:UIControlStateNormal];
//        [_cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//
//        [_districtBtn setTitle:@"请选择" forState:UIControlStateNormal];
//        [_districtBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//    }else {
//        disId = [selectItemView.itemsDataSource[indexPath.row] pcid];
//        [_districtBtn setTitle:[selectItemView.itemsDataSource[indexPath.row] name] forState:UIControlStateNormal];
//        [_districtBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
//
//}



#pragma mark -
#pragma mark xib的Action
/**
 *  点击，确定信息
 */
- (IBAction)clickConfirm:(id)sender {
    if ([[_nameTF.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]) {
        
    }else{
        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbpro.mode = MBProgressHUDModeCustomView;
        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
        mbpro.customView = imgV;
        mbpro.animationType = MBProgressHUDAnimationFade;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        mbpro.labelText = @"请填写姓名！";
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    if ([[_numberTF.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]) {
        if ([NSString checkPhoneNumWithPhone:self.numberTF.text]) {
            
        } else {
            MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            mbpro.mode = MBProgressHUDModeCustomView;
            UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
            mbpro.customView = imgV;
            mbpro.animationType = MBProgressHUDAnimationFade;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            mbpro.labelText = @"手机号码不正确，请重新检查手机号码！";
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Do something...
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            return;
        }
    }else{
        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbpro.mode = MBProgressHUDModeCustomView;
        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
        mbpro.customView = imgV;
        mbpro.animationType = MBProgressHUDAnimationFade;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        mbpro.labelText = @"请填写手机号码！";
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    if (![[_cityBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请选择"]) {
        
    }else{
        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbpro.mode = MBProgressHUDModeCustomView;
        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
        mbpro.customView = imgV;
        mbpro.animationType = MBProgressHUDAnimationFade;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        mbpro.labelText = @"请选择所在市！";
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    
    if (![[_districtBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请选择"]) {
        
    }else{
        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbpro.mode = MBProgressHUDModeCustomView;
        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
        mbpro.customView = imgV;
        mbpro.animationType = MBProgressHUDAnimationFade;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        mbpro.labelText = @"请选择所在区/县！";
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
    if (![[_detailAddressTV.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请填写详细地址"]) {
        
    }else{
        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        mbpro.mode = MBProgressHUDModeCustomView;
        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
        mbpro.customView = imgV;
        mbpro.animationType = MBProgressHUDAnimationFade;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
        mbpro.labelText = @"请填写详细地址！";
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        return;
    }
    
//    [[GlobalSetting shareGlobalSettingInstance] setReceiveName:_nameTF.text];
//    [[GlobalSetting shareGlobalSettingInstance] setReceivePhone:_numberTF.text];
//    
//    [[GlobalSetting shareGlobalSettingInstance] setProvince:_provinceBtn.titleLabel.text];
//    [[GlobalSetting shareGlobalSettingInstance] setCity:_cityBtn.titleLabel.text];
//    [[GlobalSetting shareGlobalSettingInstance] setDistrict:_districtBtn.titleLabel.text];
//    [[GlobalSetting shareGlobalSettingInstance] setDetailAddress:_detailAddressTV.text];
//    
//    
//    [[GlobalSetting shareGlobalSettingInstance] setProvinceId:proId];
//    [[GlobalSetting shareGlobalSettingInstance] setCityId:citId];
//    [[GlobalSetting shareGlobalSettingInstance] setDistrictId:disId];
    
    //掉接口，将信息同步到服务器
//    if ([[GlobalSetting shareGlobalSettingInstance] userAddressInfoId]) {
//    NSString *updateAddressInfoStr = [NSString stringWithFormat:@"{\"provinceId\":\"%@\",\"cityId\":\"%@\",\"areaId\":\"%@\",\"addr\":\"%@\",\"person\":\"%@\",\"phone\":\"%@\"}",proId,citId,disId,_detailAddressTV.text,_nameTF.text,_numberTF.text];
//        //已创建用户地址信息，更新信息
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:REQUEST_POST_UPDATEADDRESS object:nil];
//        [[RequestManager sharedRequestManager] updateAddressWithUserAddressId:[[[GlobalSetting shareGlobalSettingInstance] userAddressInfoId] integerValue] data:updateAddressInfoStr];
//     
//    }else{
//        NSString *addressInfoStr = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"provinceId\":\"%@\",\"cityId\":\"%@\",\"areaId\":\"%@\",\"addr\":\"%@\",\"person\":\"%@\",\"phone\":\"%@\"}",[[GlobalSetting shareGlobalSettingInstance] userId],proId,citId,disId,_detailAddressTV.text,_nameTF.text,_numberTF.text];
//        //创建新的用户信息
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:REQUEST_POST_CREATEADDRESS object:nil];
//        
//        [[RequestManager sharedRequestManager] createAddressWithData:addressInfoStr];
//    }
    
    
//    if (self.isEdit) {
//        if ([self.confirmBtn.currentTitle isEqualToString:@"设成默认地址"]) {
//             [self editAddressInfo:self.addressDic [@"aid"] ause:@"1"];
//            return;
//        }
//        [self editAddressInfo:self.addressDic [@"aid"] ause:self.addressDic [@"ause"]];
//    }
//    else {
//        [self editAddressInfo:@"0" ause:@"0"];
//    }
}


//修改地址
-(void)editIt {
    self.navigationItem.rightBarButtonItem = nil;
    self.contentView.userInteractionEnabled = YES;
    self.confirmBtn.enabled = YES;
    [self.confirmBtn setTitle:@"保存" forState:UIControlStateNormal];
}



#define kView_x 20
#define kView_y 100
#define kView_h 300

//- (IBAction)selectItem:(UIButton*)sender {
//    [self.view endEditing:YES];
//    
//    NSArray *dataArr;
//    NSString *headerTitle;
//    NSInteger index=0;
//    if (sender.tag == 0) {
//        dataArr = province;
//        headerTitle = @"请选择省";
//        index = [dataArr indexOfObject:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:proId]];
//        
//    }else if (sender.tag == 1){
//        
//        if (![[_provinceBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请选择"]) {
//            //[[GlobalSetting shareGlobalSettingInstance] setProvince:_provinceBtn.titleLabel.text];
//        }else{
//            MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            mbpro.mode = MBProgressHUDModeCustomView;
//            UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//            mbpro.customView = imgV;
//            mbpro.animationType = MBProgressHUDAnimationFade;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//            mbpro.labelText = @"请选择所在省份！";
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                // Do something...
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//            return;
//        }
//        
//        dataArr = [self selectCity:_provinceBtn.titleLabel.text];
//        headerTitle = @"请选择市";
//        if (citId == nil) {
//            index = 0;
//        }else{
//            index = [dataArr indexOfObject:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:citId]];
//        }
//        
//    }else{
//        
//        if (![[_provinceBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请选择"]) {
//            //[[GlobalSetting shareGlobalSettingInstance] setProvince:_provinceBtn.titleLabel.text];
//        }else{
//            MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            mbpro.mode = MBProgressHUDModeCustomView;
//            UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//            mbpro.customView = imgV;
//            mbpro.animationType = MBProgressHUDAnimationFade;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//            mbpro.labelText = @"请选择所在省份！";
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                // Do something...
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//            return;
//        }
//        
//        if (![[_cityBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"请选择"]) {
////            [[GlobalSetting shareGlobalSettingInstance] setCity:_cityBtn.titleLabel.text];
//        }else{
//            MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            mbpro.mode = MBProgressHUDModeCustomView;
//            UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//            mbpro.customView = imgV;
//            mbpro.animationType = MBProgressHUDAnimationFade;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//            mbpro.labelText = @"请选择所在市！";
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                // Do something...
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            });
//            return;
//        }
//        
//        dataArr = [self selectDistrict:_cityBtn.titleLabel.text];
//        headerTitle = @"请选择区/县";
//        if (disId == nil) {
//            index = 0;
//        }else{
//            index = [dataArr indexOfObject:[PocketLYProvinceAndCityCoreObject selectDataWithPcid:disId]];
//        }
//        
//    }
//    
//    LXSelectItemView *selectItemView = [[LXSelectItemView alloc] initWithFrame:CGRectMake(kView_x, kView_y, SCREEN_WIDTH - kView_x*2, kView_h) tagetView:self.view];
//    selectItemView.delegate = self;
//    selectItemView.unSelectItemImage = IMG(@"people_radio");
//    selectItemView.selectItemImage = IMG(@"people_radio_on");
//
//    selectItemView.headerTitle = headerTitle;
//    selectItemView.defaultIndex = index;
//    selectItemView.itemsDataSource = dataArr;
//    selectItemView.tag = sender.tag;
//    
//    [self.view addSubview:selectItemView];
//}
#pragma mark -
#pragma mark 处理键盘掩盖数据框
/**
 *  处理键盘出现事件
 */
- (void) keyboardWasShown:(NSNotification *) notif{
    NSDictionary* userInfo = [notif userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    if (!_detailAddressTV.isFirstResponder) {
        return;
    }
    CGFloat height = APP_HEIGHT - VIEW_BY(_detailAddressTV);
    if (height > keyboardFrame.size.height) {
        return;
    } else{
        CGFloat ty = height - keyboardFrame.size.height;
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, ty, self.view.frame.size.width, self.view.frame.size.height)];
    }
}
/**
 *  处理键盘隐藏事件
 */
- (void) keyboardWasHidden:(NSNotification *) notif{
    NSDictionary* userInfo = [notif userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    [self.view setFrame:CGRectMake(keyboardFrame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height)];
}


//#pragma mark - 发送请求
////新增或修改地址信息,aid=0为新增
//-(void)editAddressInfo:(NSString *)aid ause:(NSString *)ause{
//    NSString *addressInfoStr = [NSString stringWithFormat:@"{\"uid\":\"%@\",\"aid\":\"%@\",\"ause\":\"%@\",\"provId\":\"%@\",\"cityId\":\"%@\",\"areaId\":\"%@\",\"addr\":\"%@\",\"person\":\"%@\",\"phone\":\"%@\",\"postcode\":\"%@\"}",[[GlobalSetting shareGlobalSettingInstance] userId],aid,ause,proId,citId,disId,_detailAddressTV.text,_nameTF.text,_numberTF.text,_postcodeTF.text];
//    //创建新的用户信息
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Address_edit object:nil];
//    
//    [[RequestManager sharedRequestManager] requestPostAddOrEditAddressDeatil:addressInfoStr];
//}

#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
//    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
//        if (!self.networkConditionHUD) {
//            self.networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:self.networkConditionHUD];
//        }
//        self.networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
//        self.networkConditionHUD.mode = MBProgressHUDModeText;
//        self.networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//        self.networkConditionHUD.margin = HUDMargin;
//        [self.networkConditionHUD show:YES];
//        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
//        return;
//    }
//    
//    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
//    NSLog(@"notification %@", responseObject);
//    
//    if ([notification.name isEqualToString:Address_edit]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:Address_edit object:nil];
//        
//        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        mbpro.mode = MBProgressHUDModeCustomView;
//        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//        mbpro.customView = imgV;
//        mbpro.labelText = responseObject[@"content"];
//        mbpro.animationType = MBProgressHUDAnimationFade;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            // Do something...
//            if ([responseObject[@"result"] isEqualToString:@"success"]) {
//                
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    }
    
//    if ([notification.name isEqualToString:REQUEST_POST_CREATEADDRESS]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:REQUEST_POST_CREATEADDRESS object:nil];
//        
//        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        mbpro.mode = MBProgressHUDModeCustomView;
//        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//        mbpro.customView = imgV;
//        mbpro.labelText = responseObject[@"content"];
//        mbpro.animationType = MBProgressHUDAnimationFade;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            // Do something...
//            if ([responseObject[@"result"] isEqualToString:@"success"]) {
//            
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    }
//    
//    if ([notification.name isEqualToString:REQUEST_POST_UPDATEADDRESS]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:REQUEST_POST_UPDATEADDRESS object:nil];
//        
//        MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        mbpro.mode = MBProgressHUDModeCustomView;
//        UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
//        mbpro.customView = imgV;
//        mbpro.labelText = responseObject[@"content"];
//        mbpro.animationType = MBProgressHUDAnimationFade;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            // Do something...
//            if ([responseObject[@"result"] isEqualToString:@"success"]) {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    }
}

@end
