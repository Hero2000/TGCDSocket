//
//  HHSocketClient.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/16.
//  Copyright © 2017年 黑花白花. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "HHSocketClient.h"

#import "HHSocket.h"
#import "HHAppContext.h"
#import "HHSocketRequest.h"
#import "HHNetworkTaskError.h"
#import "HHSocketTask+Friend.h"
#import "HHSocketClient+Friend.h"

#import "HHSocketHeartbeat.h"

@interface HHSocketClient()<HHSocketDelegate>

@property (strong, nonatomic) HHSocket *socket;
@property (strong, nonatomic) NSMutableData *readData;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, HHSocketTask *> *dispathTable;
@property (assign, nonatomic) CGFloat totalTaskCount;
@property (assign, nonatomic) CGFloat errorTaskCount;

@property (strong, nonatomic) HHSocketHeartbeat *heatbeat;

@end

@implementation HHSocketClient

static dispatch_semaphore_t lock;
+ (instancetype)sharedInstance {
    static HHSocketClient *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        lock = dispatch_semaphore_create(1);
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.socket = [HHSocket socketWithDelegate:self];
        self.readData = [NSMutableData data];
        self.dispathTable = [NSMutableDictionary dictionary];
        self.heatbeat = [HHSocketHeartbeat heartbeatWithClient:self timeoutHandler:^{
            [self reconnect];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNetworkChangedNotificaiton:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

#pragma mark - HHSocketDelegate

- (void)socket:(HHSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接到服务器");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnectToHost" object:nil];
}

- (void)socketDidDisconnect:(HHSocket *)sock error:(NSError *)error {
    
    NSLog(@"连接断开");
    [self.heatbeat stop];
    [self reconnect];
}

- (void)socketCanNotConnectToService:(HHSocket *)sock {
    
    NSLog(@"一直连不上");
    [self.socket switchService];
    [self reconnect];
}

- (void)socket:(HHSocket *)sock didReadData:(NSData *)data {
    
    [self.heatbeat reset];
    if (data.length >= HHMaxResponseLength) { return; }
    
    [self.readData appendData:data];
    NSData *responseData = [self getParsedResponseData];
    if (responseData) {
        
        NSNumber *taskIdentifier = @([HHSocketResponseFormatter responseSerialNumberFromData:responseData]);
        HHSocketTask *task = self.dispathTable[taskIdentifier];
        if (task) {
            dispatch_async(dispatch_get_global_queue(2, 0), ^{
                [task completeWithResponseData:responseData error:nil];
            });
        } else {
            
//            switch ([taskIdentifier integerValue]) {
//                case HHSocketTaskPush: {
//                    
//                }   break;
//                    
//                case HHSocketTaskHearbeat: {
//                    
//                    NSLog(@"心跳%d",[taskIdentifier intValue]);
//                    [self.heatbeat respondToServerWithSerialNum:[taskIdentifier intValue]];
//                }
//                default: break;
//            }
            NSLog(@"心跳%d",[taskIdentifier intValue]);
            [self.heatbeat respondToServerWithSerialNum:[taskIdentifier intValue]];
        }
    }
}

#pragma mark - Interface(Public)

- (void)connect {
    [self.socket connectWithRetryTime:5];
}

- (void)disconncet {
    [self.socket disconnect];
}

- (HHSocketTask *)dataTaskWithMessgeType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message messageHeader:(NSDictionary *)messageHeader completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHSocketRequest *request = [HHSocketRequest normalRequestWithMessageType:type message:message header:messageHeader];
    return [self dataTaskWithRequest:request completionHandler:completionHandler];
}

- (HHSocketTask *)dataTaskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    NSMutableArray *taskIdentifier = [NSMutableArray arrayWithObject:@-1];
    HHSocketTask *task = [HHSocketTask taskWithRequest:request completionHandler:^(NSError *error, id result) {
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        [self checkSeriveWithTaskError:error];
        [self.dispathTable removeObjectForKey:taskIdentifier.firstObject];
        dispatch_semaphore_signal(lock);
        
        completionHandler ? completionHandler(error, result) : nil;
    }];
    task.client = self;
    taskIdentifier[0] = task.taskIdentifier;
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    [self.dispathTable setObject:task forKey:taskIdentifier.firstObject];
    dispatch_semaphore_signal(lock);
    
    return task;
}

