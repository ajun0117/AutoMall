//
//  MailGoodsCell.m
//  AutoMall
//
//  Created by LYD on 2017/9/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailGoodsCell.h"

@implementation MailGoodsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.costPriceStrikeL1.strikeThroughEnabled = YES;
    self.costPriceStrikeL2.strikeThroughEnabled = YES;
    self.costPriceStrikeL3.strikeThroughEnabled = YES;
    self.costPriceStrikeL4.strikeThroughEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
