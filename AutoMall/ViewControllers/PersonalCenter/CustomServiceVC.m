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

@interface CustomServiceVC () <UITextFieldDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *serviceArray;
    int currentpage;
    NSMutableArray *idAry;  //已选择的id数组
    NSMutableArray *priceAry;   //已选择的price数组
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CustomServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"定制服务";
    
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

    idAry = [NSMutableArray array];
    priceAry = [NSMutableArray array];
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
    NSLog(@"serviceArray.count: %lu",(unsigned long)serviceArray.count);
    if (serviceArray.count == 0) {
        return cell;
    }
    NSDictionary *dic = serviceArray[indexPath.section];
    cell.nameL.text = dic[@"name"];
//    cell.nameL.text = @"机油更换";
    cell.moneyTF.text = [NSString stringWithFormat:@"%@",dic[@"price"]];
    cell.moneyTF.delegate = self;
    [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
    if ([idAry containsObject:dic[@"id"]]) {
        cell.radioBtn.selected = YES;
    } else {
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
        [idAry addObject:dic[@"id"]];
        [priceAry addObject:cell.moneyTF.text];
    }
    else {
        [idAry removeObject:dic[@"id"]];
        [priceAry removeObject:cell.moneyTF.text];
    }
    NSLog(@"idAry: %@",idAry);
    NSLog(@"priceAry: %@",priceAry);
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
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",currentpage],@"pageNo",@"20",@"pageSize", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ListServiceContent) delegate:nil params:pram info:infoDic];
}

-(void)requestPostCustomizeServiceContent { //提交定制服务内容
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CustomizeServiceContent object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CustomizeServiceContent, @"op", nil];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:idAry,@"id",priceAry,@"price", nil];
     NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"95",@"id[0]",@"10",@"price[0]", nil];
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
