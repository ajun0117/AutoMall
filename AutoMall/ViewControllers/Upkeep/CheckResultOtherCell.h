//
//  CheckResultOtherCell.h
//  AutoMall
//
//  Created by LYD on 2017/11/20.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckResultOtherCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *checkDateL;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeCheckDateL;
@property (weak, nonatomic) IBOutlet UILabel *mileageL;
@property (weak, nonatomic) IBOutlet UIButton *mileageImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeMileageL;
@property (weak, nonatomic) IBOutlet UIButton *lastTimeMileageImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *fuelAmountL;
@property (weak, nonatomic) IBOutlet UIButton *fuelAmountImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeFuelAmountL;
@property (weak, nonatomic) IBOutlet UIButton *lastTimeFuelAmountImageBtn;

@end
