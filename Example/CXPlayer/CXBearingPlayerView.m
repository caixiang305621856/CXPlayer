//
//  CXBearingPlayerView.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXBearingPlayerView.h"
#import "UIImage+Extension.h"
#import "CXSlider.h"
#import <MediaPlayer/MediaPlayer.h>

const CGFloat CXBearingPlayerViewTopHeight = 40;
const CGFloat CXBearingPlayerViewBottomHeight = 40;
const CGFloat CXBearingPlayerViewBtnW = 40;
const CGFloat CXBearingPlayerViewBtnH = 40;
const CGFloat CXBearingPlayerViewlabelW = 50;

@interface CXBearingPlayerView()<UIGestureRecognizerDelegate>
{
    CGRect _frame;
    BOOL   _isShowControl;//控制界面是否显示 YES:显示  NO:隐藏
    CGPoint _startPoint;    //手势滑动的起始点
    CGPoint _lastPoint;     //记录上次滑动的点
    BOOL    _isStartPan;    //记录手势开始滑动
    CGFloat _fastCurrentTime;//记录当前快进快退的时间
    BOOL _isFullScreen;
}

@property (nonatomic, assign)BOOL sliderIsTouching;//slider是否正在滑动;
@property (nonatomic, strong) UIView *fullScreenView;//全屏的一个视图
@property (nonatomic, strong) UILabel *fastTimeLabel;//全屏显示快进快退时的时间进度
@property (nonatomic, strong) UIActivityIndicatorView *activityView;  //菊花
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;     //滑动手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;     //单击手势

@property (nonatomic, strong) UIView   *topView;
@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UIButton *playButton;   //播放/暂停
@property (nonatomic, strong) UILabel  *currentLabel; //当前播放时间
@property (nonatomic, strong) CXSlider *videoSlider;  //滑动条
@property (nonatomic, strong) UILabel  *totalLabel;   //视频总时间
@property (nonatomic, strong) UIButton *fullScreenButton;//全屏按钮

@property (nonatomic, strong) MPVolumeView *volumeView;  //系统音量控件
@property (strong, nonatomic) UISlider* volumeViewSlider;//控制音量
@property (nonatomic, strong) NSTimer *hideControlTimer;//隐藏控制view的定时器


@end

@implementation CXBearingPlayerView

- (void)dealloc {
    NSLog(@"🔥CXBearingPlayerView销毁了🔥");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _frame = frame;
        if (CGRectEqualToRect(frame, [UIScreen mainScreen].bounds)) {
            _isFullScreen = YES;
        }
        self.layer.masksToBounds = YES;
        [self creatUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    self.volumeView.frame = self.bounds;
    self.fullScreenView.frame = self.bounds;
    self.fastTimeLabel.frame = self.bounds;
    self.activityView.frame = self.bounds;
    
    CGFloat left = _isFullScreen?play_viewSafeArea(self.superview).left > 0?play_viewSafeArea(self.superview).left - 15:0:0;
    CGFloat right = _isFullScreen?play_viewSafeArea(self.superview).right> 0?play_viewSafeArea(self.superview).right - 15:0:0;
    CGFloat top = 0;
    CGFloat bottom = 0;
    if (_isFullScreen) {
        if (play_viewSafeArea(self.superview).top == 0 && play_viewSafeArea(self.superview).bottom > 0) {
            //横屏
            top = 10;
            bottom = play_viewSafeArea(self.superview).bottom - 10;
        } else if(play_viewSafeArea(self.superview).top > 0 &&play_viewSafeArea(self.superview).bottom > 0) {
            //竖屏
            top = play_viewSafeArea(self.superview).top;
            bottom = play_viewSafeArea(self.superview).bottom;
        }
    } else{
        top = 0;
        bottom = 0;
    }
    
    CGFloat topViewH = _isFullScreen?CXBearingPlayerViewTopHeight + top:CXBearingPlayerViewTopHeight;
    CGFloat bottomViewH = _isFullScreen?CXBearingPlayerViewTopHeight + bottom:CXBearingPlayerViewBottomHeight;
    
    //顶部
    self.topView.frame = CGRectMake(0, 0, _frame.size.width, topViewH);
    self.backButton.frame = CGRectMake(left, top, CXBearingPlayerViewBtnW, CXBearingPlayerViewBtnH);
    
    //低部
    self.bottomView.frame = CGRectMake(0, _frame.size.height - CXBearingPlayerViewBottomHeight - bottom, _frame.size.width, bottomViewH);
    self.playButton.frame = CGRectMake(left, 0, CXBearingPlayerViewBtnW, CXBearingPlayerViewBtnH);
    self.currentLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), 0, CXBearingPlayerViewlabelW, CXBearingPlayerViewBottomHeight);
    self.fullScreenButton.frame = CGRectMake(_frame.size.width - CXBearingPlayerViewBtnW - right, 0, CXBearingPlayerViewBtnW, CXBearingPlayerViewBtnH);
    self.totalLabel.frame = CGRectMake(_frame.size.width - CXBearingPlayerViewlabelW - CXBearingPlayerViewBtnW - 10 - right, 0, CXBearingPlayerViewlabelW, CXBearingPlayerViewBottomHeight);
    self.videoSlider.frame = CGRectMake(CGRectGetMaxX(self.currentLabel.frame) + 5, 0, _frame.size.width - CGRectGetMaxX(self.currentLabel.frame) - self.totalLabel.frame.size.width - self.fullScreenButton.frame.size.width - 10 - 5 - right , CXBearingPlayerViewBottomHeight);
}

