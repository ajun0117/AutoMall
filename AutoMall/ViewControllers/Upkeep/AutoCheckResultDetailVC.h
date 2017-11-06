//
//  AutoCheckResultDetailVC.h
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckResultDetailVC : UIViewController

@property (strong, nonatomic) NSString *checkId;    //检查单id
@property (strong, nonatomic) NSString *checkTermId;    //位置id
@property (strong, nonatomic) NSString *checkContentId;     //检查内容id

@end
