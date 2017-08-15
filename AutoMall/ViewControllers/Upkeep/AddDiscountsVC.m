//
//  AddDiscountsVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/15.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddDiscountsVC.h"

@interface AddDiscountsVC ()
@property (strong, nonatomic) IBOutlet UITextField *discountsNameTF;
@property (strong, nonatomic) IBOutlet UITextField *discountsMoneyTF;

@end

@implementation AddDiscountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加优惠";
}
- (IBAction)saveAction:(id)sender {
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
