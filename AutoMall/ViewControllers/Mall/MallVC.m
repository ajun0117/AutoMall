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
#import "CommodityListVC.h"
#import "CommodityDetailVC.h"
#import "WebViewController.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
static CGFloat const scrollViewHeight = 220;
#define Interval_Hobby  5   //标签之间的间隔
#define Space_Hobby     12  //标签超出文本的宽度
#define NAVBAR_COLORCHANGE_POINT (scrollViewHeight - NAV_HEIGHT)
#define NAV_HEIGHT 64

#define Head_ScrollView_Height      175
#define Head_PageControl_Width     80
#define Head_PageControl_Height     30
#define Head_button_Width           45
#define Head_button_Height          60


@interface MallVC () <MXScrollViewDelegate,UIScrollViewDelegate>
{
    MXImageScrollView *scroll;
    CALayer *_layer;
    NSInteger _cnt;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSArray *categoryArray;
    NSArray *adArray;   //广告数组
    NSArray *tjListAry; //推荐商品列表
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
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
//    最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    }
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -6;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 28, 28);
    [searchBtn setImage:[UIImage imageNamed:@"search_carInfo"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailGoodsCell" bundle:nil] forCellReuseIdentifier:@"mailGoodsCell"];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    scroll = [[MXImageScrollView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, scrollViewHeight) rootTableView:self.myTableView];
    scroll.hasNavigationBar = NO;
    scroll.showPageIndicator = NO;
    scroll.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [scroll setTapImageHandle:^(NSInteger index) {
        [weakSelf toWebView:index];
    }];
    
    [scroll setDidScrollImageViewAtIndexHandle:^(NSInteger index) {
//        NSLog(@"滑动到了第%ld页", index);
    }];
    
    self.typeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Head_ScrollView_Height)];
    self.typeScrollView.backgroundColor = [UIColor whiteColor];
    self.typeScrollView.pagingEnabled = YES;
    self.typeScrollView.showsHorizontalScrollIndicator = NO;
    self.typeScrollView.delegate = self;
    
    self.typePageControl = [[UIPageControl alloc] init];
    self.typePageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.typePageControl.currentPageIndicatorTintColor = RGBCOLOR(229, 24, 35);
    
    [self requsetAdvertList];   //请求广告列表
    [self requestGetComCategoryList];   //请求分类数据
//    [self requestPostCommoditytjList];  //请求推荐商品列表
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
    
