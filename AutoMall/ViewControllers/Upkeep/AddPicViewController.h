//
//  AddPicViewController.h
//  YMYL
//
//  Created by 李俊阳 on 15/12/23.
//  Copyright © 2015年 ljy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPicViewController : UIViewController

/**
 * 更新照片
 */
@property (copy, nonatomic) void((^GoBackUpdate)(NSMutableArray *array));

@end
