//
//  TestView.m
//  不规则滑动尺
//
//  Created by wuliangzhi on 2019/1/10.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import "TestView.h"
#import "shipeAnimation.h"

#define HEIGHT                   [UIScreen mainScreen].bounds.size.height
#define WIDTH                    [UIScreen mainScreen].bounds.size.width

static const CGFloat kWidth = 108; /**< 大矩形宽高. */
static const CGFloat kHeight = 336; /**< 大矩形宽高. */

//颜色渐变数组
static const CGFloat colors[] = {
    255.0 / 255.0, 200.0 / 255.0, 0 / 255.0, 1.0,
};

@interface TestView ()
{
    CGPoint _startPoint; /**< 图层渲染开始点. */
    CGPoint _endPoint; /**< 图层渐变结束点. */
    CGFloat _pointX;
    CGFloat _pointY;
    
    CGFloat waveHeight;//浪高
    CGFloat waveSpeed; //浪速
    CGFloat waveCurvature;//浪的弯曲度  等同于设置波的周期
    CGFloat offSetValue; //波的初相位
    
    CAShapeLayer *realWaveLayer; //真实的波形
    CAShapeLayer *maskWaveLayer; //类似于遮罩
    
    UIImageView *boardView; //小船
    
    CGFloat _distance; /**< 大小半径差值. */
    
}

/** 形状路径 */
@property(nonatomic,strong)CAShapeLayer *shaperLayer;


@property (nonatomic, strong) UIImageView *thumbView;
@property (nonatomic, assign) CGPoint lastPoint;        //滑块的实时位置

@property (nonatomic, assign) CGFloat radius;           //半径
@property (nonatomic, assign) CGPoint drawCenter;       //绘制圆的圆心
@property (nonatomic, assign) CGPoint circleStartPoint; //thumb起始位置
@property (nonatomic, assign) CGFloat angle;            //转过的角度

@property (nonatomic, assign) BOOL lockClockwise;       //禁止顺时针转动
@property (nonatomic, assign) BOOL lockAntiClockwise;   //禁止逆时针转动

@property (nonatomic, assign) BOOL interaction;

/** <#注释#> */
@property(nonatomic,strong)shipeAnimation *waveView;


@end


@implementation TestView

- (CAShapeLayer *)shaperLayer{
    if (!_shaperLayer) {
        _shaperLayer = [CAShapeLayer layer];
    }
    return _shaperLayer;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self drawShape];
        //初始化
        waveHeight = 8;
        waveSpeed = 0.4/M_PI;
        waveCurvature = 0.8 *M_PI / kWidth;
        offSetValue = 0.f;
        [self creatWave];
        
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(waveMove)];
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        //添加观察者
        [self observer];
        
    }
    return self;
}

#pragma mark ==========private method==========

/**
 添加观察者
 */
- (void)observer{
    //创建
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//        NSLog(@"----监听到runLoop的状态发生改变:%zd",activity);
    });
    //添加
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    //释放
    CFRelease(observer);
}


/**
 创建波浪
 */
-(void)creatWave{
    //真实浪
    realWaveLayer  =[CAShapeLayer layer];
    CGRect rect  = CGRectMake(0, kHeight, kWidth, kHeight);
    
    realWaveLayer.fillColor =[UIColor colorWithRed:255.0 / 255.0 green:200 / 255.0 blue:0 alpha:1.0].CGColor;
    
    realWaveLayer.frame = rect;
    
    [self.layer addSublayer:realWaveLayer];
    
    //背后的遮罩浪图层
    maskWaveLayer =[CAShapeLayer layer];
    CGRect rect1 = CGRectMake(0, kHeight, kWidth, kHeight);
    
    maskWaveLayer.fillColor =[[UIColor colorWithRed:255.0 / 255.0 green:200 / 255.0 blue:0 alpha:1.0] colorWithAlphaComponent:0.6].CGColor;
    maskWaveLayer.frame = rect1;
    [self.layer addSublayer:maskWaveLayer];
    
}


/**
 改变波浪的位置
 */
- (void)changeLayer{
    CGRect rect  = realWaveLayer.frame;
    rect.origin.y = _endPoint.y;
    realWaveLayer.frame = rect;
    maskWaveLayer.frame = rect;
}

/**
 动态的浪花
 */
