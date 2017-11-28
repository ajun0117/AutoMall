//
//  UpkeepStatementVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/8.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepStatementVC.h"
#import "ZFChart.h"
#import "NSDate+Formatter.h"

#define LL_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define LL_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define Iphone6Scale(x) ((x) * LL_SCREEN_WIDTH / 375.0f)

#define HeaderViewHeight 30
#define WeekViewHeight 40

#define SelectView_Duration    0.3  //筛选视图动画时间

@interface UpkeepStatementVC () <UICollectionViewDelegate, UICollectionViewDataSource,ZFGenericChartDataSource, ZFBarChartDelegate,UITableViewDelegate,UITableViewDataSource>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    UIButton *dateBtn;  //选择日期按钮
//    UIPickerView *typePicker;  //报表类别选择
    NSArray *typeArray;
    UIView *selectBgView;
    UITableView *selectTableView;
    UIButton *titleBtn;
    NSString *itemStr;     //需要统计的项目
    NSString *toStr;       //统计的方式
}

@property (nonatomic, strong) ZFBarChart * barChart;

@property (nonatomic, assign) CGFloat height;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIButton *dayBtn;
@property (strong, nonatomic) IBOutlet UIView *dayView;
@property (strong, nonatomic) IBOutlet UIButton *weekBtn;
@property (strong, nonatomic) IBOutlet UIView *weekView;
@property (strong, nonatomic) IBOutlet UIButton *monthBtn;
@property (strong, nonatomic) IBOutlet UIView *monthView;
@property (strong, nonatomic) IBOutlet UIButton *yearBtn;
@property (strong, nonatomic) IBOutlet UIView *yearView;

@property (strong, nonatomic) IBOutlet UIView *calendarBgView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *dayModelArray;
@property (strong, nonatomic) IBOutlet UILabel *dateL;
@property (strong, nonatomic) NSDate *tempDate;
@property (strong, nonatomic) NSDate *selectDate;       //选中的日期

@end

@implementation UpkeepStatementVC

