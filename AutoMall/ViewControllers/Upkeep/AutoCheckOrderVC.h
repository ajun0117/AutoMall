//
//  AutoCheckOrderVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckOrderVC : UIViewController

//@property (assign, nonatomic) BOOL isPayFirst;    //先付款
@property (strong, nonatomic) NSString *statusFlow;   //状态流程方式 0：先付款   1：先施工
@property (strong, nonatomic) NSString *orderId;    //订单id

@end