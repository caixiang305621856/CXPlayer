//
//  CXPlayerManager.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXPlayerManager.h"

@interface CXPlayerManager ()<CXVideoPlayerDelegate,CXBearingPlayerViewDelegate>
{
    NSTimeInterval _seekToTime;
    //手动暂停
    BOOL _isManualpPause;
}

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) CGRect originFrame;
/**
 播放器view
 */
@property (nonatomic,strong)CXPlayerView *playerView;
/**
 承载视频播放界面的View
 */
@property (nonatomic, strong) CXBearingPlayerView *bearingPlayerView;
/**
 是否是全屏
 */
@property (nonatomic, assign) BOOL isFullScreen;

@end

@implementation CXPlayerManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

#pragma mark - public
- (void)playWithUrl:(NSString *)url inView:(UIView *)view loc:(BOOL)loc{
    if (view) {
        self.backgroundView = view;
        self.originFrame = view.frame;
        [self bearingPlayerView];
        if (loc) {
            [self.playerView setUrl:[NSURL fileURLWithPath:url]];
        } else{
            [self.playerView setUrl:[NSURL URLWithString:url]];
        }
        [self.playerView play];
    }
}

- (void)play {
    [self.playerView play];
    [self.bearingPlayerView play];
    !self.playOrPauseBlock?:self.playOrPauseBlock(YES);
}

- (void)pause {
    [self.playerView pause];
    [self.bearingPlayerView pause];
    !self.playOrPauseBlock?:self.playOrPauseBlock(NO);
}

- (void)stop {
    [self.playerView stop];
}

- (void)seekToTimePlay:(CGFloat)toTime {
    _seekToTime = toTime;
}

#pragma mark - NSNotification
//横竖屏切换
- (void)changeRotate:(NSNotification*)noti {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        _isFullScreen = NO;
    } else {
        //横屏
        _isFullScreen = YES;
    }
    [self autoSetDeviceRotate:[[UIDevice currentDevice] orientation]];
}

#pragma mark - CXVideoPlayerDelegate
- (void)promptPlayerStatusOrError:(CXAVPlayerStatus)status PlayVideo:(CXPlayerView *)playerView {
    self.bearingPlayerView.playerStatus = status;
    !self.playerStatusBlock?:self.playerStatusBlock(status);
    switch (status) {
        case CXAVPlayerStatusLoadingVideo:
            //            NSLog(@"开始准备");
            //菊花
            break;
        case CXAVPlayerStatusReadyToPlay:
            //            NSLog(@"准备完成");
            if (_seekToTime > 0) {
                [self.playerView seekToTime:_seekToTime];
                _seekToTime = 0;
            }
            break;
        case CXAVPlayerStatusPlay:
            //            NSLog(@"正在播放");
            //隐藏菊花
            break;
        case CXAVPlayerStatusPlayEnd:
            //            NSLog(@"播放完成");
            //隐藏菊花
            //回归初始状态 或 循环播放
            break;
        case CXAVPlayerStatusCacheData:
            //            NSLog(@"缓冲视频");
            //菊花
            break;
        case CXAVPlayerStatusCacheEnd:
            //            NSLog(@"缓冲完成");
            break;
        case CXAVPlayerStatusItemFailed:
            //隐藏菊花
            //报错页面
            //            NSLog(@"视频资源问题");
            break;
        case CXAVPlayerStatusEnterBack:
            //            NSLog(@"进入后台");
            break;
        case CXAVPlayerStatusResignActive:
            //            NSLog(@"即将进入后台");
            if (!_isManualpPause) {
                [self pause];
            }
            break;
        case CXAVPlayerStatusBecomeActive:
            //            NSLog(@"进入前台");
            if (!_isManualpPause) {
                [self play];
            }
            break;
    }
}

- (void)refreshData:(NSTimeInterval)totalTime
           progress:(NSTimeInterval)currentTime
          loadRange:(NSTimeInterval)loadTime
{
    if(!self.bearingPlayerView.sliderIsTouching){
        if (totalTime > 0) {
            self.bearingPlayerView.currentTime = currentTime;
            self.bearingPlayerView.totalTime = totalTime;
            self.bearingPlayerView.playValue =currentTime/totalTime;
        }
    }
}