- (void)creatUI{
    _isShowControl = YES;
    self.backgroundColor = [UIColor blackColor];
    //手势
    [self.fullScreenView addGestureRecognizer:self.tapGesture];
    [self.fullScreenView addGestureRecognizer:self.panGesture];
}

#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.fullScreenView]) {
        return YES;
    }
    return NO;
}

#pragma mark - private
//转换时间格式
- (NSString *)timeFormatted:(NSInteger)totalSeconds {
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",minutes, seconds];
}

- (void)showOrHideControlView{
    CGFloat alpha = 0;
    if (_isShowControl) {
        alpha = 1;
    }
    if (self.fullScreenButton.selected) {//全屏
        self.panGesture.enabled = YES;
    }else{
        if (_halfScreenPanGestureEnabled) {
            self.panGesture.enabled = _isShowControl;
        }
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.topView.alpha = alpha;
        self.bottomView.alpha = alpha;
    } completion:^(BOOL finished) {
        if (_isShowControl) {//如果当前是显示状态，就要去倒计时隐藏了
            [self startHideControlTimer];
        }
    }];
}

- (void)startHideControlTimer{
    //销毁定时器
    [_hideControlTimer invalidate];
    _hideControlTimer = nil;
    //创建定时器
    _hideControlTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(timerToJudgeHide) userInfo:nil repeats:NO];
}

//定时隐藏掉控制界面
- (void)timerToJudgeHide{
    if (_playButton.selected == YES) {//暂停中，不隐藏
        return;
    }
    if (!_isShowControl) {//已经是隐藏状态了
        return;
    }
    //隐藏
    _isShowControl = NO;
    [self showOrHideControlView];
}

#pragma mark - Event
- (void)tapGestureTouch:(UITapGestureRecognizer *)tapGesture{
    _isShowControl = !_isShowControl;
    [self showOrHideControlView];
}

