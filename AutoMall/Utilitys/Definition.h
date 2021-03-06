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
#define HUDDelay 1.8
#define HUDMargin   10

//定位失败时的默认衡阳市经纬度
#define Latitude     @"26.8994600367"
#define Longitude     @"112.5784483174"


#pragma mark ---- color functions
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define Red_BtnColor           RGBCOLOR(237, 28, 36)
#define Gray_Color              RGBCOLOR(63, 63, 63)
#define Orange_Color           RGBCOLOR(234, 33, 45)
#define Cell_sepLineColor       RGBCOLOR(200, 199, 204)     //tablecell间隔线颜色
#define Cell_SelectedColor      RGBCOLOR(234, 234, 234)      //cell点击背景色

#define NavBarTintColor         [UIColor blackColor]        //导航栏返回按钮颜色

#define isIOS8Later ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

//iPhone4
#define   isIphone4  [UIScreen mainScreen].bounds.size.height < 500

//手动适配屏幕宽高
#define kScale_5s_W(value) (([[UIScreen mainScreen]bounds].size.width/320.0) * (value))
#define kScale_5s_H(value) (([[UIScreen mainScreen]bounds].size.height/568.0) * (value))

#define STRING_Nil(str)         (str==nil)?@"":str
#define STRING_Time_Nil(str)         (str==nil)?@"1970-01-01":str
#define STRING(str)         (str==[NSNull null])?@"":str
#define STRINGOne(str)         (str==[NSNull null])?@"1":str
#define STRINGZero(str)         (str==[NSNull null])?@"0":str
#define NSStringWithNumberNULL(number)    number==[NSNull null]?@"":[NSString stringWithFormat:@"%@",number]
#define NSStringWithNumber(number)    number==nil?@"":[NSString stringWithFormat:@"%@",number]
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

//汽车商城
#define UrlPrefix(action)                       ([NSString stringWithFormat:@"http://120.79.255.24/carupkeep%@",action])  //测试服务器ip地址
//#define UrlPrefix(action)                       ([NSString stringWithFormat:@"http://119.23.227.246/carupkeep%@",action])   //正式服务器对应ip地址
//#define UrlPrefix(action)                       ([NSString stringWithFormat:@"http://hengliantech.com/carupkeep%@",action])   //正式服务器

#define UrlPrefixNew(action)                       ([NSString stringWithFormat:@"http://120.79.255.24:8010/%@",action])  //测试服务器ip地址，发票相关的新地址
//#define UrlPrefixNew(action)                       ([NSString stringWithFormat:@"http://119.23.227.246:8010/%@",action])  //正式服务器ip地址，发票相关的新地址
//#define UrlPrefixNew(action)                       ([NSString stringWithFormat:@"http://hengliantech.com:8010/%@",action])  //正式服务器域名，发票相关的新地址

//资讯、教程
#define InformationList                          @"/api/info/list"    //资讯列表
#define InformationDetail                      @"/api/info/info"   //资讯详情
#define CourseList                                  @"/api/course/list"  //教程列表
#define CourseDetail                               @"/api/course/info"  //教程详情


#define UploadUploadImg                       @"/api/upload/uploadImg"    //上传图片
#define UploadImgFile                            @"/api/upload/uploadFile"    //上传图片（通过二进制流上传）

//商城
#define ComCategoryList                         @"/api/comCategory/list"    //商品分类
#define CommodityList                            @"/api/commodity/list"       //商品列表
#define CommoditySearch                       @"/api/commodity/search"       //商品列表
#define CommodityDetail                        @"/api/commodity/getInfo"   //商品详情
#define CommodityGetDesInfo               @"/api/commodity/getDesInfo"    //获取商品描述url
#define CommoditytjList                         @"/api/commodity/tjlist"  //商品详情推荐商品列表
#define AdvertList                                  @"/api/advert/list"             //广告列表接口
#define ConsigneeList                              @"/api/consignee/list"        //收货地址接口
#define ConsigneeAdd                             @"/api/consignee/add"        //新增收货地址
#define ConsigneeEdit                             @"/api/consignee/edit"       //编辑收货地址
#define ConsigneeDele                             @"/api/consignee/del"        //删除收货地址
#define MallOrderAdd                             @"/api/order/add"             //新增订单
#define MallOrderChoosePayMode           @"/api/order/choosePayMode"     //选择支付方式
#define MallOrderPaySuccess                  @"/api/order/paySuccess"                 //支付成功回调
#define GetIntegralAs1Yuan                    @"/api/integral/getIntegralAs1Yuan"       //获取一元对应的积分数
#define GetComtermList                          @"/api/comterm/list"        //获取商品项目列表

