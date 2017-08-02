//
//  AJAdView.h
//  YMYL
//
//  Created by LYD on 15/10/14.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#define HomeDefineAdImage @"defaultHomeAd"
#define ListDefineAdImage @"defaultListAd"
#define DefineAdTime  4

@class AJAdView;

@protocol AJAdViewDelegate <NSObject>

- (NSInteger)numberInAdView:(AJAdView *)adView;

- (NSString *)imageUrlInAdView:(AJAdView *)adView index:(NSInteger)index;

- (NSString *)titleStringInAdView:(AJAdView *)adView index:(NSInteger)index;

@optional
- (void)adView:(AJAdView *)adView didSelectIndex:(NSInteger)index;

@end


@interface AJAdView : UIView

@property (nonatomic, weak) id<AJAdViewDelegate>delegate;


@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIImageView *bgImageView;

@property (nonatomic, assign, readonly) int sIndex;

@property (nonatomic, assign) BOOL isHomeAd;    //是否首页广告1:2比例

- (void)initSubViews;
- (void)reloadData;

@end
