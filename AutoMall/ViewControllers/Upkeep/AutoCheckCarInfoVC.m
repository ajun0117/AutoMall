//
//  AutoCheckCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/16.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckCarInfoVC.h"

@interface AutoCheckCarInfoVC ()

@property (strong, nonatomic) IBOutlet UITextField *mileageTF;
@property (strong, nonatomic) IBOutlet UITextField *fuelAmountTF;

@end

@implementation AutoCheckCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"粤A88888";
    
    [self setTextFieldInputAccessoryViewWithTF:self.mileageTF];
    [self setTextFieldInputAccessoryViewWithTF:self.fuelAmountTF];
}

//-(void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    self.GoBackSubmitLicheng(@{@"mileage":self.mileageTF.text,@"fuelAmount":self.fuelAmountTF.text});
//}

#pragma mark - 添加完成按钮的toolBar工具栏
- (void)setTextFieldInputAccessoryViewWithTF:(UITextField *)field{
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn setTintColor:[UIColor grayColor]];
    doneBtn.layer.cornerRadius = 2;
    doneBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    doneBtn.layer.borderWidth = 0.5;
    doneBtn.frame = CGRectMake(2, 5, 45, 25);
    [doneBtn addTarget:self action:@selector(dealKeyboardHide) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceBtn,doneBtnItem,nil];
    [topView setItems:buttonsArray];
    [field setInputAccessoryView:topView];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
}
- (IBAction)saveAction:(id)sender {
     self.GoBackSubmitLicheng(@{@"mileage":self.mileageTF.text,@"fuelAmount":self.fuelAmountTF.text});
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealKeyboardHide {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation 
 

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
