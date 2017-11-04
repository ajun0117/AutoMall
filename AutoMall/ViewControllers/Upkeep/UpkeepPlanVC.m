//
//  UpkeepPlanVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "UpkeepPlanVC.h"
//#import "UpkeepPlanInfoCell.h"
#import "UpkeepPlanNormalCell.h"
#import "ServicePackageVC.h"
#import "BaoyangDiscountsVC.h"
#import "UpkeepCarInfoVC.h"
#import "AutoCheckOrderPayModeVC.h"

@interface UpkeepPlanVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation UpkeepPlanVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"服务方案";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
//    searchBtn.contentMode = UIViewContentModeRight;
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [searchBtn setTitleColor:RGBCOLOR(0, 191, 243) forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"套餐" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toPackage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnBarBtn;
    
//    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanInfoCell" bundle:nil] forCellReuseIdentifier:@"planInfoCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];
}

- (void) toPackage {
    ServicePackageVC *serviceVC = [[ServicePackageVC alloc] init];
    [self.navigationController pushViewController:serviceVC animated:YES];
}

- (IBAction)confirmAction:(id)sender {
        AutoCheckOrderPayModeVC *orderVC = [[AutoCheckOrderPayModeVC alloc] init];
        [self.navigationController pushViewController:orderVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 5;
            break;
            
        case 1:
            return 3;
            break;
            
        case 2:
            return 2;
            break;
            
        case 3:
            return 1;
            break;
            
        case 4:
            return 2;
            break;
            
        case 5:
            return 1;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return 44;
            break;
        }
            
        default:
            return 44;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return 44;
            break;
            
        case 4:
            return 44;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
//        case 0:{
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
//            view.backgroundColor = RGBCOLOR(249, 250, 251);
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
//            label.font = [UIFont systemFontOfSize:15];
//            label.backgroundColor = [UIColor clearColor];
//            label.text = @"车辆信息";
//            [view addSubview:label];
//            return view;
//            break;
//        }
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"方案明细";
            [view addSubview:label];
            return view;
            break;
        }
            
        case 4: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"优惠";
            [view addSubview:label];
            return view;
            break;
        }
            
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.textLabel.text = @"车辆信息";
                    return cell;
                    break;
                }
                case 1: {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"粤A88888";
                    return cell;
                    break;
                }
                case 2: {
                    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.declareL.text = @"车主";
                    cell.contentL.text = @"孙先生";
                    return cell;
                    break;
                }
                case 3: {
                    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.declareL.text = @"品牌";
                    cell.contentL.text = @"奔驰";
                    return cell;
                    break;
                }
                case 4: {
                    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.declareL.text = @"车型";
                    cell.contentL.text = @"S300L";
                    return cell;
                    break;
                }
                    
                default: {
                    return nil;
                    break;
                }
            }
            break;
        }
            
        case 1: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
            break;
        }
            
        case 2: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.declareL.text = @"套餐A";
            cell.contentL.text = @"￥3000";
            return cell;
            break;
        }
            
        case 3: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            cell.declareL.text = @"总价";
            cell.contentL.text = @"￥6000";
            return cell;
            break;
        }
            
        case 4: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            cell.declareL.text = @"火花塞更换";
            cell.contentL.text = @"-￥100";
            return cell;
            break;
        }
            
        case 5: {
            UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"planNormalCell"];
            cell.declareL.text = @"折后价";
            cell.contentL.text = @"￥5500";
            return cell;
            break;
        }
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                UpkeepCarInfoVC *infoVC = [[UpkeepCarInfoVC alloc] init];
                infoVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:infoVC animated:YES];
            }
            break;
        }
            
        case 4: {
            BaoyangDiscountsVC *discountsVC = [[BaoyangDiscountsVC alloc] init];
            discountsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:discountsVC animated:YES];
            break;
        }
            
        default:
            break;
    }

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UpkeepPlanNormalCell *cell = (UpkeepPlanNormalCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"添加" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        cell.declareL.strikeThroughEnabled = NO;
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        cell.declareL.strikeThroughEnabled = YES;
        tableView.editing = NO;
    }];
    
    if (cell.declareL.strikeThroughEnabled) {
        return @[action0];
    }
    return @[action1];
}

////指定编辑模式，插入，删除
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    //单插入
//    //return UITableViewCellEditingStyleInsert ;
//    //多选删除
//    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
//}
//
////触发编辑方法；根据editingStyle来判断时那种类型
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    //删除
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        
//    }
//    
//    if (editingStyle == UITableViewCellEditingStyleInsert) {
//        //先添加
//        
//    }
//}
//
////更改删除按钮上的文本
//- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return @"删掉我吧";
//}

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
