//
//  ReceiveAddressViewController.h
//  mobilely
//
//  Created by LYD on 15/8/10.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiveAddressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (assign, nonatomic) BOOL isSelected;  //是否作为地址选择页

@end
