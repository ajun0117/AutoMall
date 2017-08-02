//
//  DataRequest.m
//  YMYL
//
//  Created by 李俊阳 on 15/10/16.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "DataRequest.h"
//#import "Reachability.h"



static DataRequest *dataRequest;
@implementation DataRequest

-(instancetype)init{
    if (self = [super init]) {
        version = [self getVersion];
    }
    return self;
}

+(DataRequest *)sharedDataRequest{
    if (!dataRequest) {
        dataRequest = [[self alloc] init];
    }
    return dataRequest;
}

-(NSString*)getVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app名称
    //NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    //NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return app_Version;
}

#pragma mark - 绑定设备相关
-(NSString *)getUserAgentString {
    NSString *dv_nettype = [GlobalSetting getNetWorkStates];    //当前网络名称
    NSString *dv_netcorp = [GlobalSetting dv_carrierName];  //运营商名称
    NSString *dv_string = [GlobalSetting deviceString];     //设备型号
    UIDevice *device = [UIDevice currentDevice];
//    NSString *dv_phonetype = device.model;
    NSString *dv_screenwidth = [NSString stringWithFormat:@"%d",(int)SCREEN_WIDTH];
    NSString *dv_screenheight = [NSString stringWithFormat:@"%d",(int)SCREEN_HEIGHT];
    NSString *os_platform = device.systemName;      //终端操作系统
    NSString *os_version = device.systemVersion;    //iOS版本号
    NSString *isJailBreak = [GlobalSetting isJailBreak];    //是否越狱
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];    //软件版本号
//    NSString *app_vercode = [infoDictionary objectForKey:@"CFBundleVersion"];

    NSString *userAgentStr = [NSString stringWithFormat:@"%@/%@(%@;%@;%@x%@;%@;%@;%@)",dv_string,app_version,os_platform,os_version,dv_screenwidth,dv_screenheight,isJailBreak,dv_netcorp,dv_nettype];
    NSLog(@"%@",userAgentStr);
    return userAgentStr;
}

//+(BOOL) checkNetwork{
//    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    switch ([r currentReachabilityStatus]) {
//        case NotReachable:
//            return NO;
//            break;
//        case ReachableViaWWAN:
//            return YES;
//            break;
//        case ReachableViaWiFi:
//            return YES;
//            break;
//        default:
//            return NO;
//    }
//}

//get方式访问网络
-(void) getDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(NSDictionary *)params info:(NSDictionary *)infoDic{
    
    NSMutableString *appendString = [NSMutableString stringWithFormat:@"%@?_fs=1/_vc=%@",urlStr,version];
    if ([urlStr rangeOfString:@"?"].location != NSNotFound) {
        appendString = [urlStr mutableCopy];
    }
    
//    if ([DataRequest checkNetwork]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        manager.requestSerializer.timeoutInterval = 15;
        [manager GET:[appendString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"成功获取数据！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            NSDictionary *userInfo = nil;
            if (error.code == -1001) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"请求超时！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }else {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络请求失败！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        }];
//    } else {
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络无法连接！",@"ContentResult",[infoDic objectForKey:@"op"], @"op", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
//    }
}

//post方式访问网络
-(void) postDataWithUrl:(NSString *)urlStr delegate:(id)delegate params:(id)params info:(NSDictionary *)infoDic{
    
//    NSMutableString *appendString = [NSMutableString stringWithFormat:@"%@?_fs=1/_vc=%@",urlStr,version];
    
//    if ([DataRequest checkNetwork]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];  //设置传参方式为JSON
    
        //为这个下载任务HTTP头添加@"User-Agent"字段
        [manager.requestSerializer setValue:[self getUserAgentString] forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"zh-cn, zh-tw,zh-hk" forHTTPHeaderField:@"Accept-Language"];
        NSString *token = [[GlobalSetting shareGlobalSettingInstance] token];
        if (token != nil && ![token isEqualToString:@""]) {
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"XPS-UserToken"];
        }
        NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
        if (userId != nil && ![userId isEqualToString:@""]) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@",userId] forHTTPHeaderField:@"XPS-UserId"];
        }
        NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
        [manager.requestSerializer setValue:locationDic[@"longitude"] forHTTPHeaderField:@"XPS-Longitude"];
        [manager.requestSerializer setValue:locationDic[@"latitude"] forHTTPHeaderField:@"XPS-Latitude"];

        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:[NSArray arrayWithObjects:@"text/plain", @"text/html",nil]];
        manager.requestSerializer.timeoutInterval = 300;
        [manager POST:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"成功获取数据！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",nil];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"上传成功！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",[infoDic objectForKey:@"indexPath"], @"indexPath",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error.description);
            NSLog(@"Error: %@", error.debugDescription);
            NSDictionary *userInfo = nil;
            if (error.code == -1001) {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"请求超时！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            } else {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"网络请求失败！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op", nil];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
        }];
