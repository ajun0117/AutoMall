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
    self.yuan1.strikeThroughEnabled = YES;
    self.yuan2.strikeThroughEnabled = YES;
    self.yuan3.strikeThroughEnabled = YES;
    self.yuan4.strikeThroughEnabled = YES;
    self.yuan5.strikeThroughEnabled = YES;
    self.yuan6.strikeThroughEnabled = YES;
    self.yuan7.strikeThroughEnabled = YES;
    self.yuan8.strikeThroughEnabled = YES;
    self.yuan9.strikeThroughEnabled = YES;
    self.yuan10.strikeThroughEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
