//
//  EditServicePackageVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EditServicePackageVC.h"
#import "ServicePackageCell.h"
#import "UpkeepPlanNormalHeadCell.h"
#import "JSONKit.h"

@interface EditServicePackageVC () <UITextFieldDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *packageArray;
    int currentpage;
    NSMutableDictionary *selectDic;     //已选择的服务数组
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EditServicePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务套餐";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ServicePackageCell" bundle:nil] forCellReuseIdentifier:@"servicePackageCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalHeadCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanNormalHeadCell"];
    self.myTableView.tableFooterView = [UIView new];
    
//    NSArray *arr = @[
//                     @{@"title":@"套餐A",@"allmoney":@"2200",@"data":@[@{@"name":@"机油更换1",@"money":@"333"},@{@"name":@"火花塞更换1",@"money":@"444"},@{@"name":@"机舱清洗保养1",@"money":@"555"}]},
//                     @{@"title":@"套餐B",@"allmoney":@"3000",@"data":@[@{@"name":@"机油更换2",@"money":@"333"},@{@"name":@"火花塞更换2",@"money":@"444"},@{@"name":@"机舱清洗保养2",@"money":@"555"},@{@"name":@"空调系统清洗2",@"money":@"666"}]}
//                     ];
    
    packageArray = [NSMutableArray array];
    currentpage = 0;
    [self requestPostListPackage];
    
    selectDic = [NSMutableDictionary dictionary];
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

