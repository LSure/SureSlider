//
//  SureServiceSlider.m
//  SureSlider
//
//  Created by 刘硕 on 2016/11/23.
//  Copyright © 2016年 刘硕. All rights reserved.
//

#import "SureServiceSlider.h"
#import "FBShimmeringView.h"
@interface SureServiceSlider ()<UIScrollViewDelegate>
/**
 *  滚动视图偏移量记录
 */
@property (nonatomic, assign) float offSet;
/**
 *  用于存储滚动视图子视图数组
 */
@property (nonatomic, strong) NSMutableArray *buttomSubViewArr;

@end
@implementation SureServiceSlider

#pragma mark UI搭建
- (void)createUI {
    //底部滚动视图
    [self addSubview:self.buttomScrollView];
    
    NSArray *titleArr = SERVICE_STATE_ARR;
    _buttomScrollView.contentSize = CGSizeMake(SLIDER_WIDTH * titleArr.count, SLIDER_HEIGHT);
    _buttomScrollView.contentOffset = CGPointMake(SLIDER_WIDTH * (titleArr.count - 1), 0);
    for (NSInteger i = 0; i < titleArr.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(SLIDER_WIDTH * i, 0, SLIDER_WIDTH, SLIDER_HEIGHT)];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = YDRed;
        label.font = [UIFont systemFontOfSize:17.0f];
        label.text = titleArr[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        label.layer.cornerRadius = SLIDER_HEIGHT * 0.5;
        label.layer.masksToBounds = YES;
        label.font = [UIFont systemFontOfSize:18.0];
        [_buttomScrollView addSubview:label];
        //滑动箭头动画效果
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(51, (SLIDER_HEIGHT - 17) / 2, 19, 17)];
        shimmeringView.shimmering = YES;
        shimmeringView.shimmeringOpacity = 0.2;
        shimmeringView.shimmeringBeginFadeDuration = 0.5;
        shimmeringView.shimmeringSpeed = 30;
        shimmeringView.shimmeringAnimationOpacity = 1.0;
        shimmeringView.tag = SHIMMER_TAG + i;
        [label addSubview:shimmeringView];
        
        UIImageView *arrowImageView = [[UIImageView alloc]initWithFrame:shimmeringView.bounds];
        arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
        arrowImageView.image = [UIImage imageNamed:@"slider_double_arrow"];
        shimmeringView.contentView = arrowImageView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAlert)];
        [label addGestureRecognizer:tap];
    }
    //添加弹窗视图
    [self addSubview:self.popView];
    //获取滚动视图中Label子视图 便于更改对应显示效果
    _buttomSubViewArr = [[NSMutableArray alloc]initWithArray:_buttomScrollView.subviews];
    for (UIView *view in _buttomScrollView.subviews) {
        if (![view isKindOfClass:[UILabel class]]) {//去除非UILabel视图
            [_buttomSubViewArr removeObject:view];
        }
    }
}
#pragma mark 部订单状态滚动视图
- (UIScrollView*)buttomScrollView {
    if (!_buttomScrollView) {
        _buttomScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _buttomScrollView.backgroundColor = BlUR_COLOR;
        _buttomScrollView.bounces = NO;
        _buttomScrollView.pagingEnabled = YES;
        _buttomScrollView.showsHorizontalScrollIndicator = NO;
        _buttomScrollView.delegate = self;
        _buttomScrollView.layer.cornerRadius = SLIDER_HEIGHT * 0.5;
        _buttomScrollView.layer.masksToBounds = YES;
        _buttomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _buttomScrollView;
}

#pragma mark 滑动更换点击弹出视图
- (UIImageView*)popView {
    if (!_popView) {
        _popView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -60, SLIDER_WIDTH, 55)];
        UIImage *currentImage = [UIImage imageNamed:@"bubble_pop"];
        _popView.image = [currentImage stretchableImageWithLeftCapWidth:100 topCapHeight:51];
        _popView.hidden = YES;
        UILabel *alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 3, SLIDER_WIDTH - 10, 45)];
        alertLabel.text = @"为防止您误操作，我们已将点击按钮改为滑动按钮，请您向右滑试试看！";
        alertLabel.numberOfLines = 0;
        alertLabel.textColor = [UIColor whiteColor];
        alertLabel.font = [UIFont systemFontOfSize:14];
        [_popView addSubview:alertLabel];
    }
    return _popView;
}

- (void)showAlert {
    _popView.hidden = _isShow;
    _isShow = !_isShow;
    
}

- (void)dismissAlert {
    _popView.hidden = YES;
    _isShow = NO;
}

#pragma mark 滚动视图代理处理事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissAlert];
    //获取当前显示视图，切换透明度
    float width = _buttomScrollView.bounds.size.width;
    int page = scrollView.contentOffset.x / width + 1;
    if (page < _buttomSubViewArr.count) {
        if (_buttomSubViewArr[page]) {
            UILabel *currentLable = (UILabel*)_buttomSubViewArr[page];
            currentLable.alpha = 0.5;
            currentLable.backgroundColor = BlUR_COLOR;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //记录开始滑动偏移量
    _offSet = scrollView.contentOffset.x;
}

//防止拖拽回原位置偏移量未发生变化处理
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //视图回归不透明
        for (UIView *view in _buttomSubViewArr) {
            view.alpha = 1;
            view.backgroundColor = YDRed;
        }
        //弹出视图消失
        [self dismissAlert];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //视图回归不透明
    for (UIView *view in _buttomSubViewArr) {
        view.alpha = 1;
        view.backgroundColor = YDRed;
    }
    //弹出视图消失
    [self dismissAlert];
    float newOffSet = scrollView.contentOffset.x;
    //根据偏移量判断是否切换为下一状态
    if (newOffSet < _offSet) {
        //触发事件
        if (self.serviceStateChange) {
            self.serviceStateChange(SERVICE_READY);
        }
        scrollView.contentSize = CGSizeMake(SLIDER_WIDTH * (newOffSet / SLIDER_WIDTH + 1), SLIDER_HEIGHT);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self createUI];
}

#pragma mark 根据当前订单状态更改滑块显示
- (void)changeSliderStateForType:(SERVICE_STATE)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (state) {
            case SERVICE_READY:
                break;
            case SERVICE_ARRIVED:
                break;
            case SERVICE_START:
                break;
            case SERVICE_END:
                break;
            default:
                break;
        }
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
