//
//  GlobalSetting.m
//  YMYL
//
//  Created by 李俊阳 on 15/10/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "GlobalSetting.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h>

static GlobalSetting *globalSetting;
@implementation GlobalSetting

-(instancetype)init{
    if ([super init]) {
        
    }
    return self;
}

+(GlobalSetting *)shareGlobalSettingInstance{
    if (!globalSetting) {
        globalSetting = [[self alloc] init];
    }
    return globalSetting;
}

+(NSString*)deviceString {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"]) return @"iPhone 2G (A1203)";
    if ([deviceString isEqualToString:@"iPhone1,2"]) return @"iPhone 3G (A1241/A1324)";
    if ([deviceString isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS (A1303/A1325)";
    if ([deviceString isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (A1332)";
    if ([deviceString isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (A1332)";
    if ([deviceString isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (A1349)";
    if ([deviceString isEqualToString:@"iPhone4,1"]) return @"iPhone 4S (A1387/A1431)";
    if ([deviceString isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (A1428)";
    if ([deviceString isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (A1429/A1442)";
    if ([deviceString isEqualToString:@"iPhone5,3"]) return @"iPhone 5c (A1456/A1532)";
    if ([deviceString isEqualToString:@"iPhone5,4"]) return @"iPhone 5c (A1507/A1516/A1526/A1529)";
    if ([deviceString isEqualToString:@"iPhone6,1"]) return @"iPhone 5s (A1453/A1533)";
    if ([deviceString isEqualToString:@"iPhone6,2"]) return @"iPhone 5s (A1457/A1518/A1528/A1530)";
    if ([deviceString isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus (A1522/A1524)";
    if ([deviceString isEqualToString:@"iPhone7,2"]) return @"iPhone 6 (A1549/A1586)";
    if ([deviceString isEqualToString:@"iPhone8,1"]) return @"iPhone 6s Plus";      //具体代号暂缺
    if ([deviceString isEqualToString:@"iPhone8,2"]) return @"iPhone 6s";           //具体代号暂缺
    
    if ([deviceString isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G (A1213)";
    if ([deviceString isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G (A1288)";
    if ([deviceString isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G (A1318)";
    if ([deviceString isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G (A1367)";
    if ([deviceString isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G (A1421/A1509)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])   return @"iPad 1G (A1219/A1337)";
    
    if ([deviceString isEqualToString:@"iPad2,1"])   return @"iPad 2 (A1395)";
    if ([deviceString isEqualToString:@"iPad2,2"])   return @"iPad 2 (A1396)";
    if ([deviceString isEqualToString:@"iPad2,3"])   return @"iPad 2 (A1397)";
    if ([deviceString isEqualToString:@"iPad2,4"])   return @"iPad 2 (A1395+New Chip)";
    if ([deviceString isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G (A1432)";
    if ([deviceString isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G (A1454)";
    if ([deviceString isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G (A1455)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])   return @"iPad 3 (A1416)";
    if ([deviceString isEqualToString:@"iPad3,2"])   return @"iPad 3 (A1403)";
    if ([deviceString isEqualToString:@"iPad3,3"])   return @"iPad 3 (A1430)";
    if ([deviceString isEqualToString:@"iPad3,4"])   return @"iPad 4 (A1458)";
    if ([deviceString isEqualToString:@"iPad3,5"])   return @"iPad 4 (A1459)";
    if ([deviceString isEqualToString:@"iPad3,6"])   return @"iPad 4 (A1460)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])   return @"iPad Air (A1474)";
    if ([deviceString isEqualToString:@"iPad4,2"])   return @"iPad Air (A1475)";
    if ([deviceString isEqualToString:@"iPad4,3"])   return @"iPad Air (A1476)";
    if ([deviceString isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G (A1489)";
    if ([deviceString isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G (A1490)";
    if ([deviceString isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G (A1491)";
    
    if ([deviceString isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([deviceString isEqualToString:@"x86_64"])    return @"iPhone Simulator";

    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

+(NSString *)dv_carrierName {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return [carrier carrierName];
}

+(NSString *)getNetWorkStates {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    
    int netType =0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    state = @"无网络";
                    //无网模式
                    break;
                case 1:
                    //                    state = @"2G";
                    state = @"mobile";
                    break;
                case 2:
                    //                    state = @"3G";
                    state = @"mobile";
                    break;
                case 3:
                    //                    state = @"4G";
                    state = @"mobile";
                    break;
                case 5:
                {
                    state = @"wifi";
                }
                    break;
                default:
                    break;
            }
            NSLog(@"%@",state);
        }
    }
    //根据状态选择
    return state;
}

+ (NSString *)isJailBreak {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return @"p";
    }
    NSLog(@"The device is NOT jail broken!");
    return @"s";
}

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


+ (UIColor *) colorWithHexString: (NSString *) hexString

{
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha = 0.0f;
    CGFloat red = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat green = 0.0f;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            alpha = 1.0f;
            red = 0.0f;
            blue = 0.0f;
            green = 0.0f;
            break;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length

{
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}

#pragma mark - 工具方法
//给一个时间，给一个数，正数是以后n个月，负数是前n个月；
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    
    return mDate;
}


-(NSString *)transformToStarStringWithString:(NSString *)normalString {
    int leng = (int)[normalString length];
    NSRange range = NSMakeRange(1, leng - 1);
    NSMutableString *starString = [[NSMutableString alloc] init];
    for (int i = 0; i < leng - 1; ++i) {
        [starString appendString:@"*"];
    }
    NSString *transformStarString = [normalString stringByReplacingCharactersInRange:range withString:starString];
    
    return transformStarString;
}


/**
 *@brief 银行卡输入，textField4位加空格，16个数字后还能添加14位数字
 */
- (NSString *)addSpacingToLabelWithString:(NSString *)toBeString
{
    //检测是否为纯数字
    if ([self isPureInt:toBeString]) {
        //添加空格，每4位之后，4组之后不加空格，格式为xxxx xxxx xxxx xxxx xxxxxxxxxxxxxx
        if (toBeString.length % 5 == 4 && toBeString.length < 22) {
            toBeString = [NSString stringWithFormat:@"%@ ", toBeString];
        }
    }
    return toBeString;
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (UIViewController *)getCurrentVC;
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

//用“，”拼接字符串
+(NSString *) splicingTheCommaWithStringAry:(NSArray *)ary {
    NSMutableString *commaString = [[NSMutableString alloc] init];
    for (NSString *string in ary) {
            if ([commaString length] == 0) {
                [commaString appendString:[NSString stringWithFormat:@"%@",string]];
            }
            else {
                [commaString appendString:[NSString stringWithFormat:@",%@",string]];
            }
    }
    return commaString;
}

#pragma mark - NSUserDefaults存储方法...

-(void) setCityDistricts_Version:(NSString *)cityDistricts_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cityDistricts_Version forKey:@"Save_CityDistricts_Version"];
    [userDefaults synchronize];
}

-(NSString *) cityDistricts_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"Save_CityDistricts_Version"];
}


-(void) setMerchantTypeList_Version:(NSString *)merchantTypeList_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:merchantTypeList_Version forKey:@"Save_MerchantTypeList_Version"];
    [userDefaults synchronize];
}

-(NSString *) merchantTypeList_Version {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"Save_MerchantTypeList_Version"];
}


-(BOOL)isNotFirst{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:KIsFirst];
}

-(void)setIsNotFirst:(BOOL)isNotFirst{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isNotFirst forKey:KIsFirst];
    [userDefaults synchronize];
}

-(NSString *)appVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KAppVersion];
}

-(void)setAppVersion:(NSString *)appVersion{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:appVersion forKey:KAppVersion];
    [userDefaults synchronize];
}

//-(CityObject *)CityObject {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults objectForKey:@"CityObject"];
//}
//
//-(void)setCityObject:(CityObject *)city {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:city forKey:@"CityObject"];
//    [userDefaults synchronize];
//}
//
//-(CityObject *)CountyObject {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults objectForKey:@"CountyObject"];
//}
//
//-(void)setCountyObject:(CountysObject *)county {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:county forKey:@"CountyObject"];
//    [userDefaults synchronize];
//}


-(NSMutableDictionary *)homeSelectedDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"HomeSelectedDic"];
}

-(void)setHomeSelectedDic:(NSMutableDictionary *)dic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:dic forKey:@"HomeSelectedDic"];
    [userDefaults synchronize];
}


-(void)setLoginPWD:(NSString *)pwd {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pwd forKey:kLoginPWD];
    [userDefaults synchronize];
}

-(NSString *)loginPWD {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kLoginPWD];
}

-(void)setUserID:(NSString *)uid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uid forKey:kUserID];
    [userDefaults synchronize];
}

-(NSString *)userID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kUserID];
}

-(void)setToken:(NSString *)token {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:kToken];
    [userDefaults synchronize];
}

-(NSString *)token {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kToken];
}

-(void)setOrganizationID:(NSString *)oid {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oid forKey:@"OrganizationID"];
    [userDefaults synchronize];
}

-(NSString *)organizationID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"OrganizationID"];
}

-(void)setmName:(NSString *)mName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mName forKey:@"mName"];
    [userDefaults synchronize];
}

-(NSString *)mName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mName"];
}

//-(void)setmPoints:(NSString *)mPoints {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:mPoints forKey:@"mPoints"];
//    [userDefaults synchronize];
//}
//
//-(NSString *)mPoints {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    return [userDefaults valueForKey:@"mPoints"];
//}

-(void)setmIdentityId:(NSString *)mIdentityId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mIdentityId forKey:@"mIdentityId"];
    [userDefaults synchronize];
}

