//
//  CartItem.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartItem : NSObject

@property (nonatomic,copy) NSString *cartId;                        //购物车商品数组id
@property (nonatomic,copy) NSString *cartMulAry;                  //购物车商品数组

- (instancetype)initWithDict:(NSDictionary *)dict;

@end