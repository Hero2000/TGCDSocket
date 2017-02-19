//
//  OTSFriend.h
//  OneToSay
//
//  Created by HDD on 16/7/5.
//  Copyright © 2016年 Excetop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHPerson : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *largeAvatar;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *signature;
@property (assign, nonatomic) NSInteger contactTime;

@end

@interface OTSFriend : HHPerson

@property (nonatomic, assign) NSInteger hhuserId;
@property (nonatomic, copy) NSString *hhnickname;

@end
