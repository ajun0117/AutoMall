//
//  GlobalSetting.h
//  YMYL
//
//  Created by 李俊阳 on 15/10/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#define KUserId         @"uid"
#define KLoginName      @"LoginName"
#define KPassword       @"Password"

#define KIsFirst        @"isfisrt"
#define KAppVersion     @"appVersion"

#define kLoginPWD       @"loginPWD"
#define kUserID         @"userID"
#define kToken              @"userToken"
#define KUserInfo       @"userInfo"

#define KMerchantTypeList    @"merchantTypeList"

#define KMyLocation            @"myLocation"

#define kIsLogined              @"isLogined"

#define kCitysDic              @"citysDic"

#define KSearchHistory          @"searchHistory"
#define KUserSearchHistory          @"UserSearchHistory"

#import <Foundation/Foundation.h>
//#import "CityObject.h"
//#import "CountysObject.h"

@interface GlobalSetting : NSObject

/**
 *  返回一个全局设置的类的单例
 *
 *  @return
 */
+(GlobalSetting *)shareGlobalSettingInstance;

//获取设备具体型号
+(NSString*)deviceString;

//获取网络类型
+(NSString *)getNetWorkStates;

//获取运营商名称
+(NSString *)dv_carrierName;

//判断是否越狱
+ (NSString *)isJailBreak;

//md5加密算法
+ (NSString *)md5HexDigest:(NSString*)input;

/**
 *  返回一个颜色值
 *
 *  @return
 */
+ (UIColor *) colorWithHexString: (NSString *) hexString;

#pragma mark - 工具方法
//给一个时间，给一个数，正数是以后n个月，负数是前n个月；
-(NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month;

//字符串转换为*
-(NSString *)transformToStarStringWithString:(NSString *)normalString;

- (NSString *)addSpacingToLabelWithString:(NSString *)toBeString;

+ (UIViewController *)getCurrentVC;

//用“，”拼接字符串
+(NSString *)splicingTheCommaWithStringAry:(NSArray *)ary;

#pragma mark - NSUserDefaults存储方法...

///存储当前城市区县接口版本号
-(void) setCityDistricts_Version:(NSString *)cityDistricts_Version;
-(NSString *) cityDistricts_Version;


///存储当前商户类型接口版本号
-(void) setMerchantTypeList_Version:(NSString *)merchantTypeList_Version;
-(NSString *) merchantTypeList_Version;


/**
 *  是否是第一次进入应用
 *
 *  @return
 */
-(BOOL)isNotFirst;

/**
 *  设置第一次进入
 *
 *  @param isNotFirst
 */
-(void)setIsNotFirst:(BOOL)isNotFirst;

/**
 *  设置第一次进入
 *
 *  @param isNotFirst
 */
-(NSString *)appVersion;


-(void)setAppVersion:(NSString *)appVersion;


///**
// *  存取City对象
// *
// *  @return City对象
// */
//-(CityObject *)CityObject;
//
//-(void)setCityObject:(CityObject *)city;
//
//
///**
// *  存取County对象
// *
// *  @return County对象
// */
//-(CityObject *)CountyObject;
//
//-(void)setCountyObject:(CountysObject *)county;


/**
 *  存取首页已选数据
 *
 *  @return 已选数据字典
 */
-(NSMutableDictionary *)homeSelectedDic;

-(void)setHomeSelectedDic:(NSMutableDictionary *)dic;


/**
 *  存储用户登录密码
 *
 *  @param pwd 登录密码
 */
-(void)setLoginPWD:(NSString *)pwd;

-(NSString *)loginPWD;


/**
 *  存储用户会员id
 *
 *  @param uid 会员id
 */
-(void)setUserID:(NSString *)uid;

-(NSString *)userID;

//身份验证token
-(void)setToken:(NSString *)token;
-(NSString *)token;

//登录用户身份
-(void)setMobileUserType:(NSString *)type;
-(NSString *)mobileUserType;

//认证姓名
-(void)setmName:(NSString *)mName;
-(NSString *)mName;

////积分
//-(void)setmPoints:(NSString *)mPoints;
//-(NSString *)mPoints;

//认证身份证号
-(void)setmIdentityId:(NSString *)mIdentityId;
-(NSString *)mIdentityId;

//邮箱
-(void)setmEmail:(NSString *)mEmail;
-(NSString *)mEmail;

//会员位置信息
-(void)setmlocation:(NSString *)mlocation;
-(NSString *)mlocation;

/**
 *  是否认证
 *
 *  @param authenticate
 */
-(void)setAuthenticate:(id)authenticate;
-(id)authenticate;

/**
 *  是否可以换卡
 *
 *  @param authenticate
 */
-(void)setIsChangeCard:(id)isChangeCard;
-(id)isChangeCard;

/**
 *  是否绑定手机号
 *
 *  @param mBinding
 */
-(void)setmBinding:(id)mBinding;
-(id)mBinding;

/**
 *  绑定的手机号
 *
 *  @param mMobile
 */
-(void)setmMobile:(id)mMobile;
-(id)mMobile;

-(void)setmHead:(id)mHead;
-(id)mHead;

-(void)setCartMulArray:(NSMutableArray *)mulArray;
-(id)cartMulArray;

/**
 *  养老金金额
 *
 *  @param pension
 */
-(void)setPension:(NSString *)pension;
-(NSString *)pension;

/**
 *  卡号
 *
 *  @param cId
 */
-(void)setcId:(id)cId;
-(id)cId;


/**
 *  存储用户信息字典
 *
 *  @param userInfo 用户信息
 */
-(void)setUserInfo:(NSDictionary *)userInfo;

-(NSDictionary *)userInfo;

/**
 *  存储商户类型列表数据
 *
 *  @param merchantTypeList 列表数据
 */
-(void)setMerchantTypeList:(NSDictionary *)merchantTypeList;

-(NSDictionary *)merchantTypeList;

/**
 *  存储当前位置坐标
 *
 *  @param locationDic 坐标字典
 */
-(void)setMyLocationWithDic:(NSDictionary *)locationDic;

-(NSDictionary *)myLocation;


/**
 *  设置登录状态
 *
 *  @param islogined 是否登录标识
 */
-(void)setIsLogined:(BOOL)islogined;

-(BOOL)isLogined;


/**
 *  退出登录，清空用户信息，并置登录状态为NO
 */
-(void)logoutRemoveAllUserInfo;


/**
 *  设置城市区县数据
 *
 *  @param citysDic 城市区县数据字典
 */
-(void)setCitysDic:(NSDictionary *)citysDic;

-(NSDictionary *)citysDic;


//商户搜索历史记录
-(void)setSearchHistory:(NSArray *)historys;

-(NSArray *)historys;


//用户及代喝搜索历史记录
-(void)setUserSearchHistory:(NSArray *)userHistorys;

-(NSArray *)userHistorys;

/**
 *  移除UserDefaults
 */
-(void)removeUserDefaultsValue;


/**
 *  手机号码正则判断
 *
 *  @param phone 手机号码
 *
 *  @return 是手机号码，返回YES
 */
-(BOOL)validatePhone:(NSString *)phone;


@end
