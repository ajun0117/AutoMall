//
//  MailOrderListVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailOrderListVC.h"
#import "MailOrderSingleCell.h"
#import "MailOrderMultiCell.h"
#import "MailOrderDetailVC.h"

@interface MailOrderListVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailOrderListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商城订单";
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderSingleCell" bundle:nil] forCellReuseIdentifier:@"mailOrderSingleCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailOrderMultiCell" bundle:nil] forCellReuseIdentifier:@"mailOrderMultiCell"];
    self.myTableView.tableFooterView = [UIView new];
}

- (IBAction)daifuAction:(id)sender {
    [self setButton:self.daifuBtn withBool:YES andView:self.daifuView withColor:Red_BtnColor];
    [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
    [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
}

- (IBAction)yifuAction:(id)sender {
        [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
        [self setButton:self.yifuBtn withBool:YES andView:self.yifuView withColor:Red_BtnColor];
        [self setButton:self.allBtn withBool:NO andView:self.allView withColor:[UIColor clearColor]];
}

- (IBAction)allAction:(id)sender {
        [self setButton:self.daifuBtn withBool:NO andView:self.daifuView withColor:[UIColor clearColor]];
        [self setButton:self.yifuBtn withBool:NO andView:self.yifuView withColor:[UIColor clearColor]];
        [self setButton:self.allBtn withBool:YES andView:self.allView withColor:Red_BtnColor];
}

-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
        btn.selected = bo;
        view.backgroundColor = color;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 178;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        MailOrderMultiCell *cell = (MailOrderMultiCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderMultiCell"];
        cell.picScrollView.contentSize = CGSizeMake((60+10) * 3, 60);
        for (int i = 0; i < 3; ++i) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(i*(60+10), 0, 60, 60)];
            img.image = IMG(@"timg-2");
            [cell.picScrollView addSubview:img];
        }
        return cell;
    }
    MailOrderSingleCell *cell = (MailOrderSingleCell *)[tableView dequeueReusableCellWithIdentifier:@"mailOrderSingleCell"];
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //        [dataArray removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        MailOrderDetailVC *detailVC = [[MailOrderDetailVC alloc] init];
//        detailVC.userID = userArray[indexPath.section][@"id"];
//        detailVC.isDrink = self.isDrink;
//        detailVC.slidePlaceDetail = self.slidePlaceDetail;
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
