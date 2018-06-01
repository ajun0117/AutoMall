//
//  AddInvoiceVC.m
//  AutoMall
//
//  Created by 李俊阳 on 2018/6/1.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "AddInvoiceVC.h"

@interface AddInvoiceVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}
@property (weak, nonatomic) IBOutlet UIButton *plainInvoiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *valueAddedInvoiceBtn;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end

@implementation AddInvoiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"新增发票";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.plainInvoiceBtn setImage:[UIImage imageNamed:@"btn_check"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.plainInvoiceBtn.layer.cornerRadius = 2;
    self.plainInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    self.plainInvoiceBtn.layer.borderWidth = 1;
    [self.plainInvoiceBtn addTarget:self action:@selector(plainInvoiceAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.valueAddedInvoiceBtn setImage:[UIImage imageNamed:@"btn_check"] forState:UIControlStateSelected | UIControlStateHighlighted];
    self.valueAddedInvoiceBtn.layer.cornerRadius = 2;
    self.valueAddedInvoiceBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.valueAddedInvoiceBtn.layer.borderWidth = 1;
    [self.valueAddedInvoiceBtn addTarget:self action:@selector(valueAddedInvoiceAction) forControlEvents:UIControlEventTouchUpInside];
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

-(void)plainInvoiceAction {
    self.plainInvoiceBtn.selected = YES;
    self.plainInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    
    self.valueAddedInvoiceBtn.selected = NO;
    self.valueAddedInvoiceBtn.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)valueAddedInvoiceAction {
    self.valueAddedInvoiceBtn.selected = YES;
    self.valueAddedInvoiceBtn.layer.borderColor = RGBCOLOR(234, 0, 24).CGColor;
    
    self.plainInvoiceBtn.selected = NO;
    self.plainInvoiceBtn.layer.borderColor = [UIColor blackColor].CGColor;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return listAry.count;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    InvoiceListCell *cell = (InvoiceListCell *)[tableView dequeueReusableCellWithIdentifier:@"invoiceListCell"];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    if (listAry.count > 0) {
//        NSDictionary *dic = listAry[indexPath.section];
//        cell.taitouL.text = dic [@"head"];
//        NSString *name = dic [@"realName"];
//        NSString *phone = dic [@"phone"];
//        NSString *email = dic [@"email"];
//        cell.detailL.text = [NSString stringWithFormat:@"%@/%@/%@",name,phone,email];
//        BOOL preferred = [dic [@"def"] boolValue];
//        if (preferred) {
//            cell.defaultL.hidden = NO;
//        }
//        else {
//            cell.defaultL.hidden = YES;
//        }
//    }
    
//    return cell;
    return nil;
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
