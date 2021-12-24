//
//  NSModelConfig.h
//  Markdown
//
//  Created by hanxin on 2021/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 全局配置
@interface NSModelConfig : NSObject

+ (instancetype)share;

/// NSNull => nil 自动转。默认YES
@property (nonatomic) BOOL automaticNil;

/// NSString <=> NSURL 自动互转。默认YES
@property (nonatomic) BOOL automaticURL;

/// NSString <=> NSDate 自动互转。默认YES
@property (nonatomic) BOOL automaticDate;

/// 默认格式：yyyy-MM-dd HH:mm:ss
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

NS_ASSUME_NONNULL_END
