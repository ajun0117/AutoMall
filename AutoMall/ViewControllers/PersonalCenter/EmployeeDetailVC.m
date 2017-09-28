//
//  EmployeeDetailVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EmployeeDetailVC.h"
#import "EmployeeDetailCell.h"

@interface EmployeeDetailVC ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EmployeeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"张三";
    [self.myTableView registerNib:[UINib nibWithNibName:@"EmployeeDetailCell" bundle:nil] forCellReuseIdentifier:@"employeeDetailCell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    }
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        EmployeeDetailCell *cell = (EmployeeDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailCell"];
        cell.nameL.text = @"高级工程师";
        return cell;
    }
    else {
        EmployeeDetailCell *cell = (EmployeeDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"employeeDetailCell"];
        cell.nameL.text = @"高级工程师";
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MailOrderDetailVC *detailVC = [[MailOrderDetailVC alloc] init];
    //        detailVC.userID = userArray[indexPath.section][@"id"];
    //        detailVC.isDrink = self.isDrink;
    //        detailVC.slidePlaceDetail = self.slidePlaceDetail;
//    [self.navigationController pushViewController:detailVC animated:YES];
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
