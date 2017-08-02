//
//  Definition.h
// YMYL
//
//  Created by 李俊阳 on 15/10/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#ifndef YMYL_Definition_h
#define YMYL_Definition_h

//网络请求参数
#define ERROR               @"error"
#define SUCCESS             @"success"
#define MSG             @"msg"
#define DATA             @"data"

//MBProgressHUD 网络情况提示设置
#define HUDBottomH 100
#define HUDDelay 1.5
#define HUDMargin   10

//定位失败时的默认衡阳市经纬度
#define Latitude     @"26.8994600367"
#define Longitude     @"112.5784483174"


#pragma mark ---- color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define Red_BtnColor           RGBCOLOR(229, 24, 35)
#define Gray_Color              RGBCOLOR(170, 170, 170)
#define Orange_Color           RGBCOLOR(227, 163, 44)
#define Cell_sepLineColor       RGBCOLOR(200, 199, 204)     //tablecell间隔线颜色
#define Cell_SelectedColor      RGBCOLOR(234, 234, 234)      //cell点击背景色

#define isIOS8Later ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

//iPhone4
#define   isIphone4  [UIScreen mainScreen].bounds.size.height < 500

#define STRING(str)         (str==[NSNull null])?@"":str
#define NSStringWithNumber(number)    number==nil?@"未知":[NSString stringWithFormat:@"%@",number]
#define NSStringZeroWithNumber(number)    number==nil?@"0":[NSString stringWithFormat:@"%@",number]

#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width

#define APP_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width

//get the left top origin's x,y of a view
#define VIEW_TX(view) (view.frame.origin.x)
#define VIEW_TY(view) (view.frame.origin.y)

//get the width size of the view:width,height
#define VIEW_W(view)  (view.frame.size.width)
#define VIEW_H(view)  (view.frame.size.height)

//get the right bottom origin's x,y of a view
#define VIEW_BX(view) (view.frame.origin.x + view.frame.size.width)
#define VIEW_BY(view) (view.frame.origin.y + view.frame.size.height )

#pragma mark ---- UIImage  UIImageView  functions
#define IMG(name) [UIImage imageNamed:name]
#define IMGF(name) [UIImage imageNamedFixed:name]

#pragma mark - 接口基地址
//测试基地址
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://192.168.0.107:9091/doPost.ashx?action=%@",action])
//生产基地址
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://112.74.84.233:8080/yimiyule%@",action])
//#define RequestURL(action)           ([NSString stringWithFormat:@"http://yimiyule.com:8080/yimiyule%@",action])
#define RequestURL(action)           ([NSString stringWithFormat:@"http://yimiyule.com/yimiyule%@",action])

#pragma mark - 商户商品相关接口及通知标识
#define GetBanner                  @"GetBanner"     //获取广告图

#pragma mark - 个人信息相关
#define Register               @"/app/user/register"   //用户注册
#define Login                    @"/app/user/login"  //用户登录
#define OtherLogin          @"/app/user/logino" //第三方登录
#define WeixinLogin         @"weixinLogin" //微信登录接口
#define QQLogin              @"qqLogin" //QQ登录接口
#define Logout                  @"/app/user/logout" //注销
#define HomeGet              @"/app/home/get"    //首页综合
#define HomeSearch         @"/app/home/search"     //全站搜索

#define SlideList               @"/app/slide/list"  //获取滚动信息

#define ShopList                @"/app/business/list"   //商家列表
#define ShopDetail             @"/app/business/get"      //商家详情
#define CommnetList          @"/app/comment/list"    //评论，回复列表
#define Favorite                 @"/app/favorite/apply"      //收藏
#define MyFavoriteList       @"/app/favorite/list"    //我的收藏

#define UserList                 @"/app/user/list"   //用户列表
#define UserDetail              @"/app/user/get"     //用户详细信息
#define UserInfoEdit          @"/app/user/set"    //更新用户资料
#define IntegralExchange    @"/app/integral/exchange"     //代码兑换积分
#define PrizeList                  @"/app/prize/list"  //积分兑换列表
#define PrizeExchange         @"/app/prize/exchange"  //积分兑换奖品
#define UserIntegral            @"/app/user/integral"  //获取用户积分
#define ImageDelete           @"/app/image/delete"    //删除我的相册照片

#define ReplacerList            @"/app/replacer/list"   //代喝列表
#define ReplacerDetail         @"/app/replacer/get"  //代喝基本信息

#define FavoritePraise        @"/app/favorite/praise" //点赞

#define ImageUpload            @"/app/image/upload"    //上传图片
#define ImageList                @"/app/image/list"      //查询相册图片列表

#define CommentSend          @"/app/comment/send"    //发表评论

#define Checkpwd                 @"/app/user/checkpwd"   //验证旧密码
#define Updatepwd               @"/app/user/updatepwd"  //更新新密码

#pragma mark - 我的相关
#define MessageList              @"/app/message/list"    //消息列表
#define Statement                 @"/app/info/statement"  //免责声明
#define Contactus                  @"/app/info/contactus"  //联系我们

#define BusinessAdd              @"/app/business/add"    //新增商家


#define UM_Appkey                   @"5659c02367e58ec432002ca4"   //壹米娱乐友盟key

//QQ分享
//#define kShare_QQ_AppID @"1104928111"
//#define kShare_QQ_Appkey @"HbJUGVEa2YPVCpic"
//#define kShare_QQ_AppID @"1105017491"
//#define kShare_QQ_Appkey @"ITith6uC1IHl1xBA"
#define kShare_QQ_AppID @"1105226368"
#define kShare_QQ_Appkey @"iDOuxWYFquSdbs0f"



//微信分享
#define kShare_WeChat_Appkey @"wx1a8b38b73fe9c45e"
#define kShare_WeChat_AppSecret @"2242684bf379cf4d6b2f4bf7b59a2089"



#define BaiduMap_Key @"4iuR3zi67tyt80tAcVC6c1km" //壹米娱乐百度地图key

#endif
