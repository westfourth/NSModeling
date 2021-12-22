//
//  NSJsoning.m
//  Markdown
//
//  Created by xisi on 2021/12/19.
//

#import "NSJsoning.h"
#import "IMPProtocol.h"

//MARK: -   NSJsoning

@impprotocol(NSJsoning)

- (nullable NSData *)toJsonData {
    NSDictionary *dict = [self toDict];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    return data;
}

- (nullable NSString *)toJsonString {
    NSData *data = [self toJsonData];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (instancetype)fromJsonData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    [self fromDict:dict];
    return self;
}

- (instancetype)fromJsonString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self fromJsonData:data];
    return self;
}

- (instancetype)fromJsonFile:(NSString *)filename inBundle:(nullable NSBundle *)bundle {
    bundle = bundle ? bundle : [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self fromJsonData:data];
    return self;
}


//MARK: -   数组

+ (nullable NSData *)toJsonData:(NSArray *)array {
    NSArray *list = [self toDict:array];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:&error];
    return data;
}

+ (nullable NSString *)toJsonString:(NSArray *)array {
    NSData *data = [self toJsonData:array];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

+ (nullable NSArray *)fromJsonData:(NSData *)data {
    NSError *error = nil;
    NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSArray *models = [self fromDict:list];
    return models;
}

+ (nullable NSArray *)fromJsonString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *list = [self fromJsonData:data];
    return list;
}

+ (nullable NSArray *)fromJsonFile:(NSString *)filename inBundle:(nullable NSBundle *)bundle {
    bundle = bundle ? bundle : [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:filename ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *list = [self fromJsonData:data];;
    return list;
}

@end
