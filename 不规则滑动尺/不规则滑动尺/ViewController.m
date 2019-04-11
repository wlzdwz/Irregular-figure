//
//  ViewController.m
//  不规则滑动尺
//
//  Created by wuliangzhi on 2019/1/10.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "ViewController.h"
#import "TestView.h"
#import "BottomView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *whiteView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    TestView *testV = [[TestView alloc] init];
    testV.frame = CGRectMake(0, 0, 108, 336);
    testV.backgroundColor = [UIColor blueColor];
    
    BottomView *bottom = [[BottomView alloc] initWithFrame:testV.frame];
    bottom.testV = testV;
//    [self.view addSubview:bottom];
    [self.view addSubview:testV];

}


@end
