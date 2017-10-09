//
//  CommodityDetailStarCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/22.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJQRateView.h"

@interface CommodityDetailStarCell : UITableViewCell
@property (strong, nonatomic) IBOutlet DJQRateView *pingxingRV;
@property (strong, nonatomic) IBOutlet UILabel *saleL;
@property (strong, nonatomic) IBOutlet UILabel *jifenL;

@end
