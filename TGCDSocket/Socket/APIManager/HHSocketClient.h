//
//  HHSocketClient.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/16.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketTask.h"
@interface HHSocketClient : NSObject

+ (instancetype)sharedInstance;

- (void)connect;
- (void)disconncet;

- (HHSocketTask *)dataTaskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (HHSocketTask *)dataTaskWithMessgeType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message messageHeader:(NSDictionary *)messageHeader completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (NSNumber *)dispatchTask:(HHSocketTask *)task;
- (NSNumber *)dispatchTaskWithMessgeType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message messageHeader:(NSDictionary *)messageHeader completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)cancelAllTasks;
- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier;

@end
