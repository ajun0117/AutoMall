//
//  AutoCheckDisountsVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckDisountsVC : UIViewController

@property (strong, nonatomic) NSDictionary *selectedDic;

@property (copy, nonatomic) void((^SelecteDiscount)(NSMutableDictionary *discountDic));

@end
