//
//  ServicePackageCell.h
//  AutoMall
//
//  Created by LYD on 2017/11/13.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface ServicePackageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet StrikeThroughLabel *declareL;
@property (strong, nonatomic) IBOutlet UILabel *contentL;

@end
