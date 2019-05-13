//
//  CXPlayerViewController.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/12.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXPlayerViewController : UIViewController

@property (nonatomic, copy) void(^disMissBlcok)(void);

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
