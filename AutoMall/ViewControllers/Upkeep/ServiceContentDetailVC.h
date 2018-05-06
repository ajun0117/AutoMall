//
//  ServiceContentDetailVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServiceContentDetailVC : UIViewController

@property (strong ,nonatomic) NSDictionary*serviceDic;

@property (strong ,nonatomic) NSString *numStr;
@property (copy, nonatomic) void((^SelecteServiceNumber)(NSString *numStr));

@end
