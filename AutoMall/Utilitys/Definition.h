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

#define Red_BtnColor           RGBCOLOR(234, 33, 45)
#define Gray_Color              RGBCOLOR(170, 170, 170)
#define Orange_Color           RGBCOLOR(234, 33, 45)
#define Cell_sepLineColor       RGBCOLOR(200, 199, 204)     //tablecell间隔线颜色
#define Cell_SelectedColor      RGBCOLOR(234, 234, 234)      //cell点击背景色

#define isIOS8Later ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

//iPhone4
#define   isIphone4  [UIScreen mainScreen].bounds.size.height < 500

#define STRING_Nil(str)         (str==nil)?@"":str
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

//#pragma mark - 商户商品相关接口及通知标识
//#define GetBanner                  @"GetBanner"     //获取广告图
//
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
//#define MessageList              @"/app/message/list"    //消息列表
#define Statement                 @"/app/info/statement"  //免责声明
#define Contactus                  @"/app/info/contactus"  //联系我们

#define BusinessAdd              @"/app/business/add"    //新增商家


#define UM_Appkey                   @"5659c02367e58ec432002ca4"   //壹米娱乐友盟key



//汽车商城
#define UrlPrefix(action)                       ([NSString stringWithFormat:@"http://119.23.227.246/carupkeep%@",action])
//#define ImagePrefixURL(action)           ([NSString stringWithFormat:@"http://119.23.227.246/carupkeep%@",action])


//资讯、教程
#define InformationList                          @"/api/info/list"    //资讯列表
#define InformationDetail                      @"/api/info/info"   //资讯详情
#define CourseList                                  @"/api/course/list"  //教程列表
#define CourseDetail                               @"/api/course/info"  //教程详情


#define UploadUploadImg                       @"/api/upload/uploadImg"    //上传图片

//商城
#define ComCategoryList                        @"/api/comCategory/list"    //商品分类
#define CommodityList                            @"/api/commodity/list"       //商品列表
#define CommodityDetail                         @"/api/commodity/getInfo"   //商品详情
#define CommoditytjList                         @"/api/commodity/tjlist"  //商品详情推荐商品列表
#define AdvertList                                  @"/api/advert/list"             //广告列表接口
#define ConsigneeList                              @"/api/consignee/list"        //收货地址接口
#define ConsigneeAdd                             @"/api/consignee/add"        //新增收货地址
#define ConsigneeEdit                             @"/api/consignee/edit"       //编辑收货地址
#define ConsigneeDele                             @"/api/consignee/del"        //删除收货地址
#define MallOrderAdd                             @"/api/order/add"             //新增订单
#define MallOrderChoosePayMode           @"/api/order/choosePayMode"     //选择支付方式

//登录、注册、找回密码
#define GetSMS                                      @"/api/sms/send"                    //获取短信验证码
#define UserRegister                              @"/api/user/register"             //用户注册
#define UserForget                                 @"/api/user/forget"               //忘记密码
#define CheckCode                                  @"/api/sms/checkCode"          //校验验证码
#define UserLogin                                   @"/api/login"                           //用户登录
#define PhoneCheckup                             @"/api/user/checkup"             //验证手机号是否存在
#define GetUserInfo                               @"/api/info"                            //获取登录用户的信息

//保养
#define ChecktypeList                             @"/api/checktype/list"              //检查类别
#define CheckcategoryList                      @"/api/checkcategory/list"       //检查部位列表
#define ChecktermList                            @"/api/checkterm/list"             //某部位的检查内容列表
#define afafds                                         @"/api/checkContent/list"       //检查部位下检查内容和服务内容
#define CarUpkeepAdd                            @"/api/carUpkeep/add"            //生成检查单信息
#define DiscountList                                @"/api/discount/list"                //优惠列表
#define CarAdd                                        @"/api/car/add"                       //新增车辆信息
#define CarUpdate                                   @"/api/car/update"                  //更新车辆信息
#define CarList                                        @"/api/car/list"                        //车辆列表
#define CarUpkeepUpdate                       @"/api/carUpkeep/update"    //更新检查订单支付状态

