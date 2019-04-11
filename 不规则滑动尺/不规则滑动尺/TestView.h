//
//  TestView.h
//  不规则滑动尺
//
//  Created by wuliangzhi on 2019/1/10.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestView : UIControl

@property (nullable, nonatomic, strong) UIColor *backgroundTintColor;
@property (nullable, nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nullable, nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nullable, nonatomic, strong) UIColor *thumbTintColor;

@property (nonatomic, assign) CGFloat circleBorderWidth;    //圆的宽度
@property (nonatomic, assign) CGFloat circleRadius;         //圆形进度条的半径，一般比view的宽高中最小者还要小24
@property (nonatomic, assign) CGFloat thumbRadius;          //滑块正常的半径
@property (nonatomic, assign) CGFloat thumbExpandRadius;    //滑块放大的半径

@property (nonatomic, assign) float value;                  //slider当前的value
@property (nonatomic, assign) float loadProgress;           //slider加载的进度

@property (nonatomic, assign) BOOL canRepeat;               //是否可以重复拖动。默认为NO，即只能转到360；否则任意角度。
@property (nonatomic, assign, readonly) BOOL interaction;   //点击在限定的区域为YES，否则为NO.

@end

NS_ASSUME_NONNULL_END
