//
//  InvoiceManageVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/31.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceManageVC : UIViewController

@property (nonatomic, strong) NSString *orderType;      //订单类型：0 商城订单,1 保养订单
@property (nonatomic, strong) NSMutableDictionary *orderDic;    //待开发票订单

@end
