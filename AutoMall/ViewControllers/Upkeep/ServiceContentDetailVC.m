//
//  ServiceContentDetailVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ServiceContentDetailVC.h"

@interface ServiceContentDetailVC ()
@property (weak, nonatomic) IBOutlet UILabel *contentL;

@end

@implementation ServiceContentDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    self.title = self.serviceDic[@"name"];
    
    NSString *moneyStr;
    if ([self.serviceDic[@"unit"] isKindOfClass:[NSNull class]]) {
        if ([self.serviceDic[@"customized"] boolValue]) {
            moneyStr = [NSString stringWithFormat:@"￥%@",STRING(self.serviceDic[@"customizedPrice"])];
        } else {
            moneyStr = [NSString stringWithFormat:@"￥%@",self.serviceDic[@"price"]];
        }
    }  else {
        if ([self.serviceDic[@"customized"] boolValue]) {
            moneyStr = [NSString stringWithFormat:@"￥%@/%@",STRING(self.serviceDic[@"customizedPrice"]),STRING(self.serviceDic[@"unit"])];
        } else {
            moneyStr = [NSString stringWithFormat:@"￥%@/%@",self.serviceDic[@"price"],STRING(self.serviceDic[@"unit"])];
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:moneyStr style:UIBarButtonItemStylePlain target:self action:@selector(save)];
//    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.tintColor = Gray_Color;
    
    self.contentL.text = self.serviceDic[@"notice"];
}

-(void)save {
    
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
