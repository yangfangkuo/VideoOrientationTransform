//
//  CustomUseFullMasonryPlayer.m
//  VideoTransformDemo
//
//  Created by Mike on 2018/2/3.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//
#import "CustomUseFullMasonryPlayer.h"
#define ColorWithRGB(r,g,b,p)       [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:p]
#define ScreenWidth                  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight                 [UIScreen mainScreen].bounds.size.height

#import <Masonry/Masonry.h>
@interface CustomUseFullMasonryPlayer ()
{
    UIView   *bottomView;       //底部工具栏
    UIButton *playOrPauseBtn;   //播放或者暂停按钮
    UILabel  *currentTimeLabel; //当前时间进度
    UILabel  *totalTimeLabel;   //总的播放时间
    UIButton *changeFullScreenBtn; //横竖屏切换
    BOOL   isPlaying ;          //是否正在播放
    BOOL   isfullScreen;        //是否当前是全屏
    BOOL   _startSeek;           //是否正在调整进度
    long long   _trackingTouchTS;//调整进度的时候的时间
    float       _sliderValue;      //滑动的值
    BOOL     playFinish;           //是否播放完毕
    CGRect   originFrame;           //在横屏时候的frame
    UIView  *topView;               //横屏时的返回位置
    
}
@property (nonatomic,copy) NSString *currentUrl;
@property (nonatomic,weak) UIView *parentView;
@property (nonatomic,strong) UISlider *speedSlider;
@property (nonatomic,assign) UIDeviceOrientation currentOrientation;
@property (nonatomic,strong) UIView *player;

@end;
@implementation CustomUseFullMasonryPlayer

- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView{
    self = [super initWithFrame:frame];
    if (self) {
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
        _parentView = parentView;
        originFrame = frame;
        self.backgroundColor = [UIColor blackColor];
        self.player = [[UIView alloc]init];
        self.player.backgroundColor = [UIColor greenColor];
        [self addSubview:self.player];
        [self.player  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        
        
        topView =[[UIView alloc]init];
        [self addSubview:topView];
//        topView.frame = CGRectMake(0, 0, ScreenWidth, 40);
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.equalTo(@(40));
        }];
        topView.backgroundColor = ColorWithRGB(51, 51, 51, 0.3);
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [topView  addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(topView);
            make.left.equalTo(topView);
            make.width.equalTo(@(44));
        }];
        [backBtn setImage:[UIImage imageNamed:@"ei"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToSmallScreen) forControlEvents:UIControlEventTouchUpInside];
        
        topView.hidden = YES;
        
        bottomView = [[UIView alloc]init];
        [self addSubview:bottomView];
        bottomView.frame = CGRectMake(0, self.frame.size.height-40, ScreenWidth, 40);
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(40));
        }];
        bottomView.backgroundColor = ColorWithRGB(51, 51, 51, 0.3);
        playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:playOrPauseBtn];
        [playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(0));
            make.top.bottom.equalTo(bottomView);
            make.width.equalTo(@(44));
        }];
        [playOrPauseBtn setImage:[UIImage imageNamed:@"hw"] forState:UIControlStateNormal];
        [playOrPauseBtn addTarget:self action:@selector(playOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        changeFullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bottomView addSubview:changeFullScreenBtn];
        [changeFullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(0));
            make.top.bottom.equalTo(bottomView);
            make.width.equalTo(@(44));
        }];
        [changeFullScreenBtn setImage:[UIImage imageNamed:@"dk"] forState:UIControlStateNormal];
        [changeFullScreenBtn addTarget:self action:@selector(playFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        //总的时间
        totalTimeLabel = [[UILabel alloc]init];
        [bottomView addSubview:totalTimeLabel];
        [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(changeFullScreenBtn.mas_left).offset(0);
            make.height.bottom.equalTo(bottomView);
        }];
        totalTimeLabel.textColor = [UIColor whiteColor];
        totalTimeLabel.text = @"/00:00:00";
        totalTimeLabel.font = [UIFont systemFontOfSize:13];
        
        currentTimeLabel = [[UILabel alloc]init];
        [bottomView addSubview:currentTimeLabel];
        [currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(totalTimeLabel.mas_left);
            make.height.bottom.equalTo(bottomView);
        }];
        currentTimeLabel.textColor = [UIColor orangeColor];
        currentTimeLabel.text = @"00:00:00";
        currentTimeLabel.font = [UIFont systemFontOfSize:13];
        
        self.speedSlider    = [[UISlider alloc] initWithFrame:CGRectZero];
        self.speedSlider.minimumValue = 0;// 设置最小值
        self.speedSlider.value = 0;// 设置初始值
        self.speedSlider.minimumTrackTintColor = [UIColor orangeColor];
        self.speedSlider.maximumTrackTintColor = [UIColor lightGrayColor];
        [self.speedSlider setThumbImage:[UIImage imageNamed:@"lyx"] forState:UIControlStateNormal];
        [self.speedSlider addTarget:self action:@selector(onSeek:) forControlEvents:(UIControlEventValueChanged)];
        [self.speedSlider addTarget:self action:@selector(onSeekBegin:) forControlEvents:(UIControlEventTouchDown)];
        [self.speedSlider addTarget:self action:@selector(onDrag:) forControlEvents:UIControlEventTouchDragInside];
        [bottomView addSubview:self.speedSlider];
        [self.speedSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(playOrPauseBtn.mas_right).offset(0);
            make.right.equalTo(currentTimeLabel.mas_left).offset(-10);
            make.centerY.equalTo(bottomView);
            make.height.equalTo(@(25));
        }];
        _trackingTouchTS = 0;
        isfullScreen = NO;
    }
    return self;
}
- (void)playWithUrl:(NSString *)url{
    
    [playOrPauseBtn setImage:[UIImage imageNamed:@"ig"] forState:UIControlStateNormal];
    isPlaying = YES;
    playFinish = NO;
}
#pragma mark  TXVodPlayListener代理

