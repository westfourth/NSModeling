//
//  NSModeling.h
//  Markdown
//
//  Created by xisi on 2021/12/19.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//! 字典 --> 模型
#define MODEL_SET(name)     - (id)name##ModelSetter:(id)value
//! 模型 --> 字典
#define MODEL_GET(name)     - (id)name##ModelGetter:(id)value


NS_ASSUME_NONNULL_BEGIN

@protocol NSModeling <NSObject>

//! 模型 --> 字典
- (nullable NSDictionary *)toDict;

//! 字典 --> 模型
- (instancetype)fromDict:(NSDictionary *)dict;

//! 模型 --> 字典
+ (nullable NSArray *)toDict:(NSArray *)array;

//! 字典 --> 模型
+ (nullable NSArray *)fromDict:(NSArray *)array;


//MARK: -   可选方法，需要自行实现
@optional

/// 转换映射
+ (nullable NSDictionary *)dictMapper;

/// NSNull => nil 自动转。
+ (BOOL)automaticNil;

/// NSString <=> NSURL 自动互转。
+ (BOOL)automaticURL;

/// NSString <=> NSDate 自动互转。
+ (BOOL)automaticDate;

@end

NS_ASSUME_NONNULL_END