-(NSString *)mIdentityId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mIdentityId"];
}

-(void)setmEmail:(NSString *)mEmail {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mEmail forKey:@"mEmail"];
    [userDefaults synchronize];
}

-(NSString *)mEmail {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mEmail"];
}

-(void)setmlocation:(NSString *)mlocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mlocation forKey:@"mlocation"];
    [userDefaults synchronize];
}

-(NSString *)mlocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mlocation"];
}



-(void)setAuthenticate:(id)authenticate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:authenticate forKey:@"isAuthenticate"];
    [userDefaults synchronize];
}

-(id)authenticate {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"isAuthenticate"];
}

-(void)setIsChangeCard:(id)isChangeCard{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:isChangeCard forKey:@"isChangeCard"];
    [userDefaults synchronize];
}

-(id)isChangeCard{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"isChangeCard"];
}


-(void)setmBinding:(id)mBinding {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mBinding forKey:@"mBinding"];
    [userDefaults synchronize];
}

-(id)mBinding {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mBinding"];
}


-(void)setmMobile:(id)mMobile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:mMobile forKey:@"mMobile"];
    [userDefaults synchronize];
}

-(id)mMobile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"mMobile"];
}


-(void)setPension:(NSString *)pension {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:pension forKey:@"pension"];
    [userDefaults synchronize];
}

