//
//  AddInvoiceVC.h
//  AutoMall
//
//  Created by 李俊阳 on 2018/6/1.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddInvoiceVC : UIViewController

@property (assign, nonatomic) BOOL isEdit;  //是否作为编辑页
@property (strong, nonatomic) NSDictionary *invoiceDic;     //发票详细

@end
