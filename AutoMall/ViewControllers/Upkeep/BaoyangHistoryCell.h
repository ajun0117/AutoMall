//
//  BaoyangHistoryCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaoyangHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderL;
@property (weak, nonatomic) IBOutlet UILabel *lichengL;
//@property (weak, nonatomic) IBOutlet UILabel *ranyouL;
//@property (weak, nonatomic) IBOutlet UILabel *ownerL;
@property (weak, nonatomic) IBOutlet UILabel *dateL;
@property (strong, nonatomic) IBOutlet UILabel *technicianName;
@property (strong, nonatomic) IBOutlet UILabel *moneyL;

@end
