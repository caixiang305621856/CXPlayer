//
//  CXPlayViewController.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXPlayViewController.h"
#import "CXPlayerManager.h"
#import "CXSlider.h"

@interface CXPlayViewController ()

@property (nonatomic ,strong) UIView *videoPlayBGView;
@property (nonatomic, strong) CXPlayerManager *playerManager;

@end

@implementation CXPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.videoPlayBGView = [[UIView alloc] initWithFrame:CGRectMake(0, play_viewSafeArea(self.view).top, self.view.frame.size.width, self.view.frame.size.width * 9/16.0f)];
        self.videoPlayBGView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.videoPlayBGView];
        
        _playerManager = [[CXPlayerManager alloc] init];
        _playerManager.disMissBlcok = self.disMissBlcok;
        [_playerManager seekToTimePlay:13];
        [_playerManager playWithUrl:@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4" inView:self.videoPlayBGView];
    });
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
