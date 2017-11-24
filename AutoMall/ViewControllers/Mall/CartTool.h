//
//  CartTool.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/11/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CartItem.h"

@interface CartTool : NSObject


+ (instancetype)sharedManager;
//往表插入数据
- (void)insertRecordsWithItem:(CartItem *)item;
//查询出所有
- (NSMutableArray *)queryAllCart;
-(void)UpdateContentItemWithItem:(CartItem *)item;     //修改购物车数组
-(void)deleteItemWithId:(NSString *)cid;    //删除数据
//删除表中所有数据
-(void)removeAllCartItems;

@end
