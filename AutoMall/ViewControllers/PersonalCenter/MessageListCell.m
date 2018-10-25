//
//  MessageListCell.m
//  AutoMall
//
//  Created by LYD on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MessageListCell.h"

@implementation MessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ReadIM.layer.cornerRadius = 4.0f;
    self.headIM.layer.cornerRadius = 22.0f;
    self.headIM.layer.borderWidth = 0.5f;
    self.headIM.layer.borderColor = RGBCOLOR(200, 199, 204).CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