-(NSString *)pension {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"pension"];
}


-(void)setcId:(id)cId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:cId forKey:@"cId"];
    [userDefaults synchronize];
}

-(id)cId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:@"cId"];
}


-(void)setUserInfo:(NSDictionary *)userInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userInfo forKey:KUserInfo];
    [userDefaults synchronize];
}

-(NSDictionary *)userInfo {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KUserInfo];
}


-(void)setMerchantTypeList:(NSDictionary *)merchantTypeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:merchantTypeList forKey:KMerchantTypeList];
    [userDefaults synchronize];
}

-(NSDictionary *)merchantTypeList {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KMerchantTypeList];
}

-(void)setMyLocationWithDic:(NSDictionary *)locationDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:locationDic forKey:KMyLocation];
    [userDefaults synchronize];
}

-(NSDictionary *)myLocation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:KMyLocation];
}

-(void)setIsLogined:(BOOL)islogined {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:islogined forKey:kIsLogined];
    [userDefaults synchronize];
    
}

-(BOOL)isLogined {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kIsLogined];
}


-(void)logoutRemoveAllUserInfo {    //退出登录，清空用户信息
    [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:@""]; //存储登录密码
    [[GlobalSetting shareGlobalSettingInstance] setIsLogined:NO];  //未登录标示
    [[GlobalSetting shareGlobalSettingInstance] setUserID:@""];
    [[GlobalSetting shareGlobalSettingInstance] setToken:@""];
    [[GlobalSetting shareGlobalSettingInstance] setToken:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setAuthenticate:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmBinding:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmMobile:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setPension:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setcId:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setIsChangeCard:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setOrganizationID:@""];
    [[GlobalSetting shareGlobalSettingInstance] setmName:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmPoints:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmIdentityId:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmEmail:@""];
//    [[GlobalSetting shareGlobalSettingInstance] setmlocation:@""];
    
}

/**
 *  设置城市区县数据
 *
 *  @param citysDic 城市区县数据字典
 */
-(void)setCitysDic:(NSDictionary *)citysDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:citysDic forKey:kCitysDic];
    [userDefaults synchronize];
}

-(NSDictionary *)citysDic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kCitysDic];
}


//商户搜索历史记录
-(void)setSearchHistory:(NSArray *)historys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:historys forKey:KSearchHistory];
    [userDefaults synchronize];
}

-(NSArray *)historys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KSearchHistory];
}

//用户及代喝搜索历史记录
-(void)setUserSearchHistory:(NSArray *)userHistorys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userHistorys forKey:KUserSearchHistory];
    [userDefaults synchronize];
}

-(NSArray *)userHistorys {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KUserSearchHistory];
}

-(void)removeUserDefaultsValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    [userDefaults synchronize];
}


#pragma mark - 工具方法...

#pragma mark - 电话号码正则验证
-(BOOL)validatePhone:(NSString *)phone {
    NSString *phoneRegex = @"^1[3|4|5|8][0-9]\\d{8}$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [emailTest evaluateWithObject:phone];
}

@end
