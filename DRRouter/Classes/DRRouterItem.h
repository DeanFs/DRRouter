//
//  DRRouterItem.h
//  BlocksKit
//
//  Created by 冯生伟 on 2019/9/2.
//

#import <Foundation/Foundation.h>

@interface DRRouterItem : NSObject

/**
 路由指令名
 */
@property (nonatomic, copy, readonly) const NSString *commad;

/**
 路由指定目标页面的类
 */
@property (nonatomic, strong, readonly) Class targetPageClass;

/**
 路由到该页面前需要用户先登录
 */
@property (nonatomic, assign, readonly) BOOL needLogin;

/**
 command指令中带的静态写死的参数
 */
@property (nonatomic, strong, readonly) NSDictionary *staticParam;

/// 忽略重复叠加相同页面，即允许同一个页面类重复叠加，default: NO
@property (assign, nonatomic) BOOL ignoreRouterSamePage;

/**
 构建一个路由指令

 @param command 指令名称
 @param targetPageClass 路由目标页面类
 @param needLogin 需要登录
 @return 指令
 */
+ (instancetype)routerItemWithCommand:(const NSString *)command
                      targetPageClass:(Class)targetPageClass
                            needLogin:(BOOL)needLogin;

/**
 构建一个路由指令，忽略重复叠加相同页面，即允许同一个页面类重复叠加
 
 @param command 指令名称
 @param targetPageClass 路由目标页面类
 @param needLogin 需要登录
 @return 指令
 */
+ (instancetype)routerItemIgnoreRouterSamePageWithCommand:(const NSString *)command
                                          targetPageClass:(Class)targetPageClass
                                                needLogin:(BOOL)needLogin;

@end
