//
//  NSJsoning.h
//  Markdown
//
//  Created by hanxin on 2021/12/19.
//

#import <Foundation/Foundation.h>
#import "NSModeling.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NSJsoning <NSModeling>

- (nullable NSData *)toJsonData;

- (nullable NSString *)toJsonString;

- (instancetype)fromJsonData:(NSData *)data;

- (instancetype)fromJsonString:(NSString *)string;

- (instancetype)fromJsonFilename:(NSString *)filename bundle:(nullable NSBundle *)bundle;


//MARK: -   数组

+ (nullable NSData *)toJsonData:(NSArray *)array;

+ (nullable NSString *)toJsonString:(NSArray *)array;

+ (nullable NSArray *)fromJsonData:(NSData *)data;

+ (nullable NSArray *)fromJsonString:(NSString *)string;

+ (nullable NSArray *)fromJsonFilename:(NSString *)filename bundle:(nullable NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
