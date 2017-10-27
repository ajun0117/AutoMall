//
//  CheckResultMultiCell.h
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckResultMultiCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *positionL;
@property (strong, nonatomic) IBOutlet UILabel *checkContentL;

@property (strong, nonatomic) IBOutlet UIView *positionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *positionViewHeightCon;

@end
