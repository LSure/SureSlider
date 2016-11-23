//
//  SureServiceSlider.h
//  SureSlider
//
//  Created by 刘硕 on 2016/11/23.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SHIMMER_TAG 300
#define SLIDER_WIDTH self.bounds.size.width
#define SLIDER_HEIGHT self.bounds.size.height
#define SERVICE_STATE_ARR @[@"服务已完成",@"服务已经开始",@"到达约定地点",@"服务准备开始"];

#define BlUR_COLOR [UIColor \
colorWithRed:253 / 255.0 \
green:127 / 255.0 \
blue:127 /255.0 \
alpha:1]

#define YDRed [UIColor \
colorWithRed:236.0/255.0 \
green:73.0/255.0 \
blue:73.0/255.0 \
alpha:1.0]
//服务状态
typedef NS_ENUM(NSInteger, SERVICE_STATE) {
    SERVICE_READY,
    SERVICE_ARRIVED,
    SERVICE_START,
    SERVICE_END
};
@interface SureServiceSlider : UIView
/**
 *  底部订单状态滚动视图
 */
@property (nonatomic, strong) UIScrollView *buttomScrollView;
/**
 *  滑动更改点击弹出视图
 */
@property (nonatomic, strong) UIImageView *popView;
/**
 *  视图弹出状态
 */
@property (nonatomic, assign) BOOL isShow;
/**
 *  触发订单状态改变
 */
@property (nonatomic, copy) void(^serviceStateChange)(SERVICE_STATE);
/**
 *  根据订单状态显示对应滑块状态
 */
- (void)changeSliderStateForType:(SERVICE_STATE)state;

@end
