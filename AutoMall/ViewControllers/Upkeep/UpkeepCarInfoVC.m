//
//  UpkeepCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/13.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepCarInfoVC.h"
#import "UpkeepPlanNormalCell.h"

@interface UpkeepCarInfoVC ()
{
    NSArray *arr;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation UpkeepCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"粤A88888";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    arr = @[@{@"name":@"车主",@"content":@"孙先生"},@{@"name":@"品牌",@"content":@"奔驰"},@{@"name":@"车型",@"content":@"S300L"}, @{@"name":@"车龄",@"content":@"2年"}, @{@"name":@"行驶里程",@"content":@"30000km"}, @{@"name":@"燃油量",@"content":@"300L"}, @{@"name":@"进店时间",@"content":@"2017.7.17"}, @{@"name":@"上次保养时间",@"content":@"2017.1.17"}, @{@"name":@"上次保养里程",@"content":@"25000km"}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
    NSDictionary *dic = arr[indexPath.row];
    cell.declareL.text = dic[@"name"];
    cell.contentL.text = dic[@"content"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