//登录、注册、找回密码
#define GetSMS                                      @"/api/sms/send"                    //获取短信验证码
#define UserRegister                              @"/api/user/register"             //用户注册
#define UserForget                                 @"/api/user/forget"               //忘记密码
#define CheckCode                                  @"/api/sms/checkCode"          //校验验证码
#define UserLogin                                   @"/api/login"                           //用户登录
#define PhoneCheckup                             @"/api/user/checkup"             //验证手机号是否存在
#define GetUserInfo                               @"/api/info"                            //获取登录用户的信息
#define ServiceInfo                                @"http://hengliantech.com/carupkeep/api/service/info"            //服务条款

//保养
#define ChecktypeList                             @"/api/checktype/list"              //检查类别
#define CheckcategoryList                      @"/api/checkcategory/list"       //检查部位列表
#define ChecktermList                            @"/api/checkterm/list"             //某部位的检查内容列表
#define CheckContentList                        @"/api/checkContent/list"       //检查部位下检查内容和服务内容
#define CarUpkeepAdd                            @"/api/carUpkeep/add"            //生成检查单信息
#define DiscountList                                @"/api/discount/list"                //优惠列表
#define CarAdd                                        @"/api/car/add"                       //新增车辆信息
#define CarUpdate                                   @"/api/car/update"                  //更新车辆信息
#define CarListOrSearch                         @"/api/car/search"                  //车辆列表及搜索
#define CarUpkeepUpdate                       @"/api/carUpkeep/update"    //更新检查订单支付状态
#define CarUpkeepSearch                       @"/api/carUpkeep/search"    //app车辆保养记录列表和app个人中心，不同状态下的检查单和保养记录列表
#define CarUpkeepInfo                           @"/api/carUpkeep/info"              //获取检查单详情
#define CarUpkeepUnnormal                   @"/api/carUpkeep/unnormal"      //检查单所有异常列表
#define CarUpkeepCategory                    @"/api/carUpkeep/category"      //检查单具体检查部位下检查结果详情
#define CarUpkeepCheckTerm                 @"/api/carUpkeep/checkTerm"     //检查单（具体检查内容下）检查结果详情
#define CarUpkeepServiceContent           @"/api/carUpkeep/serviceContent"    //检查单相关的服务方案
#define ServicepackageList                      @"/api/servicepackage/list"     //服务套餐列表
#define CarUpkeepConfirm                       @"/api/carUpkeep/confirm"   //服务方案确认
#define CarUpkeepShare                          @"/api/carUpkeep/share"         //分享检查单
#define CarUpkeepShareService              @"/api/carUpkeep/shareService"         //分享服务方案
#define CarUpkeepLastMileage                @"carupkeep_web/carUpkeep/lastMileage"      //获取上次保养里程数

//个人中心
#define AllCheckcategorySearch            @"/api/checkcategory/search"        //平台所有部位列表
#define ChecktermSearch                      @"/api/checkterm/search"                //指定部位下，平台所有位置列表

