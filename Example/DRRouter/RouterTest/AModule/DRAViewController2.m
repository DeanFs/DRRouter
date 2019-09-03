//
//  DRAViewController2.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRAViewController2.h"
#import "DRCustomModel.h"
#import "DRRouterHandler.h"
#import <DRMacroDefines/DRMacroDefines.h>

@interface DRAViewController2 () <DRRouterHandlerOpen>

@property (nonatomic, copy) NSDictionary *param;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) DRCustomModel *customModel;

@end

@implementation DRAViewController2

@synthesize callBackBlock = _callBackBlock;

//+ (instancetype)viewControllerWithParam:(NSDictionary *)param {
//    DRAViewController2 *vc = [DRAViewController2 new];
//    vc.param = param;
//    return vc;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    if (self.param.count > 0) {
        self.label.text = self.param[@"key"];
    } else if (self.key.length) {
        self.label.text = self.key;
    } else if (self.customModel != nil) {
        self.label.text = self.customModel.key;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"点击" style:UIBarButtonItemStylePlain target:self action:@selector(onAction)];
}

- (void)onAction {
    kDR_SAFE_BLOCK(self.callBackBlock, 0, @{@"test": @"点击了导航栏"});
}

@end
