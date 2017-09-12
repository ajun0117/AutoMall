//
//  CommodityListCell.m
//  AutoMall
//
//  Created by LYD on 2017/8/18.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CommodityListCell.h"

@implementation CommodityListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.costPriceStrikeL.strikeThroughEnabled = YES;
    self.pingxingView.rate = 4;
    self.pingxingView.maxRate = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
