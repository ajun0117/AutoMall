//
//  RegisterViewController.h
//  AutoMall
//
//  Created by LYD on 2017/8/29.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet CustomTextField *phoneTF;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end
