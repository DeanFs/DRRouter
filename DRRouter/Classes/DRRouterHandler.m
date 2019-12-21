//
//  DRRouterHandler.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRRouterHandler.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <YYModel/YYModel.h>
#import "DRRouterItem.h"

@interface DRRouterHandler ()

@property (nonatomic, strong) NSMutableDictionary<const NSString *, DRRouterItem *> *cmdsMap;
@property (nonatomic, copy) const NSString *cmdScheme;
@property (nonatomic, copy) const NSString *loginCommand;

// 默认实例方法
@property (nonatomic, assign) SEL defaultInitialMethod;
@property (nonatomic, assign) BOOL isClassMethod;
@property (nonatomic, assign) BOOL isNeedParam;
@property (nonatomic, copy) UIViewController * (^getTopVcBlock)(void);

// web跳转响应
@property (nonatomic, copy) void (^webUrlHandler)(NSString *url, NSDictionary *param, UIViewController *fromVc, BOOL isPresent, BOOL animated, DRRouterCallBackBlock callBack);

// 用户登录响应
@property (nonatomic, copy) BOOL (^loginStatusBlock)(void);
@property (nonatomic, copy) void (^loginHandler)(const NSString *command, NSDictionary *param, DRRouterCallBackBlock callBack, dispatch_block_t continueRouterBlock);

@end

@implementation DRRouterHandler

+ (instancetype)router {
    static DRRouterHandler *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[DRRouterHandler alloc] init];
    });
    return router;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cmdsMap = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 一些初始化设置
/**
 设置指令协议头，一般以scheme开头，如http，https
 如指令集使用："shiguangxu://gotoScheduleEdit"
 则传入"shiguangxu"
 
 @param scheme 指令协议头
 */
+ (void)setupCommandScheme:(const NSString *)scheme {
    [DRRouterHandler router].cmdScheme = [scheme lowercaseString];
}

/**
 单个注册指令
 请在可以通过路由打开的页面中通过REGISTER_ROUTER_DOMMAND实现注册，不建议直接调用该方法
 viewControllerA->viewControllerB，则在B中调用REGISTER_ROUTER_DOMMAND(gotoB_command)
 
 @param cmd 指令字符串
 @param targetPageClass 对应类名
 */
+ (void)registerCommand:(const NSString *)cmd
        targetPgaeClass:(Class)targetPageClass
              needLogin:(BOOL)needLogin {
    [DRRouterHandler router].cmdsMap[cmd] = [DRRouterItem routerItemWithCommand:cmd
                                                                targetPageClass:targetPageClass
                                                                      needLogin:needLogin];
}

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
                topViewController:(UIViewController *(^)(void))getTopViewControllerBlock {
    DRRouterHandler *router = [DRRouterHandler router];
    router.defaultInitialMethod = initialMethod;
    router.isClassMethod = isClassMethod;
    router.isNeedParam = isNeedParam;
    router.getTopVcBlock = getTopViewControllerBlock;
}

/**
 设置网页跳转的响应回调
 >>>>>>注：如果有网页跳转则必须调用该方法
 
 @param handle 当发现出入的指令为http网页链接时，会调用该回调执行页面跳转
 */
+ (void)setupWebUrlHandle:(void(^)(NSString *url, NSDictionary *param, UIViewController *fromVc, BOOL isPresent, BOOL animated, DRRouterCallBackBlock callBack))handle {
    [DRRouterHandler router].webUrlHandler = handle;
}

/**
 设置用户登录的响应会次奥
 
 @param loginCommand 登录的路由指令名
 @param handle 当目标页面需要用户登录，切用户未登录时调用
 用户登录完成后，若调用continueRouterBlock，则会继续完成之前的将要执行的路由跳转
 @param loginStatusBlock 获取当前用户登录状态的回调
 */
+ (void)setupUserLoginCommand:(const NSString *)loginCommand
                       handle:(void (^)(const NSString *command, NSDictionary *param, DRRouterCallBackBlock callBack, dispatch_block_t continueRouterBlock))handle
             loginStatusBlock:(BOOL(^)(void))loginStatusBlock {
    [DRRouterHandler router].loginCommand = loginCommand;
    [DRRouterHandler router].loginHandler = handle;
    [DRRouterHandler router].loginStatusBlock = loginStatusBlock;
}

#pragma mark - 发起路由跳转，以下方式选一种
/**
 发送路由指令，使用Push方式弹出新页面
 
 @param command 路由指令
 @param param 传入下一页面的参数
 @param callback 传入下一页面的回调，需要被打开页面实现openXXX协议方法接收callback回调
 */
