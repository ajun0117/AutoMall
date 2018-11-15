//
//  ShoppingCartModel.m
//  HSH
//
//  Created by kangshibiao on 16/6/16.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "ShoppingCartModel.h"

@implementation ShoppingCartModel
- (instancetype)initWithDictionary:(id)dictionary{
    
    if (self = [super init]) {
        
        self.name = KSDIC(dictionary, @"name");
        self.money = [NSString stringWithFormat:@"￥%@/件",KSDIC(dictionary, @"current_price")];
        self.orderCont = KSDIC(dictionary, @"orderCont");
        self.minimum = KSDIC(dictionary, @"minimum");
    }
    return self;
}
+ (void)shoppingCartList:(id)data orderArr:(NSMutableArray *)orderArr{
    
    NSMutableArray *orderNew=  [NSMutableArray arrayWithArray:orderArr];
    
    for (id data in orderArr)
    {
        
        if ([data valueForKey:@"id"] == [data valueForKey:@"id"])
        {
         
            break;
            
        }
        else{
            
            [orderNew addObject:data];
            
            
        }
    }
}
+ (NSInteger)orderShoppingCartr:(NSMutableArray *)orderArr{
    
  __block  NSInteger num =0;
    
    [orderArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
        num = num + [[obj valueForKey:@"orderCont"] integerValue];
        
        
    }];
    
    return num;
}

/**
 * 计算商品价格
 */
+ (double)moneyOrderShoopingCart:(NSMutableArray *)orderArr{
    
    __block double money = 0;
    
    [orderArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"discount"] floatValue] > 0) {
            money = money +[[obj valueForKey:@"orderCont"] doubleValue] *[[obj valueForKey:@"discount"] doubleValue];
        } else {
            money = money +[[obj valueForKey:@"orderCont"] doubleValue] *[[obj valueForKey:@"price"] doubleValue];
        }
    }];
    
    return money;
    
}

+ (double)shippingFeeShopingCart:(NSMutableArray *)orderArr {
    __block double money = 0;
    __block double shippingFee = 0;
    [orderArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"discount"] floatValue] > 0) {
            money += [[obj valueForKey:@"orderCont"] doubleValue] *[[obj valueForKey:@"discount"] doubleValue];
        } else {
            money += [[obj valueForKey:@"orderCont"] doubleValue] *[[obj valueForKey:@"price"] doubleValue];
        }
        shippingFee += [[obj valueForKey:@"shippingFee"] doubleValue];
    }];
    if (money >= 500) {
        shippingFee = 0.0;
    }
    return shippingFee;
}
@end
