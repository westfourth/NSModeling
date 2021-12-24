//
//  IMPProtocol.h
//  Markdown
//
//  Created by hanxin on 2021/12/19.
//

#import <objc/runtime.h>

/**
    给 protocol 添加默认实现。仅实现 required，忽略 optional。
 */

#define STRSTR(NAME)   #NAME

#define impprotocol(NAME) \
interface NAME##_NSObject : NSObject <NAME> \
@end \
\
void protocol_find_conformed_class(Protocol *proto, Class protoCls); \
\
__attribute__((constructor)) \
static void NAME##_NSObject_constructor(void) { \
    Protocol *proto = @protocol(NAME); \
    Class protoCls = objc_getClass(STRSTR(NAME##_NSObject)); \
    protocol_find_conformed_class(proto, protoCls); \
} \
\
@implementation NAME##_NSObject



BOOL property_is_readonly(objc_property_t prop);
