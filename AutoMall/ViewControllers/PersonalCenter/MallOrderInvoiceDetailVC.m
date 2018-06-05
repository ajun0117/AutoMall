//
//  MallOrderInvoiceDetailVC.m
//  AutoMall
//
//  Created by LYD on 2018/6/5.
//  Copyright © 2018年 redRay. All rights reserved.
//

#import "MallOrderInvoiceDetailVC.h"
#import "MallOrderInvoiceDetailCell.h"

@interface MallOrderInvoiceDetailVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *invoiceDic;  //发票详情数据
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MallOrderInvoiceDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发票详情";
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:NavBarTintColor];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MallOrderInvoiceDetailCell" bundle:nil] forCellReuseIdentifier:@"mallOrderInvoiceDetailCell"];
    
    [self requestGetInvoiceDetail];   //获取订单详情数据
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        break;
            
        case 1:
        {
            switch ([invoiceDic[@"type"] intValue]) {
                case 0:
                    return 1;
                    break;
                    
                    case 1:
                    return 2;
                    break;
                    
                    case 2:
                    return 6;
                    break;
                    
                default:
                    return 0;
                    break;
            }
        }
            break;
            
        case 2:
            return 4;
            break;
            
        case 3:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MallOrderInvoiceDetailCell *cell = (MallOrderInvoiceDetailCell *)[tableView dequeueReusableCellWithIdentifier:@"mallOrderInvoiceDetailCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                cell.titleL.text = @"开票日期";
                NSDateFormatter* formater = [[NSDateFormatter alloc] init];
                [formater setDateFormat:@"yyyy-MM-dd h:m"];
                NSDate *creatDate = [NSDate dateWithTimeIntervalSince1970:[invoiceDic[@"uTime"] doubleValue]/1000];
                NSString *string = [formater stringFromDate:creatDate];
                cell.contentTF.text = string;
                return cell;
            }
            else if (indexPath.row == 1) {
                cell.titleL.text = @"发票类型";
                if ([invoiceDic[@"type"] intValue] == 0) {
                    cell.contentTF.text = @"普通发票 个人";
                }
                else if ([invoiceDic[@"type"] intValue] == 1) {
                    cell.contentTF.text = @"普通发票 企业";
                }
                else {
                    cell.contentTF.text = @"增值税专用发票";
                }
                return cell;
            }
        }
            break;
            
        case 1:
        {
            switch ([invoiceDic[@"type"] intValue]) {
                case 0: {
                    if (indexPath.row == 0) {
                        cell.titleL.text = @"发票抬头";
                        cell.contentTF.text = invoiceDic[@"head"];
                        return cell;
                    }
                }
                    break;
                    
                case 1: {
                    if (indexPath.row == 0) {
                        cell.titleL.text = @"发票抬头";
                        cell.contentTF.text = invoiceDic[@"head"];
                        return cell;
                    } else if (indexPath.row == 1) {
                        cell.titleL.text = @"纳税人识别号";
                        cell.contentTF.text = invoiceDic[@"taxpayerCode"];
                        return cell;
                    }
                }
                    break;
                    
                case 2: {
                    if (indexPath.row == 0) {
                        cell.titleL.text = @"发票抬头";
                        cell.contentTF.text = invoiceDic[@"head"];
                        return cell;
                    } else if (indexPath.row == 1) {
                        cell.titleL.text = @"纳税人识别号";
                        cell.contentTF.text = invoiceDic[@"taxpayerCode"];
                        return cell;
                    }
                    else if (indexPath.row == 2) {
                        cell.titleL.text = @"注册地址";
                        cell.contentTF.text = invoiceDic[@"registAddr"];
                        return cell;
                    }
                    else if (indexPath.row == 3) {
                        cell.titleL.text = @"注册电话";
                        cell.contentTF.text = invoiceDic[@"registPhone"];
                        return cell;
                    }
                    else if (indexPath.row == 4) {
                        cell.titleL.text = @"开户银行";
                        cell.contentTF.text = invoiceDic[@"depositBank"];
                        return cell;
                    }
                    else if (indexPath.row == 5) {
                        cell.titleL.text = @"银行账号";
                        cell.contentTF.text = invoiceDic[@"bankAccount"];
                        return cell;
                    }
                }
                    break;
                    
                default:
                    return nil;
                    break;
            }
        }
            break;
            
        case 2: {
            if (indexPath.row == 0) {
                cell.titleL.text = @"收票人姓名";
                cell.contentTF.text = invoiceDic[@"realName"];
                return cell;
            }
            else if (indexPath.row == 1) {
                cell.titleL.text = @"收票人手机";
                cell.contentTF.text = invoiceDic[@"registPhone"];
                return cell;
            }
            else if (indexPath.row == 2) {
                cell.titleL.text = @"收票人所在地区";
                cell.contentTF.text = [NSString stringWithFormat:@"%@ %@ %@",invoiceDic[@"province"],invoiceDic[@"city"],invoiceDic[@"addr"]];
                return cell;
            }
            else if (indexPath.row == 3) {
                cell.titleL.text = @"详细地址";
                cell.contentTF.text = invoiceDic[@"addr"];
                return cell;
            }
        }
            break;
            
        case 3: {
            cell.titleL.text = @"收票人邮箱";
            cell.contentTF.text = invoiceDic[@"email"];
            return cell;
        }
            break;
            
        default:
            return nil;
            break;
    }
    return nil;
}

#pragma mark - 发送请求
-(void)requestGetInvoiceDetail { //发票详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:OrderInvoiceDetail object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:OrderInvoiceDetail, @"op", nil];
    NSString *urlString = [NSString stringWithFormat:@"%@?id=%@",UrlPrefixNew(OrderInvoiceDetail),self.orderId];
    [[DataRequest sharedDataRequest] getDataWithUrl:urlString delegate:nil params:nil info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:OrderInvoiceDetail]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OrderInvoiceDetail object:nil];
        if ([responseObject[@"meta"][@"msg"] isEqualToString:@"success"]) {
            invoiceDic = responseObject[@"body"][@"data"];
            [self.myTableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:STRING([responseObject objectForKey:MSG]) delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
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