+ (BOOL)handleCommand:(const NSString *)command
            withParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback {
    return [DRRouterHandler handleCommand:command
                                   fromVc:nil
                                withParam:param
                                isPresent:NO
                                animation:YES
                                 callback:callback
                             setupPresent:nil];
}

/**
 发送路由指令，使用Push方式弹出新页面
 
 @param command 路由指令
 @param viewController 当前发送路由指令的界面
 @param param 传入下一页面的参数
 @param callback 传入下一页面的回调，需要被打开页面实现openXXX协议方法接收callback回调
 */
+ (BOOL)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
             callback:(DRRouterCallBackBlock)callback {
    return [DRRouterHandler handleCommand:command
                                   fromVc:viewController
                                withParam:param
                                isPresent:NO
                                animation:YES
                                 callback:callback
                             setupPresent:nil];
}

/**
 发送路由指令，使用Present(模态)方式弹出新页面
 
 @param command 路由指令
 @param viewController 当前发送路由指令的界面
 @param param 传入下一页面的参数
 @param animation 是否适用转场动画
 @param setupPresentBlock 对目标页面进行额外设置，如添加导航控制器
 */
+ (BOOL)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
     presentAnimation:(BOOL)animation
         setupPresent:(UIViewController *(^)(UIViewController *toViewController))setupPresentBlock {
    return [DRRouterHandler handleCommand:command
                                   fromVc:viewController
                                withParam:param
                                isPresent:YES
                                animation:animation
                                 callback:nil
                             setupPresent:setupPresentBlock];
}

#pragma mark - private
// 路由解析
+ (BOOL)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
            isPresent:(BOOL)isPresent
            animation:(BOOL)animation
             callback:(DRRouterCallBackBlock)callback
         setupPresent:(UIViewController *(^)(UIViewController *toViewController))setupPresentBlock {
    if (command.length == 0) {
        return NO;
    }
    DRRouterHandler *router = [DRRouterHandler router];
    
    // 获取顶层视图控制器
    UIViewController *fromVc = viewController;
    if (!fromVc) {
        if (router.getTopVcBlock == nil) {
            kDR_LOG(@"无法获取当前顶层视图控制器，请通过setupDefaultInitialMethod:..topViewController:设置获取顶层控制的回调");
            return NO;
        }
        fromVc = kDR_SAFE_BLOCK(router.getTopVcBlock);
    }
    
    // http，https使用web打开
    NSString *prefix = [[command componentsSeparatedByString:@"://"].firstObject lowercaseString];
    if ([prefix isEqualToString:@"http"] || [prefix isEqualToString:@"https"]) {
        if (router.webUrlHandler == nil) {
            kDR_LOG(@"未设置网页跳转响应，请调用setupWebUrlHandle:进行设置");
            return NO;
        }
        kDR_SAFE_BLOCK(router.webUrlHandler, (NSString *)command, param, fromVc, isPresent, animation, callback);
        return YES;
    }
    if (router.cmdScheme.length == 0) {
        kDR_LOG(@"未设置命令协议头，请调用+setupCommandScheme:进行设置");
        return NO;
    }
    
    // 处理自定义的指令集
    if ([prefix isEqualToString:(NSString *)router.cmdScheme]) {
        if ([router.loginCommand isEqualToString:(NSString *)command]) {
            if (router.loginHandler == nil) {
                kDR_LOG(@"响应指令: \"%@\"需要用户登录，请通过setupUserLoginCommand:...方法设置用户登录回调", command);
                return NO;
            }
            router.loginHandler(command, param, callback, nil);
            return YES;
        }
        
        [router sendCommand:command
                     withVc:fromVc
                      param:param
                  isPresent:isPresent
                  animation:animation
                   callback:callback
               setupPresent:setupPresentBlock];
        return YES;
    }
    
    // 其他指令视为跳转第三方应用
    NSURL *url;
    if (command.length) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", command]];
    }
    if (!url) {
        kDR_LOG(@"不能识别的指令: \"%@\"", command);
        return NO;
    }
    return [[UIApplication sharedApplication] openURL:url];
}

