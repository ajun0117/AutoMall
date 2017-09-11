//
//  FirstViewController.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepVC.h"
#import "AutoCheckVC.h"
#import "CarInfoListVC.h"
#import "LoginViewController.h"


@interface UpkeepVC ()
@property (strong, nonatomic) IBOutlet UIButton *carOwnerBtn;
@property (strong, nonatomic) IBOutlet UIButton *hairdressingBtn;
@property (strong, nonatomic) IBOutlet UIButton *customBtn;
@property (strong, nonatomic) IBOutlet UIButton *quickBtn;
@property (strong, nonatomic) IBOutlet UIButton *upkeepBtn;

@end

@implementation UpkeepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"保养服务";
    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    
    //最近iOS项目中要求导航栏的返回按钮只保留那个箭头，去掉后边的文字，在网上查了一些资料，最简单且没有副作用的方法就是
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"cars"] forState:UIControlStateNormal];
//    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toCarOwner:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];
    
    [self makeLayerWithButton:self.carOwnerBtn];
    [self makeLayerWithButton:self.hairdressingBtn];
    [self makeLayerWithButton:self.customBtn];
    [self makeLayerWithButton:self.quickBtn];
    [self makeLayerWithButton:self.upkeepBtn];
}

-(void) makeLayerWithButton:(UIButton *)btn {
    btn.layer.cornerRadius = btn.frame.size.height / 2;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = RGBCOLOR(244, 245, 246).CGColor;
}

-(void)toCarOwner:(UIButton *)btn {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)toCheckAutoAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (IBAction)toLoginAction:(id)sender {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}


- (IBAction)carInfoListAction:(id)sender {
    CarInfoListVC *listVC = [[CarInfoListVC alloc] init];
    listVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
