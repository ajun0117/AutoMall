//
//  MallVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/1.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MallVC.h"
#import "MailSearchVC.h"
#import "CommodityListVC.h"
#import "MXScrollView.h"
#import "MailGoodsCell.h"
#import "WRNavigationBar.h"
#import "CommodityListVC.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
static CGFloat const scrollViewHeight = 220;
#define Interval_Hobby  5   //标签之间的间隔
#define Space_Hobby     12  //标签超出文本的宽度
#define NAVBAR_COLORCHANGE_POINT (scrollViewHeight - NAV_HEIGHT)
#define NAV_HEIGHT 64

#define Head_ScrollView_Height      180
#define Head_PageControl_Width     80
#define Head_PageControl_Height     30
#define Head_button_Width           40
#define Head_button_Height          60


@interface MallVC () <MXScrollViewDelegate,UIScrollViewDelegate>
{
    MXImageScrollView *scroll;
    NSInteger allCount; //轮播图总数
    CALayer *_layer;
    NSInteger _cnt;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *categoryArray;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) UIScrollView *typeScrollView; //分类
@property (nonatomic, strong) UIPageControl *typePageControl;

@end

@implementation MallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    self.title = @"商城";
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailGoodsCell" bundle:nil] forCellReuseIdentifier:@"mailGoodsCell"];
    
    allCount = 3;
    scroll = [[MXImageScrollView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, scrollViewHeight) rootTableView:self.myTableView];
    scroll.delegate = self;
    scroll.images = @[[UIImage imageNamed:@"timg-1"],
                      [UIImage imageNamed:@"timg-2"],
                      [UIImage imageNamed:@"timg-1"]];
    
    [scroll setTapImageHandle:^(NSInteger index) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[NSString
                                                                     stringWithFormat:@"你点击了%ld张图片", index]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
    }];
    
    [scroll setDidScrollImageViewAtIndexHandle:^(NSInteger index) {
        NSLog(@"滑动到了第%ld页", index);
    }];
    
    self.typeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Head_ScrollView_Height)];
    self.typeScrollView.backgroundColor = [UIColor whiteColor];
    self.typeScrollView.pagingEnabled = YES;
    self.typeScrollView.showsHorizontalScrollIndicator = NO;
    self.typeScrollView.delegate = self;
    
    self.typePageControl = [[UIPageControl alloc] init];
    self.typePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.typePageControl.currentPageIndicatorTintColor = RGBCOLOR(229, 24, 35);
    
    categoryArray = [[NSMutableArray alloc] init];
    
    [self requestGetComCategoryList];   //请求分类数据
}

//-(void) viewDidAppear:(BOOL)animated {
//    NSArray *arr = @[
//                     @{@"menu_subtitle":@"分类1"},@{@"menu_subtitle":@"分类2"},
//                     @{@"menu_subtitle":@"分类23"},@{@"menu_subtitle":@"分类4"},
//                     @{@"menu_subtitle":@"分类5"},@{@"menu_subtitle":@"分类6"},
//                     @{@"menu_subtitle":@"分类7"},@{@"menu_subtitle":@"分类8"},
//                     @{@"menu_subtitle":@"分类9"},@{@"menu_subtitle":@"分类10"},
//                     @{@"menu_subtitle":@"分类11"},@{@"menu_subtitle":@"分类12"},
//                     ];
//    [self initHeadScrollViewWithArray:arr];
//}

