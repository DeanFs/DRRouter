//
//  DRRouterItem.h
//  BlocksKit
//
//  Created by 冯生伟 on 2019/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
 构建一个路由指令

 @param command 指令名称
 @param targetPageClass 路由目标页面类
 @param needLogin 需要登录
 @return 指令
 */
+ (instancetype)routerItemWithCommand:(const NSString *)command
                      targetPageClass:(Class)targetPageClass
                            needLogin:(BOOL)needLogin;

@end

NS_ASSUME_NONNULL_END
