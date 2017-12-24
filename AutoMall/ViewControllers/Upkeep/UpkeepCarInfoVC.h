//
//  UpkeepCarInfoVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/13.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpkeepCarInfoVC : UIViewController

@property (strong, nonatomic) NSDictionary *carDic;
@property (strong, nonatomic) NSString *mileage;
@property (strong, nonatomic) NSString *fuelAmount;
@property (strong, nonatomic) NSString *lastEndTime;
@property (strong, nonatomic) NSString *lastMileage;

@end
