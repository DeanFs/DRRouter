//
//  DRBViewController1.m
//  RouterTest
//
//  Created by 冯生伟 on 2019/3/27.
//  Copyright © 2019 冯生伟. All rights reserved.
//

#import "DRBViewController1.h"

@interface DRBViewController1 ()

@property (weak, nonatomic) IBOutlet UILabel *paramLabel;

@property (nonatomic, copy) NSString *key;

@end

@implementation DRBViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    
    self.paramLabel.text = self.key;
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
