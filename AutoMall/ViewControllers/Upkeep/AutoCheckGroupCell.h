//
//  AutoCheckGroupCell.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/8.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckGroupCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentL;
@property (strong, nonatomic) IBOutlet UIView *segBgView;
@property (weak, nonatomic) IBOutlet UILabel *resultL;
@property (strong, nonatomic) IBOutlet UIButton *checkResultBtn;
@property (strong, nonatomic) IBOutlet UIButton *photoBtn;

@end
