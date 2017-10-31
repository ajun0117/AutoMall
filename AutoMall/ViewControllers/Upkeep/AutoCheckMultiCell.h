//
//  AutoCheckMultiCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/26.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckMultiCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentL;
@property (strong, nonatomic) IBOutlet UIView *segBgView;
@property (weak, nonatomic) IBOutlet UILabel *resultL;
@property (strong, nonatomic) IBOutlet UIButton *checkResultBtn;
@property (strong, nonatomic) IBOutlet UIButton *photoBtn;

@end
