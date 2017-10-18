//
//  AutoCheckPhotoVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckPhotoVC : UIViewController

/**
 * 更新照片
 */
@property (copy, nonatomic) void((^GoBackUpdate)(NSArray *array));

@end
