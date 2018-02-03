//
//  CustomPlayer.h
//  ChinaSportDance
//
//  Created by Mike on 2018/1/22.
//  Copyright © 2018年 SECO. All rights reserved.
//

#import <UIKit/UIKit.h>

;

@interface CustomVodPlayer : UIView

- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView;

@property (nonatomic,assign) BOOL needDealTransForm;

//播放或者暂停
- (void)playWithUrl:(NSString  *)url;
//切换到横屏或者竖屏
- (void)changeScreenFullScreen:(BOOL)fullScreen;

- (void)pause;

- (void)stopPlay;

@end