#define ListServiceContent                     @"/api/user/listServiceContent"     //获取服务内容
#define CustomizeServiceContent           @"/api/user/customizeServiceContent"     //提交定制服务内容
#define ListServicePackage                     @"/api/user/listServicePackage"     //服务套餐列表
#define CustomizeServicePackage           @"/api/user/customizeServicePackage"    //提交服务套餐
#define MallOrderList                             @"/api/order/list"                    //商城订单列表
#define MallOrderGetInfo                      @"/api/order/getInfo"               //商城订单详情
#define DiscountAdd                               @"/api/discount/add"              //新增优惠
#define DiscountDel                                @"/api/discount/del"            //删除优惠
#define DiscountEdit                               @"/api/discount/edit"             //编辑优惠
#define StoreserviceList                         @"/api/storeservice/list"       //获取门店服务
#define StoreserviceDel                          @"/api/storeservice/del"        //删除门店服务
#define StoreserviceAdd                         @"/api/storeservice/add"        //新增门店服务
#define MessageList                                @"/api/message/list"              //消息列表
#define ReadMsgOk                                 @"carupkeep_web/message/readMsgOk"      //消息已读
#define DelMsgOk                                    @"carupkeep_web/message/delMsg"     //消息删除
#define AgreementInfo                           @"http://hengliantech.com/carupkeep/api/agreement/info"         //免责声明
#define GetPhoneInfo                              @"/api/phone/getPhoneInfo"      //获取官网联系电话
#define ChangeNickName                         @"/api/user/changeNickname"     //修改昵称和微信
#define GetApprovalStatus                      @"/api/store/getApprovalStatus"     //获取门店的审批状态
#define UserChangeImage                       @"/api/user/changeImage"        //修改个人头像
#define UserChangeRemark                     @"/api/user/changeRemark"       //员工修改个人特长
#define UserLogOut                                  @"carupkeep_web/adminUser/quitStaff"         //员工注销身份
#define ReportSum                                   @"/api/report/sum"      //统计报表
#define InvoiceManageList                        @"carupkeep_web/userInvoiceMgr/listByUserId"              //发票管理列表
#define InvoiceManageDetail                    @"carupkeep_web/userInvoiceMgr/getById"         //发票管理详情
#define AddInvoice                                   @"carupkeep_web/userInvoiceMgr/add"         //新增发票
#define UpDateInvoice                              @"carupkeep_web/userInvoiceMgr/update"      //更新发票
#define DeleInvoice                                   @"carupkeep_web/userInvoiceMgr/delete"      //删除发票
#define OrderInvoiceCreat                        @"carupkeep_web/orderInvoiceHis/invoicingList"      //批量开发票
#define OrderInvoiceList                           @"carupkeep_web/orderInvoiceHis/getByUserId"     //订单已开发票列表
//#define OrderInvoiceDetail                        @"carupkeep_web/orderInvoiceHis/getById"        //根据id获取发票详细信息
#define OrderInvoiceDetail                        @"carupkeep_web/orderInvoiceHis/getByOrderNo"           //根据订单号获取发票详细信息

#define StoreGetInfo                              @"/api/store/get"                 //获取门店详情
#define UserGetStoreInfo                      @"/api/user/getStore"           //员工获取门店详情
#define StoreInfoUpdate                        @"/api/store/update"            //修改门店信息
#define StoreRegister                             @"/api/store/register"              //门店申请
#define StoreListStaff                           @"/api/store/listStaff"             //员工列表
#define StoreDelStaff                            @"/api/store/delStaff"             //删除员工
#define StoreAddStaff                           @"/api/store/addStaff"           //添加员工
#define StaffSkillList                             @"/api/store/listStaffSkill"       //获取员工技能列表
#define StoreApproveSkill                      @"/api/store/approveSkill"           //老板审核员工技能认证
//#define StoreUpdateStaffSkill               @"/api/store/updateStaffSkill"     //员工自己修改技能
#define UserChangeSkill                          @"/api/user/changeSkill"            //员工修改单个技能
#define UserAppendSkill                         @"/api/user/appendSkill"            //员工自己添加技能
#define StoreDelStaffSkill                      @"carupkeep_web/staffSkill/deleteSkill"      //老板删除员工技能

#define FavoriteList                                @"/api/favorite/list"                   //收藏列表
#define FavoriteCollect                           @"/api/favorite/collect"              //收藏
#define FavoriteDecollect                       @"/api/favorite/decollect"          //取消收藏




#define BaiduPush_Key @"mvqSOLT1NE0VC9xgGNxdUf7j" //百度云推送key，客户提供账号
//#define BaiduPush_Key @"T0dHmi0dWENkPEETk6YiWj2B" //百度云推送key，自己的账号


