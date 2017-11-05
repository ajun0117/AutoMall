//
//  ServicePackageVC.h
//  AutoMall
//
//  Created by LYD on 2017/8/15.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServicePackageVC : UIViewController

@property (strong, nonatomic) NSDictionary *selectedDic;
//更新用户资料
@property (copy, nonatomic) void((^SelecteServicePackage)(NSMutableDictionary *packageDic));

@end
