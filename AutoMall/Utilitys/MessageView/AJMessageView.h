//
//  AJMessageView.h
//  YMYL
//
//  Created by LYD on 15/10/27.
//  Copyright © 2015年 ljy. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DefineMessageImage @"squareImageDefault"
#define DefineMessageTime  4

@class AJMessageView;

@protocol AJMessageViewDelegate <NSObject>

- (NSInteger)numberInAJMessageView:(AJMessageView *)messageView;

- (NSString *)imageUrlInAJMessageView:(AJMessageView *)messageView index:(NSInteger)index;

- (NSString *)titleStringInAJMessageView:(AJMessageView *)messageView index:(NSInteger)index;

- (NSString *)detailTitleStringInAJMessageView:(AJMessageView *)messageView index:(NSInteger)index;

@optional
- (void)messageView:(AJMessageView *)messageView didSelectIndex:(NSInteger)index;

@end

@interface AJMessageView : UIView

@property (nonatomic, weak) id<AJMessageViewDelegate>delegate;


@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, assign, readonly) int sIndex;

- (void)initSubViews;
- (void)reloadData;

@end
