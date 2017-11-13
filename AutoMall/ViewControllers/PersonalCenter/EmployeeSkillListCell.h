//
//  EmployeeSkillListCell.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeSkillListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *introduceL;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end
