//
//  BaoyangHistoryDetailVC.h
//  AutoMall
//
//  Created by LYD on 2017/11/28.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaoyangHistoryDetailVC : UIViewController

@property (strong, nonatomic) NSDictionary *carDic;
@property (strong, nonatomic) NSString *mileage;
@property (strong, nonatomic) NSString *fuelAmount;

@property (strong, nonatomic) NSString *carUpkeepId;    //检查单id

@property (strong, nonatomic) NSString *checktypeID;    //检查类别ID

@end
