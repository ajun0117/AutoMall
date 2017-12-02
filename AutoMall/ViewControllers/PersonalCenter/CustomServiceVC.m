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
#import "MultiTablesView.h"

#define SelectView_Duration    0.3  //筛选视图动画时间

@interface CustomServiceVC () <UITextFieldDelegate,MultiTablesViewDataSource,MultiTablesViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *serviceArray;
    int currentpage;
    NSMutableDictionary *selectDic;     //已选择的服务数组
//    NSMutableArray *selectArry;     //已选择的服务数组
    
//    UIView *selectBgView;
    MultiTablesView *positionSelectView;
    NSString *checkcategoryId; //部位Id
    NSString *checktermStr; //位置
    NSString *checkContentStr; //检查内容
    NSArray *allCheckcategoryAry;       //所有检查部位
    NSArray *checktermAry;       //指定部位下，平台所有位置列表
    NSString *checkTermId;  //检车位置id
    IBOutlet UIButton *positionBtn;
    NSString *lev1String;   //1级文字
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;

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
    [searchBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"套餐" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CustomServiceCell" bundle:nil] forCellReuseIdentifier:@"customServiceCell"];
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];

    selectDic = [NSMutableDictionary dictionary];
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
//    if (! selectBgView) {
//        selectBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//        selectBgView.backgroundColor = [UIColor blackColor];
//        selectBgView.alpha = 0.0;
//        [self.view addSubview:selectBgView];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelect)];
//        [selectBgView addGestureRecognizer:tap];
    
    [positionBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
        positionSelectView = [[MultiTablesView alloc]initWithFrame:CGRectMake(0, 40 - (SCREEN_HEIGHT - 64), SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 40)];
        positionSelectView.delegate = self;
        positionSelectView.dataSource = self;
        [self.view insertSubview:positionSelectView belowSubview:self.topView];
        
        [self hiddenSelectView:YES];
//    }
    

    
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
    
    serviceArray = [NSMutableArray array];
    currentpage = 0;
    [self requestPostListServiceContent];
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

-(void)cancelSelect {
    [self hiddenSelectView:YES];
}


- (void) toPackage {
    EditServicePackageVC *editVC = [[EditServicePackageVC alloc] init];
    [self.navigationController pushViewController:editVC animated:YES];
}
- (IBAction)positionAction:(id)sender {
    positionBtn.selected = YES;
    [self hiddenSelectView:NO];
    [self requestGetAllCheckcategorySearch];
}

- (IBAction)saveAction:(id)sender {
    [self requestPostCustomizeServiceContent];
}

-(void)hiddenSelectView:(BOOL)hidden {
    [UIView animateWithDuration:SelectView_Duration animations:^{
        if (hidden) {
//            selectBgView.alpha = 0.0;
            positionSelectView.frame = CGRectMake(0,  40 - (SCREEN_HEIGHT - 64 - 40), SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 40);
        }
        else {
//            selectBgView.alpha = 0.3;
            positionSelectView.frame = CGRectMake(0, 104, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 40);
        }
    }];
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
    if (textField.text.length > 0) {
        [dicc setObject:textField.text forKey:@"price"];
    }
    else {
        [dicc setObject:textField.placeholder forKey:@"price"];
    }
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [serviceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomServiceCell *cell = (CustomServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"customServiceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (serviceArray.count == 0) {
        return cell;
    }
    NSDictionary *dic = serviceArray[indexPath.row];
    cell.nameL.text = dic[@"name"];
//    cell.nameL.text = @"机油更换";
    [self setTextFieldInputAccessoryViewWithCell:cell];
    cell.moneyTF.delegate = self;
    cell.moneyTF.placeholder = [NSString stringWithFormat:@"%@",dic[@"price"]];
    cell.moneyTF.tag = indexPath.row + 100;
    if (dic[@"unit"]) {
        cell.unitL.text = [NSString stringWithFormat:@"/%@",dic[@"unit"]];
    }
    [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
    NSArray *keys = [selectDic allKeys];
    if ([keys containsObject:dic[@"id"]]) {
        NSMutableDictionary *dicc = selectDic[dic[@"id"]];
        cell.moneyTF.text = [NSString stringWithFormat:@"%@",dicc[@"price"]];
        cell.radioBtn.selected = YES;
    } else {
        if ([dic[@"customized"] boolValue]) {
            cell.moneyTF.text = [NSString stringWithFormat:@"%@",dic[@"customizedPrice"]];
        } else {
            cell.moneyTF.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
        }
        
        cell.radioBtn.selected = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CustomServiceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.radioBtn.selected = !cell.radioBtn.selected;
    NSDictionary *dic = serviceArray[indexPath.row];
    if (cell.radioBtn.selected) {
        NSMutableDictionary *dicc;
        if (cell.moneyTF.text.length > 0) {
           dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",cell.moneyTF.text,@"price", nil];
        } else {
            dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",cell.moneyTF.placeholder,@"price", nil];
        }
        [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
    }
    else {
        [selectDic removeObjectForKey:dic[@"id"]];
    }
    NSLog(@"selectDic: %@",selectDic);
}



#pragma mark - MultiTablesViewDataSource
#pragma mark Levels

- (NSInteger)numberOfLevelsInMultiTablesView:(MultiTablesView *)multiTablesView {
    return 2;
}

#pragma mark Sections
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView numberOfSectionsAtLevel:(NSInteger)level {
    return 1;
}

#pragma mark Rows
- (NSInteger)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level numberOfRowsInSection:(NSInteger)section {
    if (level == 0) {
        
        return [allCheckcategoryAry count] + 1;
    }
    else{
        return [checktermAry count] + 1;
    }
}

- (UITableViewCell *)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [multiTablesView dequeueReusableCellForLevel:level withIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = Gray_Color;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (level == 0) {
        if (indexPath.row == [allCheckcategoryAry count]) {
            cell.textLabel.text = @"全部";
        } else {
            NSDictionary *dic = allCheckcategoryAry[indexPath.row];
            cell.textLabel.text = [dic objectForKey:@"name"];
        }
    }
    else if (level == 1){
        if (indexPath.row == [checktermAry count]) {
            cell.textLabel.text = @"全部";
        } else {
            NSDictionary *dic = [checktermAry objectAtIndex:indexPath.row];
            cell.textLabel.text = [dic objectForKey:@"name"];
        }
    }
    return cell;
}

#pragma mark - MultiTablesViewDelegate
#pragma mark Levels
- (void)multiTablesView:(MultiTablesView *)multiTablesView levelDidChange:(NSInteger)level {
    if (multiTablesView.currentTableViewIndex == level) {
        [multiTablesView.currentTableView deselectRowAtIndexPath:[multiTablesView.currentTableView indexPathForSelectedRow] animated:YES];
    }
    NSLog(@"lev 变化了！");
}
#pragma mark Rows
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"11111111");
}
- (void)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (level == 0) {
        NSLog(@"加载相应数据！");
        if (indexPath.row == [allCheckcategoryAry count]) {
            [self requestGetChecktermSearchWithId:nil]; //请求2级列表
            checkcategoryId = @"";
            lev1String = @"全部部位";
            [positionBtn setTitle:lev1String forState:UIControlStateNormal];
        } else {
            NSDictionary *dic = allCheckcategoryAry[indexPath.row];
            checkcategoryId = dic[@"id"];
            [self requestGetChecktermSearchWithId:dic[@"id"]]; //请求2级列表
            lev1String = dic[@"name"];
            [positionBtn setTitle:lev1String forState:UIControlStateNormal];
        }
        
    }
    else if (level == 1) {
        if (indexPath.row == [checktermAry count]) {
            [self hiddenSelectView:YES];
            checkTermId = nil;
            currentpage = 0;
            [serviceArray removeAllObjects];
            NSString *titleStr = [NSString stringWithFormat:@"%@-%@",lev1String,@"全部位置"];
            [positionBtn setTitle:titleStr forState:UIControlStateNormal];
        } else {
            NSDictionary *dic = checktermAry[indexPath.row];
            [self hiddenSelectView:YES];
            checkTermId = dic[@"id"];
            currentpage = 0;
            [serviceArray removeAllObjects];
            NSString *titleStr = [NSString stringWithFormat:@"%@-%@",lev1String,dic[@"name"]];
            [positionBtn setTitle:titleStr forState:UIControlStateNormal];
        }
        positionBtn.selected = NO;
        [self requestPostListServiceContent];
    }
}

/*
#pragma mark Sections Headers & Footers
- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (CGFloat)multiTablesView:(MultiTablesView *)multiTablesView level:(NSInteger)level heightForHeaderInSection:(NSInteger)section {
        return 0.0;
}
*/


-(void)checkService:(UIButton *)btn {
    btn.selected = !btn.selected;
}

#pragma mark - 发起网络请求
-(void)requestGetAllCheckcategorySearch { //平台所有部位列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:AllCheckcategorySearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:AllCheckcategorySearch, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"pageNo",@"20000",@"pageSize", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(AllCheckcategorySearch) delegate:nil params:pram info:infoDic];
}

-(void)requestGetChecktermSearchWithId:(NSString *)categoryId { //指定部位下，平台所有位置列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ChecktermSearch object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ChecktermSearch, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:0],@"pageNo",@"20000",@"pageSize",categoryId,@"checkCategoryId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ChecktermSearch) delegate:nil params:pram info:infoDic];
}
                
-(void)requestPostListServiceContent { //定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ListServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ListServiceContent, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:currentpage],@"pageNo",@"20000",@"pageSize",checkcategoryId,@"checkCategoryId",checkTermId,@"checkTermId", nil];
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
    if ([notification.name isEqualToString:ListServiceContent]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ListServiceContent object:nil];
        NSLog(@"ListServiceContent: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [serviceArray addObjectsFromArray:responseObject [@"data"]];
            
            for (NSDictionary *dic in serviceArray) {
                if ([dic[@"customized"] boolValue]) {   //已定制
                    NSMutableDictionary *dicc = [NSMutableDictionary dictionaryWithObjectsAndKeys:dic[@"id"],@"id",dic[@"customizedPrice"],@"price", nil];
                    [selectDic setObject:dicc forKey:dic[@"id"]];     //以id为key
                }
            }
            
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
        NSLog(@"CustomizeServiceContent: %@",responseObject);
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
    
    if ([notification.name isEqualToString:AllCheckcategorySearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AllCheckcategorySearch object:nil];
        NSLog(@"AllCheckcategorySearch: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            allCheckcategoryAry = responseObject[@"data"];
            [positionSelectView reloadDataLevel:0]; //刷新第一级
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:ChecktermSearch]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ChecktermSearch object:nil];
        NSLog(@"ChecktermSearch: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            checktermAry = responseObject[@"data"];
            [positionSelectView reloadDataLevel:1]; //刷新第二级
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
}

- (void)toPopVC:(NSString *)carId {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
