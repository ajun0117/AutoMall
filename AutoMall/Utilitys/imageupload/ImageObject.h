//
//  ImageObject.h
//  mobilely
//
//  Created by Victoria on 15/3/3.
//  Copyright (c) 2015年 ylx. All rights reserved.
//
//--------图片信息

typedef NS_ENUM(NSUInteger, ImageUploadingStatus) {
    ImageUploadingStatusDefault,//没有上传
    ImageUploadingStatusUploading,//正在上传
    ImageUploadingStatusFinished,//上传结束
};

#import <Foundation/Foundation.h>

@interface ImageObject : NSObject
@property ImageUploadingStatus uploadStatus;
@property (nonatomic, strong) NSURL *imageUrl;//本地路径
@property (nonatomic, strong) NSString *imageStorePath;//服务器存储路径
@end
