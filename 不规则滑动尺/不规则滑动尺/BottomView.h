//
//  BottomView.h
//  不规则滑动尺
//
//  Created by wuliangzhi on 2019/1/11.
//  Copyright © 2019年 wuliangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class TestView;
@interface BottomView : UIView

/** 图片 */
@property(nonatomic,strong)UIImageView *imgView;
/** <#注释#> */
@property(nonatomic,strong)TestView *testV;

@end



NS_ASSUME_NONNULL_END
