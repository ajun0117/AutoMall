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
@property (nonatomic,strong) ChooseLocationView *chooseLocationView;
@property (nonatomic,strong) UIView  *cover;

@end

@implementation AddressInfoEditVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[CitiesDataTool sharedManager] requestGetData];
    [self.view addSubview:self.cover];
    self.chooseLocationView.address = @"广东省 广州市 白云区";
    self.chooseLocationView.areaCode = @"440104";
    [self.addressBtn setTitle:@"广东省 广州市 白云区" forState:UIControlStateNormal];
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
