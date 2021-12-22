//
//  NSModeling.m
//  Markdown
//
//  Created by xisi on 2021/12/19.
//

#import "NSModeling.h"
#import "IMPProtocol.h"
#import "NSModelConfig.h"

//! 字典 --> 模型
#define MODEL_SET_SEL(name)     name##ModelSetter:
//! 模型 --> 字典
#define MODEL_GET_SEL(name)     name##ModelGetter:

static id to_dict_value(id self, const char *name, Class cls, id value);
static id from_dict_value(id self, const char *name, Class cls, id value);
static NSString *dict_key(id self, NSString *key);
static SEL model_sel(const char *name, char *type);
static char *str_sub(const char *s, char start, char end);
Class property_get_array_class(objc_property_t prop);
Class property_get_object_class(objc_property_t prop);


//MARK: -   NSModeling

@impprotocol(NSModeling)

//! 模型 --> 字典
- (nullable NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    unsigned int count = 0;
    objc_property_t *props = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t prop = props[i];
        //  忽略readonly属性
        if (property_is_readonly(prop)) {
            continue;
        }

        Class cls = property_get_object_class(prop);
        const char *name = property_getName(prop);
        NSString *key = [NSString stringWithUTF8String:name];
        NSString *dictKey = dict_key(self, key);
        
        NSObject *value = [self valueForKey:key];
        value = to_dict_value(self, name, cls, value);
        
        if ([value isKindOfClass:[NSArray class]]) {
            cls = property_get_array_class(prop);
            if (class_conformsToProtocol(cls, @protocol(NSModeling))) {
                value = [cls toDict:(NSArray *)value];
            }
        } else if ([value conformsToProtocol:@protocol(NSModeling)]) {
            value = [(id<NSModeling>)value toDict];
        }
        dict[dictKey] = value;
    }
    free(props);
    return dict;
}

//! 字典 --> 模型
- (instancetype)fromDict:(NSDictionary *)dict {
    unsigned int count = 0;
    objc_property_t *props = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t prop = props[i];
        //  忽略readonly属性
        if (property_is_readonly(prop)) {
            continue;
        }

        Class cls = property_get_object_class(prop);
        const char *name = property_getName(prop);
        NSString *key = [NSString stringWithUTF8String:name];
        NSString *dictKey = dict_key(self, key);
        
        NSObject *value = dict[dictKey];
        value = from_dict_value(self, name, cls, value);
        
        if ([value isKindOfClass:[NSArray class]]) {
            cls = property_get_array_class(prop);
            if (class_conformsToProtocol(cls, @protocol(NSModeling))) {
                value = [cls fromDict:(NSArray *)value];
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            if (class_conformsToProtocol(cls, @protocol(NSModeling))) {
                id instance = [[cls new] fromDict:(NSDictionary *)value];
                value = instance;
            }
        }
        [self setValue:value forKey:key];
    }
    free(props);
    return self;
}

//! 模型 --> 字典
+ (nullable NSArray *)toDict:(NSArray *)array {
    NSMutableArray *list = [NSMutableArray new];
    for (int i = 0; i < array.count; i++) {
        id value = array[i];
        if ([value conformsToProtocol:@protocol(NSModeling)]) {
            value = [(id<NSModeling>)value toDict];
        }
        [list addObject:value];
    }
    return list;
}

//! 字典 --> 模型
+ (nullable NSArray *)fromDict:(NSArray *)array {
    NSMutableArray *list =  [NSMutableArray new];
    for (int i = 0; i < array.count; i++) {
        id object = [self new];
        if (class_conformsToProtocol(self, @protocol(NSModeling))) {
            [object fromDict:(NSDictionary *)array[i]];
        }
        [list addObject:object];
    }
    return list;
}

@end


//MARK: -   基础函数

/**
    字典 --> 模型，对value进行处理
 
    @param  self            实例对象
    @param  name            属性名
    @param  cls              属性类
    @param  value          属性值
 */
static id to_dict_value(id self, const char *name, Class cls, id value) {
    //  调用modelGetter:方法
    SEL sel = model_sel(name, "ModelGetter:");
    if ([self respondsToSelector:sel]) {
        value = [self performSelector:sel withObject:value];
    } else {
        //  NSNull处理
        if (value == [NSNull null]) {
            if ([[self class] respondsToSelector:@selector(automaticNil)]) {
                BOOL flag = [[self class] automaticNil];
                if (flag) {
                    value = nil;
                }
            } else if (NSModelConfig.share.automaticNil) {
                value = nil;
            }
        }
        //
        if (cls == [NSURL class]) {             //  NSURL处理
            if ([[self class] respondsToSelector:@selector(automaticURL)]) {
                BOOL flag = [[self class] automaticURL];
                if (flag) {
                    value = [(NSURL *)value absoluteString];
                }
            } else if (NSModelConfig.share.automaticNil) {
                value = [(NSURL *)value absoluteString];
            }
        } else if (cls == [NSDate class]) {     //  NSDate处理
            if ([[self class] respondsToSelector:@selector(automaticDate)]) {
                BOOL flag = [[self class] automaticDate];
                if (flag) {
                    value = [NSModelConfig.share.dateFormatter stringFromDate:(NSDate *)value];
                }
            } else if (NSModelConfig.share.automaticDate) {
                value = [NSModelConfig.share.dateFormatter stringFromDate:(NSDate *)value];
            }
        }
    }
    return value;
}


