//
//  HHSocketTask.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketRequest.h"
#import "HHNetworkTaskError.h"

typedef enum : NSUInteger {
    HHSocketTaskStateSuspended = 0,
    HHSocketTaskStateRunning = 1,
    HHSocketTaskStateCanceled = 2,
    HHSocketTaskStateCompleted = 3
} HHSocketTaskState;

typedef void(^HHNetworkTaskCompletionHander)(NSError *error,id result);

@interface HHSocketTask : NSObject

+ (NSError *)taskErrorWithResponeCode:(NSUInteger)code;
+ (instancetype)taskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler;

- (void)cancel;
- (void)resume;

- (HHSocketTaskState)state;
- (NSNumber *)taskIdentifier;

@end
