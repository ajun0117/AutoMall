//
//  EmployeeDetailCell.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/9/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeDetailCell.h"

@implementation EmployeeDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.daishenBtn.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
