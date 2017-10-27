//
//  CheckResultCell.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/26.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckResultCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *chepaiL;
@property (strong, nonatomic) IBOutlet UILabel *allNumL;
@property (strong, nonatomic) IBOutlet UILabel *unusualNumL;
@property (strong, nonatomic) IBOutlet UILabel *carBodyNumL;
@property (strong, nonatomic) IBOutlet UILabel *inCarNumL;
@property (strong, nonatomic) IBOutlet UILabel *engineNumL;
@property (strong, nonatomic) IBOutlet UILabel *underpanNumL;
@property (strong, nonatomic) IBOutlet UILabel *bootNumL;
@property (strong, nonatomic) IBOutlet UILabel *tyreNumL;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carBodyCenterCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inCarCenterCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *engineCenterCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *underpanCenterCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bootCenterCon;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tyreCenterCon;

@property (strong, nonatomic) IBOutlet UIButton *carBodybtn;
@property (strong, nonatomic) IBOutlet UIButton *inCarBtn;
@property (strong, nonatomic) IBOutlet UIButton *engineBtn;
@property (strong, nonatomic) IBOutlet UIButton *underpanBtn;
@property (strong, nonatomic) IBOutlet UIButton *bootBtn;
@property (strong, nonatomic) IBOutlet UIButton *tyreBtn;
@end
