//
//  MailOrderMultiCell.h
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailOrderMultiCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *statusL;
@property (strong, nonatomic) IBOutlet UIScrollView *picScrollView;
@property (strong, nonatomic) IBOutlet UILabel *numberL;
@property (strong, nonatomic) IBOutlet UILabel *allMoneyL;
@property (strong, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) IBOutlet UIButton *checkboxBtn;
@property (strong, nonatomic) IBOutlet UIButton *invoicedBtn;

@end
