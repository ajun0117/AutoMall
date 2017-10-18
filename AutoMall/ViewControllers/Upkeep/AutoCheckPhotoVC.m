//
//  AutoCheckPhotoVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckPhotoVC.h"

@interface AutoCheckPhotoVC ()

@end

@implementation AutoCheckPhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.GoBackUpdate(@[@"1",@"2",@"3"]);
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
