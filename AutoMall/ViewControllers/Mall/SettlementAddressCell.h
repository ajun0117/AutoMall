//
//  SettlementAddressCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettlementAddressCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *addView;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UILabel *nameL;
@property (strong, nonatomic) IBOutlet UILabel *phoneL;
@property (strong, nonatomic) IBOutlet UILabel *addressL;

@end
