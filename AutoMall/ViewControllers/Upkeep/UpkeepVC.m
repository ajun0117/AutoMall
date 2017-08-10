//
//  FirstViewController.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepVC.h"
#import "AutoCheckVC.h"

@interface UpkeepVC ()

@end

@implementation UpkeepVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"保养服务";
}

- (IBAction)toCheckAutoAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