- (NSNumber *)dispatchTask:(HHSocketTask *)task {
    
    if (task == nil) { return @-1; }
    
    [task resume];
    return task.taskIdentifier;
}

- (NSNumber *)dispatchTaskWithMessgeType:(HHSocketMessageType)type message:(PBGeneratedMessage *)message messageHeader:(NSDictionary *)messageHeader completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    return [self dispatchTask:[self dataTaskWithMessgeType:type message:message messageHeader:messageHeader completionHandler:completionHandler]];
}

- (void)cancelAllTasks {
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    for (HHSocketTask *task in self.dispathTable.allValues) {
        [task cancel];
    }
    [self.dispathTable removeAllObjects];
    dispatch_semaphore_signal(lock);
}

- (void)cancelTaskWithTaskIdentifier:(NSNumber *)taskIdentifier {
    
    HHSocketTask *task = [self.dispathTable objectForKey:taskIdentifier];
    if (task) { [task cancel]; }
}

#pragma mark - Interface(Friend)

- (void)resumeTask:(HHSocketTask *)task {
 
    if (self.socket.isConnectd) {
        [self.socket writeData:task.taskData];
    } else {
     
        NSError *error;
        if ([HHAppContext sharedInstance].isReachable) {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorDoNotConnectedToHost);
        } else {
            error = HHError(HHNetworkErrorNotice, HHNetworkTaskErrorCannotConnectedToInternet);
        }
        
        [self reconnect];
        [task completeWithResponseData:nil error:error];
    }
}

#pragma mark - Notification

- (void)didReceivedSwitchSeriveNotification:(NSNotification *)notif {
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    self.totalTaskCount = self.errorTaskCount = 0;
    [self.socket switchToService:[notif.userInfo[@"service"] integerValue]];
    dispatch_semaphore_signal(lock);
}

- (void)didReceiveNetworkChangedNotificaiton:(NSNotification *)notif {
    
    Reachability *currentReach = [notif object];
    if ([currentReach isKindOfClass:[Reachability class]] &&
        [currentReach currentReachabilityStatus] != NotReachable) {
        [self reconnect];
    }
}

#pragma mark - Utils

- (void)reconnect {
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    self.readData = [NSMutableData data];
    self.totalTaskCount = self.errorTaskCount = 0;
    for (HHSocketTask *task in self.dispathTable.allValues) {
        [task completeWithResponseData:nil error:HHError(@"长连接已断开", HHSocketTaskErrorLostConnection)];
    }
    [self.dispathTable removeAllObjects];
    dispatch_semaphore_signal(lock);
    
    if ([HHAppContext sharedInstance].isReachable) {
        [self.socket connectWithRetryTime:8];
    }
}

- (NSData *)getParsedResponseData {
    
    NSData *responseData;
    NSData *totalReceivedData = self.readData;
    if (totalReceivedData.length >= HHMaxResponseLength * 2) {
        [self reconnect];//socket解析错误, 断开重连
    } else if (totalReceivedData.length >= MsgResponsePrefixLength) {
        
        HHSocketResponseFormatter *formatter = [HHSocketResponseFormatter formatterWithResponseData:totalReceivedData];
        int msgContentLength = formatter.responseContentLength;
        int msgResponseLength = msgContentLength + MsgResponseHeaderLength;
        if (msgResponseLength == totalReceivedData.length) {
            
            responseData = totalReceivedData;
            self.readData = [NSMutableData data];
        } else if (msgContentLength < totalReceivedData.length) {
            
            responseData = [totalReceivedData subdataWithRange:NSMakeRange(0, msgResponseLength)];
            self.readData = [[totalReceivedData subdataWithRange:NSMakeRange(msgResponseLength, totalReceivedData.length - msgResponseLength)] mutableCopy];
        }
    }
    
    return responseData;
}

- (void)checkSeriveWithTaskError:(NSError *)error {
    
    if ([HHAppContext sharedInstance].isReachable) {
        switch (error.code) {
               
            case HHSocketTaskErrorUnkonwn:
            case HHNetworkTaskErrorTimeOut:
            case HHSocketTaskErrorLostPacket: {
                self.errorTaskCount += 1;
            }
            default:break;
        }
        
        if (self.totalTaskCount >= 40 && (self.errorTaskCount / self.totalTaskCount) == 0.1) {
            
            self.totalTaskCount = self.errorTaskCount = 0;
            [self.socket switchService];
            [self reconnect];
        }
    }
}

@end
