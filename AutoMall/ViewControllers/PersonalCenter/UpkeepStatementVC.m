//
//  UpkeepStatementVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/8.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepStatementVC.h"
#import "ZFChart.h"

@interface UpkeepStatementVC () <ZFGenericChartDataSource, ZFBarChartDelegate>

@property (nonatomic, strong) ZFBarChart * barChart;

@property (nonatomic, assign) CGFloat height;

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
    self.title = @"统计报表";
    [self setUp];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.barChart = [[ZFBarChart alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, _height)];
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.topicLabel.text = @"xx汽修店美容保养项目报表";
    self.barChart.unit = @"次";
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
    
    [self.view addSubview:self.barChart];
    [self.barChart strokePath];
}

#pragma mark - ZFGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZFGenericChart *)chart{
    return @[@"123", @"256", @"300", @"283", @"490", @"236", @"123", @"256", @"300", @"283", @"490", @"236", @"123", @"256", @"300", @"283", @"490"];
}

- (NSArray *)nameArrayInGenericChart:(ZFGenericChart *)chart{
    return @[@"汽油燃烧喷射系统润滑清洁汽油燃烧喷射", @"机油更换", @"轮胎更换", @"四轮动平衡", @"冷却液更换", @"节气门清洗", @"电瓶更换", @"内饰清洗", @"车辆清洗", @"火花塞更换", @"钣金/喷漆", @"六年级", @"车辆清洗", @"车辆清洗", @"车辆清洗", @"车辆清洗", @"车辆清洗",];
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
    gradientAttribute.colors = @[(id)ZFRed.CGColor, (id)ZFWhite.CGColor];
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
