//
//  InvoiceListCell.h
//  AutoMall
//
//  Created by 李俊阳 on 2018/5/31.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taitouL;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (strong, nonatomic) IBOutlet UILabel *defaultL;
@property (weak, nonatomic) IBOutlet UILabel *typeL;


@end
