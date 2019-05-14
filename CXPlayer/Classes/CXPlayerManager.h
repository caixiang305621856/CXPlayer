//
//  CXPlayerManager.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CXPlayer.h"
@class CXPlayerView,CXBearingPlayerView;
NS_ASSUME_NONNULL_BEGIN

@interface CXPlayerManager : NSObject
/**
 播放器view
 */
@property (nonatomic,strong,readonly)CXPlayerView *playerView;

/**
 承载视频播放界面的View
 */
@property (nonatomic, strong,readonly) CXBearingPlayerView *bearingPlayerView;

/**
 返回
 */
@property (nonatomic, copy) dispatch_block_t disMissBlock;

/**
 分享
 */
@property (copy, nonatomic) dispatch_block_t shareBlock;

/**
 播放器状态的回调
 */
@property (copy, nonatomic) void(^playerStatusBlock)(CXAVPlayerStatus playerStatus);

/**
 手动播放/暂停的回调
 */
@property (copy, nonatomic) void(^playOrPauseBlock)(BOOL isPlaying);

/**
 标题
 */
@property (copy, nonatomic) NSString *title;

/**
 传递外界的Url view
 
 @param url url
 @param view 放播放的view
 */
- (void)playWithUrl:(NSString *)url inView:(UIView *)view;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止播放/清空播放器
 */
- (void)stop;

/**
 @param toTime 从指定的时间开始播放（秒）
 */
- (void)seekToTimePlay:(CGFloat)toTime;

@end

NS_ASSUME_NONNULL_END
