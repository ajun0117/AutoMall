//
//  CustomServiceCell.m
//  AutoMall
//
//  Created by LYD on 2017/8/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CustomServiceCell.h"

@implementation CustomServiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.moneyTF.layer.borderColor = RGBCOLOR(239, 239, 239).CGColor;
    self.moneyTF.layer.borderWidth = 1;
    self.moneyTF.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
