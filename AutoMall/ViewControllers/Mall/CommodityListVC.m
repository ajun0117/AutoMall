//
//  CommodityListVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CommodityListVC.h"
#import "MJRefresh.h"
#import "CommodityListCell.h"
#import "CommodityDetailVC.h"

@interface CommodityListVC ()
{
    IBOutlet UIView *topView;
    IBOutlet UIButton *xiangmuBtn;
    IBOutlet UIButton *sortBtn;
    IBOutlet UIButton *tagBtn;
    UIView *selectBgView;
    UITableView *selectTableView;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *commodityArray;
    int currentpage;
    NSString *orderString;  //默认null        starLevel星级  salesVolume 销量  discount折后价
    NSString *orderTypeString;  //默认desc
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CommodityListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.categoryName;
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -6;
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(0, 0, 30, 30);
    //    [infoBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    infoBtn.contentMode = UIViewContentModeScaleAspectFit;
    [infoBtn setImage:[UIImage imageNamed:@"commFilter"] forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(toFilter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, searchBtnBarBtn, infoBtnBarBtn, nil];
    
//    [self adjustLeftBtnFrameWithTitle:@"项目" andButton:xiangmuBtn];
//    [self adjustLeftBtnFrameWithTitle:@"排列方式" andButton:sortBtn];
//    [self adjustLeftBtnFrameWithTitle:@"标签" andButton:tagBtn];
    
     [xiangmuBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
     [sortBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
     [tagBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityListCell" bundle:nil] forCellReuseIdentifier:@"commodityListCell"];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)]; 
    
    commodityArray = [NSMutableArray array];
    currentpage = 0;
    orderString = NULL;
    orderTypeString = @"desc";
    [self requestGetCommodityList];
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

-(void) toSearch {      //搜索
    
}

-(void) toFilter {      //筛选项目
    
}

- (IBAction)levelAction:(id)sender {
    xiangmuBtn.backgroundColor = [UIColor lightGrayColor];
    orderString = @"starLevel";     //按星级排序
    if (xiangmuBtn.selected) {
        xiangmuBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        xiangmuBtn.selected = YES;
        orderTypeString = @"asc";   //升序
    }
    sortBtn.selected = NO;
    sortBtn.backgroundColor = [UIColor whiteColor];
    tagBtn.selected = NO;
    tagBtn.backgroundColor = [UIColor whiteColor];
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}
- (IBAction)saleAction:(id)sender {
    xiangmuBtn.selected = NO;
    xiangmuBtn.backgroundColor = [UIColor whiteColor];
    orderString = @"salesVolume";     //按销量排序
    sortBtn.backgroundColor = [UIColor lightGrayColor];
    if (sortBtn.selected) {
        sortBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        sortBtn.selected = YES;
        orderTypeString = @"asc";   //升序
    }
    tagBtn.selected = NO;
    tagBtn.backgroundColor = [UIColor whiteColor];
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}
- (IBAction)valueAction:(id)sender {
    xiangmuBtn.selected = NO;
    xiangmuBtn.backgroundColor = [UIColor whiteColor];
    sortBtn.selected = NO;
    sortBtn.backgroundColor = [UIColor whiteColor];
    
    orderString = @"discount";     //按星级排序
    tagBtn.backgroundColor = [UIColor lightGrayColor];
    if (tagBtn.selected) {
        tagBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        tagBtn.selected = YES;
        orderTypeString = @"asc";   //升序
    }
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}

#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    [self requestGetCommodityList];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == selectTableView) {
        return 1;
    }
    return [commodityArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == selectTableView) {
        return 44;
    }
    return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 1;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == selectTableView) {
        return 1;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == selectTableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        //        cell.backgroundColor = RGBCOLOR(238, 238, 238);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        if (pingfenBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"由低到高";
//            }
//            else {
//                cell.textLabel.text = @"由高到低";
//            }
//        }
//        else if (priceBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"由低到高";
//            }
//            else {
//                cell.textLabel.text = @"由高到低";
//            }
//        }
//        else if (distanceBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"5公里";
//            }
//            else if (indexPath.row == 1) {
//                cell.textLabel.text = @"10公里";
//            }
//            else {
//                cell.textLabel.text = @"全部";
//            }
//        }
//        else if (youhuiBtn.selected) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"优惠商家";
//            }
//            else {
//                cell.textLabel.text = @"全部";
//            }
//        }
        return  cell;
    }
    else {
        CommodityListCell *cell = (CommodityListCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityListCell"];
        NSDictionary *dic = commodityArray [indexPath.section];
        [cell.goodsIM sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"default")];
        cell.goodsNameL.text = dic [@"name"];
//        cell.baokuanL.text =
//        cell.tuijianL.text =
//        cell.zhekouL.text =
        cell.pingxingView.rate = [dic [@"starLevel"] floatValue] / 2;
        cell.xiaoliangL.text = [NSString stringWithFormat:@"月销%@单",dic [@"salesVolume"]];
        cell.jifenL.text =  [NSString stringWithFormat:@"%@积分",dic[@"integral"]];
        NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        if ([mobileUserType isEqualToString:@"1"]) {    //老板
            cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"discount"]];
            cell.costPriceStrikeL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
            cell.yunfeiL.text = [NSString stringWithFormat:@"配送费%@元",dic[@"shippingFee"]];
        }
        else {
            cell.moneyL.text = @"￥--";
            cell.costPriceStrikeL.text = @"￥--";
            cell.yunfeiL.text = @"配送费--元";
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == selectTableView) {
//        UITableViewCell *cell = [selectTableView cellForRowAtIndexPath:indexPath];
//        if (pingfenBtn.selected) {
//            if (indexPath.row == 0) {
//                [sortDic setObject:@"asc" forKey:@"score"];
//            }
//            else {
//                [sortDic setObject:@"desc" forKey:@"score"];
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:pingfenBtn];
//            //            [pingfenBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (priceBtn.selected) {
//            if (indexPath.row == 0) {
//                [sortDic setObject:@"asc" forKey:@"consumption"];
//            }
//            else {
//                [sortDic setObject:@"desc" forKey:@"consumption"];
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:priceBtn];
//            //            [priceBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (distanceBtn.selected) {
//            if (indexPath.row == 0) {
//                distanceStr = @"5";
//            }
//            else if (indexPath.row == 1) {
//                distanceStr = @"10";
//            }
//            else {
//                distanceStr = @"";
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:distanceBtn];
//            //            [distanceBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        else if (youhuiBtn.selected) {
//            if (indexPath.row == 0) {
//                isCoupons = @"1";
//            }
//            else {
//                isCoupons = @"";
//            }
//            [self adjustLeftBtnFrameWithTitle:cell.textLabel.text andButton:youhuiBtn];
//            //            [youhuiBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
//        }
//        
//        [self cancelSelect];
//        currentpage = 1;
//        [self requestGetShopList];
    }
    else {
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
        detailVC.commodityId = commodityArray[indexPath.section][@"id"];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}


//-(void)adjustLeftBtnFrameWithTitle:(NSString *)str andButton:(UIButton *)btn {
//    NSDictionary *attributes = @{NSFontAttributeName : btn.titleLabel.font};
//    CGSize size = [str sizeWithAttributes:attributes];
//    NSLog(@"size: %@",NSStringFromCGSize(size));
//    //    float rate = btn.frame.size.width / size.width;
//    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, size.width+25, 0, 0)];
//    [btn setTitle:str forState:UIControlStateNormal];
//}

#pragma mark - 发送请求
-(void)requestGetCommodityList { //获取分类列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CommodityList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CommodityList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.categoryId,@"categoryId",[NSNumber numberWithInt:currentpage],@"pageNo",orderString,@"order",orderTypeString,@"orderType", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CommodityList) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:CommodityList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CommodityList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [commodityArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
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
