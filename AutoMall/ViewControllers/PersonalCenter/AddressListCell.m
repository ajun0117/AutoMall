//
//  AddressListCell.m
//  AutoMall
//
//  Created by LYD on 2017/9/7.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddressListCell.h"

@implementation AddressListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.defaultL.layer.cornerRadius = 3;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
