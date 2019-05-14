//
//  CXPlayViewController.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXPlayViewController.h"
#import "CXPlayerManager.h"

@interface CXPlayViewController ()

@property (nonatomic, strong) CXPlayerManager *playerManager;

@end

@implementation CXPlayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *showPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    showPlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:showPlayerView];
    [self.playerManager playWithUrl:@"http://vfx.mtime.cn/Video/2019/05/07/mp4/190507094456874251.mp4" inView:showPlayerView];
    [self.playerManager seekToTimePlay:14];
}

- (CXPlayerManager *)playerManager {
    if (!_playerManager) {
        _playerManager = [[CXPlayerManager alloc] init];
        _playerManager.disMissBlock = self.disMissBlock;
        _playerManager.shareBlock = self.shareBlock;
        _playerManager.playerStatusBlock = self.playerStatusBlock;
    }
    return _playerManager;
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
