//
//  ApplyAuthenticationVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/4.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplyAuthenticationVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *shortNameTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *detailAddressTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *recommendCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *licenseImgBtn;
@property (weak, nonatomic) IBOutlet UIButton *cardImgABtn;
@property (weak, nonatomic) IBOutlet UIButton *cardImgBBtn;
@property (weak, nonatomic) IBOutlet UITextField *wechatNameTF;
@property (weak, nonatomic) IBOutlet UIButton *wechatImgBtn;

@end
