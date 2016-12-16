# SureSlider
最近更新项目需求，要求封装一份类似于iPhone解锁效果切换状态的视图。所以简述下自定义控件的封装流程，本文章适用于代码封装度较低的朋友们，提供一些封装思路，希望抛砖引玉。大牛们可忽略。

效果如图所示
![service_1.png](http://upload-images.jianshu.io/upload_images/1767950-b721ade616d0c60b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![service_2.png](http://upload-images.jianshu.io/upload_images/1767950-0418a1a8c055bfb1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先对于自定义视图的封装，该自定义类最好继承于UIView，这样可以便于后续的更改。且尽量避免与工程中其他类的耦合性，保证通用。

接下来需要考虑的问题就是属性及方法的问题，以及.h、.m文件所属。简单来说就是你希望调用了你的类的程序员可以调用哪些属性或方法，就将该属性或方法声明在.h中。

对需求效果进行分析，主题效果大体分为两个控件，一为实现主体效果的UIScrollView，二为小型弹出视图，在点击时触发显示。

为了便于对视图的效果进行更改，因此可以将UIScrollView与弹出视图在.h中公开，若希望外界也可控制弹出视图显隐擦性，也可将其显示状态属性外漏。
代码如下所示：
```
@interface ServiceSlider : UIView
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
```
接下来考虑服务流程，项目需求为滑动切换订单状态。因此可将订单状态声明为枚举，这么做的好处就是，其他人阅读你的代码时会更易懂。
对于枚举，尽量不要使用typedef enum，毕竟是在书写Objective-C代码嘛。
```
typedef NS_ENUM(NSInteger, SERVICE_STATE) {
    SERVICE_READY,
    SERVICE_ARRIVED,
    SERVICE_START,
    SERVICE_END
};
```
接下来就是服务状态与控件的联动问题了，即滑动触发订单状态变化，或订单状态改变触发控件显示效果。这里选择使用Block回传订单状态，若订单相关已封装好对应服务类，Block传空亦可。
```
/**
 *  触发订单状态改变
 */
@property (nonatomic, copy) void(^serviceStateChange)(SERVICE_STATE);
/**
 *  根据订单状态显示对应滑块状态
 */
- (void)sliderStateForType:(SERVICE_STATE)state;
```
进入到.m文件中，进行对应控件的初始化即可。这里使用懒加载进行初始化，比较基础就不详述了。
```
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
```
这段代码中不常使用到的可能就是stretchableImageWithLeftCapWidth topCapHeight的这个方法。因为设计人员提供的素材为下图。
![bubble_pop@2x.png](http://upload-images.jianshu.io/upload_images/1767950-a96aeb42c115f926.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
而为了适配于各种屏幕需要进行拉伸操作，为防止图片拉伸变形可使用如上方法，分别拉取横向与纵向的一个像素对图片进行拉伸而不影响原显示效果。对于像素点选取尽量选择平滑的位置。进行拉伸后即可显示为如下效果而不失真。
![bubble.png](http://upload-images.jianshu.io/upload_images/1767950-e53d6c24e3a95e1f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
显而易见，对于聊天界面的气泡效果就是通过该方法实现。

最后，在ScrollView的代理方法中实现对应操作即可。因篇幅原因，这里只摘取具体代码。
```
#pragma mark 滚动视图代理处理事件
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissAlert];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
        _isShow = NO;
        if (self.serviceStateChange) {
            self.serviceStateChange();//该位置可进行订单状态判断。
        }
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
```
补充一个视图显示效果
这里需要实现类似于iPhone滑动解锁的效果，使用了FaceBook所提供的一个类，叫做Shimmer。很好的一个效果，推荐给大家，效果如图：
![4196_140818143415_1.gif](http://upload-images.jianshu.io/upload_images/1767950-bf61d8eec3d03482.gif?imageMogr2/auto-orient/strip)
先写到这里，后续有补充会再添加。

######demo下载链接
[自定义控件封装思路demo](https://github.com/LSure/SureSlider)
