//
//  EmployeeSkillListCell.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeSkillListCell.h"

@implementation EmployeeSkillListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.statusBtn.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
