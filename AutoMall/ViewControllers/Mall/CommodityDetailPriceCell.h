//
//  CommodityDetailPriceCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/22.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface CommodityDetailPriceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *discountL;
@property (strong, nonatomic) IBOutlet UILabel *unitsL;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;
@property (strong, nonatomic) IBOutlet UILabel *shippingFeeL;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;

@end
