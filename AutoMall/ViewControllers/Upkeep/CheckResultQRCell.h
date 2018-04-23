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
@property (strong, nonatomic) IBOutlet UILabel *mdqrL;
@property (weak, nonatomic) IBOutlet UIImageView *ptImgView;
@property (weak, nonatomic) IBOutlet UILabel *ptL;
@property (weak, nonatomic) IBOutlet UIImageView *singleImgView;
@property (weak, nonatomic) IBOutlet UILabel *singleL;

@end
