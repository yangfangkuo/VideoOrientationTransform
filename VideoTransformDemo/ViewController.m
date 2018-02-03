//
//  ViewController.m
//  VideoTransformDemo
//
//  Created by Mike on 2018/2/3.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//

#import "ViewController.h"
#import "CustomVodPlayer.h"
#import "CustomUseFullMasonryPlayer.h"
@interface ViewController ()
@property (nonatomic,strong) CustomVodPlayer *player;
@property (nonatomic,strong) CustomUseFullMasonryPlayer *hadErrorPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.player = [[CustomVodPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) parentView:self.view];
    [self.view addSubview:self.player];
    
    
    
    //下面的这个播放器 逻辑和上面的完全一致 只是bottomView和topView使用了masonry做约束,在iOS 11上效果正常,其他系统下 效果异常,希望有解决或者了解原因的告诉我一下  谢谢 放开代码 注释上面的就可以
//    self.hadErrorPlayer = [[CustomUseFullMasonryPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) parentView:self.view];
//    [self.view addSubview:self.hadErrorPlayer];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
