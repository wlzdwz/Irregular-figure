//
//  BottomView.m
//  不规则滑动尺
//
//  Created by wuliangzhi on 2019/1/11.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "BottomView.h"
#import "TestView.h"

@interface BottomView ()

@end

@implementation BottomView

- (TestView *)testV{
    if (!_testV) {
        _testV = [[TestView alloc] init];
    }
    return _testV;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.image = [UIImage imageNamed:@"灯光滑动尺左"];
    }
    return _imgView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imgView];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint p = [self convertPoint:point toView:self.testV];
    if ([self.testV pointInside:p withEvent:event]) {
//        self.imgView.image = [UIImage imageNamed:@"合并形状"];
        return self.testV;
    }else{
        return [super hitTest:point withEvent:event];
    }
}

@end
