//
//  CheckContentTool.h
//  AutoMall
//
//  Created by 李俊阳 on 2017/10/5.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckContentItem.h"

@interface CheckContentTool : NSObject

+ (instancetype)sharedManager;
//往表插入数据
- (void)insertRecordsWithAry:(NSArray *)ary;
//查询出所有的检查内容
- (NSMutableArray *)queryAllContent;
//根据部位Id 查询出该Id下所有的检查内容项目
- (NSMutableArray *)queryAllRecordWithBuweiID:(NSString *) buwei;
//根据检查内容Id 查询出该Id的数据
- (CheckContentItem *)queryRecordWithID:(NSString *) aId;
-(void)UpdateContentItemWithItem:(CheckContentItem *)item;     //通过检查内容id修改
-(void)UpdateContentItemImagesWithItem:(CheckContentItem *)item;
-(void)UpdateContentItemTipWithItem:(CheckContentItem *)item;

@end