- (void)panGestureTouch:(UIPanGestureRecognizer *)panGestureTouch{
    CGPoint touPoint = [panGestureTouch translationInView:self];
    static int changeXorY = 0;    //0:X:进度   1:Y：音量
    
    if (panGestureTouch.state == UIGestureRecognizerStateBegan) {
        _startPoint = touPoint;
        _lastPoint = touPoint;
        _isStartPan = YES;
        _fastCurrentTime = self.currentTime;
        changeXorY = 0;
    }else if (panGestureTouch.state == UIGestureRecognizerStateChanged){
        CGFloat change_X = touPoint.x - _startPoint.x;
        CGFloat change_Y = touPoint.y - _startPoint.y;
        if (_isStartPan) {
            if (fabs(change_X) > fabs(change_Y)) {
                changeXorY = 0;
            }else{
                changeXorY = 1;
            }
            _isStartPan = NO;
        }
        if (changeXorY == 0) {//进度
            /*
            self.fastTimeLabel.hidden = NO;
            
            if (touPoint.x - _lastPoint.x >= 1) {
                _lastPoint = touPoint;
                _fastCurrentTime += 2;
                if (_fastCurrentTime > self.totalTime) {
                    _fastCurrentTime = self.totalTime;
                }
            }
            if (touPoint.x - _lastPoint.x <= - 1) {
                _lastPoint = touPoint;
                _fastCurrentTime -= 2;
                if (_fastCurrentTime < 0) {
                    _fastCurrentTime = 0;
                }
            }
            
            NSString *currentTimeString = [self timeFormatted:(int)_fastCurrentTime];
            NSString *totalTimeString = [self timeFormatted:(int)self.totalTime];
            self.fastTimeLabel.text = [NSString stringWithFormat:@"%@/%@",currentTimeString,totalTimeString];
            self.videoSlider.value = _fastCurrentTime/self.totalTime*1.0f;
             */
        }else{//音量
            if (touPoint.y - _lastPoint.y >= 5) {
                _lastPoint = touPoint;
                self.volumeViewSlider.value -= 0.07;
            }
            if (touPoint.y - _lastPoint.y <= - 5) {
                _lastPoint = touPoint;
                self.volumeViewSlider.value += 0.07;
            }
        }
        
    }else if (panGestureTouch.state == UIGestureRecognizerStateEnded){
        self.fastTimeLabel.hidden = YES;
         if (changeXorY == 0) {
             /*
             if (_delegate && [_delegate respondsToSelector:@selector(seekToTime:bearingPlayerView:)]) {
                 [_delegate seekToTime:_fastCurrentTime bearingPlayerView:self];
             }
              */
         }
        [self startHideControlTimer];
    }
}

- (void)backButtonClick:(UIButton *)sender{
    [self startHideControlTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(backClick:)]) {
        [_delegate backClick:self];
    }
}

- (void)fullScreenButtonClick:(UIButton *)sender{
    [self startHideControlTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(fullScreenBtnClick:)]) {
        [_delegate fullScreenBtnClick:self];
    }
}

- (void)playButtonClick:(UIButton *)sender{
    [self startHideControlTimer];
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlay:didPlayBtnIsPause:)]) {
        [_delegate videoPlay:self didPlayBtnIsPause:!sender.selected];
    }
}

- (void)sliderValueChange:(CXSlider *)slider{
    _sliderIsTouching = YES;
    self.currentLabel.text = [self timeFormatted:slider.value * self.totalTime];
    [self startHideControlTimer];
}

- (void)sliderTouchEnd:(CXSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(seekToTime:bearingPlayerView:)]) {
        [_delegate seekToTime:slider.value *self.totalTime bearingPlayerView:self];
    }
    _sliderIsTouching = NO;
    [self startHideControlTimer];
}

#pragma mark - public
- (void)play {
    self.playButton.selected = NO;
    [self startHideControlTimer];
}

- (void)pause {
    self.playButton.selected = YES;
    //暂停时显示控制面板
    _isShowControl = YES;
    [self showOrHideControlView];
}

//横竖屏转换
- (void)fullScreenChanged:(BOOL)isFullScreen frame:(CGRect)frame{
    self.frame = frame;
    _frame = frame;
    [self creatUI];
    _isFullScreen = isFullScreen;
    if (CGRectEqualToRect(frame, [UIScreen mainScreen].bounds)) {
        _isFullScreen = YES;
    }
    self.fullScreenButton.selected = isFullScreen;
    [self.videoSlider fullScreenChanged:isFullScreen];
}

#pragma mark - set&get
-(UIView *)fullScreenView {
    if (!_fullScreenView) {
        _fullScreenView = [[UIView alloc] init];
        [self addSubview:_fullScreenView];
    }
    return _fullScreenView;
}

