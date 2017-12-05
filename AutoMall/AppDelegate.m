//
//  AppDelegate.m
//  AutoMall
//
//  Created by LYD on 2017/7/31.
//  Copyright © 2017年 redRay. All rights reserved.
//

#import "AppDelegate.h"
#import "BPush.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
static BOOL isBackGroundActivateApplication;

@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate

#warning
//***********************关于如何设置badge角标加1的方法***********************

/*
 服务端推送的badge是几就会显示几,你只需要跟服务端同步消息数目，然后让服务端自己，该推送几，就推送几,比如你应用打开的时候，或者进入后台的时候跟服务端同步，这个点，需要你们自己去设计，应用没有消息的时候，服务端推送了1，当应用打开时候，告诉服务端，app没点击通知，那下次应用推送2,依次类推。
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // iOS10 下需要使用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted) {
                                      [application registerForRemoteNotifications];
                                  }
                              }];
#endif
    }
    else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
#warning 测试 开发环境 时需要修改BPushMode为BPushModeDevelopment 需要修改Apikey为自己的Apikey
    
    // 在 App 启动时注册百度云推送服务，需要提供 Apikey
    
    [BPush registerChannel:launchOptions apiKey:@"DyHZlmzGGtjfRDyVmtcG3MG5" pushMode:BPushModeDevelopment withFirstAction:@"打开" withSecondAction:@"关闭" withCategory:@"test" useBehaviorTextInput:YES isDebug:YES];
    
    // 禁用地理位置推送 需要再绑定接口前调用。
    
    [BPush disableLbs];
    
    // App 是用户点击推送消息启动
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [BPush handleNotification:userInfo];
    }
    
     [WXApi registerApp:kShare_WeChat_Appid withDescription:@"AutoMall"];
    
    return YES;
}

// 此方法是 用户点击了通知，应用在前台 或者开启后台并且应用在后台 时调起
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
    // 打印到日志 textView 中
    NSLog(@"********** iOS7.0之后 background **********");
    // 应用在前台，不跳转页面，让用户选择。
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"acitve ");
        //        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //        [alertView show];
    }
    //杀死状态下，直接跳转到跳转页面。
    if (application.applicationState == UIApplicationStateInactive && !isBackGroundActivateApplication)
    {
//        SkipViewController *skipCtr = [[SkipViewController alloc]init];
//        // 根视图是nav 用push 方式跳转
//        [_tabBarCtr.selectedViewController pushViewController:skipCtr animated:YES];
        NSLog(@"applacation is unactive ===== %@",userInfo);
        /*
         // 根视图是普通的viewctr 用present跳转
         [_tabBarCtr.selectedViewController presentViewController:skipCtr animated:YES completion:nil]; */
    }
    // 应用在后台。当后台设置aps字段里的 content-available 值为 1 并开启远程通知激活应用的选项
    if (application.applicationState == UIApplicationStateBackground) {
        NSLog(@"background is Activated Application ");
        // 此处可以选择激活应用提前下载邮件图片等内容。
        isBackGroundActivateApplication = YES;
        //        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        //        [alertView show];
    }
//    [self.viewController addLogString:[NSString stringWithFormat:@"Received Remote Notification :\n%@",userInfo]];
    
    NSLog(@"%@",userInfo);
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"test:%@",deviceToken);
    [BPush registerDeviceToken:deviceToken];
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
//        [self.viewController addLogString:[NSString stringWithFormat:@"Method: %@\n%@",BPushRequestMethodBind,result]];
        // 需要在绑定成功后进行 settag listtag deletetag unbind 操作否则会失败
        
        // 网络错误
        if (error) {
            return ;
        }
        if (result) {
            // 确认绑定成功
            if ([result[@"error_code"]intValue]!=0) {
                return;
            }
            // 获取channel_id
            NSString *myChannel_id = [BPush getChannelId];
            NSLog(@"==%@",myChannel_id);
            
            [BPush listTagsWithCompleteHandler:^(id result, NSError *error) {
                if (result) {
                    NSLog(@"result ============== %@",result);
                }
            }];
            [BPush setTag:@"Mytag" withCompleteHandler:^(id result, NSError *error) {
                if (result) {
                    NSLog(@"设置tag成功");
                }
            }];
        }
    }];
    
    // 打印到日志 textView 中
//    [self.viewController addLogString:[NSString stringWithFormat:@"Register use deviceToken : %@",deviceToken]];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // App 收到推送的通知
    [BPush handleNotification:userInfo];
    NSLog(@"********** ios7.0之前 **********");
    // 应用在前台 或者后台开启状态下，不跳转页面，让用户选择。
    if (application.applicationState == UIApplicationStateActive || application.applicationState == UIApplicationStateBackground) {
        NSLog(@"acitve or background");
        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    else//杀死状态下，直接跳转到跳转页面。
    {
//        SkipViewController *skipCtr = [[SkipViewController alloc]init];
//        [_tabBarCtr.selectedViewController pushViewController:skipCtr animated:YES];
    }
    
//    [self.viewController addLogString:[NSString stringWithFormat:@"Received Remote Notification :\n%@",userInfo]];
    
    NSLog(@"%@",userInfo);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
//        SkipViewController *skipCtr = [[SkipViewController alloc]init];
//        // 根视图是nav 用push 方式跳转
//        [_tabBarCtr.selectedViewController pushViewController:skipCtr animated:YES];
        /*
         // 根视图是普通的viewctr 用present跳转
         [_tabBarCtr.selectedViewController presentViewController:skipCtr animated:YES completion:nil]; */
    }
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //发送支付宝支付完成通知
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult", resultDic, @"RespData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayNotification" object:nil userInfo:userInfo];
            
            NSLog(@"result = %@",resultDic);
        }];
        return YES;
        
//        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            // 解析 auth code
//            NSString *result = resultDic[@"result"];
//            NSString *authCode = nil;
//            if (result.length>0) {
//                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                for (NSString *subResult in resultArr) {
//                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                        authCode = [subResult substringFromIndex:10];
//                        break;
//                    }
//                }
//            }
//            NSLog(@"授权结果 authCode = %@", authCode?:@"");
//        }];
    }
//
    return  [WXApi handleOpenURL:url delegate:self];
}

#pragma - 微信回调
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[PayResp class]]){
        PayResp *respp = (PayResp *)resp;
        //发送微信支付完成通知
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult", respp, @"RespData",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WechatPayNotification" object:nil userInfo:userInfo];
    }
    
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            //发送支付宝支付完成通知
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"success",@"RespResult", resultDic, @"RespData",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayNotification" object:nil userInfo:userInfo];
            
            NSLog(@"result = %@",resultDic);
        }];
        
//        // 授权跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//            // 解析 auth code
//            NSString *result = resultDic[@"result"];
//            NSString *authCode = nil;
//            if (result.length>0) {
//                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
//                for (NSString *subResult in resultArr) {
//                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
//                        authCode = [subResult substringFromIndex:10];
//                        break;
//                    }
//                }
//            }
//            NSLog(@"授权结果 authCode = %@", authCode?:@"");
//        }];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