// 执行自定义指令的路由跳转
- (void)sendCommand:(const NSString *)command
             withVc:(UIViewController *)fromVc
              param:(NSDictionary *)param
          isPresent:(BOOL)isPresent
          animation:(BOOL)animation
           callback:(DRRouterCallBackBlock)callback
       setupPresent:(UIViewController *(^)(UIViewController *toViewController))setupPresentBlock {
    DRRouterItem *itme = self.cmdsMap[command];
    if (itme.needLogin) {
        if (self.loginStatusBlock != nil && self.loginHandler != nil) {
            if (!self.loginStatusBlock()) {
                kDRWeakSelf
                self.loginHandler(command, nil, nil, ^{
                    [weakSelf sendCommand:command withVc:fromVc param:param isPresent:isPresent animation:animation callback:callback setupPresent:setupPresentBlock];
                });
                return;
            }
        } else {
            kDR_LOG(@"响应指令: \"%@\"需要用户登录，请通过setupUserLoginCommand:...方法设置用户登录回调", command);
            return;
        }
    }
    if (itme.targetPageClass) {
        if (!itme.ignoreRouterSamePage && [fromVc isKindOfClass:itme.targetPageClass]) { // 避免重复叠加同一个页面
            return;
        }
        // 实现了协议方法的跳转
        if ([itme.targetPageClass respondsToSelector:@selector(openWithParam:callback:)]) {
            ((void (*)(id, SEL, id, DRRouterCallBackBlock))objc_msgSend)(itme.targetPageClass, @selector(openWithParam:callback:), param, callback);
            return;
        }
        if ([itme.targetPageClass respondsToSelector:@selector(openFromViewController:withParam:callback:)]) {
            ((void (*)(id, SEL, UIViewController*, id, DRRouterCallBackBlock))objc_msgSend)(itme.targetPageClass, @selector(openFromViewController:withParam:callback:), fromVc, param, callback);
            return;
        }
        if (![fromVc isKindOfClass:[UIViewController class]]) {
            kDR_LOG(@"无法获取当前顶层视图控制器...");
            return;
        }
        // 实例化目标视图控制器
        UIViewController *toVc = [self getDestinationVcWithItem:itme param:param callback:callback];
        // 执行页面跳转
        [self transferFromVc:fromVc
                        toVc:toVc
                   isPresent:isPresent
                   animation:animation
                setupPresent:setupPresentBlock];
        return;
    }
    kDR_LOG(@"指令：\"%@\"未注册", command);
}

// 实例化目标视图控制器
- (UIViewController *)getDestinationVcWithItem:(DRRouterItem *)item param:(NSDictionary *)param callback:(DRRouterCallBackBlock)callback {
    UIViewController *toVc;
    if (self.defaultInitialMethod) { // 设置了默认实例化方法
        if (self.isClassMethod) {
            if ([item.targetPageClass respondsToSelector:self.defaultInitialMethod]) {
                if (self.isNeedParam) {
                    toVc = ((UIViewController* (*)(id, SEL, id))objc_msgSend)(item.targetPageClass, self.defaultInitialMethod, param);
                } else {
                    toVc = ((UIViewController* (*)(id, SEL))objc_msgSend)(item.targetPageClass, self.defaultInitialMethod);
                }
            }
        } else {
            id instance = [item.targetPageClass alloc];
            if ([instance respondsToSelector:self.defaultInitialMethod]) {
                if (self.isNeedParam) {
                    toVc = ((UIViewController* (*)(id, SEL, id))objc_msgSend)(instance, self.defaultInitialMethod, param);
                } else {
                    toVc = ((UIViewController* (*)(id, SEL))objc_msgSend)(instance, self.defaultInitialMethod);
                }
            }
        }
    }
    if (!toVc) { // 没有设置默认实例化方法 或者 默认实例化方法未实现，实例化失败
        // 直接init
        toVc = (UIViewController *)[[item.targetPageClass alloc] init];
    }
    if (![toVc isKindOfClass:[UIViewController class]]) {
        kDR_LOG(@"指令：\"%@\"对应的类：\"%@\"不是视图控制UIViewController的子类", item.commad, NSStringFromClass(item.targetPageClass));
        return nil;
    }
    NSMutableDictionary *allParam = [NSMutableDictionary dictionary];
    if (callback != nil) {
        [allParam setObject:callback forKey:@"callBackBlock"];
    }
    if (item.staticParam.count > 0) {
        [allParam setValuesForKeysWithDictionary:item.staticParam];
    }
    if (param.count > 0) {
        [allParam setValuesForKeysWithDictionary:param];
    }
    if (allParam.count > 0) {
        [toVc yy_modelSetWithDictionary:allParam];
    }
    return toVc;
}

// 执行页面跳转
- (void)transferFromVc:(UIViewController *)fromVc
                  toVc:(UIViewController *)toVc
             isPresent:(BOOL)isPresent
             animation:(BOOL)animation
          setupPresent:(UIViewController *(^)(UIViewController *toViewController))setupPresentBlock {
    if (!fromVc.navigationController || isPresent) {
        if (setupPresentBlock != nil) {
            UIViewController *nav = setupPresentBlock(toVc);
            [fromVc presentViewController:nav animated:animation completion:nil];
        } else {
            [fromVc presentViewController:toVc animated:animation completion:nil];
        }
    } else {
        [fromVc.navigationController pushViewController:toVc animated:animation];
    }
}

@end
