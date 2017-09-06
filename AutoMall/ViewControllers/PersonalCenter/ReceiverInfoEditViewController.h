//
//  ReceiverInfoEditViewController.h
//  mobilely
//
//  Created by hn3l on 15/1/21.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  信息编辑视图控制器，负责管理信息编辑的视图和数据
 */
@interface ReceiverInfoEditViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UITextField *postcodeTF;
@property (weak, nonatomic) IBOutlet UIButton *provinceBtn;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@property (weak, nonatomic) IBOutlet UIButton *districtBtn;
@property (weak, nonatomic) IBOutlet UITextView *detailAddressTV;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (assign, nonatomic) BOOL isEdit; //是否显示为编辑页面
@property (assign, nonatomic) NSDictionary *addressDic; //地址详情字典

- (IBAction)selectItem:(UIButton*)sender;

- (IBAction)clickConfirm:(id)sender;

@end