#pragma mark - 支付宝配置区
#define AliPay_AppId                            @"2017101609335037"
#define Alipay_Rsa2PrivateKey               @"MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDKjP6QksVFhsbwPqV2mZeRJaP3ZUP5tHNrMv9+4H9SJvCzektbdlgYOZuSMJAO/9MhhD+p+pvw0wOMszIs4H1uawtPBjQePTGOGd0NImL+mMjxTF3QDKx0+W663TRG/VStYTW4Cmd9PYmCQeWuRoNKdbmHI33KanZ5ocl/FEpYcv6y90Et8zU266mm+LUiQt7UchgXACWdEv+nkEVTraFNZwVG5GmXzILNJQp3LhMCxiqAfKpOYyO3SxRME8tF38OmpbkisiX7Kt5VLXs93ujUd9a4gG9Qfdux3sXQnE1nxboyhU0DhGZ5/l33nzObR5lV2wLRWy3MM9ubRaQ/hqUJAgMBAAECggEAHQPNg5BCyg7geJHAyhh+acBmmI3dCuwajISlrNsj4fTKDiu6l8OAIxg9fNeQC1YCPI7hP8wygnD31TPmQB94WFTlLdDJrns9mgmCbNs8KxRf1JEH70GhgrAoeIQvdOvdMWj3dQGoiXxDMnGWITzgmc37Yaxn3JMbnZjbcGTLsZel+lFldzJ460v4eSsPh7j12tsaUvqn+W46umCCkLinr+RhLyT1Bfya6OCU/vFT7zPIFP9ATvitteF0IPzNd0QKSSpiYHci9wLgjri9JzOH3kIbNxsspFHJHEqbjyNKV8y3S2rhULHf+1Hq4fFek/bACNEPiNnG6tR5iWaKv6vWsQKBgQD5YTQHF/4sUIeO2zmtlnaRCdGKanur+CoacjNLY0OJt65BxdtdTmWyxrnkErAprTUCM1moqXfYEmNHFOZQeI5ZgSLIl9tE8ppDrv6riVtSJcyq4Ux3qJAHQJFXoiOJRGCInNRjePUMsdUZbF2OtS5CJh5ZGZADhhoT/x9Ph2WJcwKBgQDP7YoTyLvEWjRx6oSns7TPRN/k4KD47s2DWeyaWwCa5ZAohVcIR5yr4XSykUIrM4sRl6dHgD4smNImX2ataUE6qnTFtQKiQauOt2Gk1xKAtZh6q0od2J6aI8HtUNyjjK3A5/vTvN2l/jX4MeqyY0gGX5dZftILD8w3lEtNrZZokwKBgBINPz7kNbnvemCU7e/q3FpTY5+pZZplNGcFrUDfxpvJeAu6zs5KRoJScFJaJ/ZcW2H1ZaAX5Fz3t8gFc0aP8333IxVyKKUtCo2rtTOllb60jcQw2uAui3565gp56iidkn9RGu64asSoesyEU6Fo7BhNuhSpDQu0QV8BMLsJCgiRAoGBAJkMAFllpIf32aiL9Y63IPx7ds2yZeo1ZEItu5E2MLDTDpQ06YXnqDN/5PTXJLxF2TReyzs+8wTCi9TA3gQAeInlE8S+4qxp6AxJgO7je/QPNqf8Ura7TqqobULwBSfBEdfvKZaF6yQWhMUmgNlDaK2ASRgP2C1aOHgkiHUps49PAoGAFmSGJLMkPcuG/AwlWdhpmUXGzhZAySpKm06sYDNfvb/lXaRaY8h2v9vcuhi99C+a4InPm0odWnWKp9bWy90tQ9DXxzpaUst0/Mxi5OTfryv/E+8yQX6ZqDVY41/Bp8EacHJNjL+BGLgQ8iPCOV19amghabcGqpJYscxEhPW5qc8="


//QQ分享
//#define kShare_QQ_AppID @"1104928111"
//#define kShare_QQ_Appkey @"HbJUGVEa2YPVCpic"
//#define kShare_QQ_AppID @"1105017491"
//#define kShare_QQ_Appkey @"ITith6uC1IHl1xBA"
#define kShare_QQ_AppID @"1105226368"
#define kShare_QQ_Appkey @"iDOuxWYFquSdbs0f"



//微信分享
#define kShare_WeChat_Appid                     @"wx0235d94e74c9dcb8"
#define kShare_WeChat_AppSecret             @"ec76865ee87aac82fdf62af5b591d508"
#define Wx_PartnerId                                   @"1491556662"


#define BaiduMap_Key @"4iuR3zi67tyt80tAcVC6c1km" //壹米娱乐百度地图key

#endif
