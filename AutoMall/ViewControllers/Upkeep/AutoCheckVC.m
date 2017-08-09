//
//  AutoCheckVC.m
//  AutoMall
//
//  Created by LYD on 2017/8/3.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AutoCheckVC.h"
#import "SingleCheckCell.h"
#import "MultiCheckCell.h"

@interface AutoCheckVC () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation AutoCheckVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"汽车检查页";
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64 + 44, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44)];
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, SCREEN_HEIGHT - 64 - 44);
    self.mainScrollView.pagingEnabled = YES;
    [self.view addSubview:self.mainScrollView];
    
    self.carBodyTV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.carBodyTV];
    self.carBodyTV.delegate = self;
    self.carBodyTV.dataSource = self;
    [self.carBodyTV registerNib:[UINib nibWithNibName:@"SingleCheckCell" bundle:nil] forCellReuseIdentifier:@"SingleCell"];
    
    
    
    self.carInsideTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.carInsideTV];
    
    self.engineRoomTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.engineRoomTV];
    
    self.chassisTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.chassisTV];
    
    self.trunkTV = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 4, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 44) style:UITableViewStyleGrouped];
    [self.mainScrollView addSubview:self.trunkTV];
    
}

- (IBAction)carBodyAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:YES andView:self.carBodyView withColor:Red_BtnColor];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//    self.carBodyBtn.selected = YES;
//    self.carBodyView.backgroundColor = Red_BtnColor;
//    self.carInsideBtn.selected = NO;
//    self.carInsideView.backgroundColor = [UIColor clearColor];
//    self.engineRoomBtn.selected = NO;
//    self.engineRoomView.backgroundColor = [UIColor clearColor];
//    self.chassisBtn.selected = NO;
//    self.chassisView.backgroundColor = [UIColor clearColor];
//    self.trunkBtn.selected = NO;
//    self.trunkView.backgroundColor = [UIColor clearColor];
}

- (IBAction)carInsideAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:YES andView:self.carInsideView withColor:Red_BtnColor];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
}

- (IBAction)engineRoomAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:YES andView:self.engineRoomView withColor:Red_BtnColor];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 2, 0) animated:NO];
}

- (IBAction)chassisAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:YES andView:self.chassisView withColor:Red_BtnColor];
    [self setButton:self.trunkBtn withBool:NO andView:self.trunkView withColor:[UIColor clearColor]];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 3, 0) animated:NO];
}

- (IBAction)trunkAction:(id)sender {
    [self setButton:self.carBodyBtn withBool:NO andView:self.carBodyView withColor:[UIColor clearColor]];
    [self setButton:self.carInsideBtn withBool:NO andView:self.carInsideView withColor:[UIColor clearColor]];
    [self setButton:self.engineRoomBtn withBool:NO andView:self.engineRoomView withColor:[UIColor clearColor]];
    [self setButton:self.chassisBtn withBool:NO andView:self.chassisView withColor:[UIColor clearColor]];
    [self setButton:self.trunkBtn withBool:YES andView:self.trunkView withColor:Red_BtnColor];
    
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * 4, 0) animated:NO];
}


-(void) setButton:(UIButton *)btn  withBool:(BOOL)bo andView:(UIView *)view withColor:(UIColor *)color {
    btn.selected = bo;
    view.backgroundColor = color;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.myTableView.bounds), 60)];
//
//        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn1.frame = CGRectMake(0, 10, CGRectGetWidth(self.myTableView.bounds)/4, 40);
//        btn1.titleLabel.font = [UIFont systemFontOfSize:15];
//        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn1 setTitle:@"性别" forState:UIControlStateNormal];
//        [btn1 setBackgroundImage:IMG(@"bottomTabBg") forState:UIControlStateNormal];
//        [btn1 setBackgroundImage:IMG(@"") forState:UIControlStateSelected];
//        [btn1 addTarget:self action:@selector(sexAction:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btn1];
//
//        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn2.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds)/4, 10, CGRectGetWidth(self.myTableView.bounds)/4, 40);
//        btn2.titleLabel.font = [UIFont systemFontOfSize:15];
//        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn2 setTitle:@"年龄" forState:UIControlStateNormal];
//        [btn2 setBackgroundImage:IMG(@"bottomTabBg") forState:UIControlStateNormal];
//        [btn2 setBackgroundImage:IMG(@"") forState:UIControlStateSelected];
//        [btn2 addTarget:self action:@selector(ageAction:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btn2];
//
//        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn3.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds)/2, 10, CGRectGetWidth(self.myTableView.bounds)/4, 40);
//        btn3.titleLabel.font = [UIFont systemFontOfSize:15];
//        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn3 setTitle:@"距离" forState:UIControlStateNormal];
//        [btn3 setBackgroundImage:IMG(@"bottomTabBg") forState:UIControlStateNormal];
//        [btn3 setBackgroundImage:IMG(@"") forState:UIControlStateSelected];
//        [btn3 addTarget:self action:@selector(distanceAction:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btn3];
//
//        UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn4.frame = CGRectMake(CGRectGetWidth(self.myTableView.bounds)/4*3, 10, CGRectGetWidth(self.myTableView.bounds)/4, 40);
//        btn4.titleLabel.font = [UIFont systemFontOfSize:15];
//        [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn4 setTitle:@"星级" forState:UIControlStateNormal];
//        [btn4 setBackgroundImage:IMG(@"bottomTabBg") forState:UIControlStateNormal];
//        [btn4 setBackgroundImage:IMG(@"") forState:UIControlStateSelected];
//        [btn4 addTarget:self action:@selector(xingjiAction:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:btn4];
//
//        return view;
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        SingleCheckCell *cell = (SingleCheckCell *)[tableView dequeueReusableCellWithIdentifier:@"SingleCell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    MyInfoViewController *detailVC = [[MyInfoViewController alloc] init];
//    detailVC.userID = userArray[indexPath.section][@"id"];
//    detailVC.isDrink = self.isDrink;
//    detailVC.slidePlaceDetail = self.slidePlaceDetail;
//    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - GroupedCell
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//            CGFloat cornerRadius = 5.f;
//            cell.backgroundColor = UIColor.clearColor;
//            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
//            BOOL addLine = NO;
//            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//            } else if (indexPath.row == 0) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//                addLine = YES;
//            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//            } else {
//                CGPathAddRect(pathRef, nil, bounds);
//                addLine = YES;
//            }
//            layer.path = pathRef;
//            CFRelease(pathRef);
//            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
//            
//            if (addLine == YES) {
//                CALayer *lineLayer = [[CALayer alloc] init];
//                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
//                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
//                [layer addSublayer:lineLayer];
//            }
//            UIView *testView = [[UIView alloc] initWithFrame:bounds];
//            [testView.layer insertSublayer:layer atIndex:0];
//            testView.backgroundColor = UIColor.clearColor;
//            cell.backgroundView = testView;
//    }
//}

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
