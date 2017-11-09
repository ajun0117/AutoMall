//
//  ServicePackageVC.h
//  AutoMall
//
//  Created by LYD on 2017/8/15.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicePackageVC : UIViewController

@property (strong, nonatomic) NSString *carUpkeepId;    //检查单id

@property (strong, nonatomic) NSString *checktypeID;    //检查类别ID

@property (strong, nonatomic) NSDictionary *selectedDic;
//更新用户资料
@property (copy, nonatomic) void((^SelecteServicePackage)(NSMutableDictionary *packageDic));

@end
