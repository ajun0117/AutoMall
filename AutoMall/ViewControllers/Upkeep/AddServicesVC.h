//
//  AddServicesVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/7.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddServicesVC : UIViewController

@property (copy, nonatomic) void((^AddedDiscount)(NSDictionary *addedDic));

@end
