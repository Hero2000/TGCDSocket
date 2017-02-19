//
//  HHSocketRequest.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketConfig.h"
#import "HHDataFormatter.h"
#import "GeneratedMessage.h"

typedef enum : NSUInteger {
    HHSocketRequestHeader0 = 1,
    HHSocketRequestHeader1,
    HHSocketRequestHeader2
//    ...
} HHSocketRequestHeader;

@interface HHSocketRequest : NSObject

@property (assign, nonatomic) NSUInteger timeoutInterval;

+ (instancetype)heartbeatRequestWithSerialNum:(int)serialNum;/**< 心跳任务请求 */
+ (instancetype)normalRequestWithMessageType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message header:(NSDictionary *)header;/**< 数据任务请求 */
+ (instancetype)cancelRequestWithMessageType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message;/**< 取消任务请求 */

- (NSNumber *)requestIdentifier;

@end
