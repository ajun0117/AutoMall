//
//  EmployeeAuthVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/9/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeAuthVC : UIViewController

@property (assign, nonatomic) BOOL isReviewed; //是否审核过
@property (strong, nonatomic) NSDictionary *skillDic;   //技能字典

@end
