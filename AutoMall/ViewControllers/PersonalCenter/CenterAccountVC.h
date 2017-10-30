//
//  CenterAccountVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterAccountVC : UIViewController

@property (strong, nonatomic) NSDictionary *infoDic;

//更新用户资料
@property (copy, nonatomic) void((^UpdateUserInfo)(NSDictionary *infoDic));

//更新登录状态
@property (copy, nonatomic) void((^UpdateLoginStatus)());

@end
