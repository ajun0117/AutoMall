//
//  CartItem.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CartItem.h"

@implementation CartItem

- (instancetype)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end
