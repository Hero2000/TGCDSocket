//
//  HHSocketRequest.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "HHSocketRequest.h"
@interface HHSocketRequest ()

@property (strong, nonatomic) NSNumber *requestIdentifier;
@property (strong, nonatomic) NSMutableData *formattedData;

@end

#define TimeoutInterval 8
#define HHSocketTaskInitialSerialNumber 50
@implementation HHSocketRequest

- (instancetype)init {
    if (self = [super init]) {
        
        self.formattedData = [NSMutableData data];
        self.timeoutInterval = TimeoutInterval;
    }
    return self;
}

+ (int)currentRequestIdentifier {
    
    static int currentRequestIdentifier;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        currentRequestIdentifier = HHSocketTaskInitialSerialNumber;
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    currentRequestIdentifier += 1;
    dispatch_semaphore_signal(lock);
    
    return currentRequestIdentifier;
}

#pragma mark - Interface(Public)

+ (instancetype)heartbeatRequestWithSerialNum:(int)serialNum {
    
    int messageType = HHSocketRequestTypeHearbeat;
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:kSocketSessionId];
    sessionId = sessionId.length > 0 ? sessionId : @"123435435";
    
    HHSocketRequest *request = [HHSocketRequest new];
    request.requestIdentifier = @-1;
    [request.formattedData appendData:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:serialNum]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:0]];
    [request.formattedData appendData:[HHDataFormatter adler32ToDataWithProtoBuffByte:nil length:0]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];

    return request;
}

+ (instancetype)normalRequestWithMessageType:(HHSocketMessageType)messageType message:(PBGeneratedMessage *)message header:(NSDictionary *)header {
    
    int requestIdentifier = [self currentRequestIdentifier];
    int messageLength = (int)message.data.length;
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:kSocketSessionId];
    sessionId = sessionId.length > 0 ? sessionId : @"ewqewqewqew";
    
    HHSocketRequest *request = [HHSocketRequest new];
    request.requestIdentifier = @(requestIdentifier);
    [request.formattedData appendData:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:requestIdentifier]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:messageLength]];
    [request.formattedData appendData:message.data];
    [request.formattedData appendData:[HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)message.data.bytes length:messageLength]];
    
//    [request.formattedData appendData:[header[@(HHSocketRequestHeader0)] dataUsingEncoding:NSUTF8StringEncoding]];
//    [request.formattedData appendData:[header[@(HHSocketRequestHeader1)] dataUsingEncoding:NSUTF8StringEncoding]];
//    [request.formattedData appendData:[header[@(HHSocketRequestHeader2)] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];
    return request;
}

+ (instancetype)cancelRequestWithMessageType:(HHSocketMessageType)canceledType message:(PBGeneratedMessage *)message {
    
    int messageType = HHSocketRequestTypeCancel;
    int canceledMessageLength = (int)message.data.length;
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:kSocketSessionId];
    sessionId = sessionId.length > 0 ? sessionId : @"ewqewqewqewq";
    
    HHSocketRequest *request = [HHSocketRequest new];
    request.requestIdentifier = @-1;
    [request.formattedData appendData:[sessionId dataUsingEncoding:NSUTF8StringEncoding]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];
    [request.formattedData appendData:[HHDataFormatter msgSerialNumberDataFromInteger:canceledType]];
    [request.formattedData appendData:[HHDataFormatter msgContentLengthDataFromInteger:canceledMessageLength]];
    [request.formattedData appendData:message.data];
    [request.formattedData appendData:[HHDataFormatter adler32ToDataWithProtoBuffByte:(Byte *)message.data.bytes length:canceledMessageLength]];
    [request.formattedData appendData:[HHDataFormatter msgTypeDataFromInteger:messageType]];
    return request;
}

#pragma mark - Interface(Friend)

- (NSData *)requestData {
    return self.formattedData;
}

@end
