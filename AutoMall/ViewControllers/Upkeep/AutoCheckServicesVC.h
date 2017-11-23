//
//  AutoCheckServicesVC.h
//  AutoMall
//
//  Created by LYD on 2017/11/23.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckServicesVC : UIViewController

@property (strong, nonatomic) NSDictionary *selectedDic;

@property (copy, nonatomic) void((^SelecteSerices)(NSMutableDictionary *servicesDic));

@end
