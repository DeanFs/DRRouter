//
//  DRRouterHandler.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRRouterHandler.h"
#import "DRMacroDefines.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define kWebCmd @"gotoWebView"

@interface DRRouterHandler ()

@property (nonatomic, strong) NSMutableDictionary<const NSString *, Class> *cmdCalssMap;
@property (nonatomic, copy) const NSString *cmdScheme;

// 默认实例方法
@property (nonatomic, assign) SEL defaultInitialMethod;
@property (nonatomic, assign) BOOL isClassMethod;
@property (nonatomic, assign) BOOL isNeedParam;
@property (nonatomic, copy) DRRouterGetTopViewControllerBlock getTopVcBlock;

// web需要参数
@property (nonatomic, copy) NSString *urlPropertyName;
@property (nonatomic, copy) NSString *paramPropertyName;

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
        self.cmdCalssMap = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - 注册指令
/**
 注册指令
 请在可以通过路由打开的页面中通过REGISTER_ROUTER_DOMMAND实现注册，不建议直接调用该方法
 viewControllerA->viewControllerB，则在B中调用REGISTER_ROUTER_DOMMAND(gotoB_command)
 
 @param cmd 指令字符串
 @param viewControllerClass 对应类名
 */
+ (void)registerCommand:(const NSString *)cmd
                vcClass:(Class)viewControllerClass {
    [DRRouterHandler router].cmdCalssMap[cmd] = viewControllerClass;
}

#pragma mark - 一些初始化设置
/**
 设置指令协议头，一般以scheme开头，如http，https
 如指令集使用："shiguangxu://gotoScheduleEdit"
 则传入"shiguangxu"
 
 @param scheme 指令协议头
 */
+ (void)setupCommandScheme:(const NSString *)scheme {
    [DRRouterHandler router].cmdScheme = scheme;
}

/**
 批量注册指令映射表
 
 @param commandsMap 指令映射表，key为指令，value(Class类型)为对应viewController Class
 */
+ (void)regisgerCommandsWithMap:(NSDictionary<const NSString *, Class> *)commandsMap {
    [[DRRouterHandler router].cmdCalssMap addEntriesFromDictionary:commandsMap];
}

/**
 设置响应网页跳转的viewController
 
 @param webHandlerClass 一般是加载网页的viewController
 @param urlKey url属性名
 @param paramKey 其他参数属性名
 */
+ (void)setupWebHandlerCalss:(Class)webHandlerClass
             urlPropertyName:(NSString *)urlKey
           paramPropertyName:(NSString *)paramKey {
    DRRouterHandler *router = [DRRouterHandler router];
    router.cmdCalssMap[kWebCmd] = webHandlerClass;
    router.urlPropertyName = urlKey;
    router.paramPropertyName = paramKey;
}

/**
 设置统一的页面实例化方法，在路由目标页没有实现open方法的情况下调用传入的initialMethod
 
 @param initialMethod 目标页面实例化方法
 @param isClassMethod 是否是类方法
 @param isNeedParam 是否需要参数，需要的话，会把路由时传来的参数param原样传入该实例化方法
 @param getTopViewControllerBlock 获取当前顶层控制器的方法回调
 */
+ (void)setupDefaultInitialMethod:(SEL)initialMethod
                    isClassMethod:(BOOL)isClassMethod
                      isNeedParam:(BOOL)isNeedParam
                topViewController:(DRRouterGetTopViewControllerBlock)getTopViewControllerBlock {
    DRRouterHandler *router = [DRRouterHandler router];
    router.defaultInitialMethod = initialMethod;
    router.isClassMethod = isClassMethod;
    router.isNeedParam = isNeedParam;
    router.getTopVcBlock = getTopViewControllerBlock;
}

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
             callback:(DRRouterCallBackBlock)callback {
    [DRRouterHandler handleCommand:command
                            fromVc:nil
                         withParam:param
                         isPresent:NO
                         animation:YES
                          callback:callback
                      setupPresent:nil];
}

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
             callback:(DRRouterCallBackBlock)callback {
    [DRRouterHandler handleCommand:command
                            fromVc:viewController
                         withParam:param
                         isPresent:NO
                         animation:YES
                          callback:callback
                      setupPresent:nil];
}

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
         setupPresent:(DRSetupPresentBlock)setupPresentBlock {
    [DRRouterHandler handleCommand:command
                            fromVc:viewController
                         withParam:param
                         isPresent:isPresent
                         animation:animation
                          callback:nil
                      setupPresent:setupPresentBlock];
}

#pragma mark - private
// 路由解析
+ (void)handleCommand:(const NSString *)command
               fromVc:(UIViewController *)viewController
            withParam:(NSDictionary *)param
            isPresent:(BOOL)isPresent
            animation:(BOOL)animation
             callback:(DRRouterCallBackBlock)callback
         setupPresent:(DRSetupPresentBlock)setupPresentBlock {
    DRRouterHandler *router = [DRRouterHandler router];
    
    // 获取顶层视图控制器
    UIViewController *fromVc = viewController;
    if (!fromVc) {
        fromVc = kDR_SAFE_BLOCK(router.getTopVcBlock);
    }
    
    NSAssert(router.cmdScheme.length, @"未设置命令协议头，请调用+setupCommandScheme:进行设置");
    
    // 处理自定义的指令集
    if ([command hasPrefix:(NSString *)router.cmdScheme]) {
        [router sendCommand:command
                     withVc:fromVc
                      param:param
                  isPresent:isPresent
                  animation:animation
                   callback:callback
               setupPresent:setupPresentBlock];
        return;
    }
    
    // http，https使用web打开
    if ([command hasPrefix:@"http://"] || [command hasPrefix:@"https://"]) {
        [router webTransferFromVc:fromVc
                      withCommand:command
                            param:param
                        isPresent:isPresent
                        animation:animation
                     setupPresent:setupPresentBlock];
        return;
    }
    
    // 其他指令视为跳转第三方应用
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", command]];
    if (!url) {
        NSString *message = [NSString stringWithFormat:@"不能识别的指令: \"%@\"", command];
        NSAssert(NO, message);
    }
    [[UIApplication sharedApplication] openURL:url];
}

