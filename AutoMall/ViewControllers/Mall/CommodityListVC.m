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
#import "MailSearchVC.h"

#define SelectView_Duration    0.3  //筛选视图动画时间

@interface CommodityListVC () <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UIView *topView;
    IBOutlet UIButton *xingjiBtn;
    IBOutlet UIButton *sortBtn;
    IBOutlet UIButton *priceBtn;
    UIView *selectBgView; 
    UITableView *selectTableView;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *commodityArray;
    NSArray *comtermAry;    //项目列表
    int currentpage;
    NSString *orderString;  //默认null        starLevel星级  salesVolume 销量  discount折后价
    NSString *orderTypeString;  //默认desc
    NSString *commodityTermId;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;//同上
//    self.myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
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
    searchBtn.frame = CGRectMake(0, 0, 30, 30);
    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: negativeSpacer, searchBtnBarBtn, infoBtnBarBtn, nil];
    
//    [self adjustLeftBtnFrameWithTitle:@"项目" andButton:xiangmuBtn];
//    [self adjustLeftBtnFrameWithTitle:@"排列方式" andButton:sortBtn];
//    [self adjustLeftBtnFrameWithTitle:@"标签" andButton:tagBtn];
    
     [xingjiBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
     [sortBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
     [priceBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityListCell" bundle:nil] forCellReuseIdentifier:@"commodityListCell"];
    
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    
    if (! selectBgView) {
        selectBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        selectBgView.backgroundColor = [UIColor blackColor];
        selectBgView.alpha = 0.0;
        [self.view insertSubview:selectBgView belowSubview:topView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelect)];
        [selectBgView addGestureRecognizer:tap];
        
        selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 39 - 300,SCREEN_WIDTH, 300) style:UITableViewStylePlain];
        //        selectTableView.backgroundColor = RGBCOLOR(238, 238, 238);
        selectTableView.delegate = self;
        selectTableView.dataSource = self;
        selectTableView.layer.borderColor = Cell_sepLineColor.CGColor;
        selectTableView.layer.borderWidth = 1;
        [self.view insertSubview:selectTableView belowSubview:topView];
        
        [self hiddenSelectView:YES];
    }
    
    commodityArray = [NSMutableArray array];
    currentpage = 0;
    orderString = NULL;
    orderTypeString = @"desc";
    [self requestGetCommodityList];
    [self requestGetComtermList];
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

-(void)cancelSelect {
    [self hiddenSelectView:YES];
}

-(void)hiddenSelectView:(BOOL)hidden {
    [UIView animateWithDuration:SelectView_Duration animations:^{
        if (hidden) {
            selectBgView.alpha = 0.0;
            selectTableView.frame = CGRectMake(0, 39 - 300, SCREEN_WIDTH, 300);
        }
        else {
            selectBgView.alpha = 0.3;
            selectTableView.frame = CGRectMake(0, 103, SCREEN_WIDTH, 300);
        }
    }];
} 


