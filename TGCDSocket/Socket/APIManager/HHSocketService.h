//
//  HHSocketService.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 2017/2/15.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HHSocketConfig.h"
@protocol HHSocketService <NSObject>

@optional
- (int16_t)testEnvironmentPort;
- (NSString *)testEnvironmentHost;

- (int16_t)developEnvironmentPort;
- (NSString *)developEnvironmentHost;

- (int16_t)releaseEnvironmentPort;
- (NSString *)releaseEnvironmentHost;

@end

@interface HHSocketService : NSObject<HHSocketService>

+ (instancetype)defaultService;
+ (instancetype)serviceWithType:(HHServiceType)type;

- (int16_t)port;
- (NSString *)host;

- (HHServiceType)type;

@end
