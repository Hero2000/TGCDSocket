//
//  HHSocketConfig.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#ifndef HHSocketConfig_h
#define HHSocketConfig_h

typedef NS_ENUM(NSUInteger, HHSocketMessageType) {
    /**
     * 账户管理
     */
    ACOUNT_LOGIN = 0x0000000,// 账户-用户登录
    ACOUNT_ID_ARRAY = 0x0000000, // 获取用户id数组
    USER_LIST_FRIEND_INIT = 0x0000000,// 好友列表初始化
    
};

typedef NS_ENUM(NSUInteger, HHLoginType) {
    //采用8421编码，高8位指定登录端，低8位指定登录方式。
    //在请求参数的时候，使用或运算将两部分常量进行或运算拼接。
    //高8位指定登录端：
    TERMINAL_WEB = 0X0100, // 网页端登录
    TERMINAL_IOS = 0X0200,// IOS端登录
    TERMINAL_ANDROID = 0X0400,// Android端登录
    TERMINAL_WINDOWS_PHONE = 0X0800,// WindowsPhone端登录
    TERMINAL_UBUNTU = 0X1000,// Ubuntu端登录
    
    //低8位指定登录方式：
    FROM_EMAIL = 0X0001,// 邮箱登录
    FROM_PHONE_NUMBER = 0X0002,// 手机号登录
    FROM_USERNAME = 0X0004,// 用户名登录
    FROM_WEIBO = 0X0008,// 微博登录
    FROM_QQ = 0X0010,// QQ登录
    FROM_WEIXIN = 0X0020,// 微信登录
};

//这里把8421编码转换成十进制，再进行位与运算得值后判断
typedef NS_ENUM(NSInteger, HHLoginResult) {
    //    采用8421编码，接收后使用与运算进行验证。
    //    高4位表示登录是否成功，或失败则表示不成功的原因：
    ILLEGAL_USERNAME = 16, // 用户名不存在
    ILLEGAL_PASSWORD = 32, // 密码错误
    IS_IN_BLACK_LIST = 64, // 用户在黑名单中
    SUCCESS = -128, // 登录成功
    
    //    低4位表示是否更新，只有在登录成功的时候才拼接低4位：
    UPDATE_REQUEST = 1,// 需要更新
    UPDATE_NO_REQUEST = 2,// 不需要更新
};

typedef enum : NSUInteger {
    HHService0,
    HHService1,
    HHService2
} HHServiceType;
static NSUInteger const HHServiceCount = 3;
static NSString *const HHSwitchServiceNotification = @"HHSwitchServiceNotification";

typedef enum : NSUInteger {
    HHServiceEnvironmentTest,
    HHServiceEnvironmentDevelop,
    HHServiceEnvironmentRelease
} HHServiceEnvironment;
static NSUInteger const HHBulidServiceEnvironment = 0;

typedef enum : NSUInteger {
    HHSocketRequestTypeHearbeat = 0,
    HHSocketRequestTypePush,
    HHSocketRequestTypeCancel
} HHSocketRequestType;

static NSUInteger const HHMaxResponseLength = 20000;

#define kSocketSessionId @"ewqewqewqewq"

#define UUIDLength 0/** UUID的长度 */
#define MsgTypeLength 0/** 消息类型的长度 */
#define MsgSerialNumberLength 0/** 消息序号的长度 */
#define MsgResponseCodeLength 0/** 消息状态码的长度 */
#define MsgContentLength 0/** 消息内容的长度 */
#define Adler32Length 0/** Adler32的长度 */
#define MsgResponsePrefixLength (MsgTypeLength + MsgSerialNumberLength + MsgResponseCodeLength + MsgContentLength)/** 返回消息前16字节长度 */
#define MsgResponseSuffixLength (Adler32Length + MsgTypeLength)/** 返回消息后12字节长度 */
#define MsgResponseHeaderLength (MsgResponsePrefixLength + MsgResponseSuffixLength)/** 返回的消息除去protobuf外的长度 */

#endif
