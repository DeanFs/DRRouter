//
//  DRAViewController1.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRAViewController1.h"
#import "DRRouterCommandList.h"

@interface DRAViewController1 ()

@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) dispatch_block_t block1;
@property (nonatomic, copy) dispatch_block_t block2;
@property (nonatomic, copy) dispatch_block_t block3;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation DRAViewController1

REGISTER_ROUTER_DOMMAND(A1)

+ (void)openFromViewController:(UIViewController *)viewController withParam:(id)param callback:(DRRouterCallBackBlock)callback {
    DRAViewController1 *a1 = [[DRAViewController1 alloc] init];
    a1.string = param[@"key"];
    a1.block1 = ^{
        callback(1, @{@"key": @"你"});
    };
    a1.block2 = ^{
        callback(2, @{@"key": @"好"});
    };
    a1.block3 = ^{
        callback(3, @{@"key": @"呀"});
    };
    [viewController.navigationController pushViewController:a1 animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    self.label.text = self.string;
}

- (IBAction)block1Action:(id)sender {
    self.block1();
}

- (IBAction)block2Action:(id)sender {
    self.block2();
}

- (IBAction)block3Action:(id)sender {
    self.block3();
}

@end