- (void)videoPlayer:(CXPlayerView *)playerView loadedTimeRangeDidChange:(CGFloat )progress {
    self.bearingPlayerView.progress = progress;
}

#pragma mark - CXBearingPlayerViewDelegate
- (void)backClick:(CXBearingPlayerView *)bearingPlayerView {
    //全屏状态下，点击返回按钮，是置为竖屏
    if (_isFullScreen) {
        _isFullScreen = !_isFullScreen;
        [self setDeviceRotate];
    }else{//竖屏状态下，点击返回按钮
        [self.playerView stop];
        !self.disMissBlock?:self.disMissBlock();
    }
}

- (void)shareClick:(CXBearingPlayerView *)bearingPlayerView {
    !self.shareBlock?:self.shareBlock();
}

- (void)fullScreenBtnClick:(CXBearingPlayerView *)bearingPlayerView {
    _isFullScreen = !_isFullScreen;
    [self setDeviceRotate];
}

- (void)videoPlay:(CXBearingPlayerView*)bearingPlayerView didPlayBtnIsPause:(BOOL)isPause {
    //手动点击
    if (isPause) {
        _isManualpPause = YES;
        [self pause];
    }else{
        _isManualpPause = NO;
        [self play];
    }
}

- (void)seekToTime:(CGFloat)time bearingPlayerView:(CXBearingPlayerView *)bearingPlayerView {
    [self.playerView seekToTime:time];
    [self play];
}

#pragma mark - private
- (void)setDeviceRotate{
    UIDeviceOrientation orientation;
    if (_isFullScreen) {
        orientation = UIDeviceOrientationLandscapeLeft;
    }else{
        orientation = UIDeviceOrientationPortrait;
    }
    [UIView animateWithDuration:0.25 animations:^{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        [self setSubViewFrames];
    }];
}

- (void)setSubViewFrames{
    CGRect frame;
    if (_isFullScreen) {
        frame = [UIScreen mainScreen].bounds;
    }else{
        frame = _originFrame;
    }
    self.backgroundView.frame = frame;
    [self.bearingPlayerView fullScreenChanged:_isFullScreen frame:self.backgroundView.bounds];
    
    //全屏横屏模式适配iPhonex系列
    BOOL deviceOrientationLandscape = ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft);
    
    if (CGRectEqualToRect(self.bearingPlayerView.bounds, [UIScreen mainScreen].bounds) &&deviceOrientationLandscape) {
        self.playerView.frame = CGRectMake(play_viewSafeArea(self.bearingPlayerView).left, 0, self.bearingPlayerView.bounds.size.width - play_viewSafeArea(self.bearingPlayerView).left - play_viewSafeArea(self.bearingPlayerView).right, self.bearingPlayerView.bounds.size.height);
    } else {
        self.playerView.frame = self.backgroundView.bounds;
    }
}

//自动横竖屏切换
- (void)autoSetDeviceRotate:(UIDeviceOrientation)orientation{
    [UIView animateWithDuration:0.25 animations:^{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        [self setSubViewFrames];
    }];
}

- (CXPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[CXPlayerView alloc] initWithFrame:self.bearingPlayerView.bounds];
        _playerView.delegate = self;
        [self.bearingPlayerView insertSubview:_playerView atIndex:0];
    }
    return _playerView;
}

- (CXBearingPlayerView *)bearingPlayerView {
    if (!_bearingPlayerView) {
        _bearingPlayerView = [[CXBearingPlayerView alloc] initWithFrame:self.backgroundView.bounds];
        _bearingPlayerView.delegate = self;
        [self.backgroundView addSubview:_bearingPlayerView];
    }
    return _bearingPlayerView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView  alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _backgroundView;
}

#pragma mark - set&get
- (void)setTitle:(NSString *)title {
    _title = title;
    self.bearingPlayerView.title = title;
}

@end
