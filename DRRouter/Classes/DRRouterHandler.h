//
//  DRRouterHandler.h
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRRouterHandlerOpen.h"

@interface DRRouterHandler : NSObject

#pragma mark - 一些初始化设置
/**
 设置指令协议头，一般以scheme开头，如http，https
 如指令集使用："shiguangxu://gotoScheduleEdit"
 则传入"shiguangxu"
 >>>>>>注：必须调用的方法
 
 @param scheme 指令协议头
 */
+ (void)setupCommandScheme:(const NSString *)scheme;

/**
 单个注册指令
 请在可以通过路由打开的页面中通过REGISTER_ROUTER_DOMMAND实现注册，不建议直接调用该方法
 viewControllerA->viewControllerB，则在B中调用REGISTER_ROUTER_DOMMAND(gotoB_command)
 
 @param cmd 指令字符串
 @param targetPageClass 对应类名
 */
+ (void)registerCommand:(const NSString *)cmd
        targetPgaeClass:(Class)targetPageClass
              needLogin:(BOOL)needLogin;

/**
 设置统一的页面实例化方法，在路由目标页没有实现open方法的情况下调用传入的initialMethod
 >>>>>>注：可选实现
 
 @param initialMethod 目标页面实例化方法
 @param isClassMethod 是否是类方法
 @param isNeedParam 是否需要参数，需要的话，会把路由时传来的参数param原样传入该实例化方法
 @param getTopViewControllerBlock 获取当前顶层控制器的方法回调
 */
+ (void)setupDefaultInitialMethod:(SEL)initialMethod
                    isClassMethod:(BOOL)isClassMethod
                      isNeedParam:(BOOL)isNeedParam
                topViewController:(UIViewController *(^)(void))getTopViewControllerBlock;

/**
 设置网页跳转的响应回调
 >>>>>>注：如果有网页跳转则必须调用该方法
 
 @param handle 当发现出入的指令为http网页链接时，会调用该回调执行页面跳转
 */
+ (void)setupWebUrlHandle:(void(^)(NSString *url, NSDictionary *param, UIViewController *fromVc, BOOL isPresent, BOOL animated, DRRouterCallBackBlock callBack))handle;

/**
 设置用户登录的响应会次奥

 @param handle 当目标页面需要用户登录，切用户未登录时调用
               用户登录完成后，若调用continueRouterBlock，则会继续完成之前的将要执行的路由跳转
 @param loginStatusBlock 获取当前用户登录状态的回调
 */
+ (void)setupUserLoginHandle:(void (^)(dispatch_block_t continueRouterBlock))handle
            loginStatusBlock:(BOOL(^)(void))loginStatusBlock;

#pragma mark - 发起路由跳转，以下方式选一种
/**
 发送路由指令，使用Push方式弹出新页面

 @param command 路由指令
 @param param 传入下一页面的参数
 @param callback 传入下一页面的回调，需要被打开页面实现openXXX协议方法接收callback回调
 */
+ (void)handleCommand:(const NSString *)command
            withParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback;

/**
 发送路由指令，使用Push方式弹出新页面
 
 @param command 路由指令
 @param viewController 当前发送路由指令的界面
 @param param 传入下一页面的参数
 @param callback 传入下一页面的回调，需要被打开页面实现openXXX协议方法接收callback回调
 */
+ (void)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback;

/**
 发送路由指令，使用Present(模态)方式弹出新页面
 
 @param command 路由指令
 @param viewController 当前发送路由指令的界面
 @param param 传入下一页面的参数
 @param animation 是否适用转场动画
 @param setupPresentBlock 对目标页面进行额外设置，如添加导航控制器
 */
+ (void)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
     presentAnimation:(BOOL)animation
         setupPresent:(UIViewController *(^)(UIViewController *toViewController))setupPresentBlock;

@end

