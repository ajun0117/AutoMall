//
//  CarInfoListVC.h
//  AutoMall
//
//  Created by LYD on 2017/8/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarInfoListVC : UIViewController

@property (strong, nonatomic) NSString *carId;

@property (copy, nonatomic) void((^GoBackSelectCarDic)(NSDictionary *carDic));

@end