//    } else {
//        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"error",@"RespResult",@"网络无法连接！",@"ContentResult", [infoDic objectForKey:@"op"], @"op",nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:result];
//    }
}

//上传图片到服务器
-(void) uploadImageWithUrl:(NSString *)urlStr params:(NSDictionary *)param target:(WPImageView *)imageView delegate:(id)delegate info:(NSDictionary *)infoDic {
    
//    if ([DataRequest checkNetwork]) {
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        NSError *error = nil;
        NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:urlStr parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData *imageData = UIImageJPEGRepresentation(imageView.image, 1);
            NSInteger length = imageData.length;
            if (length > 1048576) {
                CGFloat packRate = 1048576.0/length;
                imageData = UIImageJPEGRepresentation(imageView.image, packRate);
            }
            
            [formData appendPartWithFileData:imageData
                                        name:@"upimg"
                                    fileName:@"upimg.jpg"
                                    mimeType:@"image/jpeg"];
        } error:&error];
        // 3. Create and use `AFHTTPRequestOperationManager` to create an `AFHTTPRequestOperation` from the `NSMutableURLRequest` that we just created.
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        //为这个下载任务HTTP头添加@"User-Agent"字段
        [manager.requestSerializer setValue:[self getUserAgentString] forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"zh-cn, zh-tw,zh-hk" forHTTPHeaderField:@"Accept-Language"];
        NSString *token = [[GlobalSetting shareGlobalSettingInstance] token];
        if (token != nil && ![token isEqualToString:@""]) {
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"XPS-UserToken"];
        }
        NSString *userId = [[GlobalSetting shareGlobalSettingInstance] userID];
        if (userId != nil && ![userId isEqualToString:@""]) {
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@",userId] forHTTPHeaderField:@"XPS-UserId"];
        }
        NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
        [manager.requestSerializer setValue:locationDic[@"longitude"] forHTTPHeaderField:@"XPS-Longitude"];
        [manager.requestSerializer setValue:locationDic[@"latitude"] forHTTPHeaderField:@"XPS-Latitude"];
        
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:[NSArray arrayWithObjects:@"text/plain", @"text/html",nil]];
        manager.requestSerializer.timeoutInterval = 300;
        __block WPImageView *imageView_ = imageView;
        
        AFHTTPRequestOperation *operation =
        [manager HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             NSLog(@"Success %@", responseObject);
                                             NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult",@"上传成功！",@"ContentResult", responseObject, @"RespData", [infoDic objectForKey:@"op"], @"op",[infoDic objectForKey:@"indexPath"], @"indexPath",nil];
                                             [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"Failure %@", error.description);
                                             NSDictionary *userInfo = nil;
                                             if (error.code == -1001) {
                                                 userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"请求超时！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op",[infoDic objectForKey:@"indexPath"], @"indexPath", nil];
                                             } else {
                                                 userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"error",@"RespResult",@"上传失败！",@"ContentResult",error,@"RespData",[infoDic objectForKey:@"op"], @"op",[infoDic objectForKey:@"indexPath"], @"indexPath", nil];
                                             }
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:userInfo];
                                             
                                         }];
        
        // 4. Set the progress block of the operation.
        [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                            long long totalBytesWritten,
                                            long long totalBytesExpectedToWrite) {
            CGFloat progress = totalBytesWritten/(CGFloat)totalBytesExpectedToWrite;
            NSLog(@"Wrote %lld/%lld  %f", totalBytesWritten, totalBytesExpectedToWrite,progress);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageView_ setCurrentProgress:progress];
            });
        }];
        
        // 5. Begin!
        //[operation start];
        [manager.operationQueue addOperation:operation];
//    }
//    else {
//        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:@"error",@"RespResult",@"网络无法连接！",@"ContentResult", [infoDic objectForKey:@"op"], @"op",[infoDic objectForKey:@"indexPath"], @"indexPath",nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:[infoDic objectForKey:@"op"] object:nil userInfo:result];
//    }
}

-(void)cancelRequest{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    NSArray *operations = [manager.operationQueue operations];
}
@end
