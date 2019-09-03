//
//  DRRouterHandlerOpen.h
//  BlocksKit
//
//  Created by 冯生伟 on 2019/9/2.
//

#import <Foundation/Foundation.h>

/**
 路由跳转的回调
 从A路由跳转到B，可以在A中传入回调，用于响应B中发生的事件
 
 @param actionCode 事件类型，当B中有多种事件时需要用此做区分
 @param param 回调参数
 */
typedef void (^DRRouterCallBackBlock)(NSInteger actionCode, NSDictionary *param);

@protocol DRRouterHandlerOpen <NSObject>

// 页面事件回调
@property (nonatomic, copy) DRRouterCallBackBlock callBackBlock;

// 可以通过路由指令打开的页面，选择实现如下任一方法，必须实现其中一个
// 否则路由指令不能响应
// viewControllerA->viewControllerB，则在B中实现
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
