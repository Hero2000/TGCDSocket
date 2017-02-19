//
//  HHClassInfo.h
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum : NSUInteger {
    HHPropertyTypeUnknown    = 0,
    HHPropertyTypeVoid       = 1,
    HHPropertyTypeBool       = 2,
    HHPropertyTypeInt8       = 3,
    HHPropertyTypeUInt8      = 4,
    HHPropertyTypeInt16      = 5,
    HHPropertyTypeUInt16     = 6,
    HHPropertyTypeInt32      = 7,
    HHPropertyTypeUInt32     = 8,
    HHPropertyTypeInt64      = 9,
    HHPropertyTypeUInt64     = 10,
    HHPropertyTypeFloat      = 11,
    HHPropertyTypeDouble     = 12,
    HHPropertyTypeLongDouble = 13,
    HHPropertyTypeObject     = 14,
    HHPropertyTypeURL        = 15,
    HHPropertyTypeString     = 16,
    HHPropertyTypeArray      = 17,
    HHPropertyTypeMutableArray = 18
} HHPropertyType;

@interface HHPropertyInfo : NSObject {
    
    @package
    SEL _setter;
    SEL _getter;
    Class _cls;
    NSString *_name;
    NSString *_getterKey;
    HHPropertyType _type;
}

+ (instancetype)propertyWithProperty:(objc_property_t)property;

@end

@interface HHClassInfo : NSObject

+ (instancetype)classInfoWithClass:(Class)cls;

- (NSArray<HHPropertyInfo *> *)properties;
@end
