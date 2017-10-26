//
//  CarInfoAddVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/25.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CarInfoAddVC.h"
#import "BaoyangHistoryVC.h"
#import "AutoCheckVC.h"

@interface CarInfoAddVC () <UIPickerViewDelegate,UIPickerViewDataSource>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    UIPickerView *genderPickerView;    //性别选择
    UIDatePicker *birthdayDatePicker;  //生日日期选择
    UIDatePicker *buyDatePicker;        //购买日期选择
    NSArray *nameArray;
}
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollV;
@property (strong, nonatomic) IBOutlet UITextField *mileageTF;
@property (strong, nonatomic) IBOutlet UITextField *fuelAmountTF;
@property (strong, nonatomic) IBOutlet UITextField *ownerTF;
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *wechatTF;
@property (strong, nonatomic) IBOutlet UITextField *genderTF;
@property (strong, nonatomic) IBOutlet UITextField *birthdayTF;
@property (strong, nonatomic) IBOutlet UITextField *plateNumberTF;
@property (strong, nonatomic) IBOutlet UITextField *brandTF;
@property (strong, nonatomic) IBOutlet UITextField *modelTF;
@property (strong, nonatomic) IBOutlet UITextField *purchaseDateTF;
@property (strong, nonatomic) IBOutlet UITextField *engineNoTF;
@property (strong, nonatomic) IBOutlet UITextField *vinTF;

@end

@implementation CarInfoAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"车辆信息";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"baoyang_history"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toHistoryList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
//    self.myScrollV.contentSize = CGSizeMake(SCREEN_WIDTH, 720);
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    nameArray = @[@"男", @"女"];
    genderPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 150)];
    genderPickerView.delegate = self;
    genderPickerView.dataSource = self;
    
    birthdayDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 150)];
    birthdayDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //显示方式是只显示年月日
    birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
    [birthdayDatePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    buyDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 150)];
    buyDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //显示方式是只显示年月日
    buyDatePicker.datePickerMode = UIDatePickerModeDate;
    buyDatePicker.maximumDate = [NSDate date];
    [buyDatePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    [self setTextFieldInputAccessoryViewWithTF:self.mileageTF];
    [self setTextFieldInputAccessoryViewWithTF:self.fuelAmountTF];
    [self setTextFieldInputAccessoryViewWithTF:self.ownerTF];
    [self setTextFieldInputAccessoryViewWithTF:self.phoneTF];
    [self setTextFieldInputAccessoryViewWithTF:self.wechatTF];
    [self setTextFieldInputAccessoryViewWithTF:self.genderTF];
    [self setTextFieldInputAccessoryViewWithTF:self.birthdayTF];
    [self setTextFieldInputAccessoryViewWithTF:self.plateNumberTF];
    [self setTextFieldInputAccessoryViewWithTF:self.brandTF];
    [self setTextFieldInputAccessoryViewWithTF:self.modelTF];
    [self setTextFieldInputAccessoryViewWithTF:self.purchaseDateTF];
    [self setTextFieldInputAccessoryViewWithTF:self.engineNoTF];
    [self setTextFieldInputAccessoryViewWithTF:self.vinTF];
    
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

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithTF:(UITextField *)field{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTintColor:[UIColor grayColor]];
    doneBtn.layer.cornerRadius = 2;
    doneBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    doneBtn.layer.borderWidth = 0.5;
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceBtn,doneBtnItem,nil];
    [topView setItems:buttonsArray];
    if (field == self.genderTF) {
        [field setInputView:genderPickerView];
    }
    else if (field == self.birthdayTF) {
        [field setInputView:birthdayDatePicker];
    }
    else if (field == self.purchaseDateTF) {
        [field setInputView:buyDatePicker];
    }
    [field setInputAccessoryView:topView];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

#pragma mark - 日期选择
- (void)dateChange:(UIDatePicker *)datePicker
{
    NSDate *theDate = datePicker.date;
    NSLog(@"%@",[theDate descriptionWithLocale:[NSLocale currentLocale]]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY年MM月dd日";
    NSString *dateString = [dateFormatter stringFromDate:theDate];
    if (datePicker == birthdayDatePicker) {
        self.birthdayTF.text = dateString;
    }
    else if (datePicker == buyDatePicker) {
        self.purchaseDateTF.text = dateString;
    }
    
}

#pragma mark - tool bar 上按钮的点击事件
- (void)doneClick {
    if ( [self.genderTF isFirstResponder] ) {
        [self.genderTF resignFirstResponder];
    }
}

- (void)cancelClick {
    [self doneClick];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myScrollV.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height- 64 - keyBoardRect.size.height);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myScrollV.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height -64 - 80);
}

-(void) toHistoryList {
    BaoyangHistoryVC *historyVC = [[BaoyangHistoryVC alloc] init];
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (IBAction)photoAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {
    [self requestPostAddCar];
}

- (IBAction)selectAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (textField == self.genderTF) {
//        genderPickerView.hidden = NO;
//        return NO;
//    }
//    if (textField == self.birthdayTF) {
//        birthdayDatePicker.hidden = NO;
//        return NO;
//    }
//    return YES;
//}

#pragma mark - Picker view data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return nameArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.bounds.size.width;
}
/**
 //- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
 //    NSString *str = [NSString stringWithString:_nameArray[row]];
 //    return str;
 //}
 */// <???>不知道有什么用?
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (!view) {
        view = [[UIView alloc] init];
    }
    UILabel *textlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    textlabel.textAlignment = NSTextAlignmentCenter;
    textlabel.text = nameArray[row];
    textlabel.font = [UIFont systemFontOfSize:19];
    [view addSubview:textlabel];
    return view;
}


// didSelectRow
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.genderTF.text = nameArray[row];
}

#pragma mark - 发起网络请求
-(void)requestPostAddCar { //新增车辆
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarAdd object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarAdd, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.mileageTF.text,@"mileage",self.fuelAmountTF.text,@"fuelAmount",self.ownerTF.text,@"owner",self.phoneTF.text,@"phone",self.wechatTF.text,@"wechat",self.genderTF.text,@"gender",self.birthdayTF.text,@"birthday",self.plateNumberTF.text,@"plateNumber",self.brandTF.text,@"brand",self.modelTF.text,@"model",self.purchaseDateTF.text,@"purchaseDate",self.engineNoTF.text,@"engineNo",self.vinTF.text,@"vin", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarAdd) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:CarAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarAdd object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //验证码正确
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
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
