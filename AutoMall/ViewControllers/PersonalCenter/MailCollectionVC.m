//
//  MailCollectionVC.m
//  AutoMall
//
//  Created by LYD on 2017/9/6.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "MailCollectionVC.h"
#import "MailCollectionCell.h"
#import "CommodityDetailVC.h"

@interface MailCollectionVC ()
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation MailCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的收藏";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editMyFavoriteList:)];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MailCollectionCell" bundle:nil] forCellReuseIdentifier:@"mailCollectionCell"];
    self.myTableView.tableFooterView = [UIView new];
}

#pragma mark -
#pragma mark 点击按钮相应事件
//编辑收藏列表
-(void) editMyFavoriteList:(UIBarButtonItem *)sender{
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setTitle:@"确认"];
        [self.myTableView setEditing:YES animated:YES];
    }else{
        sender.tag = 0;
        [sender setTitle:@"编辑"];
        [self.myTableView setEditing:NO animated:YES];
        
    }
    [self.myTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
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
    MailCollectionCell *cell = (MailCollectionCell *)[tableView dequeueReusableCellWithIdentifier:@"mailCollectionCell"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        [dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        CommodityDetailVC *detailVC = [[CommodityDetailVC alloc] init];
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
