//
//  AddressInfoEditVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/7.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressInfoEditVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *uNameTF;
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UIButton *addressBtn;
@property (strong, nonatomic) IBOutlet UITextField *addDetailTF;
@property (strong, nonatomic) IBOutlet UISwitch *defaultSW;
@property (assign, nonatomic) BOOL isEdit;  //是否作为编辑页
@property (strong, nonatomic) NSDictionary *addrDic;     //地址详细

@end