-(void) toSearch {  //搜索车辆保养记录
//    MailSearchVC *searchVC = [[MailSearchVC alloc] init];
//    searchVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:searchVC animated:YES];
    
    CommodityListVC *listVC = [[CommodityListVC alloc] init];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.myTableView) {
#warning 想拉伸必须实现此方法
        [scroll stretchingSubviews];
        
        CGFloat offsetY = scrollView.contentOffset.y;
        NSLog(@"offsetY: %f",offsetY);
        if ((offsetY + 220) >= 156)
        {
            //        CGFloat alpha = (offsetY + 220 - NAVBAR_COLORCHANGE_POINT) / NAV_HEIGHT;
            CGFloat alpha = (offsetY + 220) / 156;
            [self wr_setNavBarBackgroundAlpha:1];
            [self wr_setNavBarTintColor:[RGBCOLOR(129, 129, 129) colorWithAlphaComponent:alpha]];
            [self wr_setNavBarTitleColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
            [self wr_setStatusBarStyle:UIStatusBarStyleDefault];
//            self.title = @"商城";
        }
        else
        {
            [self wr_setNavBarBackgroundAlpha:0];
            [self wr_setNavBarTintColor:[UIColor whiteColor]];
            [self wr_setNavBarTitleColor:[UIColor clearColor]];
            [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
//            self.title = @"商城";
        }
    }
}

#pragma mark - MXScrollView delegate
- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForLeftAccessoryViewAtIndex:(NSInteger)index {
    //    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,
    //                                                                               scrollViewHeight - 40,
    //                                                                               30,
    //                                                                               30)];
    //    leftImageView.image = [UIImage imageNamed:@"house"];
    //    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollViewHeight - 50, 200,50)];
    //    bgView.backgroundColor = [UIColor clearColor];
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200,30)];
    //    view.backgroundColor = [UIColor blackColor];
    //    view.alpha = 0.3;
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    //    label.backgroundColor = [UIColor clearColor];
    //    label.textColor = [UIColor whiteColor];
    //    label.font = [UIFont systemFontOfSize:15];
    //    label.text = @"新闻标题 新闻标题";
    //    [bgView addSubview:view];
    //    [bgView addSubview:label];
    //    return bgView;
    return nil;
}

- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForRightAccessoryViewAtIndex:(NSInteger)index {
    //    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - 40,
    //                                                                                scrollViewHeight - 40,
    //                                                                                30,
    //                                                                                30)];
    //    rightImageView.image = [UIImage imageNamed:@"island"];
    //    return rightImageView;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(Screen_Width - 50, scrollViewHeight - 50, 30,50)];
    bgView.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.3;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *num = [NSString stringWithFormat:@"%ld/%ld",(long)index+1,allCount];
    label.text = num;
    [bgView addSubview:view];
    [bgView addSubview:label];
    return bgView;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView leftAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView rightAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        MailGoodsCell *cell = (MailGoodsCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        NSLog(@"%f",height);
        return height + 1;
    }
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    InformationCell *cell = (InformationCell *)[tableView dequeueReusableCellWithIdentifier:@"inforCell"];
//    NSDictionary *dic = inforArray[indexPath.section];
//    //    cell.zixunIMG.image = IMG(@"personalCenter");
//    [cell.zixunIMG sd_setImageWithURL:[NSURL URLWithString:ImagePrefixURL(dic[@"image"])] placeholderImage: IMG(@"personalCenter")];
//    cell.zixunTitle.text = STRING(dic[@"title"]);
//    cell.zixunContent.text = STRING(dic[@"content"]);
//    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;

    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.typeScrollView];
        [cell.contentView addSubview:self.typePageControl];
        self.typePageControl.frame = CGRectMake(0, Head_ScrollView_Height - 30, cell.contentView.bounds.size.width, 30);
        return cell;
    }
    else if (indexPath.section == 1) {
        MailGoodsCell *cell = (MailGoodsCell *)[tableView dequeueReusableCellWithIdentifier:@"mailGoodsCell"];
        cell.bgViewConsH.constant = (Screen_Width - 8*3)/2 + 50;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
        //    cell.nameL.text = @"壳牌灰喜力";
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.typeScrollView) {
        self.typePageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

#pragma mark - 顶部商品类型视图
-(void)initHeadScrollViewWithArray:(NSArray *)dataArray {
    
    int page = (int)  (([dataArray count] - 1) / 8 + 1); //总页数
    if (page > 1) {
        self.typePageControl.hidden = NO;
    }
    else {
        self.typePageControl.hidden = YES;
    }
    self.typePageControl.numberOfPages = page;
    
    self.typeScrollView.contentSize = CGSizeMake(page * SCREEN_WIDTH, Head_ScrollView_Height);
    
    int margin = (SCREEN_WIDTH - Head_button_Width * 4 - 15 * 2) / 3; //按钮列间距
    int rowMargin = Head_ScrollView_Height - Head_PageControl_Height - Head_button_Height * 2 - 15; //按钮行间距
    
    int p = 0;
    for (int a = 0; a < page; ++ a) {
        for (int m = 0; m < 2; ++ m) {
            for (int n = 0; n < 4; ++ n) {
                if (p < [dataArray count]) {
                    NSDictionary *dic = [dataArray objectAtIndex:p];
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(15 + n * (40 + margin) + a * SCREEN_WIDTH , 10 + m * (60 + rowMargin), Head_button_Width, Head_button_Height);
                    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, Head_button_Height - Head_button_Width, 0);
                    button.tag = p + 1000;
//                    [button sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"icon_url"]] forState:UIControlStateNormal placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    [button setImage:IMG(@"add_carInfo") forState:UIControlStateNormal];
                    
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    UILabel *subtitleL = [[UILabel alloc] initWithFrame:CGRectMake(-10, 40, 60, 20)];
                    subtitleL.textAlignment = NSTextAlignmentCenter;
                    subtitleL.font = [UIFont systemFontOfSize:13];
                    subtitleL.text = [dic objectForKey:@"name"];
                    [button addSubview:subtitleL];
                    
                    [button addTarget:self action:@selector(buttontouchAction:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [self.typeScrollView addSubview:button];
                }
                p ++;
            }
        }
    }
}

-(void)buttontouchAction:(UIButton *)sender {
//    NSLog(@"sender.tag: %ld",(long)sender.tag);
//    NSDictionary *dic = [merchantTypeArray objectAtIndex:sender.tag - 1000];
//    //    NSLog(@"sender.icon_url: %@",[dic objectForKey:@"icon_url"]);
//    NSLog(@"menu_code: %@",[dic objectForKey:@"menu_code"]);
    
    //    self.tabBarController.selectedIndex = 1;
    //    UINavigationController *nav = (UINavigationController *)self.tabBarController.selectedViewController;
    //    ShopListViewController *listVC = (ShopListViewController *)nav.visibleViewController;
    //    listVC.menu_subtitle = [dic objectForKey:@"menu_subtitle"];
    //    listVC.menu_code = [dic objectForKey:@"menu_code"];
    //    listVC.typeID = dic [@"menu_code"];
    //    [listVC.typeBtn setTitle:[dic objectForKey:@"menu_subtitle"] forState:UIControlStateNormal];
    
//    ShopListVC *listVC = [[ShopListVC alloc] init];
//    listVC.menu_subtitle = [dic objectForKey:@"menu_subtitle"];
//    listVC.menu_code = [dic objectForKey:@"menu_code"];
//    listVC.typeID = dic [@"menu_code"];
//    [listVC.typeBtn setTitle:[dic objectForKey:@"menu_subtitle"] forState:UIControlStateNormal];
//    listVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:listVC animated:YES];
    
    CommodityListVC *listVC = [[CommodityListVC alloc] init];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
    
}


-(void)requestGetComCategoryList { //获取分类列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ComCategoryList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ComCategoryList, @"op", nil];
    
    //    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"page",@"10",@"limit", nil];
    //    NSLog(@"pram: %@",pram);
    //    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MessageList) delegate:nil params:pram info:infoDic];
    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(ComCategoryList) delegate:nil params:nil info:infoDic];
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
    if ([notification.name isEqualToString:ComCategoryList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ComCategoryList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [categoryArray addObjectsFromArray:responseObject [@"data"]];
            [self initHeadScrollViewWithArray:categoryArray];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
//    if ([notification.name isEqualToString:CourseList]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:CourseList object:nil];
//        NSLog(@"_responseObject: %@",responseObject);
//        
//        if ([responseObject[@"success"] isEqualToString:@"y"]) {
//            [inforArray addObjectsFromArray:responseObject [@"data"]];
//            [self.myTableView reloadData];
//        }
//        else {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        }
//        [self.myTableView reloadData];
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
