//
//  DRWebViewController.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRWebViewController.h"
#import <WebKit/WebKit.h>
#import <MJExtension/MJExtension.h>
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) dispatch_block_t actionBlock;

@end

@implementation DRWebViewController

+ (void)showWebWithUrl:(NSString *)url
                fromVc:(UIViewController *)vc
                 param:(NSDictionary *)param
             isPresent:(BOOL)isPresent
              animated:(BOOL)animated
           actionBlock:(dispatch_block_t)actionBlock {
    DRWebViewController *webVc = [[DRWebViewController alloc] init];
    webVc.url = url;
    webVc.param = param;
    webVc.actionBlock = actionBlock;
    if (isPresent || vc.navigationController == nil) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVc];
        [vc presentViewController:nav animated:animated completion:nil];
    } else {
        [vc.navigationController pushViewController:webVc animated:animated];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.title.length) {
        self.title = self.param[@"key"];
    }
    [self.view addSubview:self.webView];    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url.mj_url]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"action" style:UIBarButtonItemStylePlain target:self action:@selector(onActionTap)];
}

- (void)onActionTap {
    kDR_SAFE_BLOCK(self.actionBlock);
}

#pragma mark - lazy load
- (WKWebView *)webView {
    if(!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

@end