/**
    字典 --> 模型，对value进行处理
 
    @param  self            实例对象
    @param  name            属性名
    @param  cls              属性类
    @param  value          属性值
 */
static id from_dict_value(id self, const char *name, Class cls, id value) {
    //  调用modelSetter:方法
    SEL sel = model_sel(name, "ModelSetter:");
    if ([self respondsToSelector:sel]) {
        value = [self performSelector:sel withObject:value];
    } else {
        //  NSNull处理
        if (value == [NSNull null]) {
            if ([[self class] respondsToSelector:@selector(automaticNil)]) {
                BOOL flag = [[self class] automaticNil];
                if (flag) {
                    value = nil;
                }
            } else if (NSModelConfig.share.automaticNil) {
                value = nil;
            }
        }
        //
        if (cls == [NSURL class]) {             //  NSURL处理
            if ([[self class] respondsToSelector:@selector(automaticURL)]) {
                BOOL flag = [[self class] automaticURL];
                if (flag) {
                    value = [NSURL URLWithString:(NSString *)value];
                }
            } else if (NSModelConfig.share.automaticNil) {
                value = [NSURL URLWithString:(NSString *)value];
            }
        } else if (cls == [NSDate class]) {     //  NSDate处理
            if ([[self class] respondsToSelector:@selector(automaticDate)]) {
                BOOL flag = [[self class] automaticDate];
                if (flag) {
                    value = [NSModelConfig.share.dateFormatter dateFromString:(NSString *)value];
                }
            } else if (NSModelConfig.share.automaticDate) {
                value = [NSModelConfig.share.dateFormatter dateFromString:(NSString *)value];
            }
        }
    }
    return value;
}

static NSString *dict_key(id self, NSString *key) {
    NSString *dictKey = key;
    //  取dictKey
    if ([[self class] respondsToSelector:@selector(dictMapper)]) {
        NSDictionary *map = [[self class] dictMapper];
        NSString *tmp = map[key];
        if (tmp) {
            dictKey = tmp;
        }
    }
    return dictKey;
}

/**
    两个字符串连接，生成SEL
 */
static SEL model_sel(const char *name, char *type) {
    char *s = malloc(sizeof(char) * (strlen(name) + strlen(type) + 1));
    strcat(s, name);
    strcat(s, type);
    SEL sel = sel_registerName(s);
    free(s);
    return sel;
}

/**
    字符串截取，使用free()释放
    
    @param  start       顺序匹配上的第一个字符
    @param  end           倒序匹配上的第一个字符
    @return 子串为排除start、end字符的字符串
 */
static char *str_sub(const char *s, char start, char end) {
    int from = 0, to = 0;
    for (int i = 0; i < strlen(s); i++) {
        if (start == s[i]) {
            from = i;
            break;
        }
    }
    for (int i = (int)strlen(s) - 1; i >= 0; i--) {
        if (end == s[i]) {
            to = i;
            break;
        }
    }
    
    int len = to - from;
    if (len <= 0) {
        return NULL;
    }
    char *sub = malloc(sizeof(char) * len);
    for (int i = from + 1; i < to; i++) {
        sub[i - (from + 1)] = s[i];
    }
    sub[len - 1] = '\0';
    return sub;
}

/**
    获取 @property (nonatomic) NSArray<SubTestObject *> <SubTestObject> *list; 结果为：<SubTestObject>中的 \c SubTestObject
 */
Class property_get_array_class(objc_property_t prop) {
    const char *v = property_copyAttributeValue(prop, "T");
    char *sub = str_sub(v, '<', '>');
    Class cls = objc_getClass(sub);
    free(sub);
    return cls;
}

/**
    获取 @property (nonatomic) SubTestObject *sub 结果为：\c SubTestObject
 */
Class property_get_object_class(objc_property_t prop) {
    const char *v = property_copyAttributeValue(prop, "T");
    char *sub = str_sub(v, '"', '"');
    Class cls = objc_getClass(sub);
    free(sub);
    return cls;
}
