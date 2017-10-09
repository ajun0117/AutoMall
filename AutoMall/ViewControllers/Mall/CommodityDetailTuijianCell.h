//
//  CommodityDetailTuijianCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/22.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface CommodityDetailTuijianCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *goodsIM;
@property (strong, nonatomic) IBOutlet UILabel *goodsNameL;
@property (strong, nonatomic) IBOutlet UILabel *baokuanL;
@property (strong, nonatomic) IBOutlet UILabel *tuijianL;
@property (strong, nonatomic) IBOutlet UILabel *zhekouL;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;

@end
