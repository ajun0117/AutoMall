//
//  CheckContentItem.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckContentItem : NSObject

@property (nonatomic,copy) NSString *pId;                  //内容所属的部位Id
@property (nonatomic,copy) NSString *pName;            //所属的部位名称（车身）
@property (nonatomic,copy) NSString *aid;                  //内容Id
@property (nonatomic,copy) NSString *name;             //内容名称
@property (nonatomic,copy) NSString *stateIndex;   //结果选择位置
@property (nonatomic,copy) NSString *stateName;   //结果名称
@property (nonatomic,copy) NSString *dPosition;      //具体位置
@property (nonatomic,copy) NSString *tip;              //检查结果文本
@property (nonatomic,copy) NSString *images;         //照片
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
