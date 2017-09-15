//
//  AddressInfoEditVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/7.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AddressInfoEditVC.h"
#import "ChooseLocationView.h"
#import "CitiesDataTool.h"

@interface AddressInfoEditVC () <NSURLSessionDelegate,UIGestureRecognizerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@end

@implementation AddressInfoEditVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加/编辑地址";
    
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    [self.addressBtn setTitle:@"广东省 广州市 白云区" forState:UIControlStateNormal];
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

- (IBAction)selectAddressAction:(id)sender {
//    [UIView animateWithDuration:0.25 animations:^{
//        self.view.transform =CGAffineTransformMakeScale(0.95, 0.95);
//    }];
    self.cover.hidden = !self.cover.hidden;
    self.chooseLocationView.hidden = self.cover.hidden;
}

- (IBAction)defaultAction:(id)sender {
}

- (IBAction)saveAction:(id)sender {
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (CGRectContainsPoint(_chooseLocationView.frame, point)){
        return NO;
    }
    return YES;
}


- (void)tapCover:(UITapGestureRecognizer *)tap{
    
    if (_chooseLocationView.chooseFinish) {
        _chooseLocationView.chooseFinish();
    }
}

- (ChooseLocationView *)chooseLocationView{
    
    if (!_chooseLocationView) {
        _chooseLocationView = [[ChooseLocationView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 350, [UIScreen mainScreen].bounds.size.width, 350)];
        
    }
    return _chooseLocationView;
}

- (UIView *)cover{
    
    if (!_cover) {
        _cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _cover.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_cover addSubview:self.chooseLocationView];
        __weak typeof (self) weakSelf = self;
        _chooseLocationView.chooseFinish = ^{
//            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf.addressBtn setTitle:weakSelf.chooseLocationView.address forState:UIControlStateNormal];
//                weakSelf.view.transform = CGAffineTransformIdentity;
                weakSelf.cover.hidden = YES;
//            }];
        };
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCover:)];
        [_cover addGestureRecognizer:tap];
        tap.delegate = self;
        _cover.hidden = YES;
    }
    return _cover;
}

#pragma mark - 发送请求
-(void)addAddress {
    //    [_addressArray removeAllObjects];
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ConsigneeAdd object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ConsigneeAdd, @"op", nil];
    NSArray *addAry = [self.chooseLocationView.address componentsSeparatedByString:@" "];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@&name=%@&phone=%@&province=%@&city=%@&county=%@&address=%@&preferred=%@",UrlPrefix(ConsigneeAdd),@"1",self.uNameTF.text,self.phoneTF.text,addAry[1],addAry[2],addAry[3],self.addDetailTF.text,[NSNumber numberWithBool:self.defaultSW.on]];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

-(void)editAddress:(NSString *)aid {
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ConsigneeEdit object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ConsigneeEdit, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?userId=%@&id=%@",UrlPrefix(ConsigneeEdit),@"1",aid];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}


#pragma mark -
#pragma mark 网络请求数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!self.networkConditionHUD) {
            self.networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.networkConditionHUD];
        }
        self.networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        self.networkConditionHUD.mode = MBProgressHUDModeText;
        self.networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        self.networkConditionHUD.margin = HUDMargin;
        [self.networkConditionHUD show:YES];
        [self.networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:ConsigneeAdd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ConsigneeAdd object:nil];
        
//        [_addressArray addObjectsFromArray:responseObject [@"data"]];
//        
//        if ([_addressArray count]) {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 1)];
//            self.myTableView.tableHeaderView = label;
//            [self.myTableView reloadData];
//        }
//        else {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, 100)];
//            label.text = @"暂无收货地址信息";
//            label.textAlignment = NSTextAlignmentCenter;
//            label.textColor = [UIColor lightGrayColor];
//            self.myTableView.tableHeaderView = label;
//        }
    }
    
    if ([notification.name isEqualToString:ConsigneeEdit]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ConsigneeEdit object:nil];
        
        //删除成功后刷新
//        [self.myTableView headerBeginRefreshing];
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
