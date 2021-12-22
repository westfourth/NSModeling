# NSModeling

`模型` <=> `字典`、`模型` <=> `JSON` 互转；采用`NSModeling` 或 `NSJsoning`协议即可使用。


## 为啥重复造轮子

对比 [Mantle](https://github.com/Mantle/Mantle)、[jsonmodel](https://github.com/jsonmodel/jsonmodel)、[MJExtension](https://github.com/CoderMJLee/MJExtension) 特点：

| 库 | 优点 | 缺点 | 
| :-: | --- | --- |
| [Mantle](https://github.com/Mantle/Mantle) | 1. 非常规范，适合高级开发者<br> 2. 支持`property`映射<br> 3. 支持属性`Transformer` 转换<br> 4. 可以指定嵌套模型的类型 | 1. 初中级开发者上手难<br> 2. 没处理好易崩溃<br> 3. 难以调试<br> 4. 使用继承方式实现 |
| [jsonmodel](https://github.com/jsonmodel/jsonmodel) | 1. 方法简明<br> 2. 使用伪`protocol`指定嵌套模型类型<br> 3. 支持`property`映射<br> 4. 对象属性支持`Optional`、`Ignore`<br> 5. 支持属性`Transformer` 转换<br> 6. 自定义`getter`、`setter` | 1. 使用继承方式实现 |
| [MJExtension](https://github.com/CoderMJLee/MJExtension) | 1. 支持`property`映射<br> 2. 可以指定嵌套模型的类型 | 1. 方法名怪异<br> 2. 使用`Category`方式实现，易造成方法冲突 |

## 举例

**TestObject**

``` objc
//	只申明，无具体形式
@protocol SubTestObject;

//	.h文件
@interface TestObject : NSObject <NSJsoning>

@property (nonatomic) NSString *name;
@property (nonatomic) int age;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSDate *date;

@property (nonatomic) SubTestObject *sub;
@property (nonatomic) NSArray<SubTestObject *> <SubTestObject> *list;

@end

//	.m文件
@implementation TestObject
@end
```

**SubTestObject**

``` objc
//	.h文件
@interface SubTestObject : NSObject <NSJsoning>

@property (nonatomic) NSString *text;
@property (nonatomic) int num;
@property (nonatomic) SubTestObject *sub;

@end

//	.m文件
@implementation SubTestObject
@end
```

## 基本使用

**采用`NSJsoning`协议即可**

``` objc
@interface TestObject : NSObject <NSJsoning>
@end
```

**调用**

``` objc
    TestObject *t =  [TestObject new];
    t.name = @"AAA";
    t.age = 123;
    t.url = [NSURL URLWithString:@"https://www.baidu.com"];
    t.date = [NSDate date];
    
    //	模型 => 字典
    NSDictionary *dict = [t toDict];
    //	字典 => 模型
    TestObject *t2 = [[TestObject alloc] fromDict:dict];
    //	模型 => JSON
    NSString *text = [t toJsonString];
    //	JSON => 模型
    TestObject *t3 = [[TestObject alloc] fromJsonString:text];
```

## 嵌套模型

嵌套子模型也采用`NSJsoning`协议即可

``` objc
//	.h文件
@interface SubTestObject : NSObject <NSJsoning>
@end

```

## 数组

使用`protocol`声明数组元素的类型即可

``` objc
//	只申明，无具体形式
@protocol SubTestObject;

//	.h文件
@interface TestObject : NSObject <NSJsoning>

@property (nonatomic) NSArray <SubTestObject> *list;

@end

```

## 属性映射

实现`+ (NSDictionary *)dictMapper`即可

``` objc
@implementation TestObject

+ (NSDictionary *)dictMapper {
    return @{@"name": @"firstName",
             @"age": @"year",
    };
}

@end
```

## 自定义getter、setter

``` objc
@implementation TestObject

//	字典 => 模型
MODEL_SET(date) {
    return @"2020-12-22 21:44:49";
}

//	模型 => 字典
MODEL_GET(date) {
    return [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * 7];
}

@end
```

和下面完全相等

``` objc
@implementation TestObject

//	字典 => 模型
- (id)dateModelSetter:(id)value {
    return @"2020-12-22 21:44:49";
}

//	模型 => 字典
- (id)dateModelGetter:(id)value {
    return [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * 7];
}

@end
```

## `NSNull`、`NSURL`、`NSDate`自动转换

``` objc
@implementation TestObject

//	关闭 NSNull => nil 自动转。
+ (BOOL)automaticNil {
    return NO;
}

//	NSString <=> NSURL 自动互转。
+ (BOOL)automaticURL {
    return YES;
}

//	NSString <=> NSDate 自动互转。
+ (BOOL)automaticDate {
    return YES;
}

@end
```

##优先级

`自定义getter、setter` > `automaticXXX方法` > `NSModelConfig全局配置`