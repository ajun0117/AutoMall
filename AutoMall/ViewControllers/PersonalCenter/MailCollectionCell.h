//
//  MailCollectionCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface MailCollectionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *goodsIMG;
@property (strong, nonatomic) IBOutlet UILabel *goodsName;
@property (strong, nonatomic) IBOutlet UILabel *goodsprice;
@property (strong, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;

@end
