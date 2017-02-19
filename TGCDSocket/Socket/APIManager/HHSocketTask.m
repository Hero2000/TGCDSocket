//
//  HHSocketTask.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "HHSocketTask.h"
#import "HHSocketTask+Friend.h"
#import "HHSocketClient+Friend.h"
#import "HHSocketRequest+Friend.h"

@interface HHSocketTask ()

@property (weak, nonatomic) id client;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) HHSocketTaskState state;
@property (strong, nonatomic) HHSocketRequest *request;
@property (copy, nonatomic) HHNetworkTaskCompletionHander completionHandler;

@end

@implementation HHSocketTask

#pragma mark - Interface(Public)

+ (instancetype)taskWithRequest:(HHSocketRequest *)request completionHandler:(HHNetworkTaskCompletionHander)completionHandler {
    
    HHSocketTask *task = [HHSocketTask new];
    task.state = HHSocketTaskStateSuspended;
    task.request = request;
    if (completionHandler != nil) {
        task.completionHandler = ^(NSError *error, id result) {
            
            completionHandler(error, result);
            task.state = task.state >= HHSocketTaskStateCanceled ? task.state : HHSocketTaskStateCompleted;
        };
    }
    return task;
}

+ (NSError *)taskErrorWithResponeCode:(NSUInteger)code {
    
#define HHTaskErrorCase(responeCode, errorDomain) case responeCode: return HHError(errorDomain, code)
    switch (code) {
            
            HHTaskErrorCase(HHNetworkTaskErrorDefault, HHDefaultErrorNotice);
            HHTaskErrorCase(HHSocketTaskErrorInvalidMsgLength, @"消息长度不合法");
            HHTaskErrorCase(HHSocketTaskErrorLostPacket, @"后台Adler验证消息失败(丢包)");
            HHTaskErrorCase(HHSocketTaskErrorInvalidMsgFormat, @"消息格式不合法");
            HHTaskErrorCase(HHSocketTaskErrorUndefinedMsgType, @"消息类型未找到");
            HHTaskErrorCase(HHSocketTaskErrorEncodeProtobuf, @"protobuf解析失败");
            HHTaskErrorCase(HHSocketTaskErrorDatabaseException, @"数据库操作异常");
            HHTaskErrorCase(HHSocketTaskErrorUnkonwn, @"未知错误");
            HHTaskErrorCase(HHSocketTaskErrorNoPermission, @"无权限");
            HHTaskErrorCase(HHNetworkTaskErrorCannotConnectedToInternet, HHNetworkErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorDoNotConnectedToHost, @"长连接建立连接失败");
            HHTaskErrorCase(HHSocketTaskErrorLostConnection, @"长连接断开连接");
            HHTaskErrorCase(HHNetworkTaskErrorTimeOut, HHTimeoutErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorCanceled, @"任务已取消");
            HHTaskErrorCase(HHSocketTaskErrorNoMatchAdler, @"前端Adler32验证失败");
            HHTaskErrorCase(HHSocketTaskErrorNoProtobuf, @"protobufBody为空");
            HHTaskErrorCase(HHNetworkTaskErrorNoData, HHNoDataErrorNotice);
            HHTaskErrorCase(HHNetworkTaskErrorNoMoreData, HHNoMoreDataErrorNotice);
            
        default: return nil;
    }
}

- (void)cancel {
    
    if (self.state <= HHSocketTaskStateRunning) {
        
        [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorCanceled]];
        self.state = HHSocketTaskStateCanceled;
    }
}

- (void)resume {

    if (self.state == HHSocketTaskStateSuspended) {
     
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.request.timeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.state = HHSocketTaskStateRunning;
        [self.client resumeTask:self];
    }
}

- (NSNumber *)taskIdentifier {
    return self.request.requestIdentifier;
}

#pragma mark - Interface(Friend)

- (NSData *)taskData {
    return self.request.requestData;
}

- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error {
    
    if (self.state <= HHSocketTaskStateRunning) {
        
        NSData *responseContent;
        if (responseData == nil) {
            error = [self taskErrorWithResponeCode:HHSocketTaskErrorUnkonwn];
        } else {
            
            int responseCode = [HHSocketResponseFormatter responseCodeFromData:responseData];
            int responseContentLength = [HHSocketResponseFormatter responseContentLengthFromData:responseData];
            NSData *responseAdler = [HHSocketResponseFormatter responseAdlerFromData:responseData];
            
            responseContent = [HHSocketResponseFormatter responseContentFromData:responseData];
            NSData *adler = [HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)responseContent.bytes length:responseContentLength];
            
            error = [self taskErrorWithResponeCode:([responseAdler isEqual:adler] ? responseCode : HHSocketTaskErrorNoMatchAdler)];
        }
        [self completeWithResult:responseContent error:error];
        error ? NSLog(@"socket请求失败: %ld %@",error.code, error.domain) : nil;
    }
}

#pragma mark - Action

- (void)requestTimeout {
    
    if (self.state <= HHSocketTaskStateRunning) {
        NSLog(@"requestTimeout");
        self.state = HHSocketTaskStateCanceled;
        [self completeWithResult:nil error:[self taskErrorWithResponeCode:HHNetworkTaskErrorTimeOut]];
    }
}

#pragma mark - Utils

- (void)completeWithResult:(id)result error:(NSError *)error {
    
    [self.timer invalidate];
    dispatch_async(dispatch_get_global_queue(2, 0), ^{
        self.completionHandler ? self.completionHandler(error, result) : nil;
        self.completionHandler = nil;
    });
}

- (NSError *)taskErrorWithResponeCode:(int)code {
    return [HHSocketTask taskErrorWithResponeCode:code];
}

@end
