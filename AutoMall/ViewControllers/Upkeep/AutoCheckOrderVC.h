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
@property (strong, nonatomic) NSString *statusFlow;   //状态流程方式 1：先付款   0：先施工
@property (strong, nonatomic) NSString *checkOrderId;    //订单id

@property (strong, nonatomic) NSDictionary *infoDic;    //字典

@end
