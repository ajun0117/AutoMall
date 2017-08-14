//
//  UpkeepPlanVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepPlanVC.h"
#import "UpkeepPlanInfoCell.h"
#import "UpkeepPlanNormalCell.h"

@interface UpkeepPlanVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation UpkeepPlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务方案";
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanInfoCell" bundle:nil] forCellReuseIdentifier:@"planInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 5;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return 125;
            break;
        }
            
        case 1: {
            return 44;
            break;
        }
            
        default:
            break;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 44;
            break;
            
        case 1:
            return 44;
            break;
            
        default:
            break;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:17];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"车辆信息";
            [view addSubview:label];
            return view;
            break;
        }
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:17];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"方案明细";
            [view addSubview:label];
            return view;
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            UpkeepPlanInfoCell *cell = (UpkeepPlanInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"planInfoCell"];
            return cell;
            break;
        }
            
        case 1: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            return cell;
            break;
        }
            
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
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
