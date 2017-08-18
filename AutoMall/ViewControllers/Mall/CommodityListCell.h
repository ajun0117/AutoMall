//
//  CommodityListCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJQRateView.h"
#import "StrikeThroughLabel.h"

@interface CommodityListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *goodsIM;
@property (strong, nonatomic) IBOutlet UILabel *goodsNameL;
@property (strong, nonatomic) IBOutlet UILabel *baokuanL;
@property (strong, nonatomic) IBOutlet UILabel *tuijianL;
@property (strong, nonatomic) IBOutlet UILabel *zhekouL;

@property (strong, nonatomic) IBOutlet DJQRateView *pingxingView;
@property (strong, nonatomic) IBOutlet UILabel *xiaoliangL;
@property (strong, nonatomic) IBOutlet UILabel *jifenL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;
@property (strong, nonatomic) IBOutlet UILabel *yunfeiL;

@end
