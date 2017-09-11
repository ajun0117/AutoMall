//
//  AddCarInfoVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/14.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddCarInfoVC.h"
#import "AddCarInfoCell.h"
#import "BaoyangHistoryVC.h"
#import "AutoCheckVC.h"

@interface AddCarInfoVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AddCarInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"车辆信息";

    [self.myTableView registerNib:[UINib nibWithNibName:@"AddCarInfoCell" bundle:nil] forCellReuseIdentifier:@"addCarCell"];
    self.myTableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 44, 44);
    [searchBtn setImage:[UIImage imageNamed:@"baoyang_history"] forState:UIControlStateNormal];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [searchBtn addTarget:self action:@selector(toHistoryList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, searchBtnBarBtn, nil];

}

-(void) toHistoryList {
    BaoyangHistoryVC *historyVC = [[BaoyangHistoryVC alloc] init];
    historyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVC animated:YES];
}

- (IBAction)saveAction:(id)sender {
}

- (IBAction)selectAction:(id)sender {
    AutoCheckVC *checkVC = [[AutoCheckVC alloc] init];
    checkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:checkVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 5;
            break;
            
        case 2:
            return 6;
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
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return 44;
            break;
            
        case 2:
            return 44;
            break;
            
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
            
        case 1: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"车主信息";
            [view addSubview:label];
            return view;
            break;
        }
            
        case 2: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 44)];
            view.backgroundColor = RGBCOLOR(249, 250, 251);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 100, 20)];
            label.font = [UIFont systemFontOfSize:15];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"车辆信息";
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
    AddCarInfoCell *cell = (AddCarInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"addCarCell"];
    //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"行驶里程";
                    cell.contentTF.placeholder = @"行驶里程";
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"燃油量";
                    cell.contentTF.placeholder = @"燃油量";
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"姓名";
                    cell.contentTF.placeholder = @"姓名";
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"电话";
                    cell.contentTF.placeholder = @"电话";
                    break;
                }
                case 2: {
                    cell.declareL.text = @"微信";
                    cell.contentTF.placeholder = @"微信";
                    break;
                }
                case 3: {
                    cell.declareL.text = @"性别";
                    cell.contentTF.placeholder = @"性别";
                    break;
                }
                case 4: {
                    cell.declareL.text = @"生日";
                    cell.contentTF.placeholder = @"生日";
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    cell.declareL.text = @"车牌号";
                    cell.contentTF.placeholder = @"车牌号";
                    break;
                }
                    
                case 1: {
                    cell.declareL.text = @"品牌";
                    cell.contentTF.placeholder = @"品牌";
                    break;
                }
                case 2: {
                    cell.declareL.text = @"车型";
                    cell.contentTF.placeholder = @"车型";
                    break;
                }
                case 3: {
                    cell.declareL.text = @"购买时间";
                    cell.contentTF.placeholder = @"购买时间";
                    break;
                }
                case 4: {
                    cell.declareL.text = @"发动机号";
                    cell.contentTF.placeholder = @"发动机号";
                    break;
                }
                case 5: {
                    cell.declareL.text = @"车架号";
                    cell.contentTF.placeholder = @"车架号";
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    
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
