//
//  HHSocketService.m
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import "HHSocketService.h"

@interface HHSocketService ()

@property (assign, nonatomic) HHServiceType type;
@property (assign, nonatomic) HHServiceEnvironment environment;

@end

@interface HHSocketServiceX : HHSocketService
@end

@interface HHSocketServiceY : HHSocketService
@end

@interface HHSocketServiceZ : HHSocketService
@end

@implementation HHSocketService

#pragma mark - Interface

+ (instancetype)defaultService {
    return [HHSocketService serviceWithType:HHService0];
}

+ (HHSocketService *)serviceWithType:(HHServiceType)type {
    
    HHSocketService *service;
    type %= HHServiceCount;
    switch (type) {
        case HHService0: service = [HHSocketServiceX new];  break;
        case HHService1: service = [HHSocketServiceY new];  break;
        case HHService2: service = [HHSocketServiceZ new];  break;
    }
    service.type = type;
    service.environment = HHBulidServiceEnvironment;
    return service;
}

- (NSString *)host {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentHost];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentHost];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentHost];
    }
}

- (int16_t)port {
    
    switch (self.environment) {
        case HHServiceEnvironmentTest: return [self testEnvironmentPort];
        case HHServiceEnvironmentDevelop: return [self developEnvironmentPort];
        case HHServiceEnvironmentRelease: return [self releaseEnvironmentPort];
    }
}

@end


#pragma mark - HHServiceX

@implementation HHSocketServiceX

- (int16_t)testEnvironmentPort {
    return 123;
}

- (int16_t)developEnvironmentPort {
    return 123;
}

- (int16_t)releaseEnvironmentPort {
    return 123;
}

- (NSString *)testEnvironmentHost {
    return @"0.0.0.0";
}

- (NSString *)developEnvironmentHost {
    return @"0.0.0.0";
}

- (NSString *)releaseEnvironmentHost {
    return @"0.0.0.0";
}

@end

#pragma mark - HHServiceY

@implementation HHSocketServiceY

- (int16_t)testEnvironmentPort {
    return 7001;
}

- (int16_t)developEnvironmentPort {
    return 7001;
}

- (int16_t)releaseEnvironmentPort {
    return 7001;
}

- (NSString *)testEnvironmentHost {
    return @"testEnvironmentHost_Y";
}

- (NSString *)developEnvironmentHost {
    return @"developEnvironmentHost_Y";
}

- (NSString *)releaseEnvironmentHost {
    return @"developEnvironmentHost_Y";
}

@end

#pragma mark - HHServiceZ

@implementation HHSocketServiceZ

- (int16_t)testEnvironmentPort {
    return 7001;
}

- (int16_t)developEnvironmentPort {
    return 7001;
}

- (int16_t)releaseEnvironmentPort {
    return 7001;
}

- (NSString *)testEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

- (NSString *)developEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

- (NSString *)releaseEnvironmentHost {
    return @"developEnvironmentHost_Z";
}

@end