- (void)setUp{
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
        //首次进入控制器为横屏时
        _height = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT * 0.5;
        
    }else{
        //首次进入控制器为竖屏时
        _height = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @" 服务项目统计";
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 175, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.frame = CGRectMake(0, 2, 175, 40);
    [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleBtn.titleLabel.minimumFontSize = 10;
    [titleBtn setTitle:@"检查台次" forState:UIControlStateNormal];
    [titleBtn setImage:[UIImage imageNamed:@"subject_expand_n"] forState:UIControlStateNormal];
    [titleBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected];
    [titleBtn setImage:[UIImage imageNamed:@"subject_collapse_n"] forState:UIControlStateSelected | UIControlStateHighlighted];
    NSString *defaultStr = @"检查台次";
    CGSize textSize = [defaultStr sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    [titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 50, 0, 0)];
//    [titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [titleBtn addTarget:self action:@selector(toSelect:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:titleBtn];
    
    self.navigationItem.titleView = view;
    
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    typeArray = @[@{@"title":@"检查台次",@"unit":@"台次"},@{@"title":@"成交金额",@"unit":@"元"},@{@"title":@"客单价",@"unit":@"元"},@{@"title":@"技师单数",@"unit":@"台次"},@{@"title":@"服务项目金额",@"unit":@"元"},@{@"title":@"服务项目台次",@"unit":@"台次"},@{@"title":@"技师的成交金额",@"unit":@"元"},@{@"title":@"技师的客单价",@"unit":@"元"}];
//    typePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 216)];
//    typePicker.delegate = self;
//    typePicker.dataSource = self;
    
    dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dateBtn.frame = CGRectMake(0, 0, 80, 44);
    //    searchBtn.contentMode = UIViewContentModeRight;
    dateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [dateBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    dateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [dateBtn setTitle:@"2017-09-09" forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(toSelectDate) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:dateBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
    [self.calendarBgView addSubview:self.collectionView];
    self.tempDate = [NSDate date];
    self.dateL.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
    
    [self setUp];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.barChart = [[ZFBarChart alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, _height)];
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.isShadow = NO;
//    self.barChart.topicLabel.text = @"xx汽修店美容保养项目报表";
    self.barChart.topicLabel.text = @"";
    self.barChart.unit = @"台次";
    //    self.barChart.isAnimated = NO;
    //    self.barChart.isResetAxisLineMinValue = YES;
    self.barChart.isResetAxisLineMaxValue = YES;
    //    self.barChart.isShowAxisLineValue = NO;
    //    self.barChart.valueLabelPattern = kPopoverLabelPatternBlank;
    //    self.barChart.isShowXLineSeparate = YES;
    //    self.barChart.isShowYLineSeparate = YES;
    //    self.barChart.topicLabel.textColor = ZFWhite;
    //    self.barChart.unitColor = ZFWhite;
    //    self.barChart.xAxisColor = ZFWhite;
    //    self.barChart.yAxisColor = ZFWhite;
    //    self.barChart.xAxisColor = ZFClear;
    //    self.barChart.yAxisColor = ZFClear;
    //    self.barChart.axisLineNameColor = ZFWhite;
    //    self.barChart.axisLineValueColor = ZFWhite;
    //    self.barChart.backgroundColor = ZFPurple;
    //    self.barChart.isShowAxisArrows = NO;
    
//    [self.view addSubview:self.barChart];
    [self.view insertSubview:self.barChart belowSubview:self.topView];
    [self.barChart strokePath];
    
    if (! selectBgView) {
        selectBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        selectBgView.backgroundColor = [UIColor blackColor];
        selectBgView.alpha = 0.0;
        [self.view insertSubview:selectBgView belowSubview:self.topView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelect)];
        [selectBgView addGestureRecognizer:tap];
        
        selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, - 350,SCREEN_WIDTH, 350) style:UITableViewStylePlain];
        //        selectTableView.backgroundColor = RGBCOLOR(238, 238, 238);
        selectTableView.delegate = self;
        selectTableView.dataSource = self;
        selectTableView.layer.borderColor = Cell_sepLineColor.CGColor;
        selectTableView.layer.borderWidth = 1;
        [self.view insertSubview:selectTableView aboveSubview:self.topView];
        
        [self hiddenSelectView:YES];
    }
    
    self.selectDate = [NSDate date];
    itemStr = @"1";
    toStr = @"2";
    [self requestPostReportSum];
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
    titleBtn.selected = NO;
    [self hiddenSelectView:YES];
}

