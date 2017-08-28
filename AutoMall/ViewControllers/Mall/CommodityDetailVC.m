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
#import "CommodityDetailStarCell.h"
#import "CommodityDetailPriceCell.h"
#import "CommodityDetailTapCell.h"
#import "CommodityDetailContentCell.h"
#import "CommodityDetailTuijianCell.h"
#import "SettlementView.h"
#import "ShoppingCartView.h"
#import "SettlementVC.h"
#import "WRNavigationBar.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width
static CGFloat const scrollViewHeight = 220;
#define Interval_Hobby  5   //标签之间的间隔
#define Space_Hobby     12  //标签超出文本的宽度
#define NAVBAR_COLORCHANGE_POINT (scrollViewHeight - NAV_HEIGHT)
#define NAV_HEIGHT 64

@interface CommodityDetailVC () <MXScrollViewDelegate>
{
    MXImageScrollView *scroll;
    NSInteger allCount; //轮播图总数
    CALayer *_layer;
    NSInteger _cnt;
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
//底部菜单
@property (strong, nonatomic) SettlementView *settemntView;
//抛物线红点
@property (strong, nonatomic) UIImageView *redView;
//购物弹出来的视图
@property (strong, nonatomic) ShoppingCartView *shoppingCartView;
//购物车视图删除还是加载
@property (assign, nonatomic) BOOL isShopping;

@end

@implementation CommodityDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商品详情";
    
    // 设置导航栏颜色
    [self wr_setNavBarBarTintColor:RGBCOLOR(247, 247, 247)];
    
    // 设置初始导航栏透明度
    [self wr_setNavBarBackgroundAlpha:0];
    
    // 设置导航栏按钮和标题颜色
    [self wr_setNavBarTintColor:[UIColor darkGrayColor]];
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailNormalCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailNormalCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailStarCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailStarCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailPriceCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailPriceCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailTapCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailTapCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailContentCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailContentCell"];
    [self.myTableView registerNib:[UINib nibWithNibName:@"CommodityDetailTuijianCell" bundle:nil] forCellReuseIdentifier:@"commodityDetailTuijianCell"];
    
    allCount = 3;
    scroll = [[MXImageScrollView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, scrollViewHeight) rootTableView:self.myTableView];
    scroll.delegate = self;
    scroll.images = @[[UIImage imageNamed:@"timg-1"],
                      [UIImage imageNamed:@"timg-2"],
                      [UIImage imageNamed:@"timg-1"]];
    
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
    
    [self addFootView];
}

- (void)addFootView{
    self.settemntView = [[SettlementView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 55, Screen_wide, 55)];
    self.settemntView.number.text = @"0";
    [self.settemntView.settlement addTarget:self action:@selector(settlementClock) forControlEvents:UIControlEventTouchUpInside];
    [self.settemntView.shoppingCart addTarget:self action:@selector(shoppingCartClock) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settemntView];
}

#pragma mark -- 去结算
- (void)settlementClock{
    
    SettlementVC *settlement = [[SettlementVC alloc] init];
//    settlement.datasArr = self.myTableView.orderArr;
    NSArray *arr = @[@{@"name":@"磁护",@"current_price":@"320.00",@"orderCont":@"2"},@{@"name":@"极护",@"current_price":@"520.00",@"orderCont":@"1"}];
    settlement.datasArr = [arr mutableCopy];
    settlement.GoBack = ^{
        
//        [weakSelf updateShoppingCart:self.popTableView.orderArr];
        
    };
    [self.navigationController pushViewController:settlement animated:YES];
}
#pragma mark -- 购物车按钮
- (void)shoppingCartClock{
    
    __weak typeof(self) weakSelf = self;
    
    if (!_isShopping)
    {
        self.settemntView.backgroundColor = RGBCOLOR(239, 239, 244);
        self.shoppingCartView =[[ShoppingCartView alloc]init];
        self.shoppingCartView.frame =CGRectMake(0, Screen_heigth, Screen_wide,self.view.bounds.size.height-CGRectGetHeight(self.settemntView.frame));
        
        UIView *bgView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_wide,self.view.bounds.size.height-CGRectGetHeight(self.settemntView.frame))];
        bgView.alpha = .7;
        bgView.tag = 111;
        bgView.backgroundColor =[UIColor lightGrayColor];
        [self.view addSubview:bgView];
        self.shoppingCartView.block = ^(NSMutableArray *darasArr){
            
            [weakSelf updateShoppingCart:darasArr];
        };
        
        [self.shoppingCartView addShoppingCartView:self];
        [UIView animateWithDuration:.3 animations:^{
            
            self.shoppingCartView.frame =CGRectMake(0, 0, Screen_wide,self.view.bounds.size.height-CGRectGetHeight(self.settemntView.frame));
            NSArray *arr = @[@{@"name":@"磁护",@"current_price":@"320.00",@"orderCont":@"2"},@{@"name":@"极护",@"current_price":@"520.00",@"orderCont":@"1"}];
            self.shoppingCartView.datasArr = [arr mutableCopy];
        } completion:^(BOOL finished)
         {
             
             
         }];
        
    }
    else{
        self.settemntView.backgroundColor = [UIColor clearColor];
        [self.shoppingCartView removeSubView:self];
    }
    _isShopping = !_isShopping;
    
}

