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

@interface DRWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation DRWebViewController

+ (void)showWebWithUrl:(NSString *)url fromVc:(UIViewController *)vc {
    DRWebViewController *webVc = [[DRWebViewController alloc] init];
    webVc.url = url;
    if (vc.navigationController) {
        [vc.navigationController pushViewController:webVc animated:YES];
    } else {
        [vc presentViewController:webVc animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.title.length) {
        self.title = @"网页连接";
    }
    [self.view addSubview:self.webView];    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url.mj_url]];
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
