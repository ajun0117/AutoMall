//
//  HeadNameCell.h
//  AutoMall
//
//  Created by LYD on 2017/8/28.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPImageView.h"

@interface HeadNameCell : UITableViewCell
@property (strong, nonatomic) IBOutlet WPImageView *headIMG;
@property (strong, nonatomic) IBOutlet UIButton *accountBtn;
@property (strong, nonatomic) IBOutlet UIButton *shopNameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *shopLevelIM;
@property (strong, nonatomic) IBOutlet UILabel *jifenL;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginL;
@property (weak, nonatomic) IBOutlet UIImageView *arrowsIM;
@property (strong, nonatomic) IBOutlet UIImageView *shopNameIM;

@end
