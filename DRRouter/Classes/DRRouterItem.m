//
//  DRRouterItem.m
//  BlocksKit
//
//  Created by 冯生伟 on 2019/9/2.
//

#import "DRRouterItem.h"

@implementation DRRouterItem

/**
 构建一个路由指令
 
 @param command 指令名称
 @param targetPageClass 路由目标页面类
 @param needLogin 需要登录
 @return 指令
 */
+ (instancetype)routerItemWithCommand:(const NSString *)command
                      targetPageClass:(Class)targetPageClass
                            needLogin:(BOOL)needLogin {
    DRRouterItem *item = [[DRRouterItem alloc] initWithCommand:command
                                               targetPageClass:targetPageClass
                                                     needLogin:needLogin];
    return item;
}

- (instancetype)initWithCommand:(const NSString *)command
                targetPageClass:(Class)targetPageClass
                      needLogin:(BOOL)needLogin {
    self = [super init];
    if (self) {
        _commad = command;
        _targetPageClass = targetPageClass;
        _needLogin = needLogin;
        _staticParam = [self paramFromCommand:command];
    }
    return self;
}

- (NSDictionary *)paramFromCommand:(const NSString *)command {
    if (command.length == 0 || ![command containsString:@"?"]) {
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:(NSString *)command];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"] ];
    [scanner scanUpToString:@"?" intoString:nil];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *tmpValue;
    while ([scanner scanUpToString:@"&" intoString:&tmpValue]) {
        NSArray *components = [tmpValue componentsSeparatedByString:@"="];
        if (components.count >= 2) {
            NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            parameters[key] = value;
        }
    }
    return parameters;
}

@end