- (void)waveMove{

    //改变layer的y值
//    [self changeLayer];
    
    //为实浪设置路径,起始点
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 0, waveHeight);
    CGFloat y = 0;
    //为遮罩图层设置路径,起始点
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathMoveToPoint(maskPath, nil, 0, waveHeight);
    CGFloat masky = 0;
    offSetValue += waveSpeed;
    
    /**
     *  使用for循环,生成一系列的正弦曲线的点,并添加到路径中
     */
    for (NSInteger x = 0; x < kWidth; x++) {
        y = waveHeight * sinf(waveCurvature * x + offSetValue);
        CGPathAddLineToPoint(path, nil, x, y);
        
        //遮罩层的路径与之相反
        masky = waveHeight * cosf(waveCurvature * x + offSetValue);
        CGPathAddLineToPoint(maskPath, nil, x, masky);
    }
    
    //CAShapeLayer右下角的点
    CGPathAddLineToPoint(path, nil, kWidth, waveHeight);
    //CAShapeLayer左下角的点
    CGPathAddLineToPoint(path, nil, 0, waveHeight);
    //闭合路径
    CGPathCloseSubpath(path);
    realWaveLayer.path = path;
    
    //释放路径
    CGPathRelease(path);
    
    //CAShapeLayer右下角的点
    CGPathAddLineToPoint(maskPath, nil, kWidth, waveHeight);
    //CAShapeLayer左下角的点
    CGPathAddLineToPoint(maskPath, nil, 0, waveHeight);
    //闭合路径
    CGPathCloseSubpath(maskPath);
    maskWaveLayer.path = maskPath;
    
    //释放路径
    CGPathRelease(maskPath);
    
}


 //垂直渲染方案,非圆弧路径
 - (void)drawRect:(CGRect)rect{
     [super drawRect:rect];
     
    //1.渲染图层
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    //locations只是决定颜色数组中颜色的显示顺序
    CGFloat locations[] = {0.3,0.5,1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, sizeof(colors) / (sizeof(colors[0]) * 4));
 
 //渲染整块路径包含的区域
     UIBezierPath *berzier = [UIBezierPath bezierPath];
     [berzier moveToPoint:CGPointMake(0, kHeight)];
     [berzier addLineToPoint:CGPointMake(kWidth, kHeight)];
     [berzier addLineToPoint:CGPointMake(kWidth, _endPoint.y)];
     [berzier addLineToPoint:CGPointMake(0, _endPoint.y)];
     [berzier closePath];
     CGPathRef path = berzier.CGPath;
     CGContextSaveGState(context);
     CGContextAddPath(context, path);
     CGContextClip(context);
     
     CGContextDrawLinearGradient(context, gradient, _startPoint, _endPoint, kCGGradientDrawsAfterEndLocation);
     CGContextRestoreGState(context);
     CGGradientRelease(gradient);
     CGColorSpaceRelease(rgb);
     
     NSLog(@"%s",__func__);
     
 }

/*
//画圆弧路径
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    //大圆半径
    CGFloat BigR = (kHeight * 0.5) / cos(M_PI_4);
    //小圆半径
    CGFloat smallR = (BigR - kWidth) / cos(M_PI_4);
    //距离
    CGFloat distance = BigR - smallR;
    _distance = distance * 2;
    //圆心
    self.drawCenter = CGPointMake(BigR, kHeight * 0.5);
    
    //开始画图
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    CGFloat originstart = M_PI * 3 / 4.0;
    CGFloat currentOrigin = originstart +  M_PI_2 * self.value;
    [circlePath addArcWithCenter:self.drawCenter radius:BigR startAngle:originstart endAngle:currentOrigin clockwise:YES];
    
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetLineWidth(ctx, distance * 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextAddPath(ctx, circlePath.CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);
    
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGPathContainsPoint(self.shaperLayer.path, NULL, point, YES)) {
        return [super pointInside:point withEvent:event];
    }else{
        return NO;
    }
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [super beginTrackingWithTouch:touch withEvent:event];
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint point = [touch locationInView:self];
    _endPoint = point;
    self.value = (kHeight - ABS(point.y)) / (kHeight);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsDisplay];
    
    NSLog(@"%s",__func__);
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    _endPoint = point;
    self.value = (kHeight - ABS(point.y)) / (kHeight);
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    NSLog(@"%s",__func__);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    realWaveLayer.hidden = YES;
    maskWaveLayer.hidden = YES;
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _endPoint = point;
    self.value = (kHeight - ABS(point.y)) / (kHeight);
    [self setNeedsDisplay];
    
    [self changeLayer];
    realWaveLayer.hidden = NO;
    maskWaveLayer.hidden = NO;
    NSLog(@"%s",__func__);

}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    NSLog(@"%s",__func__);
}

#pragma mark ==========画图形==========

- (void)drawShape{
    /*
     矩形:336X108;圆环对应弧线M_PI_2
     */
    //大圆半径
    CGFloat BigR = (kHeight * 0.5) / cos(M_PI_4);
    //小圆半径
    CGFloat smallR = (BigR - kWidth) / cos(M_PI_4);
    
    _distance = (BigR - smallR) * 2;
    //圆心
    CGPoint pointCenter = CGPointMake(BigR, kHeight * 0.5);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //起始点A
    CGFloat Ax = BigR * (1 - cos(M_PI_4));
    CGPoint pointA = CGPointMake(Ax, 0);
    [path moveToPoint:pointA];
    
    //与A点对称的D点
    CGPoint pointD = CGPointMake(Ax, kHeight);
    _startPoint = CGPointMake(0, kHeight);
    _endPoint = pointD;
    _pointX = Ax;
    _pointY = kHeight;
    
    //画弧线AD
    [path addArcWithCenter:pointCenter radius:BigR startAngle:(M_PI_4 * 5) endAngle:(M_PI_4 * 3) clockwise:NO];
    //    [path addLineToPoint:pointD];
    //第三个点C
    CGFloat distanceC = smallR * cos(M_PI_4);
    CGFloat Cy = kHeight * 0.5 + distanceC;
    CGPoint pointC = CGPointMake(kWidth, Cy);
    [path addLineToPoint:pointC];
    [path addArcWithCenter:pointCenter radius:smallR startAngle:(M_PI_4 * 3) endAngle:M_PI_4 * 5 clockwise:YES];
    //第四个点B
    //    CGPoint pointB = CGPointMake(kWidth, kHeight * 0.5 - distanceC);
    [path closePath];
    
    self.shaperLayer.path = path.CGPath;
    [self.layer setMask:self.shaperLayer];
    self.layer.masksToBounds = YES;
    
}

@end

