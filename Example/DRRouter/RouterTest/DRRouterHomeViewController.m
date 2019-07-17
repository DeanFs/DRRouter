//
//  DRRouterHomeViewController.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRRouterHomeViewController.h"
#import "DRRouterCommandList.h"
#import "DRRouterHandler.h"
#import "DRWebViewController.h"
#import "DRAViewController2.h"
#import "DRBViewController1.h"
#import "DRBViewController2.h"
#import <DRMacroDefines/DRMacroDefines.h>
#import <BlocksKit/BlocksKit.h>

@interface DRRouterHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *lable2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (nonatomic, assign) NSInteger block1count;
@property (nonatomic, assign) NSInteger block2count;
@property (nonatomic, assign) NSInteger block3count;

@end

@implementation DRRouterHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"开始";
    
    // 注册协议头
    [DRRouterHandler setupCommandScheme:SCHEME];
    
    // 设置网页链接响应控制器
    [DRRouterHandler setupWebHandlerCalss:[DRWebViewController class]
                          urlPropertyName:@"url"
                        paramPropertyName:@"title"];
    
    // 批量注册指令
    [DRRouterHandler regisgerCommandsWithMap:@{A2: [DRAViewController2 class],
                                               B1: [DRBViewController1 class]
                                               }];
    
    // 指定通用实例化方法
    kDRWeakSelf
    [DRRouterHandler setupDefaultInitialMethod:@selector(viewControllerWithParam:) isClassMethod:YES isNeedParam:YES topViewController:^UIViewController *{
        // 此处比较特殊，可以这么写
        // 加入到你的项目的时候，这里应该是一个方法，遍历获取当前视图控制器
        return weakSelf.navigationController.topViewController;
    }];
}

- (IBAction)gotoA1:(id)sender {
    [DRRouterHandler handleCommand:A1 fromVc:self withParam:@{@"key": @"hfakdjlfajldk"} callback:^(NSInteger actionCode, NSDictionary *param) {
        if (actionCode == 1) {
            self.block1count ++;
            self.label1.text = [NSString stringWithFormat:@"%@@%ld", param[@"key"], self.block1count];
        } else if (actionCode == 2) {
            self.block2count ++;
            self.lable2.text = [NSString stringWithFormat:@"%@@%ld", param[@"key"], self.block2count];
        } else {
            self.block3count ++;
            self.label3.text = [NSString stringWithFormat:@"%@@%ld", param[@"key"], self.block3count];
        }
    }];
}

- (IBAction)gotoA2:(id)sender {
    [DRRouterHandler handleCommand:A2
                            fromVc:self
                         withParam:@{@"key": @"哈哈哈哈哈哈"}
                         isPresent:NO
                         animation:NO
                      setupPresent:^UINavigationController *(UIViewController *toViewController) {
                          return [[UINavigationController alloc] initWithRootViewController:toViewController];
                      }];
}

- (IBAction)gotoB1:(id)sender {
    [DRRouterHandler handleCommand:B1
                            fromVc:self
                         withParam:@{@"key": @"哈哈哈哈哈哈"}
                         isPresent:YES
                         animation:YES
                      setupPresent:^UINavigationController *(UIViewController *toViewController) {
                          return [[UINavigationController alloc] initWithRootViewController:toViewController];
                      }];
}

- (IBAction)gotoB2:(id)sender {
    // B2指令没有注册，将会抛出异常
    [DRRouterHandler handleCommand:B2 fromVc:self withParam:nil callback:nil];
}


- (IBAction)gotoWeb:(id)sender {
    [DRRouterHandler handleCommand:@"http://www.baidu.com"
                            fromVc:self
                         withParam:@{@"key": @"xxx百度一下xxx"}
                         isPresent:NO
                         animation:YES
                      setupPresent:^UINavigationController *(UIViewController *toViewController) {
                          return [[UINavigationController alloc] initWithRootViewController:toViewController];
                      }];
}


@end
