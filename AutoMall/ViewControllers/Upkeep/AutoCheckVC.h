//
//  AutoCheckVC.h
//  AutoMall
//
//  Created by LYD on 2017/8/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoCheckVC : UIViewController

@property (strong, nonatomic) NSString *checktypeID;    //检查类别ID
//@property (strong, nonatomic) NSNumber *carId;  //选择的车辆Id
@property (strong, nonatomic) NSDictionary *carDic;  //选择的车辆Dic
@property (strong, nonatomic) UIScrollView *mainScrollView;
//@property (strong, nonatomic) UITableView *carBodyTV;
//@property (strong, nonatomic) UITableView *carInsideTV;
//@property (strong, nonatomic) UITableView *engineRoomTV;
//@property (strong, nonatomic) UITableView *chassisTV;
//@property (strong, nonatomic) UITableView *trunkTV;

//@property (strong, nonatomic) NSDictionary *lichengDic;    //里程油量数据

@end
