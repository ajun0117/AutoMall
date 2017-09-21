//
//  CommodityDetailVC.h
//  AutoMall
//
//  Created by LYD on 2017/8/21.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettlementView.h"

@interface CommodityDetailVC : UIViewController

//底部菜单
@property (strong, nonatomic) SettlementView *settemntView;
@property (assign, nonatomic) int commodityId;  //商品ID
//购物车视图删除还是加载
@property (assign, nonatomic) BOOL isShopping;

@end
