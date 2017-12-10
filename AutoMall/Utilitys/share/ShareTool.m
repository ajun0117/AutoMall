//
//  ShareTool.m
//  mobilely
//
//  Created by LYD on 15/7/6.
//  Copyright (c) 2015年 ylx. All rights reserved.
//

#import "ShareTool.h"
#import "WXApi.h"
 
@implementation ShareTool

+(void)ShareToWxWithScene:(int)scene andTitle:(NSString *)title andDescription:(NSString *)description andThumbImageUrlStr:(NSString *)thumbImageUrlStr andWebUrlStr:(NSString *)webUrlStr  {
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 处理耗时操作的代码块...
        __block NSData *thumbData = nil;
        thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbImageUrlStr]];
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            NSLog(@"Reslength: %ld",(unsigned long)[thumbData length]);
            UIImage *thumbResImage = [UIImage imageWithData:thumbData];
            
            CGSize thumbImgSize = thumbResImage.size;
            for (float i = 1.0; [thumbData length] > 32000; i = i - 0.1) {
                //宽和高每次等比例缩小10%
                CGSize imgSize = CGSizeMake(thumbImgSize.width * i, thumbImgSize.height * i);
                NSLog(@"imgSize: %@",NSStringFromCGSize(imgSize));
                thumbData = [self imageWithImage:[UIImage imageWithData:thumbData] scaledToSize:imgSize];
                NSLog(@"length: %ld",(unsigned long)[thumbData length]);
            }
            NSLog(@"Resultlength: %ld",(unsigned long)[thumbData length]);
            
            [message setThumbData:thumbData];
            
            WXWebpageObject *ext = [WXWebpageObject object];
            ext.webpageUrl = webUrlStr;
            
            message.mediaObject = ext;
            message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
            
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            [WXApi sendReq:req];
        });
    });
    
}

+ (NSData *)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return UIImageJPEGRepresentation(newImage, 0.1);
}


@end
