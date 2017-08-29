//
//  RegisterYZMViewController.m
//  AutoMall
//
//  Created by LYD on 2017/8/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "RegisterYZMViewController.h"

@interface RegisterYZMViewController ()
@property (strong, nonatomic) IBOutlet UILabel *phoneL;

@end

@implementation RegisterYZMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.phoneL.text = self.phoneStr;
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
