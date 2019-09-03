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
@property (nonatomic, strong) NSDictionary *param;

+ (void)showWebWithUrl:(NSString *)url
                fromVc:(UIViewController *)vc
                 param:(NSDictionary *)param
             isPresent:(BOOL)isPresent
              animated:(BOOL)animated
           actionBlock:(dispatch_block_t)actionBlock;

@end

NS_ASSUME_NONNULL_END
