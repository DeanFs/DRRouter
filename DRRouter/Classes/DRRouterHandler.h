//
//  DRRouterHandler.h
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DRRouterHandler;

#pragma mark - 指令注册方式一的懒人版，通过+load方法自动注册，对APP冷启动速度有一定影响
/**
 注册指令
 在可以通过路由打开的类中调用该宏方法，传入打开该类对应的指令

 @param cmd 指令字符串
 @return 空
 */
#define REGISTER_ROUTER_DOMMAND(cmd) \
+ (void)load { \
    [super load]; \
    [DRRouterHandler registerCommand:cmd vcClass:[self class]]; \
}

#pragma mark - blocks
/**
 路由跳转的回调
 从A路由跳转到B，可以在A中传入回调，用于响应B中发生的事件

 @param actionCode 事件类型，当B中有多种事件时需要用此做区分
 @param param 回调参数
 */
typedef void (^DRRouterCallBackBlock)(NSInteger actionCode, NSDictionary *param);
typedef UINavigationController *(^DRSetupPresentBlock)(UIViewController *toViewController);

/**
 获取路由跳转前的视图控制器

 @return 视图控制器
 */
typedef UIViewController * (^DRRouterGetTopViewControllerBlock)(void);

#pragma mark - 路由跳转响应，在路由跳转的目标类中实现DRRouterHandlerOpen中的任一方法
// 可以通过路由指令打开的页面，选择实现如下任一方法，必须实现其中一个
// 否则路由指令不能响应
// viewControllerA->viewControllerB，则在B中实现
@protocol DRRouterHandlerOpen <NSObject>

@optional
/**
 在可以通过路由打开的类中实现
 当其他类欲通过路由指令打开时调用，实现页面实例化和跳转逻辑

 @param param 路由前一级页面传来的参数
 @param callback 路由前一级页面传来的回调，在合适时机回调给前一级页面
 */
+ (void)openWithParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback;

/**
 在可以通过路由打开的类中实现
 当其他类欲通过路由指令打开时调用，实现页面实例化和跳转逻辑
 
 @param viewController 前一级页面控制器
 @param param 路由前一级页面传来的参数
 @param callback 路由前一级页面传来的回调，在合适时机回调给前一级页面
 */
+ (void)openFromViewController:(UIViewController *)viewController
                     withParam:(NSDictionary *)param
                      callback:(DRRouterCallBackBlock)callback;

@end

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
 设置响应网页跳转的viewController
 >>>>>>注：如果有网页跳转则必须调用该方法
 
 @param webHandlerClass 一般是加载网页的viewController
 @param urlKey url属性名，该属性只能是NSString >>>>>>注：必须指定
 @param paramKey 其他参数属性名
 */
+ (void)setupWebHandlerCalss:(Class)webHandlerClass
             urlPropertyName:(NSString *)urlKey
           paramPropertyName:(NSString *)paramKey;

// >>>>>>注：以下两个注册方法，必须至少使用其中一个实现指令注册
/**
 单个注册指令
 请在可以通过路由打开的页面中通过REGISTER_ROUTER_DOMMAND实现注册，不建议直接调用该方法
 viewControllerA->viewControllerB，则在B中调用REGISTER_ROUTER_DOMMAND(gotoB_command)
 
 @param cmd 指令字符串
 @param viewControllerClass 对应类名
 */
+ (void)registerCommand:(const NSString *)cmd
                vcClass:(Class)viewControllerClass;

/**
 批量注册指令映射表
 可添加在组件内，也可以在主项目

 @param commandsMap 指令映射表，key为指令，value(Class类型)为对应viewController Class
 */
+ (void)regisgerCommandsWithMap:(NSDictionary<const NSString *, Class> *)commandsMap;

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
                topViewController:(DRRouterGetTopViewControllerBlock)getTopViewControllerBlock;

#pragma mark - 发起路由跳转，以下方式选一种
/**
 发送路由指令
 没有实现openXXX协议方法时，使用Push方式弹出新页面

 @param command 路由指令
 @param param 传入下一页面的参数
 @param callback 传入下一页面的回调，需要被打开页面实现openXXX协议方法接收callback回调
 */
+ (void)handleCommand:(const NSString *)command
            withParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback;

/**
 发送路由指令
 没有实现openXXX协议方法时，使用Push方式弹出新页面
 
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
 发送路由指令
 适用于目标页面没有实现openXXX协议方法，且希望页面弹出时没有动画，或者使用模态呼出页面的情景

 @param command 路由指令
 @param viewController 当前发送路由指令的界面
 @param param 传入下一页面的参数
 @param animation 是否适用转场动画
 @param setupPresentBlock 是否适用模态
 */
+ (void)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
            isPresent:(BOOL)isPresent
            animation:(BOOL)animation
         setupPresent:(DRSetupPresentBlock)setupPresentBlock;

@end
