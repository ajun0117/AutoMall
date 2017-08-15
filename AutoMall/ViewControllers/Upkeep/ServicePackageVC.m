//
//  ServicePackageVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/15.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "ServicePackageVC.h"
#import "UpkeepPlanNormalCell.h"

@interface ServicePackageVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation ServicePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务套餐";
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];
}
- (IBAction)confirmAction:(id)sender {
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 4;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"套餐A";
            [view addSubview:label];
            return view;
            break;
        }
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"套餐B";
            [view addSubview:label];
            return view;
            break;
        }
            
        default:
            return nil;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
            bgView.backgroundColor = [UIColor clearColor];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            [bgView addSubview:view];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:15];
            label.text = @"￥2200";
            [view addSubview:label];
            return bgView;
            break;
        }
            
        case 1: {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
            bgView.backgroundColor = [UIColor clearColor];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            [bgView addSubview:view];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"￥3000";
            [view addSubview:label];
            return bgView;
            break;
        }
            
        default:
            return nil;
            break;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
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