-(void) toSearch {  //搜索商品列表
    MailSearchVC *searchVC = [[MailSearchVC alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}

-(void) toFilter {      //筛选项目
    if (selectBgView.alpha > 0) {
        [self hiddenSelectView:YES];
    } else {
        [self hiddenSelectView:NO];
    }
}

- (IBAction)levelAction:(id)sender {
    orderString = @"starLevel";     //按星级排序
    if (xingjiBtn.selected) {
        xingjiBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        xingjiBtn.selected = YES;
        orderTypeString = @"asc";   //升序
    }
    sortBtn.selected = NO;
    priceBtn.selected = NO;
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}
- (IBAction)saleAction:(id)sender {
    xingjiBtn.selected = NO;
    orderString = @"salesVolume";     //按销量排序
    if (sortBtn.selected) {
        sortBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        sortBtn.selected = YES;
        orderTypeString = @"asc";   //升序
    }
    priceBtn.selected = NO;
    currentpage = 0;
    [commodityArray removeAllObjects];
    [self requestGetCommodityList];
}
- (IBAction)valueAction:(id)sender {
    xingjiBtn.selected = NO;
    sortBtn.selected = NO;
    
    orderString = @"discount";     //按价格排序
    if (priceBtn.selected) {
        priceBtn.selected = NO;
        orderTypeString = @"desc";   //降序
    }
    else {
        priceBtn.selected = YES;
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
        return comtermAry.count + 1;
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
        UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
        selectedBGView.backgroundColor = RGBCOLOR(246, 246, 246);
        cell.selectedBackgroundView = selectedBGView;
//        cell.selectedBackgroundView.backgroundColor = RGBCOLOR(246, 246, 246);
        if (indexPath.row == comtermAry.count) {
            cell.textLabel.text = @"全部";
        } else {
            NSDictionary *dic = comtermAry[indexPath.row];
            cell.textLabel.text = dic[@"name"];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return  cell;
    }
    else {
        CommodityListCell *cell = (CommodityListCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (commodityArray.count > 0) {
            NSDictionary *dic = commodityArray [indexPath.section];
            [cell.goodsIM sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.goodsNameL.text = dic [@"name"];
    //        cell.baokuanL.text =
    //        cell.tuijianL.text =
    //        cell.zhekouL.text =
            cell.pingxingView.rate = [dic [@"starLevel"] floatValue] / 2;
            cell.xiaoliangL.text = [NSString stringWithFormat:@"月销%@单",dic [@"salesVolume"]];
            if ([dic[@"integral"] intValue] > 0) {
                cell.jifenL.text = [NSString stringWithFormat:@"%@大卡",dic[@"integral"]];
            } else {
                cell.jifenL.text = @"该优惠商品不累计积分";
            }
            NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic[@"discount"] intValue] > 0) {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"discount"]];
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                    cell.zhekouL.hidden = NO;
                } else {
                    cell.moneyL.text = [NSString stringWithFormat:@"￥%@",dic[@"price"]];
                    cell.costPriceStrikeL.text = @"";
                    cell.zhekouL.hidden = YES;
                }

                cell.yunfeiL.text = [NSString stringWithFormat:@"配送费%@元",dic[@"shippingFee"]];
            }
            else {
                if ([dic[@"discount"] intValue] > 0) {
                    cell.moneyL.text = @"￥--";
                    cell.costPriceStrikeL.text = @"￥--";
                    cell.zhekouL.hidden = NO;
                } else {
                    cell.moneyL.text = @"￥--";
                    cell.costPriceStrikeL.text = @"";
                    cell.zhekouL.hidden = YES;
                }
                cell.yunfeiL.text = @"配送费--元";
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == selectTableView) {
        if (indexPath.row == comtermAry.count) {
            commodityTermId = @"";
        } else {
            NSDictionary *dic = comtermAry[indexPath.row];
            commodityTermId = dic[@"id"];
        }
        [self cancelSelect];
        currentpage = 0;
        [commodityArray removeAllObjects];
        [self requestGetCommodityList];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.categoryId,@"categoryId",[NSNumber numberWithInt:currentpage],@"pageNo",STRING_Nil(commodityTermId),@"commodityTermId",orderString,@"order",orderTypeString,@"orderType", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CommodityList) delegate:nil params:pram info:infoDic];
}

-(void)requestGetComtermList { //获取所有项目列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetComtermList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetComtermList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.categoryId,@"categoryId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(GetComtermList) delegate:nil params:pram info:infoDic];
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
        NSLog(@"CommodityList: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            if ([responseObject[@"data"] count] == 0) {
                _networkConditionHUD.labelText = @"已没有更多产品";
                [_networkConditionHUD show:YES];
                [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            }
            [commodityArray addObjectsFromArray:responseObject [@"data"]];
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:GetComtermList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetComtermList object:nil];
        NSLog(@"GetComtermList: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            comtermAry = responseObject [@"data"];
            [selectTableView reloadData];
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
