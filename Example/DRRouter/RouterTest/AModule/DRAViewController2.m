//
//  DRAViewController2.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRAViewController2.h"

@interface DRAViewController2 ()

@property (nonatomic, copy) NSDictionary *param;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation DRAViewController2

+ (instancetype)viewControllerWithParam:(NSDictionary *)param {
    DRAViewController2 *vc = [DRAViewController2 new];
    vc.param = param;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    self.label.text = self.param[@"key"];
}

@end