- (UILabel *)fastTimeLabel{
    if (!_fastTimeLabel) {
        _fastTimeLabel = [[UILabel alloc] init];
        _fastTimeLabel.textColor = [UIColor whiteColor];
        _fastTimeLabel.font = [UIFont systemFontOfSize:26];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.hidden = YES;
        [self.fullScreenView addSubview:_fastTimeLabel];
    }
    return _fastTimeLabel;
}

- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.hidesWhenStopped = YES;
        [self.fullScreenView addSubview:_activityView];
        [_activityView startAnimating];
    }
    return _activityView;
}

- (UITapGestureRecognizer *)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureTouch:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureTouch:)];
    }
    return _panGesture;
}

- (UIView *)topView{
    if (!_topView) {
        //改渐变view
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:_topView];
    }
    return _topView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:_backButton];
    }
    return _backButton;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        //改渐变view
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_playButton];
    }
    return _playButton;
}

- (UILabel *)currentLabel{
    if (!_currentLabel) {
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.text = @"00:00";
        _currentLabel.textColor = [UIColor whiteColor];
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        _currentLabel.font = [UIFont systemFontOfSize:14];
        [self.bottomView addSubview:_currentLabel];
    }
    return _currentLabel;
}

- (UILabel *)totalLabel{
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.text = @"00:00";
        _totalLabel.textColor = [UIColor whiteColor];
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        _totalLabel.font = [UIFont systemFontOfSize:14];
        [self.bottomView addSubview:_totalLabel];
    }
    return _totalLabel;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"normal_screen"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:_fullScreenButton];
    }
    return _fullScreenButton;
}

-(CXSlider *)videoSlider {
    if (!_videoSlider) {
        _videoSlider = [[CXSlider alloc] init];

        UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        highlightView.layer.cornerRadius = 8;
        highlightView.backgroundColor = [UIColor whiteColor];
        UIImage *highlightImage = [UIImage creatImageWithView:highlightView];

        [_videoSlider setThumbImage:highlightImage forState:UIControlStateNormal];
        [_videoSlider setThumbImage:highlightImage forState:UIControlStateHighlighted];
        
        _videoSlider.trackHeight = 1.5;
        _videoSlider.thumbVisibleSize = 12;//设置滑块（可见的）大小
        [_videoSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];//正在拖动
        [_videoSlider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventEditingDidEnd];//拖动结束
        [self.bottomView addSubview:_videoSlider];
    }
    return _videoSlider;
}

- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

- (void)setCurrentTime:(NSInteger)currentTime {
    _currentTime = currentTime;
    if (_sliderIsTouching == NO) {
        self.currentLabel.text = [self timeFormatted:currentTime];
    }
}

- (void)setTotalTime:(NSInteger)totalTime {
    _totalTime = totalTime;
    self.totalLabel.text = [self timeFormatted:totalTime];
}

- (void)setPlayValue:(CGFloat)playValue{
    _playValue = playValue;
    if (_sliderIsTouching == NO) {
        self.videoSlider.value = playValue;
    }
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    self.videoSlider.bufferProgress = progress;
}

//纯UI操作不做任何播放事件处理
- (void)setPlayerStatus:(CXAVPlayerStatus)playerStatus {
    _playerStatus = playerStatus;
    switch (playerStatus) {
        case CXAVPlayerStatusLoadingVideo:
            [self.activityView startAnimating];
            break;
        case CXAVPlayerStatusReadyToPlay:
            break;
        case CXAVPlayerStatusPlay:
            [self.activityView stopAnimating];
            [self startHideControlTimer];
            break;
        case CXAVPlayerStatusPlayEnd:
            [self.activityView stopAnimating];
            [self pause];
            break;
        case CXAVPlayerStatusCacheData:
            [self.activityView startAnimating];
            break;
        case CXAVPlayerStatusCacheEnd:
            [self.activityView stopAnimating];
            [self startHideControlTimer];
            break;
        case CXAVPlayerStatusItemFailed:
            [self.activityView stopAnimating];
            break;
        case CXAVPlayerStatusEnterBack:
            break;
        case CXAVPlayerStatusBecomeActive:
            break;
    }
}

@end