#pragma mark -- 更新 数量 价钱
- (void)updateShoppingCart:(NSMutableArray *)darasArr{
    
    __weak typeof(self) weakSelf = self;
    
    weakSelf.settemntView.number.text  = [NSString stringWithFormat:@"%d",2];
    weakSelf.settemntView.money.text = [NSString stringWithFormat:@"￥%.2f",30.0];
    
//    [weakSelf.popTableView.rightTableView reloadData];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
#warning 想拉伸必须实现此方法
    [scroll stretchingSubviews];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    NSLog(@"offsetY: %f",offsetY);
    if ((offsetY + 220) >= 156)
    {
//        CGFloat alpha = (offsetY + 220 - NAVBAR_COLORCHANGE_POINT) / NAV_HEIGHT;
        CGFloat alpha = (offsetY + 220) / 156;
        [self wr_setNavBarBackgroundAlpha:alpha];
        [self wr_setNavBarTintColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
        [self wr_setNavBarTitleColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
        [self wr_setStatusBarStyle:UIStatusBarStyleDefault];
        self.title = @"商品详情";
    }
    else
    {
        [self wr_setNavBarBackgroundAlpha:0];
        [self wr_setNavBarTintColor:[UIColor whiteColor]];
        [self wr_setNavBarTitleColor:[UIColor whiteColor]];
        [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
        self.title = @"";
    }

}

#pragma mark - MXScrollView delegate
- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForLeftAccessoryViewAtIndex:(NSInteger)index {
    //    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,
    //                                                                               scrollViewHeight - 40,
    //                                                                               30,
    //                                                                               30)];
    //    leftImageView.image = [UIImage imageNamed:@"house"];
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, scrollViewHeight - 50, 200,50)];
//    bgView.backgroundColor = [UIColor clearColor];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200,30)];
//    view.backgroundColor = [UIColor blackColor];
//    view.alpha = 0.3;
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont systemFontOfSize:15];
//    label.text = @"新闻标题 新闻标题";
//    [bgView addSubview:view];
//    [bgView addSubview:label];
//    return bgView;
    return nil;
}

- (UIView *)MXScrollView:(MXImageScrollView *)mxScrollView viewForRightAccessoryViewAtIndex:(NSInteger)index {
//    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen_Width - 40,
//                                                                                scrollViewHeight - 40,
//                                                                                30,
//                                                                                30)];
//    rightImageView.image = [UIImage imageNamed:@"island"];
//    return rightImageView;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(Screen_Width - 50, scrollViewHeight - 50, 30,50)];
    bgView.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.3;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    NSString *num = [NSString stringWithFormat:@"%ld/%ld",(long)index+1,allCount];
    label.text = num;
    [bgView addSubview:view];
    [bgView addSubview:label];
    return bgView;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView leftAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

- (UIViewAutoresizing)MXScrollView:(MXImageScrollView *)mxScrollView rightAccessoryViewAutoresizingMaskAtIndex:(NSInteger)index {
    return UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark - tableVeiw delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 4) {
            return 60;
        }
        else {
            return 44;
        }
    }
    else {
        return 80;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    CommodityDetailNormalCell *cell = (CommodityDetailNormalCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailNormalCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    //    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
                    cell.nameL.text = @"壳牌灰喜力";
                    return cell;
                    break;
                }
                case 1: {
                    CommodityDetailStarCell *cell = (CommodityDetailStarCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailStarCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.pingxingRV.rate = 4.5;
                    cell.pingxingRV.maxRate = 5;
                    return cell;
                    break;
                }
                case 2: {
                    CommodityDetailPriceCell *cell = (CommodityDetailPriceCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailPriceCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.costPriceStrikeL.strikeThroughEnabled = YES;
                    return cell;
                    break;
                }
                case 3: {
                    CommodityDetailTapCell *cell = (CommodityDetailTapCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailTapCell"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    for (UIView *view in cell.hobbyScrollView.subviews) {
                        [view removeFromSuperview];
                    }
//                    NSString *hobbyStr = userDetailDic [@"hobby"];
//                    NSArray *hobbyAry = [hobbyStr componentsSeparatedByString:@","];
                    NSArray *hobbyAry = @[@"标签",@"标签",@"标签",@"标签",@"标签"];
                    CGFloat originX = 0;
                    for (int i = 0; i < hobbyAry.count; ++i) {
                        NSString *str = hobbyAry[i];
                        CGSize size =  [str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}]; //根据字体计算出文本单行的长度和高度（宽度和高度），注意是单行，所以你返回的高度是一个定值。
                        UILabel *label = nil;
                        if (i == 0) {
                            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, size.width+Space_Hobby, 16)];
                            originX = VIEW_BX(label);   //存储当前label的横向位
                        }
                        else {
                            label = [[UILabel alloc] initWithFrame:CGRectMake(originX + Interval_Hobby, 2, size.width+Space_Hobby, 16)];
                            originX = VIEW_BX(label);   //存储当前label的横向位置
                        }
                        label.layer.cornerRadius = 8;   //圆角
                        label.clipsToBounds = YES;
                        label.backgroundColor = [UIColor blackColor];
                        label.textColor = [UIColor whiteColor];
                        label.font = [UIFont systemFontOfSize:12];
                        label.text = str;
                        label.textAlignment = NSTextAlignmentCenter;
                        [cell.hobbyScrollView addSubview:label];
                    }
                    cell.hobbyScrollView.contentSize = CGSizeMake(originX, 16);
                    return cell;
                    break;
                }
                case 4: {
                    CommodityDetailContentCell *cell = (CommodityDetailContentCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailContentCell"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                    break;
                }
                    
                default:
                    return nil;
                    break;
            }
            break;
        }
            
        case 1:{
            CommodityDetailTuijianCell *cell = (CommodityDetailTuijianCell *)[tableView dequeueReusableCellWithIdentifier:@"commodityDetailTuijianCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
            
        default:
            return nil;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 40)];
