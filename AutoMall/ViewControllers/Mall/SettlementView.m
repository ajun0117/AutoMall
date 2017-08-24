//
//  SettlementView.m
//  HSH
//
//  Created by kangshibiao on 16/5/19.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "SettlementView.h"

@implementation SettlementView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self =[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addUI];
    }
    return self;
    
}
- (void)addUI{
    
    CGFloat height = self.bounds.size.height;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, self.frame.size.width, self.frame.size.height-15)];
    bgView.backgroundColor = GRGB;
    [self addSubview:bgView];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
    lineV.backgroundColor = [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1];
    [bgView addSubview:lineV];
    
//    _number = [[UILabel alloc]initWithFrame:CGRectMake(59, 0, 16, 16)];
//    _number.backgroundColor = [UIColor redColor];
//    _number.textColor = [UIColor whiteColor];
//    _number.font = [UIFont systemFontOfSize:10];
//    _number.textAlignment = NSTextAlignmentCenter;
//    _number.layer.masksToBounds = YES;
//    _number.layer.cornerRadius = 8;
//    [bgView addSubview:_number];
    
    _money = [[UILabel alloc]initWithFrame:CGRectMake(66, 8, 100, 24)];
    _money.text = @"￥1160.00";
    _money.font = FONT(14);
    _money.textColor = [UIColor blackColor];
    [bgView addSubview:_money];
    
    _peisongMoney = [[UILabel alloc]initWithFrame:CGRectMake(VIEW_BX(_money), 8, 60, 24)];
    _peisongMoney.text = @"配送费￥5";
    _peisongMoney.font = FONT(10);
    _peisongMoney.textColor = [UIColor darkGrayColor];
    [bgView addSubview:_peisongMoney];
    
    _settlement =[UIButton buttonWithType:UIButtonTypeCustom];
    _settlement.frame =CGRectMake(SCREEN_WIDTH - 100, 0, 100, 40);
    _settlement.backgroundColor = RRGB;
    _settlement.titleLabel.font = FONT(15);
    [_settlement setTitle:@"结算" forState:UIControlStateNormal];
    [bgView addSubview:_settlement];
    
    self.shoppingCart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shoppingCart setImage:[UIImage imageNamed:@"cart_exist"] forState:UIControlStateNormal];
    [self.shoppingCart addTarget:self action:@selector(shoppingCartClokc) forControlEvents:UIControlEventTouchUpInside];
    self.shoppingCart.frame = CGRectMake(10, 0, 49, 55);
    [self addSubview:self.shoppingCart];
}
- (void)setNumber:(UILabel *)number{
    
    CGSize size = [_number.text boundingRectWithSize:CGSizeMake(999, 25) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_number.font} context:nil].size;
    CGRect rect = _number.frame;
    if (size.width >rect.size.width) {
        rect.size.width = size.width+6;
    }
    _number.frame = rect;
}
- (void)getNumber:(objc_objectptr_t **)buffer range:(NSRange)inRange{
    
}
#pragma mark --购物车
- (void)shoppingCartClokc{
    
}

@end
