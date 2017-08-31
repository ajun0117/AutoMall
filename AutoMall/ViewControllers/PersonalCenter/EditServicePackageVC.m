//
//  EditServicePackageVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "EditServicePackageVC.h"
#import "UpkeepPlanNormalCell.h"
#import "UpkeepPlanNormalHeadCell.h"

@interface EditServicePackageVC ()
{
    NSArray *dataArray;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation EditServicePackageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务套餐";
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalHeadCell" bundle:nil] forCellReuseIdentifier:@"upkeepPlanNormalHeadCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    NSArray *arr = @[
                     @{@"title":@"套餐A",@"allmoney":@"2200",@"data":@[@{@"name":@"机油更换1",@"money":@"333"},@{@"name":@"火花塞更换1",@"money":@"444"},@{@"name":@"机舱清洗保养1",@"money":@"555"}]},
                     @{@"title":@"套餐B",@"allmoney":@"3000",@"data":@[@{@"name":@"机油更换2",@"money":@"333"},@{@"name":@"火花塞更换2",@"money":@"444"},@{@"name":@"机舱清洗保养2",@"money":@"555"},@{@"name":@"空调系统清洗2",@"money":@"666"}]}
                     ];
    dataArray = arr;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dic = dataArray[section];
    return [dic[@"data"] count] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐A";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        case 1: {
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"套餐B";
//            [view addSubview:label];
//            
//            UIButton *radioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            radioBtn.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds) - 44, 7, 30, 30);
//            radioBtn.imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
//            [radioBtn setImage:IMG(@"checkbox_no") forState:UIControlStateNormal];
//            [radioBtn setImage:IMG(@"checkbox_yes") forState:UIControlStateSelected];
//            [radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
//            [radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
//            radioBtn.tag = section + 100;
//            [view addSubview:radioBtn];
//            
//            return view;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    switch (section) {
//        case 0:{
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.text = @"￥2200";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        case 1: {
//            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 54)];
//            bgView.backgroundColor = [UIColor clearColor];
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            [bgView addSubview:view];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 16 - 100, 12, 100, 20)];
//            label.textAlignment = NSTextAlignmentRight;
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"￥3000";
//            [view addSubview:label];
//            return bgView;
//            break;
//        }
//            
//        default:
//            return nil;
//            break;
//    }
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = dataArray[indexPath.section];
    NSArray *arr = dic[@"data"];
    if (indexPath.row == 0) {
        UpkeepPlanNormalHeadCell *cell = (UpkeepPlanNormalHeadCell *)[tableView dequeueReusableCellWithIdentifier:@"upkeepPlanNormalHeadCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameL.text = dic[@"title"];
        [cell.radioBtn setImage:[UIImage imageNamed:@"checkbox_yes"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [cell.radioBtn addTarget:self action:@selector(checkPackage:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if (indexPath.row == [arr count] + 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = [NSString stringWithFormat:@"￥%@",dic[@"allmoney"]];
        return cell;
    }
    else {
        UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSDictionary *dicc = arr[indexPath.row - 1];
        cell.declareL.text = dicc[@"name"];
        cell.contentL.text = [NSString stringWithFormat:@"￥%@",dicc[@"money"]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
    //    detailVC.userID = userArray[indexPath.section][@"id"];
    //    detailVC.isDrink = self.isDrink;
    //    detailVC.slidePlaceDetail = self.slidePlaceDetail;
    //    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)checkPackage:(UIButton *)btn {
    btn.selected = !btn.selected;
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
