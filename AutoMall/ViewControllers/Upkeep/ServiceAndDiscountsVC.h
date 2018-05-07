//
//  ServiceAndDiscountsVC.h
//  AutoMall
//
//  Created by LYD on 2018/5/7.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceAndDiscountsVC : UIViewController

@property (strong ,nonatomic) NSString*titleStr;

@property (strong ,nonatomic) NSDictionary*theDic;

@property (strong ,nonatomic) NSString *numStr;
@property (copy, nonatomic) void((^SelecteTheNumber)(NSString *numStr));

@end
