//
//  EmployeeEditIntroduceVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeEditIntroduceVC : UIViewController

@property (strong , nonatomic) NSString *introduceStr;

//更新用户信息
@property (copy, nonatomic) void((^UpdateUserInfo)());

@end
