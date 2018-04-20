//
//  CheckResultQRCell.h
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckResultQRCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *mdqrImgView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mdqrImgCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *ptqrImgCon;
@property (strong, nonatomic) IBOutlet UILabel *mdqrL;

@end
