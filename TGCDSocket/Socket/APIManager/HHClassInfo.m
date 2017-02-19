//
//  HHClassInfo.m
//  TCoreData
//
//  Created by HeiHuaBaiHua on 16/6/15.
//  Copyright © 2016年 黑花白花. All rights reserved.
//

#import "HHClassInfo.h"

#pragma mark - HHPropertyInfo

@interface HHPropertyInfo ()

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *getterKey;

@property (assign, nonatomic) SEL getter;
@property (assign, nonatomic) SEL setter;
@property (assign, nonatomic) Class cls;
@property (assign, nonatomic) HHPropertyType type;
@property (assign, nonatomic) objc_property_t property;

@end

@implementation HHPropertyInfo

NS_INLINE HHPropertyType getPropertyType(const char *type) {
    
    switch (*type) {
        case 'B': return HHPropertyTypeBool;
        case 'c': return HHPropertyTypeInt8;
        case 'C': return HHPropertyTypeUInt8;
        case 's': return HHPropertyTypeInt16;
        case 'S': return HHPropertyTypeUInt16;
        case 'i': return HHPropertyTypeInt32;
        case 'I': return HHPropertyTypeUInt32;
        case 'l': return HHPropertyTypeInt32;
        case 'L': return HHPropertyTypeUInt32;
        case 'q': return HHPropertyTypeInt64;
        case 'Q': return HHPropertyTypeUInt64;
        case 'f': return HHPropertyTypeFloat;
        case 'd': return HHPropertyTypeDouble;
        case 'D': return HHPropertyTypeLongDouble;
        case '@': {
            
            NSString *typeString = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
            if ([typeString rangeOfString:@"URL"].length > 0) { return HHPropertyTypeURL; }
            else if([typeString rangeOfString:@"MutableArray"].length > 0) { return HHPropertyTypeMutableArray; }
            else if([typeString rangeOfString:@"Array"].length > 0) { return HHPropertyTypeArray; }
            else if([typeString rangeOfString:@"String"].length > 0) { return HHPropertyTypeString; }
            else { return HHPropertyTypeObject; };
        };
        default: return 0;
    }
}

+ (instancetype)propertyWithProperty:(objc_property_t)property {
    
    HHPropertyInfo *info = [HHPropertyInfo new];
    
    char *propertyAttribute = property_copyAttributeValue(property, "T");
    info->_name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    info->_type = getPropertyType(propertyAttribute);
    info->_setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",[[info->_name substringToIndex:1] uppercaseString],[info->_name substringFromIndex:1]]);
    info->_getter = NSSelectorFromString(info->_name);
    info->_getterKey = info->_name;
    info->_property = property;
    
    if (info->_type >= 14) {
        
        NSString *propertyClassName = [NSString stringWithCString:propertyAttribute encoding:NSUTF8StringEncoding];
        if (![propertyClassName isEqualToString:@"@"]) {//id类型没有类名
            info->_cls = NSClassFromString([[propertyClassName componentsSeparatedByString:@"\""] objectAtIndex:1]);
        }
    }
    free(propertyAttribute);
    return info;
}

@end

#pragma mark - HHClassInfo

@interface HHClassInfo ()

@property (strong, nonatomic) NSArray *properties;

@end

#define IgnorePropertyNames @[@"debugDescription", @"description", @"superclass", @"hash"]
@implementation HHClassInfo

+ (instancetype)classInfoWithClass:(Class)cls {
    
    HHClassInfo *classInfo = [HHClassInfo new];
    NSMutableArray *properties = [NSMutableArray array];
    while (cls != [NSObject class] && cls != [NSProxy class]) {
        
        [properties addObjectsFromArray:[self propertiesWithClass:cls]];
        cls = [cls superclass];
    }
    classInfo.properties = [properties copy];
    return classInfo;
}

+ (NSArray *)propertiesWithClass:(Class)cls {
    
    uint count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *propertyInfos = [NSMutableArray array];
    SEL selector = NSSelectorFromString(@"replacedKeyForProtobufPropertyName");
    NSDictionary *replacedKeyValues = [(id)cls respondsToSelector:selector] ? [(id)cls performSelector:selector] : nil;
    for (int i = 0; i < count; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([IgnorePropertyNames containsObject:propertyName]) { continue; }
        
        HHPropertyInfo *propertyInfo = [HHPropertyInfo propertyWithProperty:property];
        if (replacedKeyValues.count > 0) {
            
            NSString *replacedKey = replacedKeyValues[propertyInfo->_name];
            if (replacedKey) {
                propertyInfo->_getter = NSSelectorFromString(replacedKey);
                propertyInfo->_getterKey = replacedKey;
            }
        }
        [propertyInfos addObject:propertyInfo];
    }
    free(properties);
    
    return propertyInfos;
}

@end
