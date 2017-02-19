//
//  HHSocket.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketConfig.h"

@class HHSocket;
@protocol HHSocketDelegate <NSObject>

- (void)socketCanNotConnectToService:(HHSocket *)sock;
- (void)socket:(HHSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;
- (void)socketDidDisconnect:(HHSocket *)sock error:(NSError *)error;

- (void)socket:(HHSocket *)sock didReadData:(NSData *)data;

@end

@interface HHSocket : NSObject

+ (instancetype)socketWithDelegate:(id<HHSocketDelegate>)delegate;
+ (instancetype)socketWithDelegate:(id<HHSocketDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (BOOL)isConnectd;

- (void)close;
- (void)connect;
- (void)disconnect;
- (void)connectWithRetryTime:(NSUInteger)retryTime;

- (void)writeData:(NSData *)data;

- (void)switchService;
- (void)switchToService:(HHServiceType)serviceType;

@end
