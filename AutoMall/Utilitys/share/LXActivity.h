//
//  LXActivity.h
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  监听器委托，用于监听内部按钮的触发情况
 */
@protocol LXActivityDelegate <NSObject>

/**
 *  这个方法在点击了内部按钮时调用
 *
 *  @param imageIndex 点击的按钮的下标
 */
- (void)didClickOnImageIndex:(NSInteger *)imageIndex;
@optional

/**
 *  这个方法在点击了取消按钮时调用
 */
- (void)didClickOnCancelButton;

@end

/**
 专为社会化分享，特别定制视图。展示了各种分享图标，处理点击事件。
 */
@interface LXActivity : UIView

@property (assign, nonatomic) BOOL cannotCancel;   //是否不可取消

/**
 *  初始化对象
 *
 *  @param title                      标题
 *  @param delegate                   监听器委托
 *  @param cancelButtonTitle          取消按钮文本
 *  @param shareButtonTitlesArray     内部按钮标题数组
 *  @param shareButtonImagesNameArray 内部按钮图片
 *
 *  @return 该类的对象
 */
- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;

/**
 *  在当前视图上显示分享视图
 */
- (void)show;

@end
