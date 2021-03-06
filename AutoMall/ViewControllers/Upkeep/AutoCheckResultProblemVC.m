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
    
    if (self.isUnnormal) {      //所有异常项目
        [self requestGetAllUnnormal];
    } else {
        [self requestGetCarUpkeepCategory];
    }
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
    NSString *groupStr = dic[@"checkContentVos"][@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && groupStr.length > 0) {  //多个位置
        NSArray *entities = dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"];
        return 43 + 30*entities.count;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = categoryAry[indexPath.row];
    NSString *groupStr = dic[@"checkContentVos"][@"group"];
    if ([groupStr isKindOfClass:[NSString class]] && groupStr.length > 0) {  //多个位置
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
            
            UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 106 - 8 - 16 - 55 - 15 - 80, 30*i , 80, 22)];
            result.text = STRING(dic1[@"describe"]);
            result.textColor = [UIColor grayColor];
            result.font = [UIFont systemFontOfSize:14];
            
            UILabel *level = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH- 106 - 8 - 16 - 55 , 30*i , 55, 22)];
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
                level.backgroundColor = RGBCOLOR(250, 69, 89);
            }
            else if (levelInt == 2) {
                level.backgroundColor = RGBCOLOR(249, 182, 48);
            }
            else if (levelInt == 3) {
                level.backgroundColor = RGBCOLOR(71, 188, 92);
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
        cell.resultL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"describe"]);
        int level = [[dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"level"] intValue];
        cell.levelL.text = STRING([dic[@"checkContentVos"][@"carUpkeepCheckContentEntities"] firstObject][@"result"]);
        if (level == 1) {
            cell.levelL.backgroundColor = RGBCOLOR(250, 69, 89);
        }
        else if (level == 2) {
            cell.levelL.backgroundColor = RGBCOLOR(249, 182, 48);
        }
        else if (level == 3) {
            cell.levelL.backgroundColor = RGBCOLOR(71, 188, 92);
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = categoryAry[indexPath.row];
    AutoCheckResultDetailVC *detailVC = [[AutoCheckResultDetailVC alloc] init];
    detailVC.checkId = self.carUpkeepId;
    detailVC.checkTermId = dic[@"id"];
    detailVC.checkContentId = dic[@"checkContentVos"][@"id"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

//CarUpkeepInfo
#pragma mark - 发送请求
-(void)requestGetCarUpkeepCategory { //检查单具体检查部位下检查结果详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepCategory object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepCategory, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@&categoryId=%@",UrlPrefix(CarUpkeepCategory),self.carUpkeepId,self.categoryId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)requestGetAllUnnormal { //获取所有异常，或轮胎刹车片相关
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CarUpkeepUnnormal object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CarUpkeepUnnormal, @"op", nil];
    NSString *urlString;
    if (self.isTyre) {
        urlString = [NSString stringWithFormat:@"%@?id=%@&condition=%@",UrlPrefix(CarUpkeepUnnormal),self.carUpkeepId,@"0"];
    } else {
        urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefix(CarUpkeepUnnormal),self.carUpkeepId];
    }
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
                    NSDictionary *dic3 = @{@"id":dic1[@"id"],@"name":dic1[@"name"],@"checkContentVos":dic2};
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
    
    if ([notification.name isEqualToString:CarUpkeepUnnormal]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CarUpkeepUnnormal object:nil];
        NSLog(@"CarUpkeepUnnormal: %@",responseObject);
        if ([responseObject[@"success"] isEqualToString:@"y"]) {  //返回正确
            if (self.isTyre) {
                self.title = @"轮胎刹车盘";
            } else {
                self.title = @"所有异常项";
            }
            
            NSArray *checkTermVos = responseObject[@"data"];
            
            for (NSDictionary *dic1 in checkTermVos) {
                NSMutableArray *checkContentVosAry = [NSMutableArray array];
                NSLog(@"dic1: %@",dic1);
                NSArray *checkContentVos = dic1[@"checkContentVos"];
                for (NSDictionary *dic2 in checkContentVos) {
                    NSLog(@"dic1name%@",dic1[@"name"]);
                    NSDictionary *dic3 = @{@"id":dic1[@"id"],@"name":dic1[@"name"],@"checkContentVos":dic2};
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