//        view.backgroundColor = RGBCOLOR(249, 250, 251);
         view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 100, 20)];
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"向您推荐";
        [view addSubview:label];
        return view;
     }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


// 添加动画以及数量
- (void)setNum:(int)num index:(NSIndexPath *)index{
    CommodityDetailPriceCell *cell = [self.myTableView cellForRowAtIndexPath:index];
    CGRect parentRectA = [cell convertRect:cell.addBtn.frame toView:self.settemntView];
    [self startAnimationWithRect:parentRectA ImageView:self.redView];
}

-(void)startAnimationWithRect:(CGRect)rect ImageView:(UIImageView *)imageView
{
    if (!_layer) {
        //        _btn.enabled = NO;
        _layer = [CALayer layer];
        _layer.contents = (id)imageView.layer.contents;
        
        _layer.contentsGravity = kCAGravityResizeAspectFill;
        _layer.bounds = rect;
        //        [_layer setCornerRadius:CGRectGetHeight([_layer bounds]) / 2];
        _layer.masksToBounds = YES;
        // 导航64
        _layer.position = CGPointMake(rect.origin.x, CGRectGetMidY(rect));
        //        [_tableView.layer addSublayer:_layer];
        [self.myTableView.layer addSublayer:_layer];
        
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path moveToPoint:_layer.position];
        //        (SCREEN_WIDTH - 60), 0, -50, 50)
        [path addQuadCurveToPoint:CGPointMake(38, Screen_heigth - 40) controlPoint:CGPointMake(Screen_wide/4,rect.origin.y-80)];
        //        [_path addLineToPoint:CGPointMake(SCREEN_WIDTH-40, 30)];
        [self groupAnimation:(path)];
    }
}
-(void)groupAnimation:(UIBezierPath*)path{
    self.myTableView.userInteractionEnabled = NO;
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.1f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:1];
    expandAnimation.toValue = [NSNumber numberWithFloat:1.3f];
    expandAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.1;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:1.3f];
    narrowAnimation.duration = 0.4f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.3f];
    
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation,expandAnimation,narrowAnimation];
    groups.duration = 0.5f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self.myTableView;
    [_layer addAnimation:groups forKey:@"group"];
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    if (anim == [_layer animationForKey:@"group"]) {
        self.myTableView.userInteractionEnabled = YES;
        //        _btn.enabled = YES;
        [_layer removeFromSuperlayer];
        _layer = nil;
        _cnt++;
        if (_cnt) {
            self.settemntView.number.hidden = NO;
        }
        CATransition *animation = [CATransition animation];
        animation.duration = 0.25f;
        
        //设置商品数量
//        self.settemntView.number.text = [NSString stringWithFormat:@"%ld",(long)[ShoppingCartModel orderShoppingCartr:self.orderArr]];
        self.settemntView.number.text = [NSString stringWithFormat:@"%d",3];
        [self.settemntView setNumber:self.settemntView.number];
        [self.settemntView.number.layer addAnimation:animation forKey:nil];
        //设置商品价格
//        self.settemntView.money.text = [NSString stringWithFormat:@"￥%.2f",[ShoppingCartModel moneyOrderShoopingCart:self.orderArr]];
        self.settemntView.money.text = [NSString stringWithFormat:@"￥%.2f",4.0];
        
        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.25f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
        [self.settemntView.shoppingCart.layer addAnimation:shakeAnimation forKey:nil];
    }
}

/**
 *  抛物线小红点
 *
 */
- (UIImageView *)redView
{
    if (!_redView) {
        _redView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _redView.image = [UIImage imageNamed:@"adddetail"];
        _redView.layer.cornerRadius = 10;
    }
    return _redView;
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
