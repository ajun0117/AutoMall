//
//  TabBarController.h
//  SupermarketOnline
//
//  Created by lyd on 16/10/20.
//  Copyright (c) 2016年 lydcom. All rights reserved.
//

#import "TabBarController.h"
#import "UITabBarItem+Universal.h"

@implementation TabBarController

- (void)initTabBar {
//    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"bottomTabBg"]];
    
    UIOffset offset = UIOffsetMake(0, -3);
    
    UIColor *yellowColor = Orange_Color;//主题橘色
    
    NSDictionary *normalDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName, nil];
    NSDictionary *selectedDict = [NSDictionary dictionaryWithObjectsAndKeys:yellowColor,NSForegroundColorAttributeName, nil];
    
    UIImage *selectedImage0 = [UIImage imageNamed:@"bottomTabHomeHi"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"bottomTabHome"];
    UIImage *selectedImage1 = [UIImage imageNamed:@"bottomTabPointsHi"];
    UIImage *unselectedImage1 = [UIImage imageNamed:@"bottomTabPoints"];
    UIImage *selectedImage2 = [UIImage imageNamed:@"bottomTabFavHi"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"bottomTabFav"];
    UIImage *selectedImage3 = [UIImage imageNamed:@"bottomTabMeHi"];
    UIImage *unselectedImage3 = [UIImage imageNamed:@"bottomTabMe"];
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    
    [item0 itemWithImage:unselectedImage0 selectedImage:selectedImage0];
    [item1 itemWithImage:unselectedImage1 selectedImage:selectedImage1];
    [item2 itemWithImage:unselectedImage2 selectedImage:selectedImage2];
    [item3 itemWithImage:unselectedImage3 selectedImage:selectedImage3];
    
    [item0 setTitle:@"保养服务"];
    [item1 setTitle:@"资讯"];
    [item2 setTitle:@"商城"];
    [item3 setTitle:@"个人中心"];
    
    [item0 setTitlePositionAdjustment:offset];
    [item1 setTitlePositionAdjustment:offset];
    [item2 setTitlePositionAdjustment:offset];
    [item3 setTitlePositionAdjustment:offset];
    
    [item0 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item0 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item1 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item1 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item2 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item2 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];
    [item3 setTitleTextAttributes:normalDict forState:UIControlStateNormal];
    [item3 setTitleTextAttributes:selectedDict forState:UIControlStateSelected];

    // 解决超出屏幕tabbar图片背后显示黑线的问题
//    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
}

//-(void)initTabbarWithSelectedImage:(NSString *)selectedImage unselectedImage:(NSString *)unselectedImage title:(NSString *)title color:(UIColor *)color offset:(UIOffset)offset normalDict:(NSDictionary *)normalDict selectedDict:(NSDictionary *)selectedDict {
//    UIImage *selectedImage0 = IMG(selectedImage);
//    UIImage *unselectedImage0 = IMG(unselectedImage);
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTabBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
