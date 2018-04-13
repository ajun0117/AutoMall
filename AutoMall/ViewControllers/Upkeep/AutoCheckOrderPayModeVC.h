//
//  AutoCheckOrderPayModeVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckOrderPayModeVC : UIViewController

@property (strong, nonatomic) NSString *checkOrderId;    //检查单id

@property (strong, nonatomic) NSDictionary *infoDic;    //字典

@property (assign, nonatomic) BOOL isFromList;  //是否从订单列表进入

@end
