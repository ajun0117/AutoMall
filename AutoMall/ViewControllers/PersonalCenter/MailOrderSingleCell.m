//
//  MailOrderSingleCell.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailOrderSingleCell.h"

@implementation MailOrderSingleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.btn.layer.cornerRadius = 2;
    self.btn.layer.borderColor = [UIColor blackColor].CGColor;
    self.btn.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
