//
//  UpkeepOrderListCell.h
//  AutoMall
//
//  Created by LYD on 2017/11/13.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpkeepOrderListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *statusL;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *orderNumberL;
@property (strong, nonatomic) IBOutlet UILabel *dateL;
@property (strong, nonatomic) IBOutlet UILabel *plateNumberL;
@property (strong, nonatomic) IBOutlet UILabel *ownerL;
@property (strong, nonatomic) IBOutlet UILabel *allMoneyL;
@property (strong, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) IBOutlet UIButton *checkboxBtn;

@end
