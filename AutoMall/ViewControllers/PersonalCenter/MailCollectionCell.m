//
//  MailCollectionCell.m
//  AutoMall
//
//  Created by LYD on 2017/9/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailCollectionCell.h"

@implementation MailCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.costPriceStrikeL.strikeThroughEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
