//
//  UpkeepCarMarkVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/19.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpkeepCarMarkVC : UIViewController

@property (strong, nonatomic) NSString *imgUrl;

/**
 * 更新照片
 */
@property (copy, nonatomic) void((^GoBackGet)(NSString *imageUrl));

@end
