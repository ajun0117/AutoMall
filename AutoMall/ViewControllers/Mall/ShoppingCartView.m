//
//  ShoppingCartView.m
//  HSH
//
//  Created by kangshibiao on 16/5/20.
//  Copyright © 2016年 宋丰. All rights reserved.
//

#import "ShoppingCartView.h"
#import "CommodityDetailVC.h"
#import "CartItem.h"
#import "CartTool.h"

@implementation ShoppingCartView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self =[super initWithFrame:frame]) {
    }
    return self;
}
- (void)setDatasArr:(NSMutableArray *)datasArr{
    
    _datasArr = datasArr;
    if (_datasArr.count == 0) {
        
        self.lableText.text = @"当前购物车为空，快去选购吧！";
    }
    [self.myTableView reloadData];
}

- (UITableView *)myTableView{
    if (!_myTableView) {
        UIView *vc = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 200, Screen_wide, 40)];
        vc.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UILabel *lable =[[UILabel alloc]initWithFrame:CGRectMake(18, 0, 100, 40)];
        lable.text = @"购物车";
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = [UIColor blackColor];
        lable.font = [UIFont systemFontOfSize:16];
        [vc addSubview:lable];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(SCREEN_WIDTH - 24 - 18, 8, 24, 24);
        [btn setImage:IMG(@"cart_delete") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clearCart) forControlEvents:UIControlEventTouchUpInside];
        [vc addSubview:btn];
        [self addSubview:vc];
        
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 200 + 40, Screen_wide, 200 - 40) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerNib:[UINib nibWithNibName:@"ShoppingCartCell" bundle:nil] forCellReuseIdentifier:@"ShoppingCartCell"];
        [self addSubview:_myTableView];
        _myTableView.tableFooterView = [UIView new];

    }
    return _myTableView;
}

- (UILabel *)lableText{
    
    if (!_lableText) {
        _lableText = [[UILabel alloc]init];
        _lableText.frame = CGRectMake(0, CGRectGetHeight(self.myTableView.frame)/2 - 40, Screen_wide, 40);
        _lableText.textAlignment = NSTextAlignmentCenter;
        _lableText.textColor = [UIColor lightGrayColor];
        _lableText.font = [UIFont systemFontOfSize:12];
        _lableText.numberOfLines = 0;
        [_myTableView addSubview:_lableText];

    }
    
    return _lableText;
    
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.datasArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShoppingCartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShoppingCartCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.addBtn addTarget:self action:@selector(addBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    cell.addBtn.tag = indexPath.row;
    cell.deleteBtn.tag = indexPath.row;
    
    cell.data = self.datasArr[indexPath.row];
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    return 40;
//}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UIView *vc = [UIView new];
//    vc.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    UILabel *lable =[[UILabel alloc]initWithFrame:CGRectMake(8, 0, 100, 40)];
//    lable.text = @"购物车";
//    lable.textAlignment = NSTextAlignmentLeft;
//    lable.textColor = [UIColor blackColor];
//    lable.font = [UIFont systemFontOfSize:16];
//    [vc addSubview:lable];
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(SCREEN_WIDTH - 40 - 8, 8, 24, 24);
//    [btn setImage:IMG(@"cart_delete") forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(clearCart) forControlEvents:UIControlEventTouchUpInside];
//    [vc addSubview:btn];
//    
//    return vc;
//}

-(void)clearCart {
    [self.datasArr removeAllObjects];
    [self.myTableView reloadData];
    [[CartTool sharedManager] removeAllCartItems];      //清空本地购物车数据
    self.lableText.text = @"当前购物车为空，快去选购吧！";
    _block(self.datasArr);
}

- (void)addShoppingCartView:(UIViewController *)vc{
    _viewController = vc;
//    [vc.view addSubview:self];
}
- (void)removeSubView:(UIViewController *)vc{
    UIView * v = [vc.view viewWithTag:111];
    [v removeFromSuperview];
    [self removeFromSuperview];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FootView" object:nil];
    [UIView animateWithDuration:.3 animations:^{
        UIView * v = [_viewController.view viewWithTag:111];
        v.alpha = 0;
        self.frame = CGRectMake(0, Screen_heigth, Screen_wide,SCREEN_HEIGHT + 15);
    } completion:^(BOOL finished)
     {
         [self removeSubView:_viewController];
         CommodityDetailVC *dvc = (CommodityDetailVC *)_viewController;
         dvc.isShopping = NO;
     }];
}
#pragma mark -- 加加
- (void)addBtn:(UIButton *)sender{
    
    [self updatesContNumber:sender addAndDele:YES];
}
#pragma mark -- 减减
- (void)deleteBtn:(UIButton *)sender{
    
    [self updatesContNumber:sender addAndDele:NO];
    
}
- (void)updatesContNumber:(UIButton *)indexPath addAndDele:(BOOL)isAD{
    
//    ShoppingCartCell *cell = [self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.tag inSection:0]];
    ShoppingCartCell * cell = (ShoppingCartCell *)indexPath.superview.superview;
    NSIndexPath *indx = [self.myTableView indexPathForCell:cell];
    int num = [cell.number.text intValue];
    if (isAD) {
        num ++;
    }
    else{
        NSMutableArray *ary = [[CartTool sharedManager] queryAllCart];
        CartItem *item = ary[indx.row];
        if (num == [item.minimum intValue]) {   //如果当前数量等于最小发货数量，则直接减为0
            num = 0;
        }
        else {
            num --;
        }
    }

    cell.number.text = [NSString stringWithFormat:@"%d",num];
    NSMutableDictionary * data  = self.datasArr[indx.row];
    [data setObject:[NSString stringWithFormat:@"%d",num] forKey:@"orderCont"];
    
    //更新本地数据库
    CartItem *item = [[CartItem alloc] init];
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"jsonStr: %@",jsonStr);
    item.cartDic = jsonStr;
    item.cartId = [NSString stringWithFormat:@"%@",data[@"id"]];
    //更新可变数组到本数据库
    item.orderCont = [NSString stringWithFormat:@"%d",num];
    [[CartTool sharedManager] UpdateContentItemWithItem:item];
    
    if (num == 0) {
        [self.datasArr removeObject:data];
        [self.myTableView deleteRowsAtIndexPaths:@[indx] withRowAnimation:0];
        
        if (self.datasArr.count == 0) {
            self.lableText.text = @"当前购物车为空，快去选购吧！";
        }
        
        [[CartTool sharedManager] deleteItemWithId:item.cartId];
    }
    
    _block(self.datasArr);
}



@end

