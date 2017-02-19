//
//  HHNetworkTaskError.h
//  TAFNetworking
//
//  Created by 黑花白花 on 2017/2/11.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#ifndef HHNetworkTaskError_h
#define HHNetworkTaskError_h

typedef enum : NSUInteger {
    HHNetworkTaskErrorDoNotConnectedToHost = 100,
    HHNetworkTaskErrorTimeOut = 101,
    HHNetworkTaskErrorCannotConnectedToInternet = 102,
    HHNetworkTaskErrorCanceled = 103,
    HHNetworkTaskErrorDefault = 104,
    HHNetworkTaskErrorNoData = 105,
    HHNetworkTaskErrorNoMoreData = 106
} HHNetworkTaskError;

typedef enum : NSUInteger {
    HHSocketTaskErrorLostConnection = 300,
    HHSocketTaskErrorInvalidMsgLength = 301,
    HHSocketTaskErrorLostPacket = 302,
    HHSocketTaskErrorInvalidMsgFormat = 303,
    HHSocketTaskErrorUndefinedMsgType = 401,
    HHSocketTaskErrorEncodeProtobuf = 402,
    HHSocketTaskErrorDatabaseException = 403,
    HHSocketTaskErrorUnkonwn = 404,
    HHSocketTaskErrorNoPermission = 405,
    HHSocketTaskErrorNoMatchAdler = 455,
    HHSocketTaskErrorNoProtobuf = 456
} HHSocketTaskError;

static NSError *HHError(NSString *domain, NSInteger code) {
    return [NSError errorWithDomain:domain code:code userInfo:nil];
}

static NSString *const HHNoDataErrorNotice = @"这里什么也没有~";
static NSString *const HHNetworkErrorNotice = @"当前网络差, 请检查网络设置~";
static NSString *const HHTimeoutErrorNotice = @"请求超时了~";
static NSString *const HHDefaultErrorNotice = @"请求失败了~";
static NSString *const HHNoMoreDataErrorNotice = @"没有更多了~";
#endif
