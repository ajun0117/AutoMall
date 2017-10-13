//
//  AddCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddCarInfoVC.h"
#import "AddCarInfoCell.h"
#import "BaoyangHistoryVC.h"
#import "AutoCheckVC.h"

@interface AddCarInfoVC () <UITextFieldDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AddCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"车辆信息";

    [self.myTableView registerNib:[UINib nibWithNibName:@"AddCarInfoCell" bundle:nil] forCellReuseIdentifier:@"addCarCell"];
    self.myTableView.tableFooterView = [UIView new];
    
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
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

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

//#pragma mark 键盘出现
//-(void)keyboardWillShow:(NSNotification *)note
//{
//    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
////    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, keyBoardRect.size.height, 0);
//    self.myTableView.contentOffset = CGPointMake(0, keyBoardRect.size.height);
//}
//#pragma mark 键盘消失
//-(void)keyboardWillHide:(NSNotification *)note
//{
////    self.myTableView.contentInset = UIEdgeInsetsZero;
//    self.myTableView.contentOffset = CGPointMake(0, 0);
//}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 80);
}

-(void) toHistoryList {
    BaoyangHistoryVC *historyVC = [[BaoyangHistoryVC alloc] init];
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (IBAction)saveAction:(id)sender {
    [self requestPostAddDiscount];
}

- (IBAction)selectAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithCell:(AddCarInfoCell *)cell{
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
    [cell.contentTF setInputAccessoryView:topView];
    [cell.contentTF setAutocorrectionType:UITextAutocorrectionTypeNo];
    [cell.contentTF setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 5;
            break;
            
        case 2:
            return 6;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 44;
            break;
            
        case 2:
            return 44;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"车主信息";
            [view addSubview:label];
            return view;
            break;
        }
            
        case 2: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"车辆信息";
            [view addSubview:label];
            return view;
            break;
        }
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddCarInfoCell *cell = (AddCarInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"addCarCell"];
    [self setTextFieldInputAccessoryViewWithCell:cell];
    cell.contentTF.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"行驶里程";
                    cell.contentTF.placeholder = @"行驶里程，单位KM";
                    cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"燃油量";
                    cell.contentTF.placeholder = @"燃油量，单位L";
                    cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"姓名";
                    cell.contentTF.placeholder = @"姓名";
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"电话";
                    cell.contentTF.placeholder = @"电话";
                    cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
                    break;
                }
                case 2: {
                    cell.declareL.text = @"微信";
                    cell.contentTF.placeholder = @"微信";
                    break;
                }
                case 3: {
                    cell.declareL.text = @"性别";
                    cell.contentTF.placeholder = @"性别";
                    break;
                }
                case 4: {
                    cell.declareL.text = @"生日";
                    cell.contentTF.placeholder = @"生日";
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"车牌号";
                    cell.contentTF.placeholder = @"车牌号";
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"品牌";
                    cell.contentTF.placeholder = @"品牌";
                    break;
                }
                case 2: {
                    cell.declareL.text = @"车型";
                    cell.contentTF.placeholder = @"车型";
                    break;
                }
                case 3: {
                    cell.declareL.text = @"购买时间";
                    cell.contentTF.placeholder = @"购买时间";
                    break;
                }
                case 4: {
                    cell.declareL.text = @"发动机号";
                    cell.contentTF.placeholder = @"发动机号";
                    break;
                }
                case 5: {
                    cell.declareL.text = @"车架号";
                    cell.contentTF.placeholder = @"车架号";
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddCarInfoCell *cell = (AddCarInfoCell *) [tableView cellForRowAtIndexPath:indexPath];
    for (id subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            [subView resignFirstResponder];
        }
    }
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;     //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    for (AddCarInfoCell *cell in self.myTableView.visibleCells) {
//        for (id subView in cell.contentView.subviews) {
//            if ([subView isKindOfClass:[UITextField class]]) {
//                [subView resignFirstResponder];
//            }
//        }
//    }
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 发起网络请求
-(void)requestPostAddDiscount { //新增优惠
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarAdd object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarAdd, @"op", nil];
    AddCarInfoCell *cell1 = (AddCarInfoCell *) [self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *mileage = cell1.contentTF.text;
    AddCarInfoCell *cell2 = (AddCarInfoCell *) [self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *fuelAmount = cell2.contentTF.text;
    NSLog(@"mileage: %@,fuelAmount: %@",mileage,fuelAmount);
    
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"storeId",self.discountsNameTF.text,@"item",self.discountsMoneyTF.text,@"money", nil];
//    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CarAdd) delegate:nil params:pram info:infoDic];
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