-(void)hiddenSelectView:(BOOL)hidden {
    [UIView animateWithDuration:SelectView_Duration animations:^{
        if (hidden) {
            selectBgView.alpha = 0.0;
            selectTableView.frame = CGRectMake(0, - 350, SCREEN_WIDTH, 350);
        }
        else {
            selectBgView.alpha = 0.3;
            selectTableView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 350);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return typeArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBGView.backgroundColor = RGBCOLOR(246, 246, 246);
    cell.selectedBackgroundView = selectedBGView;
    NSDictionary *dic = typeArray[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = typeArray[indexPath.row];
    [titleBtn setTitle:dic[@"title"] forState:UIControlStateNormal];
    NSString *defaultStr = dic[@"title"];
    CGSize textSize = [defaultStr sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    if (indexPath.row == 2) {
        [titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 66, 0, 0)];
    } else if (indexPath.row == 6) {
        [titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 40, 0, 0)];
    } else {
        [titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, textSize.width + 50, 0, 0)];
    }
    self.barChart.unit = dic[@"unit"];
    if ([dic[@"title"] isEqualToString:@"检查台次"]) {
        itemStr = @"1";
    }
    else if ([dic[@"title"] isEqualToString:@"成交金额"]) {
        itemStr = @"2";
    }
    else if ([dic[@"title"] isEqualToString:@"客单价"]) {
        itemStr = @"3";
    }
    else if ([dic[@"title"] isEqualToString:@"技师单数"]) {
        itemStr = @"41";
    }
    else if ([dic[@"title"] isEqualToString:@"技师的成交金额"]) {
        itemStr = @"42";
    }
    else if ([dic[@"title"] isEqualToString:@"技师的客单价"]) {
        itemStr = @"43";
    }
    else if ([dic[@"title"] isEqualToString:@"服务项目台次"]) {
        itemStr = @"51";
    }
    else if ([dic[@"title"] isEqualToString:@"服务项目金额"]) {
        itemStr = @"52";
    }
    [self requestPostReportSum];
//    [self.barChart strokePath];
    [self cancelSelect];
}

-(void) toSelect:(UIButton *)btn {
    if (selectBgView.alpha > 0) {
        titleBtn.selected = NO;
        [self hiddenSelectView:YES];
    } else {
        titleBtn.selected = YES;
        [self hiddenSelectView:NO];
    }
}

- (IBAction)dayAction:(id)sender {
    self.dayBtn.selected = YES;
    self.weekBtn.selected = NO;
    self.monthBtn.selected = NO;
    self.yearBtn.selected = NO;
    self.dayView.backgroundColor = RGBCOLOR(237, 28, 36);
    self.weekView.backgroundColor = [UIColor clearColor];
    self.monthView.backgroundColor = [UIColor clearColor];
    self.yearView.backgroundColor = [UIColor clearColor];
    toStr = @"1";
    [self requestPostReportSum];
}

- (IBAction)weekAction:(id)sender {
    self.dayBtn.selected = NO;
    self.weekBtn.selected = YES;
    self.monthBtn.selected = NO;
    self.yearBtn.selected = NO;
    self.dayView.backgroundColor = [UIColor clearColor];
    self.weekView.backgroundColor = RGBCOLOR(237, 28, 36);
    self.monthView.backgroundColor = [UIColor clearColor];
    self.yearView.backgroundColor = [UIColor clearColor];
    toStr = @"2";
    [self requestPostReportSum];
}

- (IBAction)monthAction:(id)sender {
    self.dayBtn.selected = NO;
    self.weekBtn.selected = NO;
    self.monthBtn.selected = YES;
    self.yearBtn.selected = NO;
    self.dayView.backgroundColor = [UIColor clearColor];
    self.weekView.backgroundColor = [UIColor clearColor];
    self.monthView.backgroundColor = RGBCOLOR(237, 28, 36);
    self.yearView.backgroundColor = [UIColor clearColor];
    toStr = @"3";
    [self requestPostReportSum];
}

- (IBAction)yearAction:(id)sender {
    self.dayBtn.selected = NO;
    self.weekBtn.selected = NO;
    self.monthBtn.selected = NO;
    self.yearBtn.selected = YES;
    self.dayView.backgroundColor = [UIColor clearColor];
    self.weekView.backgroundColor = [UIColor clearColor];
    self.monthView.backgroundColor = [UIColor clearColor];
    self.yearView.backgroundColor = RGBCOLOR(237, 28, 36);
    toStr = @"4";
    [self requestPostReportSum];
}

-(void)toSelectDate {
    if (self.selectDate) {
        [self getDataDayModel:self.selectDate];
    }
    
    if (self.calendarBgView.alpha) {
        [UIView animateWithDuration:0.1 animations:^{
            self.calendarBgView.alpha = 0;
        }];
    }
    else {
        [UIView animateWithDuration:0.1 animations:^{
            self.calendarBgView.alpha = 1;
        }];
    }
}

- (IBAction)lastMonth:(id)sender {
    self.tempDate = [self getLastMonth:self.tempDate];
    self.dateL.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
}

- (IBAction)nextMonth:(id)sender {
    self.tempDate = [self getNextMonth:self.tempDate];
    self.dateL.text = self.tempDate.yyyyMMByLineWithDate;
    [self getDataDayModel:self.tempDate];
}

- (void)getDataDayModel:(NSDate *)date{
    NSUInteger days = [self numberOfDaysInMonth:date];
    NSInteger week = [self startDayOfWeek:date];
    self.dayModelArray = [[NSMutableArray alloc] initWithCapacity:42];
    int day = 1;
    for (int i= 1; i<days+week; i++) {
        if (i<week) {
            [self.dayModelArray addObject:@""];
        }else{
            MonthModel *mon = [MonthModel new];
            mon.dayValue = day;
            NSDate *dayDate = [self dateOfDay:day];
            mon.dateValue = dayDate;
            if ([dayDate.yyyyMMddByLineWithDate isEqualToString:[NSDate date].yyyyMMddByLineWithDate]) {
                mon.isToDay = YES;
            }
            if ([dayDate.yyyyMMddByLineWithDate isEqualToString:self.selectDate.yyyyMMddByLineWithDate]) {
                mon.isSelectedDay = YES;
            }
            [self.dayModelArray addObject:mon];
            day++;
        }
    }
    [self.collectionView reloadData];
}



#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return @[@"123", @"256", @"300", @"283", @"490", @"236", @"123", @"256", @"300", @"283", @"490", @"236", @"123", @"256", @"300", @"283", @"490"];
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return @[@"汽油燃烧喷射系统润滑清洁", @"机油更换", @"轮胎更换", @"四轮动平衡", @"冷却液更换", @"节气门清洗", @"电瓶更换", @"内饰清洗", @"车辆清洗", @"火花塞更换", @"钣金/喷漆", @"火花塞更换", @"车辆清洗", @"车辆清洗", @"车辆清洗", @"车辆清洗", @"车辆清洗",];
}

