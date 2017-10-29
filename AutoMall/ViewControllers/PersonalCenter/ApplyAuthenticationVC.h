//
//  ApplyAuthenticationVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/4.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplyAuthenticationVC : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet WPImageView *shopImg;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *shortNameTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *detailAddressTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *recommendCodeTF;
@property (weak, nonatomic) IBOutlet WPImageView *licenseImg;
@property (weak, nonatomic) IBOutlet WPImageView *cardAImg;
@property (weak, nonatomic) IBOutlet WPImageView *cardBImg;
@property (weak, nonatomic) IBOutlet UITextField *wechatNameTF;
@property (weak, nonatomic) IBOutlet WPImageView *gongzhongImg;
@property (strong, nonatomic) IBOutlet WPImageView *aliPayCollectionImg;
@property (strong, nonatomic) IBOutlet WPImageView *wechatCollectionImg;
@property (weak, nonatomic) IBOutlet UIButton *replayBtn;

@property (strong, nonatomic) NSDictionary *infoDic;    //门店信息

@end