- (IBAction)saveAction:(id)sender {
    [self requestPostCustomizeServicePackage];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [packageArray removeAllObjects];
    [self requestPostListPackage];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestPostListPackage];
}

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithCell:(UITableViewCell *)cell{
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
    UITextField *priceTF = (UITextField *)[cell.contentView viewWithTag:10];
    [priceTF setInputAccessoryView:topView];
    [priceTF setAutocorrectionType:UITextAutocorrectionTypeNo];
    [priceTF setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height);
    //    self.myScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.myScrollView.frame) - keyBoardRect.size.height);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44);
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"修改价格后更新选中记录中的价格");
    NSString *tempString = textField.text;
    while ([tempString hasPrefix:@"0"])
    {
        tempString = [tempString substringFromIndex:1];
        NSLog(@"压缩之后的tempString:%@",tempString);
    }
    textField.text = tempString;
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *ind = [self.myTableView indexPathForCell:cell];
    NSDictionary *dic = packageArray[ind.section];
    if([dic[@"price"] intValue] != [tempString intValue]) {     //如果价格和默认价格不一致则改为红色
        textField.textColor = [UIColor redColor];
    } else {
        textField.textColor = [UIColor blackColor];
    }
    NSMutableDictionary *dicc = [selectDic objectForKey:dic[@"id"]];
    if (textField.text.length > 0) {
        [dicc setObject:textField.text forKey:@"price"];
    }
    else {
        [dicc setObject:textField.placeholder forKey:@"price"];
    }
    NSLog(@"selectDicChange: %@",selectDic);
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString *tempString = [NSString stringWithFormat:@"%@%@",textField.text,string];
//    while ([tempString hasPrefix:@"0"])
//    {
//        tempString = [tempString substringFromIndex:1];
//        NSLog(@"压缩之后的tempString:%@",tempString);
//    }
//    textField.text = tempString;
//    return YES;
//}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [packageArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = packageArray[section];
    return [dic[@"serviceContents"] count] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐A";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        case 1: {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐B";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.text = @"￥2200";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        case 1: {
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"￥3000";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = packageArray[indexPath.section];
    NSArray *arr = dic[@"serviceContents"];
    if (indexPath.row == 0) {
        UpkeepPlanNormalHeadCell *cell = (UpkeepPlanNormalHeadCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanNormalHeadCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameL.text =  dic[@"name"];
        cell.nameL.font = [UIFont boldSystemFontOfSize:15];
        [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
        NSArray *keys = [selectDic allKeys];
        if ([keys containsObject:dic[@"id"]]) {
            cell.radioBtn.selected = YES;
        } else {
            cell.radioBtn.selected = NO;
        }
        return cell;
    }
    else if (indexPath.row == [arr count] + 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.textLabel.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
        UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 20, 30)];
        noticeL.font = [UIFont boldSystemFontOfSize:15];
        noticeL.text = @"￥";
        [cell.contentView addSubview:noticeL];
        UITextField *priceTF = [[UITextField alloc] initWithFrame:CGRectMake(32, 7, 80, 30)];
        priceTF.font = [UIFont boldSystemFontOfSize:15];
        priceTF.layer.borderColor = RGBCOLOR(239, 239, 239).CGColor;
        priceTF.layer.borderWidth = 1;
        priceTF.layer.cornerRadius = 4;
        priceTF.placeholder = [NSString stringWithFormat:@"%@",dic[@"price"]];
        priceTF.keyboardType = UIKeyboardTypeNumberPad;
        NSArray *keys = [selectDic allKeys];
        if ([keys containsObject:dic[@"id"]]) {
            NSMutableDictionary *diccc = selectDic[dic[@"id"]];
            
            if ( [diccc[@"price"] intValue] != [dic[@"price"] intValue]) {
                priceTF.textColor = [UIColor redColor];
            } else {
                priceTF.textColor = [UIColor blackColor];
            }
            
            priceTF.text = [NSString stringWithFormat:@"%@",diccc[@"price"]];
        } else {
            if ([dic[@"customized"] boolValue]) {
                priceTF.text = [NSString stringWithFormat:@"%@",dic[@"customizedPrice"]];
            } else {
                priceTF.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
            }
            
        }
        priceTF.tag = 10;
        priceTF.delegate = self;
        [cell.contentView addSubview:priceTF];
        [self setTextFieldInputAccessoryViewWithCell:cell];
        return cell;
    }
    else {
        ServicePackageCell *cell = (ServicePackageCell *)[tableView dequeueReusableCellWithIdentifier:@"servicePackageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dicc = arr[indexPath.row - 1];
        cell.declareL.text = dicc[@"name"];
        if ([dicc[@"customized"] boolValue]) {
            cell.contentL.text = [NSString stringWithFormat:@"￥%@",dicc[@"customizedPrice"]];
        } else {
            cell.contentL.text = [NSString stringWithFormat:@"￥%@",dicc[@"price"]];
        }
       
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UpkeepPlanNormalHeadCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.radioBtn.selected = !cell.radioBtn.selected;
        NSDictionary *dic = packageArray[indexPath.section];
        if (cell.radioBtn.selected) {
            NSArray *arr = dic[@"serviceContents"];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[arr count] + 1 inSection:indexPath.section]];
            UITextField *priceTF = (UITextField *)[cell.contentView viewWithTag:10];
//            NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",priceTF.text,@"price", nil];
//            [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
            
            NSMutableDictionary *dicc;
            if (priceTF.text.length > 0) {
                dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",priceTF.text,@"price", nil];
            } else {
                dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",priceTF.placeholder,@"price", nil];
            }
            [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
        }
        else {
            [selectDic removeObjectForKey:dic[@"id"]];
        }
        NSLog(@"selectDic: %@",selectDic);
    }
}

#pragma mark - 发起网络请求
-(void)requestPostListPackage { //定制服务套餐列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ListServicePackage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ListServicePackage, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo",@"20000",@"pageSize", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ListServicePackage) delegate:nil params:pram info:infoDic];
}

-(void)requestPostCustomizeServicePackage { //提交定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CustomizeServicePackage object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CustomizeServicePackage, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[[selectDic allValues] JSONString],@"data", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CustomizeServicePackage) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    if ([notification.name isEqualToString:ListServicePackage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ListServicePackage object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [packageArray addObjectsFromArray:responseObject [@"data"]];
            
            for (NSDictionary *dic in packageArray) {
                if ([dic[@"customized"] boolValue]) {   //已定制
                    NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"customizedPrice"],@"price", nil];
                    [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
                }
            }
            
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CustomizeServicePackage]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CustomizeServicePackage object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            [self performSelector:@selector(toPopVC:) withObject:responseObject[@"data"] afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC:(NSString *)carId {
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
