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
    self.title = self.carDic[@"plateNumber"];
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"UpkeepPlanNormalCell" bundle:nil] forCellReuseIdentifier:@"planNormalCell"];
    self.myTableView.tableFooterView = [UIView new];

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0: {
            cell.declareL.text = @"车主";
            cell.contentL.text = STRING(self.carDic[@"owner"]);
            break;
        }
        case 1: {
            cell.declareL.text = @"品牌";
            cell.contentL.text = STRING(self.carDic[@"brand"]);
            break;
        }
        case 2: {
            cell.declareL.text = @"车型";
            cell.contentL.text = STRING(self.carDic[@"model"]);
            break;
        }
        case 3: {
            cell.declareL.text = @"年款";
            if (! [self.carDic[@"purchaseDate"] isKindOfClass:[NSNull class]]) {
                NSDateFormatter* formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy"];
                NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[self.carDic[@"purchaseDate"] doubleValue]/1000];
                NSString *string = [formater stringFromDate:creatDate];
                cell.contentL.text = string;
            }
            break;
        }
        case 4: {
            cell.declareL.text = @"行驶里程";
            cell.contentL.text = NSStringWithNumber(self.mileage);
            break;
        }
        case 5: {
            cell.declareL.text = @"燃油量";
            if ([self.fuelAmount isKindOfClass:[NSNull class]]) {
                cell.contentL.text = @"";
            } else {
                cell.contentL.text = [NSString stringWithFormat:@"%@%%",self.fuelAmount];
            }
            break;
        }
        case 6: {
            cell.declareL.text = @"初次建档时间";
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[self.carDic[@"createTime"] doubleValue]/1000];
            NSString *string = [formater stringFromDate:creatDate];
            cell.contentL.text = string;
            break;
        }
        case 7: {
            cell.declareL.text = @"上次保养时间";
            if (! [self.lastEndTime isKindOfClass:[NSNull class]] && [self.lastEndTime doubleValue] > 0) {
                NSDateFormatter* formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd"];
                NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[self.lastEndTime doubleValue]/1000];
                NSString *string = [formater stringFromDate:creatDate];
                cell.contentL.text = string;
            } else {
                cell.contentL.text = @"";
            }
            break;
        }
        case 8: {
            cell.declareL.text = @"上次保养里程";
            cell.contentL.text = NSStringWithNumber(self.lastMileage);
            break;
        }
            
        default:
            break;
    }
    
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
