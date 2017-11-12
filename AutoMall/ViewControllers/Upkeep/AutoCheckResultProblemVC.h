//
//  AutoCheckResultProblemVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckResultProblemVC : UIViewController

@property (assign, nonatomic) BOOL isUnnormal;      //是否所有异常项目

@property (strong, nonatomic) NSString *carUpkeepId;    //检查单id

@property (strong, nonatomic) NSString *categoryId;    //检查单id

@end
