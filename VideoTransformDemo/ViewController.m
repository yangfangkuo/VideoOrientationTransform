//
//  ViewController.m
//  VideoTransformDemo
//
//  Created by Mike on 2018/2/3.
//  Copyright © 2018年 Quarkdata. All rights reserved.
//

#import "ViewController.h"
#import "CustomVodPlayer.h"
@interface ViewController ()
@property (nonatomic,strong) CustomVodPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.player = [[CustomVodPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) parentView:self.view];
    [self.view addSubview:self.player];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
