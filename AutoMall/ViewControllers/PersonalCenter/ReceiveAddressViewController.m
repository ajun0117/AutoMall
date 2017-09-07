//
//  ReceiveAddressViewController.m
//  mobilely
//
//  Created by LYD on 15/8/10.
//  Copyright (c) 2015年 ylx. All rights reserved.
//


static NSString *const AddressCellIdentify = @"addressListCell";

#import "ReceiveAddressViewController.h"
#import "AddressListCell.h"
//#import "ReceiverInfoEditViewController.h"
#import "AddressInfoEditVC.h"
//#import "PocketLYProvinceAndCityCoreObject.h"

@interface ReceiveAddressViewController ()
{
    NSMutableArray *_addressArray;
}

@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;

@end

@implementation ReceiveAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _addressArray = [[NSMutableArray alloc] init];

    //导航条左右按钮-请根据具体情况自行设置，左右两侧的按钮也可以是文字，是文字的话自行重写self.navigationItem.rightBarButtonItem
    [self setNavitationItemWithLeftImageName:nil rightImageName:nil];
    
    UINib *nib = [UINib nibWithNibName:@"AddressListCell" bundle:nil];
    [self.myTableView registerNib:nib forCellReuseIdentifier:AddressCellIdentify];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.myTableView headerBeginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.myTableView reloadData];
}

-(void)setNavitationItemWithLeftImageName:(NSString*)leftImageName rightImageName:(NSString*)rightImageName{
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:IMG(leftImageName) style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAddress)];
}

#pragma mark - 下拉刷新个人信息
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    [self getMyAddress];
}

-(void)editAddress {
    NSLog(@"去编辑！");
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        self.myTableView.editing = YES;
        return;
    }
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    self.myTableView.editing = NO;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 0) {
//        NSDictionary *dic = _addressArray [indexPath.row];
//        AddressInfoEditVC *editVC = [[AddressInfoEditVC alloc] init];
////        editVC.isEdit = YES;
////        editVC.addressDic = dic;
//        [self.navigationController pushViewController:editVC animated:YES];
//    }
//    else {
        AddressInfoEditVC *addVC = [[AddressInfoEditVC alloc] init];
        [self.navigationController pushViewController:addVC animated:YES];
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 80;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 10;
}
#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
//        return [_addressArray count];
        return 4;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        AddressListCell *cell = (AddressListCell *)[tableView dequeueReusableCellWithIdentifier:AddressCellIdentify forIndexPath:indexPath];
//        cell.backgroundColor = [UIColor grayColor];
//        unameL;
//        phoneL
//        addressL;
//        defaultIM
//        NSDictionary *dic = _addressArray [indexPath.row];
//        cell.unameL.text = dic [@"rname"];
//        cell.phoneL.text = dic [@"mobile"];
//        NSString *provStr = [PocketLYProvinceAndCityCoreObject selectDataWithPcid:dic [@"provId"]].name;
//        NSString *cityStr = [PocketLYProvinceAndCityCoreObject selectDataWithPcid:dic [@"cityId"]].name;
//        NSString *areaStr = [PocketLYProvinceAndCityCoreObject selectDataWithPcid:dic [@"areaId"]].name;
//        cell.addressL.text = [NSString stringWithFormat:@"%@-%@-%@-%@",provStr,cityStr,areaStr,dic [@"areadesc"]];
//        int ause = [dic [@"ause"] intValue];
//        if (ause == 1) {
//            cell.defaultIM.hidden = NO;
//        }
//        else {
//             cell.defaultIM.hidden = YES;
//        }
        return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"row: %ld",(long)indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //先删除相应的地址
        [self deleteAddress:_addressArray [indexPath.row] [@"aid"]];
        [_addressArray removeObjectAtIndex:indexPath.row];//移除数据源的数据
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
    }
}


#pragma mark - 发送请求
-(void)getMyAddress {
//    [_addressArray removeAllObjects];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Address_Getall object:nil];
//    NSString *uid = [[GlobalSetting shareGlobalSettingInstance] userId];
//    [[RequestManager sharedRequestManager] requestPostGetUserAddressUserID:uid];
}

-(void)deleteAddress:(NSString *)aid {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:Address_del object:nil];
//    NSString *uid = [[GlobalSetting shareGlobalSettingInstance] userId];
//    [[RequestManager sharedRequestManager] requestPostDeleteAddressUserID:uid aid:aid];
}


#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [self.myTableView headerEndRefreshing];
    
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
//    if ([notification.name isEqualToString:Address_Getall]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:Address_Getall object:nil];
//        
//        [_addressArray addObjectsFromArray:responseObject [@"addr"]];
//        
//        if ([_addressArray count]) {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 1)];
//            self.myTableView.tableHeaderView = label;
//            [self.myTableView reloadData];
//        }
//        else {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 100)];
//            label.text = @"暂无收货地址信息";
//            label.textAlignment = NSTextAlignmentCenter;
//            label.textColor = [UIColor lightGrayColor];
//            self.myTableView.tableHeaderView = label;
//        }
//    }
//    
//    if ([notification.name isEqualToString:Address_del]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:Address_del object:nil];
//        
//        //删除成功后刷新
//        [self.myTableView headerBeginRefreshing];
//    }
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
