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

@property (strong, nonatomic) IBOutlet UIButton *carBodyBtn;
@property (strong, nonatomic) IBOutlet UIButton *carInsideBtn;
@property (strong, nonatomic) IBOutlet UIButton *engineRoomBtn;
@property (strong, nonatomic) IBOutlet UIButton *chassisBtn;
@property (strong, nonatomic) IBOutlet UIButton *trunkBtn;

@property (strong, nonatomic) IBOutlet UIView *carBodyView;
@property (strong, nonatomic) IBOutlet UIView *carInsideView;
@property (strong, nonatomic) IBOutlet UIView *engineRoomView;
@property (strong, nonatomic) IBOutlet UIView *chassisView;
@property (strong, nonatomic) IBOutlet UIView *trunkView;

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UITableView *carBodyTV;
//@property (strong, nonatomic) UITableView *carInsideTV;
//@property (strong, nonatomic) UITableView *engineRoomTV;
//@property (strong, nonatomic) UITableView *chassisTV;
//@property (strong, nonatomic) UITableView *trunkTV;

@end
