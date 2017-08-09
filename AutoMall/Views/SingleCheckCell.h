//
//  SingleCheckCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/9.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DVSwitch.h"


@interface SingleCheckCell : UITableViewCell

@property (strong, nonatomic) DVSwitch *switcher;

@property (strong, nonatomic) IBOutlet UIButton *checkResultBtn;
@end
