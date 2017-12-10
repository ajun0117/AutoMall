//
//  ShareTool.h
//  mobilely
//
//  Created by LYD on 15/7/6.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareTool : NSObject

+(void)ShareToWxWithScene:(int)scene andTitle:(NSString *)title andDescription:(NSString *)description andThumbImageUrlStr:(NSString *)thumbImageUrlStr andWebUrlStr:(NSString *)webUrlStr;

@end