//    [self requsetAdvertList];   //请求广告列表
//    [self requestGetComCategoryList];   //请求分类数据
    [self requestPostCommoditytjList];  //请求推荐商品列表
    
    //解决ios11下导航栏不透明的bug
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - 点击进入webView
-(void)toWebView:(NSInteger)index {
    NSDictionary *dic = adArray[index];
    if ([dic[@"resourceType"] intValue] == 1) {
        NSLog(@"点击了第%ld页，resourceId为%@", index,dic[@"resourceId"]);
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
        detailVC.commodityId = dic[@"resourceId"];
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else {
        WebViewController *webVC = [[WebViewController alloc] init];
        webVC.webUrlStr = dic[@"targetUrl"];
        webVC.titleStr = @"广告详情";
        webVC.canShare = NO;
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }
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

-(void) toSearch {  //搜索商品列表
    MailSearchVC *searchVC = [[MailSearchVC alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
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
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(Screen_Width - 50, scrollViewHeight - 50, 30,50)];
//    bgView.backgroundColor = [UIColor clearColor];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
//    view.backgroundColor = [UIColor blackColor];
//    view.alpha = 0.3;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:15];
//    label.textAlignment = NSTextAlignmentCenter;
//    NSString *num = [NSString stringWithFormat:@"%ld/%ld",(long)index+1,allCount];
//    label.text = num;
//    [bgView addSubview:view];
//    [bgView addSubview:label];
//    return bgView;
    return nil;
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
    return Head_ScrollView_Height;
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
//    [cell.zixunIMG sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] placeholderImage: IMG(@"personalCenter")];
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
        
//        cell.bgViewConsH.constant = (Screen_Width - 8*3)/2 + 50;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString *mobileUserType = [[GlobalSetting shareGlobalSettingInstance] mobileUserType];
        if (tjListAry.count >= 4) {
            NSDictionary *dic1 = tjListAry[0];
            [cell.img1 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic1[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name1.text = dic1[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                NSLog(@"discount： %@,name: %@",dic1[@"discount"],dic1[@"name"]);
                 if ([dic1[@"discount"] floatValue] > 0) {
                    cell.money1.text = [NSString stringWithFormat:@"￥%@",dic1[@"discount"]];
                    cell.yuan1.text = [NSString stringWithFormat:@"￥%@",dic1[@"price"]];
                 } else {
                     cell.money1.text = [NSString stringWithFormat:@"￥%@",dic1[@"price"]];
                     cell.yuan1.text = @"";
                 }
            }
            cell.btn1.tag = 101;
            [cell.btn1 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic2 = tjListAry[1];
            [cell.img2 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic2[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name2.text = dic2[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic2[@"discount"] floatValue] > 0) {
                    cell.money2.text = [NSString stringWithFormat:@"￥%@",dic2[@"discount"]];
                    cell.yuan2.text = [NSString stringWithFormat:@"￥%@",dic2[@"price"]];
                } else {
                    cell.money2.text = [NSString stringWithFormat:@"￥%@",dic2[@"price"]];
                    cell.yuan2.text = @"";
                }
            }
            cell.btn2.tag = 102;
            [cell.btn2 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic3 = tjListAry[2];
            [cell.img3 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic3[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name3.text = dic3[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic3[@"discount"] floatValue] > 0) {
                    cell.money3.text = [NSString stringWithFormat:@"￥%@",dic3[@"discount"]];
                    cell.yuan3.text = [NSString stringWithFormat:@"￥%@",dic3[@"price"]];
                } else {
                    cell.money3.text = [NSString stringWithFormat:@"￥%@",dic3[@"price"]];
                    cell.yuan3.text = @"";
                }
            }
            cell.btn3.tag = 103;
            [cell.btn3 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic4 = tjListAry[3];
            [cell.img4 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic4[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name4.text = dic4[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic4[@"discount"] floatValue] > 0) {
                    cell.money4.text = [NSString stringWithFormat:@"￥%@",dic4[@"discount"]];
                    cell.yuan4.text = [NSString stringWithFormat:@"￥%@",dic4[@"price"]];
                } else {
                    cell.money4.text = [NSString stringWithFormat:@"￥%@",dic4[@"price"]];
                    cell.yuan4.text = @"";
                }
            }
            cell.btn4.tag = 104;
            [cell.btn4 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic5 = tjListAry[4];
            [cell.img5 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic5[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name5.text = dic5[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic5[@"discount"] floatValue] > 0) {
                    cell.money5.text = [NSString stringWithFormat:@"￥%@",dic5[@"discount"]];
                    cell.yuan5.text = [NSString stringWithFormat:@"￥%@",dic5[@"price"]];
                } else {
                    cell.money5.text = [NSString stringWithFormat:@"￥%@",dic5[@"price"]];
                    cell.yuan5.text = @"";
                }
            }
            cell.btn5.tag = 105;
            [cell.btn5 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic6 = tjListAry[5];
            [cell.img6 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic6[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name6.text = dic6[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic6[@"discount"] floatValue] > 0) {
                    cell.money6.text = [NSString stringWithFormat:@"￥%@",dic6[@"discount"]];
                    cell.yuan6.text = [NSString stringWithFormat:@"￥%@",dic6[@"price"]];
                } else {
                    cell.money6.text = [NSString stringWithFormat:@"￥%@",dic6[@"price"]];
                    cell.yuan6.text = @"";
                }
            }
            cell.btn6.tag = 106;
            [cell.btn6 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic7 = tjListAry[6];
            [cell.img7 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic7[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name7.text = dic7[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic7[@"discount"] floatValue] > 0) {
                    cell.money7.text = [NSString stringWithFormat:@"￥%@",dic7[@"discount"]];
                    cell.yuan7.text = [NSString stringWithFormat:@"￥%@",dic7[@"price"]];
                } else {
                    cell.money7.text = [NSString stringWithFormat:@"￥%@",dic7[@"price"]];
                    cell.yuan7.text = @"";
                }
            }
            cell.btn7.tag = 107;
            [cell.btn7 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic8 = tjListAry[7];
            [cell.img8 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic8[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name8.text = dic8[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic8[@"discount"] floatValue] > 0) {
                    cell.money8.text = [NSString stringWithFormat:@"￥%@",dic8[@"discount"]];
                    cell.yuan8.text = [NSString stringWithFormat:@"￥%@",dic8[@"price"]];
                } else {
                    cell.money8.text = [NSString stringWithFormat:@"￥%@",dic8[@"price"]];
                    cell.yuan8.text = @"";
                }
            }
            cell.btn8.tag = 108;
            [cell.btn8 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic9 = tjListAry[8];
            [cell.img9 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic9[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name9.text = dic9[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic9[@"discount"] floatValue] > 0) {
                    cell.money9.text = [NSString stringWithFormat:@"￥%@",dic9[@"discount"]];
                    cell.yuan9.text = [NSString stringWithFormat:@"￥%@",dic9[@"price"]];
                } else {
                    cell.money9.text = [NSString stringWithFormat:@"￥%@",dic9[@"price"]];
                    cell.yuan9.text = @"";
                }
            }
            cell.btn9.tag = 109;
            [cell.btn9 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *dic10 = tjListAry[9];
            [cell.img10 sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic10[@"image"])] placeholderImage:IMG(@"placeholderPictureSquare")];
            cell.name10.text = dic10[@"name"];
            if ([mobileUserType isEqualToString:@"1"]) {    //老板
                if ([dic10[@"discount"] floatValue] > 0) {
                    cell.money10.text = [NSString stringWithFormat:@"￥%@",dic10[@"discount"]];
                    cell.yuan10.text = [NSString stringWithFormat:@"￥%@",dic10[@"price"]];
                } else {
                    cell.money10.text = [NSString stringWithFormat:@"￥%@",dic10[@"price"]];
                    cell.yuan10.text = @"";
                }
            }
            cell.btn10.tag = 110;
            [cell.btn10 addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
        }
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
    int margin = (SCREEN_WIDTH - Head_button_Width * 4 - 8 * 2) / 3; //按钮列间距
    int rowMargin = Head_ScrollView_Height - Head_PageControl_Height - Head_button_Height * 2 - 8; //按钮行间距
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
                    [button sd_setImageWithURL:[NSURL URLWithString:UrlPrefix(dic[@"image"])] forState:UIControlStateNormal placeholderImage:IMG(@"placeholderPictureSquare")];
//                    [button setImage:IMG(@"add_carInfo") forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    UILabel *subtitleL = [[UILabel alloc] initWithFrame:CGRectMake(-5, 44, 60, 20)];
                    subtitleL.textAlignment = NSTextAlignmentCenter;
                    subtitleL.font = [UIFont systemFontOfSize:13];
                    subtitleL.text = dic[@"name"];
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
    int p = (int)sender.tag - 1000;
    NSDictionary *dic = [categoryArray objectAtIndex:p];
    CommodityListVC *listVC = [[CommodityListVC alloc] init];
    listVC.categoryId = dic [@"id"];
    listVC.categoryName = dic [@"name"];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

-(void)toDetail:(UIButton *)btn {
    CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
    detailVC.commodityId = tjListAry[btn.tag - 101][@"id"];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - 网络请求
-(void)requsetAdvertList {      //获取广告列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:AdvertList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:AdvertList, @"op", nil];
//    [[DataRequest sharedDataRequest] getDataWithUrl:UrlPrefix(AdvertList) delegate:nil params:nil info:infoDic];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"pageNo",@"30",@"pageSize", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(AdvertList) delegate:nil params:pram info:infoDic];
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

-(void)requestPostCommoditytjList { //推荐列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CommoditytjList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CommoditytjList, @"op", nil];
//    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:commodityTermId,@"commodityTermId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(CommoditytjList) delegate:nil params:nil info:infoDic];
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
            categoryArray = responseObject [@"data"];
            [self initHeadScrollViewWithArray:categoryArray];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    if ([notification.name isEqualToString:AdvertList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AdvertList object:nil];
        NSLog(@"_responseObject: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            adArray = responseObject[@"data"];
            if (adArray.count > 0) {
                NSMutableArray *urlAry = [NSMutableArray array];
                for (NSDictionary *dic in adArray) {
                    [urlAry addObject:UrlPrefix(dic[@"image"])];
                }
                scroll.images = urlAry;
            }
            else {
                scroll.images = @[@"http://hengliantech.com/carupkeep/uploads/2018/01/94be1467-83e9-405c-8163-dae26911e8d2.jpg"];
            }
            
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    
    if ([notification.name isEqualToString:CommoditytjList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CommoditytjList object:nil];
        NSLog(@"TjList_responseObject: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            tjListAry = responseObject [@"data"];
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
