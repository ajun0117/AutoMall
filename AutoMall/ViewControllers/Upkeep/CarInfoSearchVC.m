//
//  CarInfoSearchVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/11.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CarInfoSearchVC.h"
#import "CarInfoListCell.h"

@interface CarInfoSearchVC ()
@property (strong, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;

@end

@implementation CarInfoSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"车辆信息";
    [self.searchTableView registerNib:[UINib nibWithNibName:@"CarInfoListCell" bundle:nil] forCellReuseIdentifier:@"carInfoCell"];
    self.searchTableView.tableFooterView = [UIView new];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 24);
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn setTitle:@"新车登记" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [searchBtn addTarget:self action:@selector(toRegister) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
}

-(void) toRegisterNewCarInfo {
    
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
