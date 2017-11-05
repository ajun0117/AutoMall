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
    NSMutableArray *categoryAry;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation AutoCheckResultProblemVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.title = @"机舱";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultSingleCell" bundle:nil] forCellReuseIdentifier:@"checkResultSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CheckResultMultiCell" bundle:nil] forCellReuseIdentifier:@"checkResultMultiCell"];
    
    categoryAry = [NSMutableArray array];
    [self requestGetCarUpkeepCategory];
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
    return categoryAry.count;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = categoryAry[indexPath.row];
    if ([dic[@"checkContentVos"][@"group"] isKindOfClass:[NSString class]]) {  //多个位置
        NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
        return 43 + 30*entities.count;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = categoryAry[indexPath.row];
    
    if ([dic[@"checkContentVos"][@"group"] isKindOfClass:[NSString class]]) {  //多个位置
        CheckResultMultiCell *cell = (CheckResultMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultMultiCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.positionL.text = dic[@"name"];
        cell.checkContentL.text = dic[@"checkContentVos"][@"name"];
        NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
        
        for (UIView *subViews in cell.positionView.subviews) {
            [subViews removeFromSuperview];
        }
        
        for (int i=0; i < entities.count; ++i) {
            NSDictionary *dic1 = entities[i];
            UILabel *position = [[UILabel alloc] initWithFrame:CGRectMake(0, 30*i , 80, 22)];
            position.text = STRING(dic1[@"dPosition"]);
            position.tag = 100 + i;
            position.textColor = [UIColor grayColor];
            position.font = [UIFont systemFontOfSize:14];
            
            UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(90, 30*i , 80, 22)];
            result.text = STRING(dic1[@"remark"]);
            result.textColor = [UIColor grayColor];
            result.font = [UIFont systemFontOfSize:14];
            
            UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 84 - 50 - 18 - 22, 30*i , 50, 22)];
            level.text = STRING(dic1[@"result"]);
            level.minimumFontSize = 8;
            level.textAlignment = NSTextAlignmentCenter;
            level.textColor = [UIColor whiteColor];
            level.backgroundColor = RGBCOLOR(0, 166, 59);
            level.font = [UIFont systemFontOfSize:13];
            level.layer.cornerRadius = 4;
            level.clipsToBounds = YES;
            int levelInt = [dic1[@"level"] intValue];
            if (levelInt == 1) {
                level.backgroundColor = [UIColor redColor];
            }
            else if (levelInt == 2) {
                level.backgroundColor = [UIColor orangeColor];
            }
            else if (levelInt == 3) {
                level.backgroundColor = [UIColor greenColor];
            }
            [cell.positionView addSubview:position];
            [cell.positionView addSubview:result];
            [cell.positionView addSubview:level];
        }

        return cell;
    }
    else {
        CheckResultSingleCell *cell = (CheckResultSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"checkResultSingleCell"];
        cell.levelL.layer.cornerRadius = 4;
        cell.positionL.text = dic[@"name"];
        cell.checkContentL.text = dic[@"checkContentVos"][@"name"];
        cell.resultL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"remark"]);
        int level = [[dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"level"] intValue];
        cell.levelL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"result"]);
        if (level == 1) {
            cell.levelL.backgroundColor = [UIColor redColor];
        }
        else if (level == 2) {
            cell.levelL.backgroundColor = [UIColor orangeColor];
        }
        else if (level == 3) {
            cell.levelL.backgroundColor = [UIColor greenColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

//CarUpkeepInfo
#pragma mark - 发送请求
-(void)requestGetCarUpkeepCategory { //检查单具体检查部位下检查结果详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepCategory object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepCategory, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&categoryId=%@",UrlPrefix(CarUpkeepCategory),@"1",@"1"];    //测试时固定传id=1的检查单
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:CarUpkeepCategory]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepCategory object:nil];
        NSLog(@"CarUpkeepCategory: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            self.title = responseObject[@"data"][@"name"];
            NSArray *checkTermVos = responseObject[@"data"][@"checkTermVos"];
            
            for (NSDictionary *dic1 in checkTermVos) {
                NSMutableArray *checkContentVosAry = [NSMutableArray array];
                NSLog(@"dic1: %@",dic1);
                NSArray *checkContentVos = dic1[@"checkContentVos"];
                for (NSDictionary *dic2 in checkContentVos) {
                    NSLog(@"dic1name%@",dic1[@"name"]);
                    NSDictionary *dic3 = @{@"name":dic1[@"name"],@"checkContentVos":dic2};
                    [checkContentVosAry addObject:dic3];
                }
                [categoryAry addObjectsFromArray:checkContentVosAry];
            }
            NSLog(@"categoryAry: %@",categoryAry);
            [self.myTableView reloadData];
        }
        else {
            _networkConditionHUD.labelText = STRING([responseObject objectForKey:MSG]);
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
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
