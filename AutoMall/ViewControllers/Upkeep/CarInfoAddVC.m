//
//  CarInfoAddVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/25.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CarInfoAddVC.h"
#import "BaoyangHistoryVC.h"
#import "AddPicViewController.h"

@interface CarInfoAddVC () <UIPickerViewDelegate,UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    UIPickerView *genderPickerView;    //性别选择
    UIDatePicker *birthdayDatePicker;  //生日日期选择
    UIDatePicker *buyDatePicker;        //购买日期选择
    NSArray *nameArray;
    NSArray *textFieldArray;
    NSString *carImgUrl;    //车图url
    BOOL isAutoSelect;      //自动选择
    NSArray *mileagePhotos;     //总里程表
    NSArray *fuelAmountPhotos;      //燃油量
    NSArray *enginePhotos;
    NSArray *vinPhotos;
}
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollV;
@property (strong, nonatomic) IBOutlet UILabel *mileageL;
@property (strong, nonatomic) IBOutlet UITextField *mileageTF;
@property (strong, nonatomic) IBOutlet UILabel *fuelAmountL;
@property (strong, nonatomic) IBOutlet UITextField *fuelAmountTF;
@property (strong, nonatomic) IBOutlet UITextField *ownerTF;
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UITextField *wechatTF;
@property (strong, nonatomic) IBOutlet UITextField *genderTF;
@property (strong, nonatomic) IBOutlet UITextField *birthdayTF;
@property (weak, nonatomic) IBOutlet WPImageView *carImgView;
//@property (weak, nonatomic) IBOutlet UILabel *carImgL;
@property (strong, nonatomic) IBOutlet UITextField *plateNumberTF;
@property (strong, nonatomic) IBOutlet UITextField *brandTF;
@property (strong, nonatomic) IBOutlet UITextField *modelTF;
@property (strong, nonatomic) IBOutlet UITextField *engineModelTF;
@property (strong, nonatomic) IBOutlet UITextField *purchaseDateTF;
@property (strong, nonatomic) IBOutlet UITextField *engineNoTF;
@property (strong, nonatomic) IBOutlet UITextField *vinTF;

@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@end

