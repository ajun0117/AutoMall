//
//  AutoCheckVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckVC.h"

@interface AutoCheckVC ()

@end

@implementation AutoCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"汽车检查页";
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 44, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44)];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, SCREEN_HEIGHT - 64 - 44);
    self.mainScrollView.pagingEnabled = YES;
    [self.view addSubview:self.mainScrollView];
    
    self.carBodyTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.carBodyTV];
    
    self.carInsideTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.carInsideTV];
    
    self.engineRoomTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.engineRoomTV];
    
    self.chassisTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.chassisTV];
    
    self.trunkTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 4, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStylePlain];
    [self.mainScrollView addSubview:self.trunkTV];
}

- (IBAction)carBodyAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:YES andView:self.carBodyView withColor:Red_BtnColor];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    self.carBodyBtn.selected = YES;
//    self.carBodyView.backgroundColor = Red_BtnColor;
//    self.carInsideBtn.selected = NO;
//    self.carInsideView.backgroundColor = [UIColor clearColor];
//    self.engineRoomBtn.selected = NO;
//    self.engineRoomView.backgroundColor = [UIColor clearColor];
//    self.chassisBtn.selected = NO;
//    self.chassisView.backgroundColor = [UIColor clearColor];
//    self.trunkBtn.selected = NO;
//    self.trunkView.backgroundColor = [UIColor clearColor];
}

- (IBAction)carInsideAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:YES andView:self.carInsideView withColor:Red_BtnColor];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
}

- (IBAction)engineRoomAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:YES andView:self.engineRoomView withColor:Red_BtnColor];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:NO];
}

- (IBAction)chassisAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:YES andView:self.chassisView withColor:Red_BtnColor];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 3, 0) animated:NO];
}

- (IBAction)trunkAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:YES andView:self.trunkView withColor:Red_BtnColor];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 4, 0) animated:NO];
}


-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
    btn.selected = bo;
    view.backgroundColor = color;
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
