//
//  ServiceAndDiscountsVC.m
//  AutoMall
//
//  Created by LYD on 2018/5/7.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "ServiceAndDiscountsVC.h"

@interface ServiceAndDiscountsVC ()
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UILabel *numberL;

@end

@implementation ServiceAndDiscountsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    self.title = self.titleStr;
    
    NSString *moneyStr;
//    if ([self.theDic[@"unit"] isKindOfClass:[NSNull class]]) {
//        if ([self.theDic[@"customized"] boolValue]) {
//            moneyStr = [NSString stringWithFormat:@"￥%@",STRING(self.theDic[@"customizedPrice"])];
//        } else {
//            moneyStr = [NSString stringWithFormat:@"￥%@",self.theDic[@"price"]];
//        }
//    }  else {
//        if ([self.theDic[@"customized"] boolValue]) {
//            moneyStr = [NSString stringWithFormat:@"￥%@/%@",STRING(self.theDic[@"customizedPrice"]),STRING(self.theDic[@"unit"])];
//        } else {
//            moneyStr = [NSString stringWithFormat:@"￥%@/%@",self.theDic[@"price"],STRING(self.theDic[@"unit"])];
//        }
//    }
    if (self.theDic[@"money"]) {
        moneyStr = [NSString stringWithFormat:@"￥%@",self.theDic[@"money"]];
    } else {
        moneyStr = @"";
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:moneyStr style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    //    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.tintColor = Gray_Color;
    
    self.contentL.text = self.theDic[@"item"];
    
    self.numberL.text = self.numStr;
}

-(void)save {
    
}

-(IBAction)subtractAction:(id)sender {
    int num = [self.numberL.text intValue];
    if (num == 1) {
        return;
    }
    num --;
    self.numberL.text = [NSString stringWithFormat:@"%d",num];
}

- (IBAction)plusAction:(id)sender {
    int num = [self.numberL.text intValue];
    num ++;
    self.numberL.text = [NSString stringWithFormat:@"%d",num];
}
- (IBAction)confirmAction:(id)sender {
    self.SelecteTheNumber(self.numberL.text);
    [self.navigationController popViewControllerAnimated:YES];
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
