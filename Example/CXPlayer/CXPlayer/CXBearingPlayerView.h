//
//  CXBearingPlayerView.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXPlayerView.h"

@class CXBearingPlayerView;
@protocol CXBearingPlayerViewDelegate <NSObject>
@optional
/**
 返回按钮被点击
 */
- (void)backClick:(CXBearingPlayerView *)bearingPlayerView;
/**
 分享按钮被点击
 */
- (void)shareClick:(CXBearingPlayerView *)bearingPlayerView;
/**
 全屏按钮被点击
 */
- (void)fullScreenBtnClick:(CXBearingPlayerView *)bearingPlayerView;
/**
 按钮点击

 @param bearingPlayerView self
 @param isPause 暂停/播放
 */
- (void)videoPlay:(CXBearingPlayerView*)bearingPlayerView didPlayBtnIsPause:(BOOL)isPause;
/**
 滑动到指定位置播放视频

 @param time 指定时长位置
 @param bearingPlayerView self
 */
- (void)seekToTime:(CGFloat)time bearingPlayerView:(CXBearingPlayerView *)bearingPlayerView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CXBearingPlayerView : UIView

@property (nonatomic, assign,readonly)BOOL sliderIsTouching;
/**
 当前播放时间
 */
@property (nonatomic, assign) NSInteger  currentTime;

/**
 总时间
 */
@property (nonatomic, assign) NSInteger  totalTime;

/**
 播放进度
 */
@property (nonatomic, assign) CGFloat  playValue;

/**
 缓冲进度
 */
@property (nonatomic, assign) CGFloat  progress;

/**
 半屏播放时，滑动手势在当前view(控制面板)唤起时是否可用
 */
@property (nonatomic, assign) BOOL halfScreenPanGestureEnabled;

@property (nonatomic, weak) id <CXBearingPlayerViewDelegate> delegate;

@property (nonatomic, assign) CXAVPlayerStatus playerStatus;

- (void)play;

- (void)pause;

- (void)fullScreenChanged:(BOOL)isFullScreen frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
