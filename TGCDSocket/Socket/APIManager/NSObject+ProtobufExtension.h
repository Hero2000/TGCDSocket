//
//  NSObject+ProtobufExtension.h
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeneratedMessage.h"

extern NSString *const kHHProtobufModelKeyPath;
extern NSString *const kHHProtobufModelClassName;

@protocol OTSProtobufModel <NSObject>

+ (NSDictionary *)protobufModelForKeypaths;/**< model中有model/model数组时对应的keypath */
+ (NSDictionary *)replacedKeyForProtobufPropertyName;/**< protobuf替换键值 */

@end

@interface NSObject (ProtobufExtension)

+ (instancetype)modelWithGeneratedMessage:(PBGeneratedMessage *)message;/**< protobuf数据转换为模型 */

@end
