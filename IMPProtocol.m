//
//  IMPProtocol.m
//  Markdown
//
//  Created by xisi on 2021/12/19.
//

#import "IMPProtocol.h"

/**
    拷贝 \c protoCls 中 \c proto 声明的实例方法到 \c cls 中
 
    @param  proto               协议
    @param  protoCls        proto协议默认方法的类
    @param  cls                   采用proto协议的类
 */
void protocol_add_default_instance_method(Protocol *proto, Class protoCls, Class cls) {
    unsigned int count = 0;
    struct objc_method_description *descs = protocol_copyMethodDescriptionList(proto, YES, YES, &count);
    for (int j = 0; j < count; j++) {
        struct objc_method_description desc = descs[j];
        Method m = class_getInstanceMethod(protoCls, desc.name);
        IMP imp = method_getImplementation(m);
        class_addMethod(cls, desc.name, imp, desc.types);
    }
    free(descs);
}

/**
    拷贝 \c protoCls 中 \c proto 声明的类方法到 \c cls 中
 
    @param  proto               协议
    @param  protoCls        proto协议默认方法的类
    @param  cls                   采用proto协议的类
 */
void protocol_add_default_class_method(Protocol *proto, Class protoCls, Class cls) {
    unsigned int count = 0;
    struct objc_method_description *descs = protocol_copyMethodDescriptionList(proto, YES, NO, &count);
    for (int j = 0; j < count; j++) {
        struct objc_method_description desc = descs[j];
        Method m = class_getClassMethod(protoCls, desc.name);
        IMP imp = method_getImplementation(m);
        const char *s = class_getName(cls);
        Class metaCls = objc_getMetaClass(s);
        class_addMethod(metaCls, desc.name, imp, desc.types);
    }
    free(descs);
}

/**
    找出所有使用 \c proto 协议的类。时间代价：0.0035s / 万个class。
    
    @param  proto               协议
    @param  protoCls        proto协议默认方法的类
 */
void protocol_find_conformed_class(Protocol *proto, Class protoCls) {
    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (int i = 0; i < count; i++) {
        Class cls = classes[i];
        if (cls == protoCls) {
            continue;
        }
        if (class_conformsToProtocol(cls, proto)) {
            protocol_add_default_instance_method(proto, protoCls, cls);
            protocol_add_default_class_method(proto, protoCls, cls);
        }
    }
    free(classes);
}


/**
    判断property是否只读
    
    @param  prop    属性
 */
BOOL property_is_readonly(objc_property_t prop) {
    BOOL readonly = NO;
    unsigned int num = 0;
    objc_property_attribute_t *attrs = property_copyAttributeList(prop, &num);
    for (int j = 0; j < num; j++) {
        objc_property_attribute_t attr = attrs[j];
        if (strcmp(attr.name, "R") == 0) {
            readonly = YES;
            break;
        }
    }
    free(attrs);
    return readonly;
}
