//
//  EmployeeAuthVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/9/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeAuthVC.h"

@interface EmployeeAuthVC ()
@property (strong, nonatomic) IBOutlet UILabel *nameL;
@property (strong, nonatomic) IBOutlet UILabel *introduceL;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UIView *revieweView;

@end

@implementation EmployeeAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"技能认证审核";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.nameL.text = @"认证名称名称";
    self.introduceL.text = @"技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 技能介绍介绍 ";
    
    if (self.isReviewed) {
        self.revieweView.hidden = YES;
    }
}

- (IBAction)pass:(id)sender {
}

- (IBAction)reject:(id)sender {
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
