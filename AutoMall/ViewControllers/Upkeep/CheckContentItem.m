//
//  CheckContentItem.m
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CheckContentItem.h"

@implementation CheckContentItem

- (instancetype)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

@end
