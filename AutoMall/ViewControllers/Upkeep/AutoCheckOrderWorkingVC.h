//
//  AutoCheckOrderWorkingVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckOrderWorkingVC : UIViewController

//@property (assign, nonatomic) BOOL isWorkFirst;    //先施工
@property (strong, nonatomic) NSString *statusFlow;   //状态流程方式 1：先付款   0：先施工
@property (strong, nonatomic) NSString *checkOrderId;    //检查单id

@property (strong, nonatomic) NSDictionary *infoDic;    //字典

@end