- (NSArray *)colorArrayInGenericChart:(ZFGenericChart *)chart{
    return @[ZFMagenta];
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZFGenericChart *)chart{
    return 500;
}

//- (CGFloat)axisLineMinValueInGenericChart:(ZFGenericChart *)chart{
//    return 50;
//}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZFGenericChart *)chart{
    return 10;
}

//- (NSInteger)axisLineStartToDisplayValueAtIndex:(ZFGenericChart *)chart{
//    return -7;
//}

- (void)genericChartDidScroll:(UIScrollView *)scrollView{
    NSLog(@"当前偏移量 ------ %f", scrollView.contentOffset.x);
}

#pragma mark - ZFBarChartDelegate

//- (CGFloat)barWidthInBarChart:(ZFBarChart *)barChart{
//    return 40.f;
//}

//- (CGFloat)paddingForGroupsInBarChart:(ZFBarChart *)barChart{
//    return 40.f;
//}

//- (id)valueTextColorArrayInBarChart:(ZFGenericChart *)barChart{
//    return ZFBlue;
//}

- (NSArray *)gradientColorArrayInBarChart:(ZFBarChart *)barChart{
    ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
//    gradientAttribute.colors = @[(id)ZFRed.CGColor, (id)ZFWhite.CGColor];
    gradientAttribute.colors = @[(id)ZFColor(90, 177, 239, 1).CGColor, (id)ZFColor(90, 177, 239, 1).CGColor];
    gradientAttribute.locations = @[@(0.5), @(0.99)];
    
    return [NSArray arrayWithObjects:gradientAttribute, nil];
}

- (void)barChart:(ZFBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)barIndex);
    
    //可在此处进行bar被点击后的自身部分属性设置,可修改的属性查看ZFBar.h
    bar.barColor = ZFGold;
    bar.isAnimated = YES;
    //    bar.opacity = 0.5;
    [bar strokePath];
    
    //可将isShowAxisLineValue设置为NO，然后执行下句代码进行点击才显示数值
    //    popoverLabel.hidden = NO;
}

- (void)barChart:(ZFBarChart *)barChart didSelectPopoverLabelAtGroupIndex:(NSInteger)groupIndex labelIndex:(NSInteger)labelIndex popoverLabel:(ZFPopoverLabel *)popoverLabel{
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)labelIndex);
    
    //可在此处进行popoverLabel被点击后的自身部分属性设置
    //    popoverLabel.textColor = ZFSkyBlue;
    //    [popoverLabel strokePath];
}

#pragma mark - 横竖屏适配(若需要同时横屏,竖屏适配，则添加以下代码，反之不需添加)

