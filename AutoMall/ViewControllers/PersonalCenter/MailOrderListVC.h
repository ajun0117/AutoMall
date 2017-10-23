//
//  MailOrderListVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailOrderListVC : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *daifuBtn;
@property (strong, nonatomic) IBOutlet UIButton *yifuBtn;
@property (strong, nonatomic) IBOutlet UIButton *allBtn;

@property (strong, nonatomic) IBOutlet UIView *daifuView;
@property (strong, nonatomic) IBOutlet UIView *yifuView;
@property (strong, nonatomic) IBOutlet UIView *allView;

@property (strong, nonatomic) NSString *orderStatus;      //0未支付，1已支付


@end
