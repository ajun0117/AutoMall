//
//  AddInvoiceVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2018/6/1.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "AddInvoiceVC.h"
#import "ChooseLocationView.h"
#import "CitiesDataTool.h"

@interface AddInvoiceVC () <NSURLSessionDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *textFieldArray;
    id activeField;
    BOOL keyboardShown; //键盘是否弹出
    CGRect scrollViewFrame;       //记录初始frame
    NSString *invoiceType;  //发票类型
}
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollV;
@property (weak, nonatomic) IBOutlet UIButton *plainInvoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *valueAddedInvoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *personageBtn;
@property (weak, nonatomic) IBOutlet UIButton *companyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *taxpayerViewHeiCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewHeiCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bankViewHeiCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewHeiCon;

@property (weak, nonatomic) IBOutlet UITextField *invoiceTitleTF;

@property (weak, nonatomic) IBOutlet UIView *taxpayerView;
@property (weak, nonatomic) IBOutlet UITextField *taxpayerTF;

@property (weak, nonatomic) IBOutlet UITextField *regisAddrTF;
@property (weak, nonatomic) IBOutlet UITextField *regisPhoneTF;
@property (weak, nonatomic) IBOutlet UITextField *bankNameTF;
@property (weak, nonatomic) IBOutlet UITextField *bankCodeTF;

@property (weak, nonatomic) IBOutlet UITextField *receiveNameTF;
@property (weak, nonatomic) IBOutlet UITextField *receivePhoneTF;
@property (weak, nonatomic) IBOutlet UIButton *receiveAddrBtn;
@property (weak, nonatomic) IBOutlet UITextField *receiveAddrDetailTF;
@property (weak, nonatomic) IBOutlet UISwitch *defaultSw;

@property (weak, nonatomic) IBOutlet UITextField *receiveEmailTF;

@end

