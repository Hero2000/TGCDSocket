//
//  NSObject+ProtobufExtension.m
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "HHClassInfo.h"
#import "NSObject+ProtobufExtension.h"

NSString *const kHHProtobufModelKeyPath = @"kHHProtobufModelKeyPath";
NSString *const kHHProtobufModelClassName = @"kHHProtobufModelClassName";

@implementation NSObject (ProtobufExtension)

/** protobuf数据转换为模型 */
+ (instancetype)modelWithGeneratedMessage:(PBGeneratedMessage *)message {
    
    if (![message isKindOfClass:[PBGeneratedMessage class]]) { return nil; }
    
    id model = [self new];
    
    Class cls = self;
    HHClassInfo *classInfo = [self objectClassInfoWithModel:model];

    NSDictionary *protobufModelForKeypaths;
    if ([(id)cls respondsToSelector:@selector(protobufModelForKeypaths)]) {
        protobufModelForKeypaths = [cls protobufModelForKeypaths];
    }
    for (HHPropertyInfo *property in classInfo.properties) {
        
        if (protobufModelForKeypaths[property->_name]) {
            
            id protobufModel = [self protobufModelForKeypathsWithMessage:message propertyName:property->_name];
            if (protobufModel) {
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, protobufModel);
            }
        } else if ([message respondsToSelector:property->_getter]) {
            
            id propertyValue = [message valueForKey:property->_getterKey];
            HHPropertyType type = property->_type;
            if (type == HHPropertyTypeString && [propertyValue isKindOfClass:[NSNumber class]]) {
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, [propertyValue stringValue]);
            } else if ((type == HHPropertyTypeBool || type == HHPropertyTypeInt8) && [propertyValue respondsToSelector:@selector(boolValue)]) {
                
                ((void (*)(id, SEL, bool))(void *) objc_msgSend)(model, property->_setter, [propertyValue boolValue]);
            } else if ((type == HHPropertyTypeInt32 || type == HHPropertyTypeUInt32) && [propertyValue respondsToSelector:@selector(intValue)]) {
                
                ((void (*)(id, SEL, int))(void *) objc_msgSend)(model, property->_setter, [propertyValue intValue]);
            } else if ((type == HHPropertyTypeInt64 || type == HHPropertyTypeUInt64) && [propertyValue respondsToSelector:@selector(longValue)]) {
                
                ((void (*)(id, SEL, long))(void *) objc_msgSend)(model, property->_setter, [propertyValue longValue]);
            } else if (type == HHPropertyTypeFloat && [propertyValue respondsToSelector:@selector(floatValue)]) {
                
                ((void (*)(id, SEL, float))(void *) objc_msgSend)(model, property->_setter, [propertyValue floatValue]);
            } else if (type == HHPropertyTypeDouble && [propertyValue respondsToSelector:@selector(doubleValue)]) {
                
                ((void (*)(id, SEL, double))(void *) objc_msgSend)(model, property->_setter, [propertyValue doubleValue]);
            } else if (type == HHPropertyTypeString && [propertyValue respondsToSelector:@selector(stringValue)]) {
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, [propertyValue stringValue]);
            } else if (type == HHPropertyTypeURL && [propertyValue isKindOfClass:[NSString class]]) {
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, [NSURL URLWithString:propertyValue]);
            } else if (type == HHPropertyTypeObject){
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, [property->_cls modelWithGeneratedMessage:propertyValue]);
            } else {
                
                ((void (*)(id, SEL, id))(void *) objc_msgSend)(model, property->_setter, propertyValue);
            }
        }
    }
    return model;
}

+ (id)protobufModelForKeypathsWithMessage:(PBGeneratedMessage *)message propertyName:(NSString *)propertyName {
    
    Class cls = self;
    id map = [[cls protobufModelForKeypaths] objectForKey:propertyName];
    
    NSString *keyPath;
    Class modelClass;
    if ([map isKindOfClass:[NSDictionary class]]) {
        
        keyPath = [map objectForKey:kHHProtobufModelKeyPath];
        modelClass = NSClassFromString([map objectForKey:kHHProtobufModelClassName]);
    } else {
        
        keyPath = propertyName;
        modelClass = NSClassFromString(map);
    }
    
    id value = [message valueForKeyPath:keyPath];
    if (![value isKindOfClass:[NSArray class]]) {
        return [modelClass modelWithGeneratedMessage:value];
    } else {
        
        NSMutableArray *mArr = [NSMutableArray array];
        for (PBGeneratedMessage<GeneratedMessageProtocol> *message in value) {
            [mArr addObject:[modelClass modelWithGeneratedMessage:message]];
        }
        return mArr;
    }
    return nil;
}

+ (HHClassInfo *)objectClassInfoWithModel:(id)model {
    
    static NSMutableDictionary<Class, HHClassInfo *> *objectClasses;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
        objectClasses = [NSMutableDictionary dictionary];
    });
    
    Class cls = [model class];
    HHClassInfo *classInfo = objectClasses[cls];
    if (!classInfo) {
        
        classInfo = [HHClassInfo classInfoWithClass:cls];
        
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        objectClasses[(id)cls] = classInfo;
        dispatch_semaphore_signal(lock);
    }
    
    return classInfo;
}

@end
