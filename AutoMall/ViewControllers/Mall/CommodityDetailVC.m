//
//  CommodityDetailVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/21.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "CommodityDetailVC.h"
#import "MXScrollView.h"
#import "CommodityDetailNormalCell.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
static CGFloat const scrollViewHeight = 220;

@interface CommodityDetailVC () <MXScrollViewDelegate>
{
    MXImageScrollView *scroll;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation CommodityDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商品详情";
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailNormalCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailNormalCell"];
    
    scroll = [[MXImageScrollView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 Screen_Width,
                                                                 scrollViewHeight)
                                        rootTableView:self.myTableView];
    scroll.delegate = self;
    scroll.images = @[[UIImage imageNamed:@"picture_1"],
                      [UIImage imageNamed:@"picture_2"],
                      [UIImage imageNamed:@"picture_3"]];
    
    [scroll setTapImageHandle:^(NSInteger index) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[NSString
                                                                     stringWithFormat:@"你点击了%ld张图片", index]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
    }];
    
    [scroll setDidScrollImageViewAtIndexHandle:^(NSInteger index) {
        NSLog(@"滑动到了第%ld页", index);
    }];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
#warning 想拉伸必须实现此方法
    [scroll stretchingSubviews];
}

#pragma mark - MXScrollView delegate
- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForLeftAccessoryViewAtIndex:(NSInteger)index {
    //    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,
    //                                                                               scrollViewHeight - 40,
    //                                                                               30,
    //                                                                               30)];
    //    leftImageView.image = [UIImage imageNamed:@"house"];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollViewHeight - 50, 200,50)];
    bgView.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200,30)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.3;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"新闻标题 新闻标题";
    [bgView addSubview:view];
    [bgView addSubview:label];
    return bgView;
}

- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForRightAccessoryViewAtIndex:(NSInteger)index {
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - 40,
                                                                                scrollViewHeight - 40,
                                                                                30,
                                                                                30)];
    rightImageView.image = [UIImage imageNamed:@"island"];
    return rightImageView;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView leftAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView rightAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - tableVeiw delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommodityDetailNormalCell *cell = (CommodityDetailNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailNormalCell"];
//    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    cell.nameL.text = [NSString stringWithFormat:@"%ld", indexPath.row];
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