@implementation AddInvoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"新增发票";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.plainInvoiceBtn setImage:[UIImage imageNamed:@"btn_check"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.plainInvoiceBtn.layer.cornerRadius = 2;
    self.plainInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    self.plainInvoiceBtn.layer.borderWidth = 1;
    [self.plainInvoiceBtn addTarget:self action:@selector(plainInvoiceAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.valueAddedInvoiceBtn setImage:[UIImage imageNamed:@"btn_check"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.valueAddedInvoiceBtn.layer.cornerRadius = 2;
    self.valueAddedInvoiceBtn.layer.borderColor = RGBCOLOR(85, 85, 85).CGColor;
    self.valueAddedInvoiceBtn.layer.borderWidth = 1;
    [self.valueAddedInvoiceBtn addTarget:self action:@selector(valueAddedInvoiceAction) forControlEvents:UIControlEventTouchUpInside];
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setTextFieldInputAccessoryViewWithTF:self.receiveNameTF];
    [self setTextFieldInputAccessoryViewWithTF:self.receivePhoneTF];
    [self setTextFieldInputAccessoryViewWithTF:self.receiveAddrDetailTF];
    [self setTextFieldInputAccessoryViewWithTF:self.receiveEmailTF];
    
    textFieldArray = @[self.receiveNameTF, self.receivePhoneTF, self.receiveAddrDetailTF,self.receiveEmailTF];
    
    self.taxpayerViewHeiCon.constant = 0;
    self.taxpayerView.hidden = YES;
    self.bankViewHeiCon.constant = 0;
    self.personageBtn.selected = YES;
    self.companyBtn.selected = NO;
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    [self.receiveAddrBtn setTitle:@"广东省 广州市 白云区" forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keybordDown)];
    [self.myScrollV addGestureRecognizer:tap];
    
    invoiceType = @"0";     //默认个人发票
    
    if (self.isEdit) {
        self.title = @"编辑发票";
        invoiceType = self.invoiceDic [@"type"];
        if ([invoiceType intValue] == 0)  {
            [self plainInvoiceAction];  //个人普通发票
        } else if ([invoiceType intValue] == 1)  {
            [self companyAction:self.companyBtn];
        } else if ([invoiceType intValue] == 2)  {
            [self valueAddedInvoiceAction];
        }
        self.invoiceTitleTF.text = self.invoiceDic [@"head"];
        self.taxpayerTF.text = self.invoiceDic [@"taxpayerCode"];
        NSString *proStr = [NSString stringWithFormat:@"%@ %@ %@",self.invoiceDic [@"province"],self.invoiceDic [@"city"],self.invoiceDic [@"area"]];
        [self.receiveAddrBtn setTitle:proStr forState:UIControlStateNormal];
        self.regisAddrTF.text = self.invoiceDic [@"registAddr"];
        self.regisPhoneTF.text = self.invoiceDic[@"registPhone"];
        self.bankNameTF.text = self.invoiceDic[@"depositBank"];
        self.bankCodeTF.text = self.invoiceDic[@"bankAccount"];
        self.receiveNameTF.text = self.invoiceDic[@"realName"];
        self.receivePhoneTF.text = self.invoiceDic[@"phone"];
        self.receiveAddrDetailTF.text = self.invoiceDic[@"addr"];
        self.receiveEmailTF.text = self.invoiceDic[@"email"];
        
        BOOL preferred = [self.invoiceDic [@"def"] boolValue];
        self.defaultSw.on = preferred;
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    scrollViewFrame = [self.myScrollV frame];
    NSLog(@"scrollViewFrame: %@",NSStringFromCGRect(scrollViewFrame));
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) keybordDown {
    NSLog(@"--------keybordDown-------");
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
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

//电话号码格式判断，包含手机号和座机号
-(BOOL) checkTelNumWithNumber:(NSString *)number {
    /**
     *  是否是电话号码格式
     */
    NSString *regEX = @"^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}|0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEX];
    if ([pred evaluateWithObject:number]) {
        return YES;
    } else {
        return NO;
    }
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
            [weakSelf.receiveAddrBtn setTitle:weakSelf.chooseLocationView.address forState:UIControlStateNormal];
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

- (IBAction)addressAction:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    self.cover.hidden = !self.cover.hidden;
    self.chooseLocationView.hidden = self.cover.hidden;
}

- (IBAction)defaultAction:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    sw.on = !sw.on;
}

- (IBAction)saveAction:(id)sender {
    
    if ([invoiceType intValue] == 0) {   //普通个人
        if(self.invoiceTitleTF.text.length == 0 || self.receiveNameTF.text.length == 0 || self.receivePhoneTF.text.length == 0 || self.receiveAddrDetailTF.text.length == 0 || self.receiveEmailTF.text.length == 0){
            _networkConditionHUD.labelText = @"请完善信息后再保存！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            return;
        }
        else {
            if (! [self checkPhoneNumWithPhone:self.receivePhoneTF.text]) {
                _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                return;
            }
        }
    }
    else if([invoiceType intValue] == 1) {   //普通企业
        if(self.invoiceTitleTF.text.length == 0 || self.taxpayerTF.text.length == 0 || self.receiveNameTF.text.length == 0 || self.receivePhoneTF.text.length == 0 || self.receiveAddrDetailTF.text.length == 0 || self.receiveEmailTF.text.length == 0){
            _networkConditionHUD.labelText = @"请完善信息后再保存！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            return;
        }
        else {
            if (! [self checkPhoneNumWithPhone:self.receivePhoneTF.text]) {
                _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                return;
            }
        }
    }
    else {      //增值税发票
        if(self.invoiceTitleTF.text.length == 0 || self.taxpayerTF.text.length == 0 || self.regisAddrTF.text.length == 0 || self.regisPhoneTF.text.length == 0 || self.bankNameTF.text.length == 0 || self.bankCodeTF.text.length == 0 || self.receiveNameTF.text.length == 0 || self.receivePhoneTF.text.length == 0 || self.receiveAddrDetailTF.text.length == 0 || self.receiveEmailTF.text.length == 0){
            _networkConditionHUD.labelText = @"请完善信息后再保存！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            return;
        }
        else {
            if (! [self checkTelNumWithNumber:self.regisPhoneTF.text]) {
                _networkConditionHUD.labelText = @"电话号码输入不正确，请重新输入。";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                return;
            }
            if (! [self checkPhoneNumWithPhone:self.receivePhoneTF.text]) {
                _networkConditionHUD.labelText = @"手机号码输入不正确，请重新输入。";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
                return;
            }
        }
    }
    
    if (self.isEdit) {
        [self editInvoice];
    }
    else {
        [self addInvoice];
    }
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

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

//设置当前激活的文本框或文本域
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSLog(@"--------change-------");
//    return YES;
//}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
////    if (keyboardShown)
////        return;
//
//    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    NSLog(@"keyBoardRect: %@",NSStringFromCGRect(keyBoardRect));
//    CGRect viewFrame = scrollViewFrame;
//    viewFrame.size.height -= keyBoardRect.size.height;
//    self.myScrollV.frame = viewFrame;
//    NSLog(@"self.myScrollV.frame: %@",NSStringFromCGRect(self.myScrollV.frame));
//
//    CGRect textFieldRect = [activeField frame];
//    [self.myScrollV scrollRectToVisible:textFieldRect animated:YES];
//
////    keyboardShown = YES; 
    
    if (activeField == self.receiveAddrDetailTF || activeField == self.receiveEmailTF ) {
        //获取键盘高度，在不同设备上，以及中英文下是不同的
        CGFloat kbHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
        CGFloat offset = kbHeight;
        // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
        double duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        //将视图上移计算好的偏移
        if(offset > 0) {
            [UIView animateWithDuration:duration animations:^{
                self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}

#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
//    NSLog(@"--------keyboardWillHide-------");
//    self.myScrollV.frame = scrollViewFrame;
////    keyboardShown = NO;
    
    // 键盘动画时间
    double duration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

-(void)plainInvoiceAction {
    self.plainInvoiceBtn.selected = YES;
    self.plainInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    
    self.valueAddedInvoiceBtn.selected = NO;
    self.valueAddedInvoiceBtn.layer.borderColor = RGBCOLOR(85, 85, 85).CGColor;
    
    [self personageAction:self.personageBtn];
}

-(void)valueAddedInvoiceAction {
    self.valueAddedInvoiceBtn.selected = YES;
    self.valueAddedInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    
    self.plainInvoiceBtn.selected = NO;
    self.plainInvoiceBtn.layer.borderColor = RGBCOLOR(85, 85, 85).CGColor;
    
    self.headViewHeiCon.constant = 0;
    self.taxpayerView.hidden = NO;
    self.taxpayerViewHeiCon.constant = 45;
    self.bankViewHeiCon.constant = 179;
    self.bgViewHeiCon.constant = 605;
    
    invoiceType = @"2";     //增值税专用
}

- (IBAction)personageAction:(id)sender {
    self.personageBtn.selected = YES;
    self.companyBtn.selected = NO;
    self.taxpayerView.hidden = YES;
    self.headViewHeiCon.constant = 45;
    self.taxpayerViewHeiCon.constant = 0;
    self.bankViewHeiCon.constant = 0;
    self.bgViewHeiCon.constant = 426;
    
    invoiceType = @"0";     //普通个人
}

- (IBAction)companyAction:(id)sender {
    self.personageBtn.selected = NO;
    self.companyBtn.selected = YES;
    self.taxpayerView.hidden = NO;
    self.taxpayerViewHeiCon.constant = 45;
    self.bankViewHeiCon.constant = 0;
    self.bgViewHeiCon.constant = 471;
    
    invoiceType = @"1";     //普通企业
}

#pragma mark - 发送请求
-(void)addInvoice {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:AddInvoice object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:AddInvoice, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSArray *addrAry = [self.chooseLocationView.address componentsSeparatedByString:@" "];
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userId,@"userId",self.invoiceTitleTF.text,@"head",invoiceType,@"type",self.taxpayerTF.text,@"taxpayerCode",self.receiveNameTF.text,@"realName", self.receivePhoneTF.text,@"phone", self.receiveEmailTF.text,@"email",addrAry[0],@"province", addrAry[1],@"city", addrAry[2],@"area",self.receiveAddrDetailTF.text,@"addr",  [NSNumber numberWithInt:self.defaultSw.on],@"def",self.regisAddrTF.text,@"registAddr",self.regisPhoneTF.text,@"registPhone",self.bankNameTF.text,@"depositBank",self.bankCodeTF.text,@"bankAccount" ,nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefixNew(AddInvoice) delegate:nil params:pram info:infoDic];
}

-(void)editInvoice {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:UpDateInvoice object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:UpDateInvoice, @"op", nil];
    NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
    NSArray *addrAry = [self.chooseLocationView.address componentsSeparatedByString:@" "];
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.invoiceDic[@"id"],@"id",userId,@"userId",self.invoiceTitleTF.text,@"head",invoiceType,@"type",self.taxpayerTF.text,@"taxpayerCode",self.receiveNameTF.text,@"realName", self.receivePhoneTF.text,@"phone", self.receiveEmailTF.text,@"email",addrAry[0],@"province", addrAry[1],@"city", addrAry[2],@"area", self.receiveAddrDetailTF.text,@"addr", [NSString stringWithFormat:@"%d",self.defaultSw.on],@"def",self.regisAddrTF.text,@"registAddr",self.regisPhoneTF.text,@"registPhone",self.bankNameTF.text,@"depositBank",self.bankCodeTF.text,@"bankAccount" , nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefixNew(UpDateInvoice) delegate:nil params:pram info:infoDic];
}


#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:AddInvoice]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AddInvoice object:nil];
        NSLog(@"AddInvoice_responseObject: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:UpDateInvoice]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UpDateInvoice object:nil];
        NSLog(@"UpDateInvoice_responseObject: %@",responseObject);
        if ([responseObject[@"meta"][@"code"] intValue] == 200) {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            _networkConditionHUD.labelText = responseObject[@"meta"][@"msg"];
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