//播放或者暂停
- (void)playOrPauseBtn:(UIButton *)btn{
    if (!_currentUrl) {
        return;
    }
    if (isPlaying) {
        [playOrPauseBtn setImage:[UIImage imageNamed:@"hw"] forState:UIControlStateNormal];
        //        [self.player pause];
        isPlaying = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        return;
    }
    if (!isPlaying) {
        if (playFinish) {
            [self playWithUrl:_currentUrl];
            return;
        }
        [playOrPauseBtn setImage:[UIImage imageNamed:@"ig"] forState:UIControlStateNormal];
        //        [self.player resume];
        isPlaying = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        return;
    }
    
}
- (void)backToSmallScreen{
    [self changeScreenFullScreen:NO];
}
//全屏或者小屏播放
- (void)playFullScreen:(UIButton *)btn{
    NSLog(@"当前是否全屏 %d",isfullScreen);
    [self changeScreenFullScreen:!isfullScreen];
}
//调整播放进度
#pragma -- UISlider - play seek
-(void)onSeek:(UISlider *)slider{
    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(goRealValue:) object:slider];
    [self performSelector:@selector(goRealValue:) withObject:slider afterDelay:0.3];
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
    NSLog(@"vod seek drag end %f",_sliderValue);
}
- (void)goRealValue:(UISlider *)slider{
    //    [self.player seek:_sliderValue];
}

-(void)onSeekBegin:(UISlider *)slider{
    _startSeek = YES;
    NSLog(@"vod seek drag begin");
}
-(void)onDrag:(UISlider *)slider {
    NSLog(@"进度正在滑动 %f",slider.value);
    float progress = slider.value;
    int intProgress = progress + 0.5;
    currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)(intProgress /3600), (int)((intProgress%3600)/60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}
//是否全屏
- (void)changeScreenFullScreen:(BOOL)fullScreen{
    //    if (!self.needDealTransForm) {
    //        NSLog(@"当前代码不允许横竖屏");
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
            isfullScreen = YES;
            [changeFullScreenBtn setImage:[UIImage imageNamed:@"ox"] forState:UIControlStateNormal];
            return;
        }else{
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            self.transform  =CGAffineTransformMakeRotation(0);
            self.frame = originFrame;
            topView.hidden = YES;
            [self removeFromSuperview];
            [changeFullScreenBtn setImage:[UIImage imageNamed:@"dk"] forState:UIControlStateNormal];
            [_parentView addSubview:self];
            isfullScreen = NO;
        }
    }];
}
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

- (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
}
- (void)onAppDidEnterBackGround:(UIApplication*)app {
    if (isPlaying) {
        [self playOrPauseBtn:nil];
    }
}
- (void)pause{
    if (isPlaying) {
        [self playOrPauseBtn:nil];
    }
}
- (void)stopPlay{
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

@end
