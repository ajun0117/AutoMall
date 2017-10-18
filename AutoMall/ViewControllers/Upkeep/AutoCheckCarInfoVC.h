//
//  AutoCheckCarInfoVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/16.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckCarInfoVC : UIViewController

/**
 * 提交里程油量
 */
@property (copy, nonatomic) void((^GoBackSubmitLicheng)(NSDictionary *dic));

@end
