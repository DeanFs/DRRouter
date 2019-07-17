//
//  DRWebViewController.h
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DRWebViewController : UIViewController

@property (nonatomic, copy) NSString *url;

+ (void)showWebWithUrl:(NSString *)url fromVc:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
