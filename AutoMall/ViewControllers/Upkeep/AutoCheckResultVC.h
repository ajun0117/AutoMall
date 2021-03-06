//
//  AutoCheckResultVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/26.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckResultVC : UIViewController

@property (strong, nonatomic) NSString *carUpkeepId;    //检查单id

@property (strong, nonatomic) NSString *checktypeID;    //检查类别ID
@property (strong, nonatomic) NSString *checktypeName;    //检查类别Name

@property (assign, nonatomic) BOOL isFromList;  //是否从订单列表进入
@property (assign, nonatomic) BOOL isFromAffirm;  //是否从确认页进入或是否为普通用户

@end
