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
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UILabel *money1;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *yuan1;
@property (weak, nonatomic) IBOutlet UIButton *btn1;

@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL2;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UILabel *name2;
@property (weak, nonatomic) IBOutlet UILabel *money2;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *yuan2;
@property (weak, nonatomic) IBOutlet UIButton *btn2;

@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL3;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UILabel *name3;
@property (weak, nonatomic) IBOutlet UILabel *money3;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *yuan3;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL4;
@property (weak, nonatomic) IBOutlet UIImageView *img4;
@property (weak, nonatomic) IBOutlet UILabel *name4;
@property (weak, nonatomic) IBOutlet UILabel *money4;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *yuan4;
@property (weak, nonatomic) IBOutlet UIButton *btn4;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bgViewConsH;

@end
