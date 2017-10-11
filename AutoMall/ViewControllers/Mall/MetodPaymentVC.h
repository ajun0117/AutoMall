//
//  MetodPaymentVC.h
//  HSH
//
//  Created by kangshibiao on 16/5/23.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetodPaymentVC : UIViewController
@property (nonatomic, strong) NSString *orderNumber;    //订单号

/**
 * 微信
 */
@property (weak, nonatomic) IBOutlet UIImageView *wx;
/**
 * 支付宝
 */
@property (weak, nonatomic) IBOutlet UIImageView *ailpay;


@end
