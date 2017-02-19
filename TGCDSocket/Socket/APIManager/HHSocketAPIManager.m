//
//  HHSocketAPIManager.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/8.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "HHSocketAPIManager.h"
#import "HHSocketClient.h"

@implementation HHAPIConfiguration
@end

@implementation HHDataAPIConfiguration
@end

@interface HHSocketAPIManager ()

@property (strong, nonatomic) NSMutableArray *dispatchTaskIdentifiers;

@end

@implementation HHSocketAPIManager

- (void)dealloc {
    [self cancelAllTask];
}

#pragma mark - Interface

- (HHSocketTask *)dataTaskWithConfiguration:(HHDataAPIConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    return [[HHSocketClient sharedInstance] dataTaskWithMessgeType:config.messageType message:config.message messageHeader:config.messageHeader completionHandler:completionHandler];
}

- (NSNumber *)dispatchDataTaskWithConfiguration:(HHDataAPIConfiguration *)config completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    NSMutableArray *taskIdentifier = [NSMutableArray arrayWithObject:@-1];
    taskIdentifier[0] = [[HHSocketClient sharedInstance] dispatchTaskWithMessgeType:config.messageType message:config.message messageHeader:config.messageHeader completionHandler:^(NSError *error, id result) {
        
        completionHandler ? completionHandler(error, result) : nil;
        [self.dispatchTaskIdentifiers removeObject:taskIdentifier.firstObject];
    }];
    [self.dispatchTaskIdentifiers addObject:taskIdentifier.firstObject];
    return taskIdentifier.firstObject;
}

- (void)cancelAllTask {
    
    for (NSNumber *taskIdentifier in self.dispatchTaskIdentifiers) {
        [[HHSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
    }
    [self.dispatchTaskIdentifiers removeAllObjects];
}

- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier {
    
    if ([self.dispatchTaskIdentifiers containsObject:taskIdentifier]) {
        [[HHSocketClient sharedInstance] cancelTaskWithTaskIdentifier:taskIdentifier];
        [self.dispatchTaskIdentifiers removeObject:taskIdentifier];
    }
}

#pragma mark - Getter

- (NSMutableArray *)dispatchTaskIdentifiers {
    if (!_dispatchTaskIdentifiers) {
        _dispatchTaskIdentifiers = [NSMutableArray array];
    }
    return _dispatchTaskIdentifiers;
}

@end
