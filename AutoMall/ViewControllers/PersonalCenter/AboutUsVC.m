//
//  AboutUsVC.m
//  AutoMall
//
//  Created by LYD on 2017/11/2.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AboutUsVC.h"

@interface AboutUsVC ()

@end

@implementation AboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于我们";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
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
