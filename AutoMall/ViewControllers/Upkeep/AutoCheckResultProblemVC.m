//
//  AutoCheckResultProblemVC.m
//  AutoMall
//
//  Created by LYD on 2017/10/27.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckResultProblemVC.h"
#import "CheckResultSingleCell.h"
#import "CheckResultMultiCell.h"
#import "AutoCheckResultDetailVC.h"

@interface AutoCheckResultProblemVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckResultProblemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"机舱";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return  206;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
        if (! label) {
            for (int i=0; i<4; ++i) {
                UILabel *position = [[UILabel alloc] initWithFrame:CGRectMake(0, 36*i , 80, 22)];
                position.text = @"左前";
                position.tag = 100 + i;
                position.textColor = [UIColor grayColor];
                position.font = [UIFont systemFontOfSize:14];
                
                UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(90, 36*i , 80, 22)];
                result.text = @"262kpa";
                result.textColor = [UIColor grayColor];
                result.font = [UIFont systemFontOfSize:14];
                
                UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 84 - 50 - 18, 36*i , 50, 22)];
                level.text = @"正常";
                level.textAlignment = NSTextAlignmentCenter;
                level.textColor = [UIColor whiteColor];
                level.backgroundColor = RGBCOLOR(0, 166, 59);
                level.font = [UIFont systemFontOfSize:13];
                level.layer.cornerRadius = 4;
                level.clipsToBounds = YES;
                
                [cell.positionView addSubview:position];
                [cell.positionView addSubview:result];
                [cell.positionView addSubview:level];
            }
        }
        return cell;
    }
    else {
        CheckResultSingleCell *cell = (CheckResultSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultSingleCell"];
        cell.levelL.layer.cornerRadius = 4;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
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
