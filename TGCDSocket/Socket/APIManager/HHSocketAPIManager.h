//
//  HHSocketAPIManager.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/8.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketTask.h"
@interface HHAPIConfiguration : NSObject

@property (strong, nonatomic) NSDictionary *messageHeader;
@property (strong, nonatomic) PBGeneratedMessage *message;
@property (assign, nonatomic) HHSocketMessageType messageType;

@end

@interface HHDataAPIConfiguration : HHAPIConfiguration

@property (assign, nonatomic) NSTimeInterval cacheValidTimeInterval;

@end

@interface HHSocketAPIManager : NSObject

- (HHSocketTask *)dataTaskWithConfiguration:(HHDataAPIConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;
- (NSNumber *)dispatchDataTaskWithConfiguration:(HHDataAPIConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)cancelAllTask;
- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier;

@end
