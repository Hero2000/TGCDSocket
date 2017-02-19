//
//  HHSocketHeartbeat.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/10.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import "HHSocketHeartbeat.h"

#import "HHSocketClient+Friend.h"

@interface HHSocketHeartbeat ()

@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) id client;
@property (copy, nonatomic) void(^timeoutHandler)();

@end

@implementation HHSocketHeartbeat

+ (instancetype)heartbeatWithClient:(id)client timeoutHandler:(void (^)())timeoutHandler {
    
    HHSocketHeartbeat *heartbeat = [HHSocketHeartbeat new];
    heartbeat.client = client;
    heartbeat.timeoutHandler = timeoutHandler;
    return heartbeat;
}

- (void)start {
    
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:25 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)reset {
    [self start];
}

- (void)stop {
    [self.timer invalidate];
}

- (void)timeout {
    NSLog(@"-----------timeout------------");
    self.timeoutHandler ? self.timeoutHandler() : nil;
}

- (void)respondToServerWithSerialNum:(int)serialNum {
    
    HHSocketRequest *request = [HHSocketRequest heartbeatRequestWithSerialNum:serialNum];
    [self.client resumeTask:[HHSocketTask taskWithRequest:request completionHandler:nil]];
}

@end
