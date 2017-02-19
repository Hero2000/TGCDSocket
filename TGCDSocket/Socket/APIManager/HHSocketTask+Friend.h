//
//  HHSocketTask+Friend.h
//  TGCDSocket
//
//  Created by HeiHuaBaiHua on 16/9/1.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

@interface HHSocketTask ()

- (NSData *)taskData;

- (void)setClient:(id)client;
- (void)completeWithResponseData:(NSData *)responseData error:(NSError *)error;

@end
