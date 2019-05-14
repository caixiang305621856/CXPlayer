//
//  CXPlayerHeader.h
//  CXPlayer
//
//  Created by caixiang on 2019/5/14.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#ifndef CXPlayer_h
#define CXPlayer_h

/**
 CXAVPlayerStatus
 
 - CXAVPlayerStatusReadyToPlay: 准备好播放
 - CXAVPlayerStatusLoadingVideo: 加载视频
 - CXAVPlayerStatusPlay: 正在播放
 - CXAVPlayerStatusPlayEnd: 播放结束
 - CXAVPlayerStatusCacheData: 缓冲视频
 - CXAVPlayerStatusCacheEnd: 缓冲结束
 - CXAVPlayerStatusItemFailed: 视频资源问题
 - CXAVPlayerStatusEnterBack: 进入后台
 - CXAVPlayerStatusResignActive: 即将进入后台
 - CXAVPlayerStatusBecomeActive: 从后台返回
 */
typedef NS_OPTIONS(NSInteger, CXAVPlayerStatus) {
    CXAVPlayerStatusReadyToPlay = 0,
    CXAVPlayerStatusLoadingVideo = 1 << 1,
    CXAVPlayerStatusPlay = 1 << 2,
    CXAVPlayerStatusPlayEnd = 1 << 3,
    CXAVPlayerStatusCacheData = 1 << 4,
    CXAVPlayerStatusCacheEnd = 1 << 5,
    CXAVPlayerStatusItemFailed = 1 << 6,
    CXAVPlayerStatusEnterBack = 1 << 7,
    CXAVPlayerStatusResignActive = 1 << 8,
    CXAVPlayerStatusBecomeActive = 1 << 9,
};

UIKIT_STATIC_INLINE UIEdgeInsets play_viewSafeArea(UIView *view) {
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        return view.safeAreaInsets;
    }
#endif
    return UIEdgeInsetsZero;
}

#import "CXPlayerView.h"
#import "CXBearingPlayerView.h"
#import "CXPlayerManager.h"

#endif /* CXPlayerHeader_h */