/**
 *  PS：size为控制器self.view的size，若图表不是直接添加self.view上，则修改以下的frame值
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height - NAVIGATIONBAR_HEIGHT * 0.5);
    }else{
        self.barChart.frame = CGRectMake(0, 0, size.width, size.height + NAVIGATIONBAR_HEIGHT * 0.5);
    }
    
    [self.barChart strokePath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dayModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    cell.dayLabel.backgroundColor = [UIColor whiteColor];
    cell.dayLabel.textColor = [UIColor blackColor];
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        cell.monthModel = (MonthModel *)mon;
    }else{
        cell.dayLabel.text = @"";
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    CalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CalendarHeaderView" forIndexPath:indexPath];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    CalendarCell *cell = (CalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    id mon = self.dayModelArray[indexPath.row];
    if ([mon isKindOfClass:[MonthModel class]]) {
        self.selectDate = [(MonthModel *)mon dateValue];
        [dateBtn setTitle:[(MonthModel *)mon dateValue].yyyyMMddByLineWithDate forState:UIControlStateNormal];
        [UIView animateWithDuration:0.1 animations:^{
            self.calendarBgView.alpha = 0;
        }];
//        self.dateL.text = [(MonthModel *)mon dateValue].yyyyMMddByLineWithDate;
        //        cell.dayLabel.backgroundColor = [UIColor redColor];
        //        cell.dayLabel.textColor = [UIColor whiteColor];
    }
    [self requestPostReportSum];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        NSInteger width = Iphone6Scale(54);
        NSInteger height = Iphone6Scale(54);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(width, height);
        flowLayout.headerReferenceSize = CGSizeMake(LL_SCREEN_WIDTH, HeaderViewHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, WeekViewHeight + 10, width * 7, LL_SCREEN_HEIGHT - 64 - WeekViewHeight - 10) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        [_collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
        [_collectionView registerClass:[CalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CalendarHeaderView"];
        
    }
    return _collectionView;
}


#pragma mark -Private
- (NSUInteger)numberOfDaysInMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [greCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
}

- (NSDate *)firstDateOfMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:date];
    comps.day = 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSUInteger)startDayOfWeek:(NSDate *)date
{
    NSCalendar *greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];//Asia/Shanghai
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitWeekday | NSCalendarUnitDay
                               fromDate:[self firstDateOfMonth:date]];
    return comps.weekday;
}

- (NSDate *)getLastMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month -= 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSDate *)getNextMonth:(NSDate *)date{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:date];
    comps.month += 1;
    return [greCalendar dateFromComponents:comps];
}

- (NSDate *)dateOfDay:(NSInteger)day{
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [greCalendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents *comps = [greCalendar
                               components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                               fromDate:self.tempDate];
    comps.day = day;
    return [greCalendar dateFromComponents:comps];
}

#pragma mark - 发送请求
-(void)requestPostReportSum { //统计报表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ReportSum object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ReportSum, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectDate.yyyyMMddByLineWithDate,@"from",itemStr,@"item",toStr,@"to", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:UrlPrefix(ReportSum) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:ReportSum]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ReportSum object:nil];
        if ([responseObject[@"success"] isEqualToString:@"y"]) {
            [self.barChart strokePath];
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

@implementation CalendarHeaderView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        NSArray *weekArray = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
        
        for (int i=0; i<weekArray.count; i++) {
            UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*Iphone6Scale(54), 0, Iphone6Scale(54), HeaderViewHeight)];
            weekLabel.textAlignment = NSTextAlignmentCenter;
            weekLabel.textColor = [UIColor grayColor];
            weekLabel.font = [UIFont systemFontOfSize:13.f];
            weekLabel.text = weekArray[i];
            [self addSubview:weekLabel];
        }
        
    }
    return self;
}
@end


@implementation CalendarCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat width = self.contentView.frame.size.width*0.6;
        CGFloat height = self.contentView.frame.size.height*0.6;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake( self.contentView.frame.size.width*0.5-width*0.5,  self.contentView.frame.size.height*0.5-height*0.5, width, height )];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.layer.masksToBounds = YES;
        dayLabel.layer.cornerRadius = height * 0.5;
        
        [self.contentView addSubview:dayLabel];
        self.dayLabel = dayLabel;
        
    }
    return self;
}

- (void)setMonthModel:(MonthModel *)monthModel{
    _monthModel = monthModel;
    self.dayLabel.text = [NSString stringWithFormat:@"%02ld",monthModel.dayValue];
    if (monthModel.isToDay) {
        self.dayLabel.backgroundColor = [UIColor grayColor];
        self.dayLabel.textColor = [UIColor whiteColor];
    }
    if (monthModel.isSelectedDay) {
        self.dayLabel.backgroundColor = [UIColor redColor];
        self.dayLabel.textColor = [UIColor whiteColor];
    }
}
@end

@implementation MonthModel

@end
