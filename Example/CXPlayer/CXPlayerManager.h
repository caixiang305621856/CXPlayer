//
//  CXPlayerManager.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXPlayerManager : NSObject

@property (nonatomic, copy) void(^disMissBlcok)(void);

/**
 传递外界的Url view

 @param url
 @param view 放播放的view
 */
- (void)playWithUrl:(NSString *)url inView:(UIView *)view;
/**
 传递外界的URL
 
 @param url
 */
- (void)playWithUrl:(NSString *)url;

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
