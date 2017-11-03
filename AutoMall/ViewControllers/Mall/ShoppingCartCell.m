//
//  ShoppingCartCell.m
//  HSH
//
//  Created by kangshibiao on 16/5/20.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "ShoppingCartCell.h"

@implementation ShoppingCartCell

- (void)awakeFromNib {
    // Initialization code
    self.number.text = @"0";
    self.name.font = FONT(12);
    self.money.font = FONT(12);
    [super awakeFromNib];
}
- (void)setData:(id)data{
   
    self.name.text = KSDIC(data, @"name");
    if (data[@"discount"]) {
        self.money.text = [NSString stringWithFormat:@"￥%@/件",KSDIC(data, @"discount")];
    } else {
        self.money.text = [NSString stringWithFormat:@"￥%@/件",KSDIC(data, @"price")];
    }
    self.number.text = [NSString stringWithFormat:@"%@",KSDIC(data, @"orderCont")];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
