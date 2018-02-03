# VideoOrientationTransform
视频横竖屏 旋转效果实现demo
在项目过程中,有视频横竖屏切换的逻辑,但是在各种尝试之后,个人感觉,在关闭掉app在当前页面横竖屏支持,处理起来逻辑最简单,但是我们又不能不支持用户自己横竖手机时候的动态支持,所以,我在自己的项目中通过监听设备信息来处理横竖屏逻辑(可以简单的避免有些用户进入到我们支持自动旋转屏幕页面的时候,当时的设备就是横屏的时候的一些问题,我们之间避开了)
个人实现逻辑如下:
1.进入播放器页面 确定当前设备状态及未进行横竖屏时 播放器视图的位置及视图关系
2.用户点击横屏/竖屏,或者用户手动旋转的时候,进行逻辑处理,将播放器从之前的父视图移动到window上,然后将播放器旋转正负90度(左横屏和右横屏,其实此时frame会变,宽高颠倒),然后调整播放器的frame为全屏), 反之,将播放器从window恢复到原父视图(旋转回复到0),然后修改frame即可

具体细节如下:
1.在进入播放器页面的时候,首先获取当前设备的状态,左横屏?右横屏?竖屏?代码如下:
```
//以后还需要监听屏幕旋转 和进入后台等操作
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotateAction:) name:UIDeviceOrientationDidChangeNotification object:nil]; 
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
UIInterfaceOrientation sataus=[UIApplication sharedApplication].statusBarOrientation;
 if (sataus == UIDeviceOrientationLandscapeLeft) {
   self.currentOrientation = UIDeviceOrientationLandscapeLeft;
 }else if (sataus == UIDeviceOrientationLandscapeRight){
  self.currentOrientation = UIDeviceOrientationLandscapeRight;
 }else{
   self.currentOrientation = UIDeviceOrientationPortrait;
 }
```
2.然后构造播放器和视图,效果如图:

![Untitled12.gif](http://upload-images.jianshu.io/upload_images/5505686-9d837ed786cbb9bf.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.然后监听设备状态:
代码如下:
```
//实现监听的通知方法:
- (void)doRotateAction:(NSNotification *)notification {
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
       self.currentOrientation = UIDeviceOrientationPortrait;
        if (isfullScreen) {
            [self changeScreenFullScreen:NO];
        }
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        if (self.currentOrientation == UIDeviceOrientationLandscapeLeft && isfullScreen ) {
            return;
        }
        self.currentOrientation = UIDeviceOrientationLandscapeLeft;
        [self changeScreenFullScreen:YES];
    }else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        if (self.currentOrientation == UIDeviceOrientationLandscapeRight && isfullScreen ) {
            return;
        }
        self.currentOrientation = UIDeviceOrientationLandscapeRight;
        [self changeScreenFullScreen:YES];
    }
}

```
4. 关键的处理横竖屏的代码
```
//是否全屏
- (void)changeScreenFullScreen:(BOOL)fullScreen{
//    if (!self.needDealTransForm) {
//        NSLog(@"当前代码不允许横竖屏 根据个人的逻辑来处理");
//        return;
//    }
    [UIView animateWithDuration:0.3 animations:^{
        if (fullScreen) {
            //是全屏
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            [self removeFromSuperview];
            UIWindow *window = [self mainWindow];
            topView.hidden = NO ;
            [window addSubview:self];
            if (self.currentOrientation == UIDeviceOrientationLandscapeLeft) {
                self.transform  =CGAffineTransformMakeRotation(M_PI_2);
            }else if (self.currentOrientation == UIDeviceOrientationLandscapeRight){
                self.transform  =CGAffineTransformMakeRotation(-M_PI_2);
            }else{
                self.transform  =CGAffineTransformMakeRotation(M_PI_2);
            }
            self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
            bottomView.frame = CGRectMake(0, ScreenWidth-40, ScreenHeight, 40);
            topView.frame = CGRectMake(0, 0, ScreenHeight, 40);
            isfullScreen = YES;
            [changeFullScreenBtn setImage:[UIImage imageNamed:@"ox"] forState:UIControlStateNormal];
            return;
        }else{
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            self.transform  =CGAffineTransformMakeRotation(0);
            self.frame = originFrame;
            bottomView.frame = CGRectMake(0, self.frame.size.height-40, ScreenWidth, 40);
            topView.hidden = YES;
            [self removeFromSuperview];
            [changeFullScreenBtn setImage:[UIImage imageNamed:@"dk"] forState:UIControlStateNormal];
            [_parentView addSubview:self];
            isfullScreen = NO;
        }
    }];
}

```
以上,基本上播放器横竖屏功能已经实现,上面可能会有同学告诉我,为什么我既用frame,还用masonry,其实,我使用frame我没办法,当我使用masonry设置播放器代理里面的bottomeView和topView的时候 ,旋转的时候, 在iOS 11上效果是我们期望的效果,但是在iOS其他版本(个人试了iOS 10 和iOS 8)效果不是我们期望的那样,后来也没想明白,如果有朋友或者同学了解具体原因,可以给我指导一下,谢谢大家!
顺便给大家上个demo:  https://github.com/yangfangkuo/VideoOrientationTransform
