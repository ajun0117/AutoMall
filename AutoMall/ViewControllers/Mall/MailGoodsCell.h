//
//  MailGoodsCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface MailGoodsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL1;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL2;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL3;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL4;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bgViewConsH;

@end
