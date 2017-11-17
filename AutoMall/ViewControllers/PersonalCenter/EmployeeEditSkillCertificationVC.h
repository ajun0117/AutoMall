//
//  EmployeeEditSkillCertificationVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeEditSkillCertificationVC : UIViewController

@property (assign , nonatomic) int approvalStatus;  //认证状态

@property (strong , nonatomic) NSDictionary *skillDic;  //技能数据

@end
