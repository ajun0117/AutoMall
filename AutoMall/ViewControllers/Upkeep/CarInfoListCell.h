//
//  CarInfoListCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarInfoListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *plateNumberL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;
@property (strong, nonatomic) IBOutlet UILabel *dateL;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;

@end
