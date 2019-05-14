//
//  CXPlayerView.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/11.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CXPlayer.h"

@class CXPlayerView;

@protocol CXVideoPlayerDelegate <NSObject>

@optional

/**
 播放器状态

 @param status 状态
 @param playerView self
 */
- (void)promptPlayerStatusOrError:(CXAVPlayerStatus)status PlayVideo:(CXPlayerView *)playerView;

/**
 刷新数据

 @param totalTime 总时长
 @param currentTime 当前时长
 @param loadTime 加载进度时长
 */
- (void)refreshData:(NSTimeInterval)totalTime
           progress:(NSTimeInterval)currentTime
          loadRange:(NSTimeInterval)loadTime;
/**
 当前缓冲的时长

 @param playerView
 @param duration
 */
- (void)videoPlayer:(CXPlayerView *)playerView loadedTimeRangeDidChange:(CGFloat )progress;

@end
NS_ASSUME_NONNULL_BEGIN

@interface CXPlayerView : UIView
/**
 AVPlayerLayer的videoGravity属性设置
 AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
 AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
 AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
 */
@property (nonatomic, copy) NSString *videoGravity;

@property (nonatomic, strong,readonly) AVPlayer *player;

@property (nonatomic, strong,readonly) AVPlayerItem *playerItem;

@property (nonatomic, strong,readonly) AVURLAsset *urlAsset;

@property (nonatomic, strong,readonly) AVPlayerLayer *playerLayer;

@property (nonatomic, assign,readonly) BOOL isPlaying;

@property (nonatomic,weak) id<CXVideoPlayerDelegate> delegate;
/**
 缓存时长
 */
@property (nonatomic, assign) NSTimeInterval loadRange;
/**
 总时长
 */
@property (nonatomic, assign) NSTimeInterval totalTime;
/**
 设置播放的Url

 @param url
 */
- (void)setUrl:(NSURL *)url;

- (void)setAsset:(AVURLAsset *)asset;

/**
 定位到多少秒后播放视频

 @param time
 */
- (void)seekToTime:(CGFloat )time;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止播放
 */
- (void)stop;

/**
 播放|暂停

 @param block 播放状态的回调
 */
- (void)playOrPause:(void (^)(BOOL isPlay))block;

/**
 设置播放倍速 0.5-2.0

 @param rate 播放倍速
 */
- (void)setPlayerRate:(CGFloat )rate;

/**
 获取当前播放时间

 @return 当前播放时间
 */
- (CGFloat )getCurrentPlayTime;

/**
 获取视频的总时间长

 @return 视频的总时间长
 */
- (CGFloat)getTotalPlayTime;

/**
 获取视频宽高比

 @param Url
 @return 视频宽高比
 */
- (CGFloat )getVideoScale:(NSURL *)URL;

/**
 获取网络视频的缩略图

 @param Url
 @param videoTime
 @return 网络视频的缩略图
 */
- (UIImage *)getThumbnailImageFromVideoURL:(NSURL *)URL time:(NSTimeInterval )videoTime;

/**
 获取本地视频缩略图

 @param videoPath
 @param videoTime
 @return 本地视频缩略图
 */
- (UIImage *)getThumbnailImageFromFilePath:(NSString *)videoPath time:(NSTimeInterval )videoTime;

@end

NS_ASSUME_NONNULL_END