@implementation CarInfoAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    if (self.carDic) {
        self.title = @"车辆信息编辑";
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -6;
        
//        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        addBtn.frame = CGRectMake(0, 0, 28, 28);
//        [addBtn setImage:[UIImage imageNamed:@"add_carInfo"] forState:UIControlStateNormal];
//        //    [addBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//        [addBtn addTarget:self action:@selector(toEdit) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *addBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
        
        UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        searchBtn.frame = CGRectMake(0, 0, 28, 28);
        [searchBtn setImage:[UIImage imageNamed:@"baoyang_history"] forState:UIControlStateNormal];
//        [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [searchBtn addTarget:self action:@selector(toHistoryList) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
        
        self.editBtn.hidden = NO;
        
        carImgUrl = self.carDic[@"image"];
        
        if ([carImgUrl isKindOfClass:[NSString class]]) {
            if (carImgUrl.length > 0) {
                [self.carImgView sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(carImgUrl)]];
            }
//            self.carImgL.hidden = YES;
        }
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd"];
    
        self.mileageTF.enabled = NO;
        self.mileageTF.text = NSStringWithNumberNULL(self.carDic[@"mileage"]);
        self.fuelAmountTF.enabled = NO;
        self.fuelAmountTF.text = NSStringWithNumberNULL(self.carDic[@"fuelAmount"]);
        self.ownerTF.enabled = NO;
        self.ownerTF.textColor = RGBCOLOR(104, 104, 104);
        self.ownerTF.text = STRING(self.carDic[@"owner"]);
        self.phoneTF.enabled = NO;
        self.phoneTF.text = NSStringWithNumberNULL(self.carDic[@"phone"]);
        self.wechatTF.enabled = NO;
        self.wechatTF.text = NSStringWithNumber(self.carDic[@"wechat"]);
        self.genderTF.enabled = NO;
        self.genderTF.text = STRING(self.carDic[@"gender"]);
        self.birthdayTF.enabled = NO;
        if (! [self.carDic[@"birthday"] isKindOfClass:[NSNull class]]) {
            NSDate *birthdayDate = [NSDate dateWithTimeIntervalSince1970:[self.carDic[@"birthday"] doubleValue]/1000];
            NSString *birthdayStr = [formater stringFromDate:birthdayDate];
            self.birthdayTF.text = birthdayStr;
        }
        self.plateNumberTF.enabled = NO;
        self.plateNumberTF.textColor = RGBCOLOR(104, 104, 104);
        self.plateNumberTF.text = NSStringWithNumberNULL(self.carDic[@"plateNumber"]);
        self.brandTF.enabled = NO;
        self.brandTF.textColor = RGBCOLOR(104, 104, 104);
        self.brandTF.text = STRING(self.carDic[@"brand"]);
        self.modelTF.enabled = NO;
        self.modelTF.textColor = RGBCOLOR(104, 104, 104);
        self.modelTF.text = STRING(self.carDic[@"model"]);
        self.engineModelTF.enabled = NO;
        self.engineModelTF.text = STRING(self.carDic[@"engineModel"]);
        self.purchaseDateTF.enabled = NO;
        if (! [self.carDic[@"purchaseDate"] isKindOfClass:[NSNull class]]) {
            NSDate *purchaseDate = [NSDate dateWithTimeIntervalSince1970:[self.carDic[@"purchaseDate"] doubleValue]/1000];
            NSString *purchaseStr = [formater stringFromDate:purchaseDate];
            self.purchaseDateTF.text = purchaseStr;
        }
        self.engineNoTF.enabled = NO;
        self.engineNoTF.text = NSStringWithNumberNULL(self.carDic[@"engineNo"]);
        self.vinTF.enabled = NO;
        self.vinTF.text = NSStringWithNumberNULL(self.carDic[@"vin"]);
        
        if ([self.carDic[@"mileageImage"] isKindOfClass:[NSString class]]) {
            if ([self.carDic[@"mileageImage"] length] > 0) {
                mileagePhotos = @[@{@"relativePath":self.carDic[@"mileageImage"]}];
            }
        }
        if ([self.carDic[@"fuelImage"] isKindOfClass:[NSString class]]) {
            if ([self.carDic[@"fuelImage"] length] > 0) {
                fuelAmountPhotos = @[@{@"relativePath":self.carDic[@"fuelImage"]}];
            }
        }
        if ([self.carDic[@"engineImage"] isKindOfClass:[NSString class]]) {
            if ([self.carDic[@"engineImage"] length] > 0) {
                enginePhotos = @[@{@"relativePath":self.carDic[@"engineImage"]}];
            }
        }
        if ([self.carDic[@"vinImage"] isKindOfClass:[NSString class]]) {
            if ([self.carDic[@"vinImage"] length] > 0) {
                vinPhotos = @[@{@"relativePath":self.carDic[@"vinImage"]}];
            }
        }
    }
    else {
        self.title = @"新增车辆";
        self.editBtn.hidden = YES;
        
        self.mileageL.text = @"总里程表";
        self.mileageTF.enabled = YES;
        self.fuelAmountL.text = @"燃油量";
        self.fuelAmountTF.enabled = YES;
        self.ownerTF.enabled = YES;
        self.phoneTF.enabled = YES;
        self.wechatTF.enabled = YES;
        self.genderTF.enabled = YES;
        self.birthdayTF.enabled = YES;
        self.plateNumberTF.enabled = YES;
        self.brandTF.enabled = YES;
        self.modelTF.enabled = YES;
        self.engineModelTF.enabled = YES;
        self.purchaseDateTF.enabled = YES;
        self.engineNoTF.enabled = YES;
        self.vinTF.enabled = YES;
    }
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoAction)];
    [self.carImgView addGestureRecognizer:tap0];
    
    nameArray = @[@"男", @"女"];
    genderPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 216)];
    genderPickerView.delegate = self;
    genderPickerView.dataSource = self;
    
    birthdayDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 216)];
    birthdayDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
    //显示方式是只显示年月日
    birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
    [birthdayDatePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    
    buyDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 216)];
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
    [self setTextFieldInputAccessoryViewWithTF:self.engineModelTF];
    [self setTextFieldInputAccessoryViewWithTF:self.purchaseDateTF];
    [self setTextFieldInputAccessoryViewWithTF:self.engineNoTF];
    [self setTextFieldInputAccessoryViewWithTF:self.vinTF];
    
    textFieldArray = @[self.mileageTF, self.fuelAmountTF, self.ownerTF, self.phoneTF, self.wechatTF, self.genderTF, self.birthdayTF, self.plateNumberTF, self.brandTF, self.modelTF,self.engineModelTF, self.purchaseDateTF, self.engineNoTF, self.vinTF];
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

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithTF:(UITextField *)field{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextBtn setTitle:@"下一项" forState:UIControlStateNormal];
    nextBtn.tag = field.tag;
    nextBtn.frame = CGRectMake(2, 5, 60, 25);
    [nextBtn addTarget:self action:@selector(nextField:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBtnItem = [[UIBarButtonItem alloc]initWithCustomView:nextBtn];
    
    UIButton *lastBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [lastBtn setTitle:@"上一项" forState:UIControlStateNormal];
    lastBtn.tag = field.tag;
    lastBtn.frame = CGRectMake(2, 5, 60, 25);
    [lastBtn addTarget:self action:@selector(lastField:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *lastBtnItem = [[UIBarButtonItem alloc]initWithCustomView:lastBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:lastBtnItem, nextBtnItem, spaceBtn, doneBtnItem,nil];
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

-(void)nextField:(UIButton *)nextBtn {
    NSInteger textFieldIndex = nextBtn.tag;
    UITextField *textField = (UITextField *)textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex < [textFieldArray count] - 1)
    {
        UITextField *nextTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex + 1)];
        [nextTextField becomeFirstResponder];
    }
}

-(void)lastField:(UIButton *)lastBtn {
    NSInteger textFieldIndex = lastBtn.tag;
    UITextField *textField = (UITextField *)textFieldArray[textFieldIndex];
    [textField resignFirstResponder];
    if (textFieldIndex > 0)
    {
        UITextField *lastTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex - 1)];
        [lastTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger textFieldIndex = textField.tag;
    [textField resignFirstResponder];
    if (textFieldIndex < [textFieldArray count] - 1)
    {
        UITextField *nextTextField = (UITextField *)[textFieldArray objectAtIndex:(textFieldIndex + 1)];
        [nextTextField becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.plateNumberTF) {      //字母转大写
        self.plateNumberTF.text = [self.plateNumberTF.text uppercaseString];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.fuelAmountTF) {
        if ([textField.text intValue] > 100) {
            _networkConditionHUD.labelText = @"燃油量百分比不能超过100%！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    return YES;
}

#pragma mark - 日期选择
- (void)dateChange:(UIDatePicker *)datePicker
{
    NSDate *theDate = datePicker.date;
    NSLog(@"%@",[theDate descriptionWithLocale:[NSLocale currentLocale]]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd";
    NSString *dateString = [dateFormatter stringFromDate:theDate];
    if (datePicker == birthdayDatePicker) {
        self.birthdayTF.text = dateString;
    }
    else if (datePicker == buyDatePicker) {
        self.purchaseDateTF.text = dateString;
    }
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (IBAction)mileagePhoto:(id)sender {
    if (self.carDic) {  //编辑页面
        if (mileagePhotos.count > 0) {
            AddPicViewController *photoVC = [[AddPicViewController alloc] init];
            photoVC.maxCount = 1;
            photoVC.GoBackUpdate = ^(NSMutableArray *array) {
                mileagePhotos = array;
                NSLog(@"mileagePhotos: %@",mileagePhotos);
            };
            photoVC.localImgsArray = mileagePhotos;
            [self.navigationController pushViewController:photoVC animated:YES];
        }
        else {
            _networkConditionHUD.labelText = @"没有相关图片";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    else {
        AddPicViewController *photoVC = [[AddPicViewController alloc] init];
        photoVC.maxCount = 1;
        photoVC.GoBackUpdate = ^(NSMutableArray *array) {
            mileagePhotos = array;
            NSLog(@"mileagePhotos: %@",mileagePhotos);
        };
        photoVC.localImgsArray = mileagePhotos;
        [self.navigationController pushViewController:photoVC animated:YES];
    }
}

- (IBAction)fuelAmountPhoto:(id)sender {
    if (self.carDic) {  //编辑页面
        if (fuelAmountPhotos.count > 0) {
            AddPicViewController *photoVC = [[AddPicViewController alloc] init];
            photoVC.maxCount = 1;
            photoVC.GoBackUpdate = ^(NSMutableArray *array) {
                fuelAmountPhotos = array;
                NSLog(@"fuelAmountPhotos: %@",fuelAmountPhotos);
            };
            photoVC.localImgsArray = fuelAmountPhotos;
            [self.navigationController pushViewController:photoVC animated:YES];
        }
        else {
            _networkConditionHUD.labelText = @"没有相关图片";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    else {
        AddPicViewController *photoVC = [[AddPicViewController alloc] init];
        photoVC.maxCount = 1;
        photoVC.GoBackUpdate = ^(NSMutableArray *array) {
            fuelAmountPhotos = array;
            NSLog(@"fuelAmountPhotos: %@",fuelAmountPhotos);
        };
        photoVC.localImgsArray = fuelAmountPhotos;
        [self.navigationController pushViewController:photoVC animated:YES];
    }
}

- (IBAction)enginePhoto:(id)sender {
    AddPicViewController *photoVC = [[AddPicViewController alloc] init];
    photoVC.maxCount = 1;
    photoVC.GoBackUpdate = ^(NSMutableArray *array) {
        enginePhotos = array;
        NSLog(@"enginePhotos: %@",enginePhotos);
    };
    photoVC.localImgsArray = enginePhotos;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (IBAction)vinPhoto:(id)sender {
    AddPicViewController *photoVC = [[AddPicViewController alloc] init];
    photoVC.maxCount = 1;
    photoVC.GoBackUpdate = ^(NSMutableArray *array) {
        vinPhotos = array;
        NSLog(@"vinPhotos: %@",vinPhotos);
    };
    photoVC.localImgsArray = vinPhotos;
    [self.navigationController pushViewController:photoVC animated:YES];
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


#pragma mark - 手机号码及验证码格式初步验证
-(BOOL) checkplateNumberTFWithPlateNumer:(NSString *)plateNumber {
    /**
     *  是否纯数字
     */
    BOOL isDigit = NO;
    NSString *regEX = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Z]{1}[A-Z]{1}[A-Z0-9]{4}[A-Z0-9挂学警港澳]{1}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:plateNumber]) {
        isDigit = YES;
    } else {
        isDigit = NO;
    }
    
    if (isDigit && [plateNumber length] == 7) {
        return YES;
    }
    return NO;
}

- (IBAction)toEdit:(id)sender {
    NSLog(@"编辑按钮");
    self.editBtn.hidden = YES;
    
//    self.mileageTF.enabled = YES;
//    self.fuelAmountTF.enabled = YES;
    self.ownerTF.enabled = NO;
    self.phoneTF.enabled = YES;
    self.wechatTF.enabled = YES;
    self.genderTF.enabled = YES;
    self.birthdayTF.enabled = YES;
    self.plateNumberTF.enabled = NO;
    self.brandTF.enabled = NO;
    self.modelTF.enabled = NO;
    self.engineModelTF.enabled = YES;
    self.purchaseDateTF.enabled = YES;
    self.engineNoTF.enabled = YES;
    self.vinTF.enabled = YES;
}

-(void) toHistoryList {
    BaoyangHistoryVC *historyVC = [[BaoyangHistoryVC alloc] init];
    historyVC.carDic = self.carDic;
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (void)photoAction {
    [self selectThePhotoOrCamera];
}

- (IBAction)saveAction:(id)sender {
    if (! self.ownerTF.text || self.ownerTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车主姓名必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.phoneTF.text || self.phoneTF.text.length == 0) {
        _networkConditionHUD.labelText = @"电话必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.plateNumberTF.text || self.plateNumberTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车牌号必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! [self checkplateNumberTFWithPlateNumer:self.plateNumberTF.text]) {
        _networkConditionHUD.labelText = @"车牌号格式不正确，请重新输入！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.brandTF.text || self.brandTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车辆品牌必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.modelTF.text || self.modelTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车型必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    isAutoSelect = NO;
    if (self.carDic) {
        [self requestPostUpdateCar];
    } else {
        [self requestPostAddCar];
    }
}

- (IBAction)selectAction:(id)sender {
    if (! self.ownerTF.text || self.ownerTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车主姓名必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.phoneTF.text || self.phoneTF.text.length == 0) {
        _networkConditionHUD.labelText = @"电话必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.plateNumberTF.text || self.plateNumberTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车牌号必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! [self checkplateNumberTFWithPlateNumer:self.plateNumberTF.text]) {
        _networkConditionHUD.labelText = @"车牌号格式不正确，请重新输入！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.brandTF.text || self.brandTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车辆品牌必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! self.modelTF.text || self.modelTF.text.length == 0) {
        _networkConditionHUD.labelText = @"车型必须填写！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    isAutoSelect = YES;
    if (self.carDic) {
        [self requestPostUpdateCar];
    } else {
        [self requestPostAddCar];
    }
}

-(void)selectThePhotoOrCamera {
    UIActionSheet *actionSheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    actionSheet.tag = 1000;
    [actionSheet showInView:self.view];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //来源:相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    //来源:相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else {
            if (buttonIndex == 1) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //设置导航栏背景颜色
        imagePickerController.navigationBar.barTintColor = [UIColor whiteColor];
        //设置右侧取消按钮的字体颜色
        imagePickerController.navigationBar.tintColor = [UIColor blackColor];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
}
// 拍照完成回调 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
{
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //图片存入相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    self.carImgView.image = image;
//    self.carImgL.hidden = YES;
    [self requestUploadImgFile:self.carImgView]; 
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进入拍摄页面点击取消按钮
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
 */
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
-(void)requestUploadImgFile:(WPImageView *)image {  //上传图片
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UploadImgFile object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UploadImgFile,@"op", nil];
    [[DataRequest sharedDataRequest] uploadImageWithUrl:UrlPrefix(UploadImgFile) params:nil target:image delegate:nil info:infoDic];
}

-(void)requestPostAddCar { //新增车辆
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarAdd object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarAdd, @"op", nil];
    
    NSString *mileageUrl;
    if (mileagePhotos.count > 0) {
        mileageUrl = [mileagePhotos firstObject][@"relativePath"];
    }
    NSString *fuelAmountUrl;
    if (fuelAmountPhotos.count > 0) {
        fuelAmountUrl = [fuelAmountPhotos firstObject][@"relativePath"];
    }
    NSString *engineUrl;
    if (enginePhotos.count > 0) {
        engineUrl = [enginePhotos firstObject][@"relativePath"];
    }
    NSString *vinUrl;
    if (vinPhotos.count > 0) {
        vinUrl = [vinPhotos firstObject][@"relativePath"];
    }

    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:STRING_Nil(self.mileageTF.text),@"mileage",STRING_Nil(mileageUrl),@"mileageImage",STRING_Nil(self.fuelAmountTF.text),@"fuelAmount",STRING_Nil(fuelAmountUrl),@"fuelImage",self.ownerTF.text,@"owner",self.phoneTF.text,@"phone",STRING_Nil(self.wechatTF.text),@"wechat",STRING_Nil(self.genderTF.text),@"gender",STRING_Nil(self.birthdayTF.text),@"birthday",self.plateNumberTF.text,@"plateNumber",self.brandTF.text,@"brand",self.modelTF.text,@"model",STRING_Nil(self.purchaseDateTF.text),@"purchaseDate",STRING_Nil(carImgUrl),@"image",STRING_Nil(engineUrl),@"engineImage",STRING_Nil(self.engineNoTF.text),@"engineNo",STRING_Nil(self.vinTF.text),@"vin",STRING_Nil(vinUrl),@"vinImage",STRING_Nil(self.engineModelTF.text),@"engineModel", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(CarAdd) delegate:nil params:pram info:infoDic];
}

-(void)requestPostUpdateCar { //更新车辆
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpdate object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpdate, @"op", nil];
    
    NSString *mileageUrl;
    if (mileagePhotos.count > 0) {
        mileageUrl = [mileagePhotos firstObject][@"relativePath"];
    }
    NSString *fuelAmountUrl;
    if (fuelAmountPhotos.count > 0) {
        fuelAmountUrl = [fuelAmountPhotos firstObject][@"relativePath"];
    }
    NSString *engineUrl;
    if (enginePhotos.count > 0) {
        engineUrl = [enginePhotos firstObject][@"relativePath"];
    }
    NSString *vinUrl;
    if (vinPhotos.count > 0) {
        vinUrl = [vinPhotos firstObject][@"relativePath"];
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.carDic[@"id"],@"id",STRING_Nil(self.mileageTF.text),@"mileage",STRING_Nil(mileageUrl),@"mileageImage",STRING_Nil(self.fuelAmountTF.text),@"fuelAmount",STRING_Nil(fuelAmountUrl),@"fuelImage",self.ownerTF.text,@"owner",STRING_Nil(self.phoneTF.text),@"phone",STRING_Nil(self.wechatTF.text),@"wechat",STRING_Nil(self.genderTF.text),@"gender",STRING_Nil(self.birthdayTF.text),@"birthday",self.plateNumberTF.text,@"plateNumber",self.brandTF.text,@"brand",self.modelTF.text,@"model",STRING_Nil(self.purchaseDateTF.text),@"purchaseDate",STRING_Nil(carImgUrl),@"image",STRING_Nil(engineUrl),@"engineImage",STRING_Nil(self.engineNoTF.text),@"engineNo",STRING_Nil(self.vinTF.text),@"vin",STRING_Nil(vinUrl),@"vinImage",STRING_Nil(self.engineModelTF.text),@"engineModel", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postJSONRequestWithUrl:UrlPrefix(CarUpdate) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:CarAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarAdd object:nil];
        NSLog(@"CarAdd: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:CarUpdate]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpdate object:nil];
        NSLog(@"CarUpdate: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:UploadImgFile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UploadImgFile object:nil];
        if ([responseObject[@"result"] boolValue]) {
            carImgUrl = [NSString stringWithFormat:@"%@%@",responseObject[@"relativePath"],responseObject[@"name"]];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC:(NSString *)carId {
    if (isAutoSelect) {
        NSDictionary *car = @{@"id":carId,@"plateNumber":self.plateNumberTF.text,@"mileage":self.mileageTF.text,@"fuelAmount":self.fuelAmountTF.text};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidSelectedCar" object:nil userInfo:car];
        [self.navigationController popToRootViewControllerAnimated:YES];
//        self.GoBackSelectCarDic(car);   //返回刷新并选择
    } else {
//        self.GoBackAddedCarDic();       //仅返回刷新
        [self.navigationController popViewControllerAnimated:YES];
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
