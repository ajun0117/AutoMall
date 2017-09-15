//
//  ChooseLocationView.h
//  ChooseLocation
//
//  Created by Sekorm on 16/8/22.
//  Copyright © 2016年 HY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseLocationView : UIView

@property (nonatomic, copy) NSString * province;    //省
@property (nonatomic, copy) NSString * city;           //市
@property (nonatomic, copy) NSString * county;      //区

@property (nonatomic, copy) NSString * address;

@property (nonatomic, copy) void(^chooseFinish)();

@property (nonatomic,copy) NSString * areaCode;

@end