//个人中心
#define ListServiceContent                     @"/api/user/listServiceContent"     //获取服务内容
#define CustomizeServiceContent           @"/api/user/customizeServiceContent"     //提交定制服务内容
#define ListServicePackage                     @"/api/user/listServicePackage"     //服务套餐列表
#define CustomizeServicePackage           @"/api/user/customizeServicePackage"    //提交服务套餐
#define MallOrderList                             @"/api/order/list"                    //商城订单列表
#define MallOrderGetInfo                      @"/api/order/getInfo"               //商城订单详情
#define DiscountAdd                               @"/api/discount/add"              //新增优惠
#define DiscountEdit                               @"/api/discount/edit"             //编辑优惠
#define MessageList                                @"/api/message/list"              //消息列表

#define StoreGetInfo                              @"/api/store/get"                 //获取门店详情
#define StoreInfoUpdate                        @"/api/store/update"            //修改门店信息
#define StoreRegister                             @"/api/store/register"              //门店申请
#define StoreListStaff                           @"/api/store/listStaff"             //员工列表
#define StoreDelStaff                            @"/api/store/delStaff"             //删除员工
#define StoreAddStaff                           @"/api/store/addStaff"           //添加员工
#define StaffSkillList                             @"/api/store/listStaffSkill"       //获取员工技能列表
#define StoreUpdateStaffSkill               @"/api/store/updateStaffSkill"     //员工自己修改技能

#define FavoriteList                                @"/api/favorite/list"                   //收藏列表
#define FavoriteCollect                           @"/api/favorite/collect"              //收藏
#define FavoriteDecollect                       @"/api/favorite/decollect"          //取消收藏


#define BaiduPush_Key @"DyHZlmzGGtjfRDyVmtcG3MG5" //百度云推送key

#pragma mark - 支付宝配置区
#define AliPay_AppId                            @"2017101609335037"
//#define Alipay_Rsa2PrivateKey               @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsLs8Y1IMwkIMNy/jXRiOjrOyK0TEibTUwJl5LQRbNCueX6NYABsFsfPtCTEUarSoyuKf5YWtQ6KdBPwNWHDNx2B+vgx7fsluMHmv2Yj742sX5CCV6mdB9EPmr7kySFMv6sh8RSK13DnS5xOpUSxX3kDbNBo4ayQ8lXUvLhIJZPl42C1ToVJZhGMU3jBIYSSe9q1fjF4DzYEpEmfsziP7nn5f67udQhCYzP7eB5pGJTHVdk3R67ZQOAEdmC5sU7pyJ9IoJyW6FbyvXJ3BsVNkJYXQN0HjtLbK3HsLb7mlZrjDjyLkm69EfGmG+l7xTlPI4S7XgC9TUP0GTYJLJmBocQIDAQAB"
#define Alipay_Rsa2PrivateKey              @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBANolGFJ9a/52qMkoJ5mSbReFNshUnghUAh6WPsUXsAbgwYhjQs7wZ+Vs0etHsHDgQrv1dO9S7d+d9QdoWyQyXSQL2z5/Vm03JpuPSrlOsuiwvUdFRZeYkj+7FCxSsLMUIpBxz6p9K3CFrSAq7+0SgCn1EkdeDSjYdoOccYKSAaErAgMBAAECgYAzLGyOPVnuMcvalI7lmdH5qIh3alJAReTRZBGJjsr+cg80fYSYoxDcYzDDbufXMuS0zxoFYoDm6lkmybZHwYDTmuu+4/FvnSzPwNMqZtBfbIaBGDL5wqw8RqGDMn7vvzlxleHnYea2JjRXhNZvNAPC+cJMtdwIgkVGAaUG/lPREQJBAPf7KgjW0HA3TlKol7gjQJrIPKOe+2ey03vSxNq4h1TIM5J6xgxSUlYHp2bBPHi3FlkdNiSrVpdAKEl4vXwvxcUCQQDhMvDd/6t0GmniKslE2yaFsJw4aYh7PQWPQLUqEk9HcUMB141bVTQ3qgnym4X3JqQ3/mroCzo4uUQhRDlKQiovAkAuwMfYCsgZoBPAOdEBAoR3qjDkmGDF2E1PFxnOMuQw893lTAhy4kJrvd2t3djM2Zf5DSzcFQGqWoo97+mptEgRAkEAjtmleO0JcWif6duCOK9bTEqvjglDjgkzUZ+WS825hHQQMUbuYBU4PmcaUE7fN9vHJ823OuKEWB8NXJzOSpCV+QJBANAHUyuGNjsYBLCYeWkPWZ2Om7KhVoh3mmqgJPgLI5EgYQHq3onJL8l3ht+2bGcBToM+Aag5vLqT6Cgy6iHss+M="


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
