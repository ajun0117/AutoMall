//
//  MailOrderSingleCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailOrderSingleCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *statusL;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *nameL;
@property (strong, nonatomic) IBOutlet UILabel *UnitPriceL;
@property (strong, nonatomic) IBOutlet UILabel *numL;
@property (strong, nonatomic) IBOutlet UILabel *numberL;
@property (strong, nonatomic) IBOutlet UILabel *allMoneyL;
@property (strong, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) IBOutlet UIButton *checkboxBtn;
@property (strong, nonatomic) IBOutlet UIButton *invoicedBtn;

@end
