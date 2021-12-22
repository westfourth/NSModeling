//
//  NSModelConfig.m
//  Markdown
//
//  Created by xisi on 2021/12/22.
//

#import "NSModelConfig.h"

@implementation NSModelConfig

+ (instancetype)share {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticNil = YES;
        self.automaticURL = YES;
        self.automaticDate = YES;
        
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        self.dateFormatter = df;
    }
    return self;
}

@end
