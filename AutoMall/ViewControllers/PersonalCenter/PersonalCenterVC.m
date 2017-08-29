//
//  PersonalCenterVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/1.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "PersonalCenterVC.h"
#import "HeadNameCell.h"
#import "CenterNormalCell.h"
#import "CenterOrderCell.h"
#import "CenterMailOrderCell.h"

@interface PersonalCenterVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation PersonalCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = RGBCOLOR(129, 129, 129);
    self.title = @"个人中心";
    [self.myTableView registerNib:[UINib nibWithNibName:@"HeadNameCell" bundle:nil] forCellReuseIdentifier:@"headNameCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterNormalCell" bundle:nil] forCellReuseIdentifier:@"centerNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterOrderCell" bundle:nil] forCellReuseIdentifier:@"centerOrderCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CenterMailOrderCell" bundle:nil] forCellReuseIdentifier:@"centerMailOrderCell"];
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return 1;
            break;
        }
        case 1: {
            return 5;
            break;
        }
        case 2: {
            return 3;
            break;
        }
        case 3: {
            return 2;
            break;
        }
        case 4: {
            return 2;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return 60;
            break;
        }
        case 1: {
            if (indexPath.row == 1) {
                return 80;
            }
            return 44;
            break;
        }
        case 2: {
            if (indexPath.row == 1) {
                return 80;
            }
            return 44;
            break;
        }
        case 3: {
            return 44;
            break;
        }
        case 4: {
            return 44;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            HeadNameCell *cell = (HeadNameCell *)[tableView dequeueReusableCellWithIdentifier:@"headNameCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
            cell.nameL.text = @"壳牌授权店";
            cell.nickNameL.text = @"店小二";
            return cell;
            break;
        }
            
        case 1:{
            switch (indexPath.row) {
                case 0: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"服务订单";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                case 1: {
                    CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                case 2: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"统计报表";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                case 3: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"定制服务";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                case 4: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"员工管理";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                default:
                    return nil;
                    break;
            }
            break;
        }
            
        case 2:{
            switch (indexPath.row) {
                case 0: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"商城订单";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                case 1: {
                    CenterOrderCell *cell = (CenterOrderCell *)[tableView dequeueReusableCellWithIdentifier:@"centerOrderCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    return cell;
                    break;
                }
                case 2: {
                    CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                    cell.nameL.text = @"商品收藏";
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    return cell;
                    break;
                }
                default:
                    return nil;
                    break;
            }
            break;
        }
            
        case 3:{
            if (indexPath.row == 0) {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.nameL.text = @"修改密码";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            }
            else {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.nameL.text = @"地址管理";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            }
            break;
        }
            
        case 4:{
            if (indexPath.row == 0) {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.nameL.text = @"免责声明";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            }
            else {
                CenterNormalCell *cell = (CenterNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"centerNormalCell"];
                cell.nameL.text = @"联系我们";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                return cell;
            }
            break;
        }
            
        default:
            return nil;
            break;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 40)];
//        //        view.backgroundColor = RGBCOLOR(249, 250, 251);
//        view.backgroundColor = [UIColor whiteColor];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 100, 20)];
//        label.font = [UIFont systemFontOfSize:15];
//        label.backgroundColor = [UIColor clearColor];
//        label.text = @"向您推荐";
//        [view addSubview:label];
//        return view;
//    }
//    return nil;
//}

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
