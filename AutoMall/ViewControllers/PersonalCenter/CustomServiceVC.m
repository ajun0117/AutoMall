//
//  CustomServiceVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CustomServiceVC.h"
#import "CustomServiceCell.h"
#import "EditServicePackageVC.h"
#import "JSONKit.h"

@interface CustomServiceVC () <UITextFieldDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *serviceArray;
    int currentpage;
    NSMutableDictionary *selectDic;     //已选择的服务数组
//    NSMutableArray *selectArry;     //已选择的服务数组
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CustomServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"定制服务";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    //    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:RGBCOLOR(129, 129, 129) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"套餐" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CustomServiceCell" bundle:nil] forCellReuseIdentifier:@"customServiceCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    serviceArray = [NSMutableArray array];
    currentpage = 0;
    [self requestPostListServiceContent];

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

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [serviceArray removeAllObjects];
    [self requestPostListServiceContent];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestPostListServiceContent];
}

- (void) toPackage {
    EditServicePackageVC *editVC = [[EditServicePackageVC alloc] init];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (IBAction)saveAction:(id)sender {
    [self requestPostCustomizeServiceContent];
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
    NSInteger ind = textField.tag - 100;
    NSDictionary *dic = serviceArray[ind];
    NSMutableDictionary *dicc = [selectDic objectForKey:dic[@"id"]];
    [dicc setObject:textField.text forKey:@"price"];
    NSLog(@"selectDicChange: %@",selectDic);
}

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithCell:(CustomServiceCell *)cell{
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
    [cell.moneyTF setInputAccessoryView:topView];
    [cell.moneyTF setAutocorrectionType:UITextAutocorrectionTypeNo];
    [cell.moneyTF setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - keyBoardRect.size.height);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44);
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [serviceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomServiceCell *cell = (CustomServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"customServiceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (serviceArray.count == 0) {
        return cell;
    }
    NSDictionary *dic = serviceArray[indexPath.section];
    cell.nameL.text = dic[@"name"];
//    cell.nameL.text = @"机油更换";
    [self setTextFieldInputAccessoryViewWithCell:cell];
    cell.moneyTF.delegate = self;
    cell.moneyTF.tag = indexPath.section + 100;
    [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
    NSArray *keys = [selectDic allKeys];
    if ([keys containsObject:dic[@"id"]]) {
        NSMutableDictionary *dicc = selectDic[dic[@"id"]];
        cell.moneyTF.text = [NSString stringWithFormat:@"%@",dicc[@"price"]];
        cell.radioBtn.selected = YES;
    } else {
        cell.moneyTF.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
        cell.radioBtn.selected = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CustomServiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.radioBtn.selected = !cell.radioBtn.selected;
    NSDictionary *dic = serviceArray[indexPath.section];
    if (cell.radioBtn.selected) {
        NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",cell.moneyTF.text,@"price", nil];
        [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
    }
    else {
        [selectDic removeObjectForKey:dic[@"id"]];
    }
    NSLog(@"selectDic: %@",selectDic);
}

-(void)checkService:(UIButton *)btn {
    btn.selected = !btn.selected;
}

#pragma mark - 发起网络请求
-(void)requestPostListServiceContent { //定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ListServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ListServiceContent, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo",@"20",@"pageSize", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ListServiceContent) delegate:nil params:pram info:infoDic];
}

-(void)requestPostCustomizeServiceContent { //提交定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CustomizeServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CustomizeServiceContent, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[[selectDic allValues] JSONString],@"data", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CustomizeServiceContent) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:ListServiceContent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ListServiceContent object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [serviceArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG]; 
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CustomizeServiceContent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CustomizeServiceContent object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
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
