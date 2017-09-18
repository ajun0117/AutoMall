//
//  UpkeepStatementVC.h
//  AutoMall
//
//  Created by LYD on 2017/9/8.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpkeepStatementVC : UIViewController

@end


@class MonthModel;
//控制器
@interface CalendarViewController : UIViewController
@end

//CollectionViewHeader
@interface CalendarHeaderView : UICollectionReusableView
@end

//UICollectionViewCell
@interface CalendarCell : UICollectionViewCell
@property (weak, nonatomic) UILabel *dayLabel;

@property (strong, nonatomic) MonthModel *monthModel;
@end

//存储模型
@interface MonthModel : NSObject
@property (assign, nonatomic) NSInteger dayValue;
@property (strong, nonatomic) NSDate *dateValue;
@property (assign, nonatomic) BOOL isSelectedDay;
@property (assign, nonatomic) BOOL isToDay;
@end
