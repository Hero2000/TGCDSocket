//
//  OTSFriend.m
//  OneToSay
//
//  Created by HDD on 16/7/5.
//  Copyright © 2016年 Excetop. All rights reserved.
//

#import "OTSFriend.h"

@implementation HHPerson
@end

@implementation OTSFriend

#pragma mark - Protobuf

+ (NSDictionary *)replacedKeyForProtobufPropertyName {
    return @{@"hhuserId" : @"userId",
             @"hhnickname" : @"nickname"};
}

@end