// 执行自定义指令的路由跳转
- (void)sendCommand:(const NSString *)command
             withVc:(UIViewController *)fromVc
              param:(NSDictionary *)param
          isPresent:(BOOL)isPresent
          animation:(BOOL)animation
           callback:(DRRouterCallBackBlock)callback
       setupPresent:(DRSetupPresentBlock)setupPresentBlock {
    Class class = self.cmdCalssMap[command];
    if (class) {
        if ([fromVc isKindOfClass:class]) { // 避免重复叠加同一个页面
            return;
        }
        // 实现了协议方法的跳转
        if ([class respondsToSelector:@selector(openWithParam:callback:)]) {
            ((void (*)(id, SEL, id, DRRouterCallBackBlock))objc_msgSend)(class, @selector(openWithParam:callback:), param, callback);
            return;
        }
        if ([class respondsToSelector:@selector(openFromViewController:withParam:callback:)]) {
            ((void (*)(id, SEL, UIViewController*, id, DRRouterCallBackBlock))objc_msgSend)(class, @selector(openFromViewController:withParam:callback:), fromVc, param, callback);
            return;
        }
        
        NSAssert([fromVc isKindOfClass:[UIViewController class]], @"无法获取当前顶层视图控制器...");
        // 实例化目标视图控制器
        UIViewController *toVc = [self getDestinationVcWithCalss:class command:command param:param];
        // 执行页面跳转
        [self transferFromVc:fromVc
                        toVc:toVc
                   isPresent:isPresent
                   animation:animation
                setupPresent:setupPresentBlock];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"指令：\"%@\"未注册", command];
    NSAssert(NO, message);
}

- (void)webTransferFromVc:(UIViewController *)fromVc
              withCommand:(const NSString *)command
                    param:(NSDictionary *)param
                isPresent:(BOOL)isPresent
                animation:(BOOL)animation
             setupPresent:(DRSetupPresentBlock)setupPresentBlock {
    Class webVcClass = self.cmdCalssMap[kWebCmd];
    if (webVcClass) {
        if ([fromVc isKindOfClass:webVcClass]) { // 避免重复叠加同一个页面
            return;
        }
        NSAssert(self.urlPropertyName.length, @"未指定webView的url属性名");
        NSAssert([fromVc isKindOfClass:[UIViewController class]], @"无法获取当前顶层视图控制器...");
        
        UIViewController *webVc = [self getDestinationVcWithCalss:webVcClass command:command param:param];
        [webVc setValue:command forKey:self.urlPropertyName];
        if (self.paramPropertyName) {
            [webVc setValue:param forKey:self.paramPropertyName];
        }
        [self transferFromVc:fromVc
                        toVc:webVc
                   isPresent:isPresent
                   animation:animation
                setupPresent:setupPresentBlock];
        return;
    }
    NSAssert(NO, @"未注册响应网页跳转的视图控制器");
}

// 实例化目标视图控制器
- (UIViewController *)getDestinationVcWithCalss:(Class)class command:(const NSString *)command param:(NSDictionary *)param {
    UIViewController *toVc;
    if (self.defaultInitialMethod) { // 设置了默认实例化方法
        if (self.isClassMethod) {
            if ([class respondsToSelector:self.defaultInitialMethod]) {
                if (self.isNeedParam) {
                    toVc = ((UIViewController* (*)(id, SEL, id))objc_msgSend)(class, self.defaultInitialMethod, param);
                } else {
                    toVc = ((UIViewController* (*)(id, SEL))objc_msgSend)(class, self.defaultInitialMethod);
                }
            }
        } else {
            id instance = [class alloc];
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
        toVc = (UIViewController *)[[class alloc] init];
    }
    if (![toVc isKindOfClass:[UIViewController class]]) {
        NSString *message = [NSString stringWithFormat:@"指令：\"%@\"对应的类：\"%@\"不是视图控制UIViewController的子类", command, NSStringFromClass(class)];
        NSAssert(NO, message);
    }
    
    return toVc;
}

// 执行页面跳转
- (void)transferFromVc:(UIViewController *)fromVc
                  toVc:(UIViewController *)toVc
             isPresent:(BOOL)isPresent
             animation:(BOOL)animation
          setupPresent:(DRSetupPresentBlock)setupPresentBlock {
    if (!fromVc.navigationController || isPresent) {
        if (setupPresentBlock) {
            UINavigationController *nav = setupPresentBlock(toVc);
            [fromVc presentViewController:nav animated:animation completion:nil];
        } else {
            [fromVc presentViewController:toVc animated:animation completion:nil];
        }
    } else {
        [fromVc.navigationController pushViewController:toVc animated:animation];
    }
}

@end
