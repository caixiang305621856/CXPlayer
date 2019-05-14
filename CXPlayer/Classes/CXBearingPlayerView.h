//
//  CXBearingPlayerView.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXPlayer.h"


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

/**
 是否支持分享
 */
@property (assign, nonatomic) BOOL supportShare;

/**
 滑块正在拖拽
 */
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
 标题
 */
@property (copy, nonatomic) NSString *title;

@property (nonatomic, weak) id <CXBearingPlayerViewDelegate> delegate;

@property (nonatomic, assign) CXAVPlayerStatus playerStatus;

- (void)play;

- (void)pause;

- (void)fullScreenChanged:(BOOL)isFullScreen frame:(CGRect)frame;

@end

@interface CXSlider : UIControl
/**
 0 - 1. 播放进度
 */
@property (nonatomic, assign) CGFloat value;

/**
 0 - 1. 缓冲进度
 */
@property (nonatomic, assign) CGFloat bufferProgress;

/**
 轨道高度
 */
@property (nonatomic, assign) CGFloat trackHeight;

/**
 滑块触发大小的宽高
 */
@property (nonatomic, assign) CGFloat thumbTouchSize;

/**
 滑块可视大小的宽高
 */
@property (nonatomic, assign) CGFloat thumbVisibleSize;

/**
 轨道的颜色
 */
@property (nonatomic, strong) UIColor *trackColor;

/**
 缓冲的颜色
 */
@property (nonatomic, strong) UIColor *bufferColor;

/**
 播放进度的颜色
 */
@property (nonatomic, strong) UIColor *thumbValueColor;

/**
 为滑块设置图片
 
 @param thumbImage 滑块图片
 @param state 状态
 */
- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state;


@end
NS_ASSUME_NONNULL_END
