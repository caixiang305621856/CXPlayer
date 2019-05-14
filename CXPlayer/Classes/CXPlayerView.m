//
//  CXPlayerView.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/11.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXPlayerView.h"

static void *VideoPlayer_PlayerItemStatusContext = &VideoPlayer_PlayerItemStatusContext;
static void *VideoPlayer_PlayerItemPlaybackLikelyToKeepUp = &VideoPlayer_PlayerItemPlaybackLikelyToKeepUp;
static void *VideoPlayer_PlayerItemPlaybackBufferEmpty = &VideoPlayer_PlayerItemPlaybackBufferEmpty;
static void *VideoPlayer_PlayerItemLoadedTimeRangesContext = &VideoPlayer_PlayerItemLoadedTimeRangesContext;

@interface CXPlayerView()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) id timeObserverToken;
//@property (nonatomic, strong) id playingTimeObserverToken;


@property (nonatomic,assign)CGFloat rate;
// 拖动进度条的时候停止刷新数据
@property (nonatomic ,assign) BOOL isSeeking;
//是否是能播放状态
@property (nonatomic, assign) BOOL isCanPlay;
// 是否需要缓冲
@property (nonatomic, assign) BOOL needBuffer;

@end

@implementation CXPlayerView

- (void)dealloc {
//    NSLog(@"🔥CXPlayerView销毁了🔥");
    [self resetPlayerItemIfNecessary];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupAudioSession];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAudioSession];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupAudioSession];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.playerLayer) {
        self.playerLayer.frame =self.bounds;
    }
}

#pragma mark - public
- (void)setUrl:(NSURL *)url {
    //如果有正在播放的视频 先释放掉
    [self resetPlayerItemIfNecessary];
    self.urlAsset =[AVURLAsset assetWithURL:url];
    [self creatPlayerWithAsset:self.urlAsset];
}

- (void)setAsset:(AVURLAsset *)asset {
    [self resetPlayerItemIfNecessary];
    [self creatPlayerWithAsset:asset];
}

- (void)seekToTime:(CGFloat )time {
    if (self.player) {
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        [self startToSeek];
        CMTime cmTime =CMTimeMakeWithSeconds(time, 1);
        if (CMTIME_IS_INVALID(cmTime) || self.player.currentItem.status != AVPlayerStatusReadyToPlay) {
            return;
        }
        /*
        __weak typeof(self)weakSelf = self;
        [self.player seekToTime:cmTime completionHandler:^(BOOL finished) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            [strongSelf play];
        }];
         */
        __weak typeof(self)weakSelf = self;
        [self.player seekToTime:cmTime toleranceBefore:CMTimeMake(1,1)  toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            [strongSelf endSeek];
        }];
    }
}

- (void)play {
    self.isPlaying =YES;
    if (self.player.rate == 0.0) {
        [self.player play];
    }
}

- (void)pause {
    if(self.isPlaying){
        self.isPlaying =NO;
        [self.player pause];
    }
}

/** 播放|暂停 */
- (void)playOrPause:(void (^)(BOOL isPlay))block {
    if (self.player.rate == 0) {
        [self play];
        block(YES);
    }else if (self.player.rate > 0) {
        [self pause];
        block(NO);
    }else {
        NSLog(@"播放器出错");
    }
}

- (void)stop {
    [self.player pause];
    //item置为nil相关
    [self resetPlayerItemIfNecessary];
}

- (void)setPlayerRate:(CGFloat )rate{
    _rate =rate;
    if(self.player) self.player.rate =rate;
}

- (CGFloat )getCurrentPlayTime {
    if(self.player) return CMTimeGetSeconds([self.player currentTime]);
    return 0.0f;
}

- (CGFloat)getTotalPlayTime {
    if(self.player) return CMTimeGetSeconds(self.player.currentItem.duration);
    return 0.0f;
}

- (CGFloat )getVideoScale:(NSURL *)URL {
    if (!URL) return 0.0f;
    //获取视频尺寸
    AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    return videoSize.height/videoSize.width;
}

- (UIImage *)getThumbnailImageFromVideoURL:(NSURL *)URL time:(NSTimeInterval )videoTime {
    if (!URL) return nil;
    UIImage *shotImage;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:URL options:nil];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(videoTime, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetImageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}

- (UIImage *)getThumbnailImageFromFilePath:(NSString *)videoPath time:(NSTimeInterval )videoTime {
    if (!videoPath) {
        return nil;
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:videoPath] options:nil];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = videoTime;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 600)
                                                    actualTime:NULL error:nil];
    if (!thumbnailImageRef) {
        return nil;
    }
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:thumbnailImageRef];
    CFRelease(thumbnailImageRef);
    return thumbnailImage;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == VideoPlayer_PlayerItemStatusContext){// 播放状态
        AVPlayerStatus newStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        AVPlayerStatus oldStatus = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if (newStatus != oldStatus) {
            switch (newStatus) {
                case AVPlayerItemStatusUnknown:// 状态未知
                    NSLog(@"AVPlayerItemStatusUnknown");
                    break;
                case AVPlayerItemStatusReadyToPlay:// 准备好播放
                    self.isCanPlay = YES;
                    [self setDelegateStatus:CXAVPlayerStatusReadyToPlay];
                    break;
                case AVPlayerItemStatusFailed:// 播放出错
                    [self setDelegateStatusOutCanPlay:CXAVPlayerStatusItemFailed];
                    break;
            }
        }
    } else if (context == VideoPlayer_PlayerItemPlaybackBufferEmpty) {// 跳转后没数据
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            if (self.player.currentItem.playbackBufferEmpty) {
                // 转菊花
                if (self.isCanPlay) {
                    self.needBuffer = YES;
                    [self setDelegateStatus:CXAVPlayerStatusCacheData];
                }
            }
        }
    } else if (context == VideoPlayer_PlayerItemPlaybackLikelyToKeepUp) {//跳转后有数据
        if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (self.player.currentItem.playbackLikelyToKeepUp){
                // 隐藏菊花
                if (self.isCanPlay && self.needBuffer) {
                    self.needBuffer = NO;
                    [self setDelegateStatus:CXAVPlayerStatusCacheEnd];
                }
            }
        }
    }else if (context == VideoPlayer_PlayerItemLoadedTimeRangesContext) {// 缓冲进度
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
            CGFloat loadedDuration = [self updateLoadedTimeRanges:timeRanges];
            
            CMTime duration = self.player.currentItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            CGFloat progress = loadedDuration / totalDuration;

            if ([self.delegate respondsToSelector:@selector(videoPlayer:loadedTimeRangeDidChange:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate videoPlayer:self loadedTimeRangeDidChange:progress];
                });
            }
        }
    } else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - notification
- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    [self setDelegateStatus:CXAVPlayerStatusPlayEnd];
    [self.player seekToTime:kCMTimeZero];
}

- (void)videoPlayWaiting:(NSNotification *)notic {
    [self setDelegateStatus:CXAVPlayerStatusCacheData];
}

- (void)videoPlayEnterBack:(NSNotification *)notic {
    [self setDelegateStatus:CXAVPlayerStatusEnterBack];
}

- (void)videoPlayWillResignActive:(NSNotification *)notic {
    [self setDelegateStatus:CXAVPlayerStatusResignActive];    
}

- (void)videoPlayBecomeActive:(NSNotification *)notic {
    [self setDelegateStatus:CXAVPlayerStatusBecomeActive];
}

//耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            //判断为耳机接口
            AVAudioSessionRouteDescription *previousRoute =interuptionDict[AVAudioSessionRouteChangePreviousRouteKey];
            AVAudioSessionPortDescription *previousOutput =previousRoute.outputs[0];
            NSString *portType =previousOutput.portType;
            if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
                // 拔掉耳机继续播放
                if (self.isPlaying) {
                    [self.player play];
                }
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            break;
    }
}

#pragma mark - private
- (void)setDelegateStatus:(CXAVPlayerStatus)status {
    /*
     if (self.player.currentItem.status != AVPlayerStatusReadyToPlay) {
     return;
     }
     */
    if (self.isCanPlay == NO) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(promptPlayerStatusOrError:PlayVideo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate promptPlayerStatusOrError:status PlayVideo:self];
        });
    }
}

/**
 不需要 AVPlayerStatusReadyToPlay 的条件

 @param status 状态
 */
- (void)setDelegateStatusOutCanPlay:(CXAVPlayerStatus)status {
    if (self.delegate && [self.delegate respondsToSelector:@selector(promptPlayerStatusOrError:PlayVideo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate promptPlayerStatusOrError:status PlayVideo:self];
        });
    }
}

/** 滑动中不监听 */
- (void)startToSeek {
    self.isSeeking = YES;
}

- (void)endSeek {
    self.isSeeking = NO;
}

- (void)setupAudioSession {
    self.isCanPlay = NO;
    self.needBuffer = NO;
    self.isSeeking = NO;
    self.isPlaying = NO;
    
    _rate =1.0f;
    
    NSError *categoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
    if (!success) {
        NSLog(@"Error setting audio session category: %@", categoryError);
    }
    NSError *activeError = nil;
    success = [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
    if (!success) {
        NSLog(@"Error setting audio session active: %@", activeError);
    }
}

- (void)creatPlayerWithAsset:(AVURLAsset *)urlAsset{
    // 初始化playerItem
    self.playerItem =[AVPlayerItem playerItemWithAsset:urlAsset];
    if (@available(iOS 10.0, *)) {
        self.playerItem.preferredForwardBufferDuration =10.f;
    } else {
        // Fallback on earlier versions
    }
    if(!self.playerItem){
        [self reportUnableToCreatePlayerItem];
        return;
    }
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player =[AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer =[AVPlayerLayer playerLayerWithPlayer:self.player];
    // 此处为默认视频填充模式
    self.playerLayer.videoGravity = self.videoGravity;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // 添加playerLayer到self.layer
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    //添加播放时间观察
    [self addTimeObserver];
    //添加AVPlayerItem观察
    [self addPlayerItemObservers:self.playerItem];
    
    [self setDelegateStatusOutCanPlay:CXAVPlayerStatusLoadingVideo];
    self.isCanPlay = NO;
}

- (void)reportUnableToCreatePlayerItem {
    [self setDelegateStatusOutCanPlay:CXAVPlayerStatusItemFailed];
}

- (void)addPlayerItemObservers:(AVPlayerItem *)playerItem {
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:VideoPlayer_PlayerItemStatusContext];
    
    [playerItem addObserver:self
                 forKeyPath:@"playbackLikelyToKeepUp"
                    options:NSKeyValueObservingOptionNew
                    context:VideoPlayer_PlayerItemPlaybackLikelyToKeepUp];
    
    [playerItem addObserver:self
                 forKeyPath:@"playbackBufferEmpty"
                    options:NSKeyValueObservingOptionNew
                    context:VideoPlayer_PlayerItemPlaybackBufferEmpty];
    
    [playerItem addObserver:self
                 forKeyPath:@"loadedTimeRanges"
                    options:NSKeyValueObservingOptionNew
                    context:VideoPlayer_PlayerItemLoadedTimeRangesContext];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    //播放完毕的通知
    [center addObserver:self selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    //耳机插入和拔掉通知
    [center addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                   name:AVAudioSessionRouteChangeNotification
                 object:nil];
    [center addObserver:self selector:@selector(videoPlayWaiting:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//播放时间 观察
- (void)addTimeObserver{
    if (self.timeObserverToken || self.player == nil) {
        return;
    }
    __weak typeof (self) weakSelf = self;
    /*
     self.playingTimeObserverToken = [self.player addBoundaryTimeObserverForTimes:@[[NSValue valueWithCMTime:CMTimeMake(1, 30)]] queue:dispatch_get_main_queue()
     usingBlock:^{
     __strong typeof (weakSelf) strongSelf = weakSelf;
     NSLog(@"首次加载成功");
     [strongSelf setDelegateStatusOutCanPlay:CXAVPlayerStatusPlay];
     }];
     */
    
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        AVPlayerItem *playerItem = weakSelf.player.currentItem;
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds([playerItem duration]);
        if (strongSelf.isSeeking) {
            return;
        }
        if (current > 0.f) {
            [strongSelf setDelegateStatusOutCanPlay:CXAVPlayerStatusPlay];
        }
        if ([strongSelf.delegate respondsToSelector:@selector(refreshData:progress:loadRange:)]) {
            [strongSelf.delegate refreshData:total progress:current loadRange:strongSelf.loadRange];
        }
    }];
}

//移除AVPlayerItem观察
- (void)removePlayerItemObservers:(AVPlayerItem *)playerItem {
    [playerItem cancelPendingSeeks];
    [playerItem removeObserver:self forKeyPath:@"status" context:VideoPlayer_PlayerItemStatusContext];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:VideoPlayer_PlayerItemLoadedTimeRangesContext];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:VideoPlayer_PlayerItemPlaybackBufferEmpty];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:VideoPlayer_PlayerItemPlaybackLikelyToKeepUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

//移除时间观察
- (void)removeTimeObserver{
    if (!self.timeObserverToken) {
        return;
    }
//    if (!self.playingTimeObserverToken) {
//        return;
//    }
    if (self.player) {
        [self.player removeTimeObserver:self.timeObserverToken];
//        [self.player removeTimeObserver:self.playingTimeObserverToken];
    }
    self.timeObserverToken = nil;
//    self.playingTimeObserverToken = nil;
}

//释放
- (void)resetPlayerItemIfNecessary{
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    
    if (self.playerItem) {
        [self removePlayerItemObservers:self.playerItem];
    }
    
    [self removeTimeObserver];
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    if (self.playerItem){
        self.playerItem = nil;
    }
    
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.player =nil;
    }
    
    if (self.urlAsset) {
        self.urlAsset =nil;
    }
    
    if (self.playerLayer) {
        self.playerLayer =nil;
    }
}

#pragma mark - set&get
- (NSString *)videoGravity {
    if (!_videoGravity) {
        _videoGravity =AVLayerVideoGravityResizeAspect;
    }
    return _videoGravity;
}

- (CGFloat )updateLoadedTimeRanges:(NSArray *)timeRanges {
    if (timeRanges && [timeRanges count]) {
        CMTimeRange timerange = [[timeRanges firstObject] CMTimeRangeValue];
        CMTime bufferDuration = CMTimeAdd(timerange.start, timerange.duration);
        // 获取到缓冲的时间,然后除以总时间,得到缓冲的进度
        _loadRange = CMTimeGetSeconds(bufferDuration);
        return _loadRange;
    }
    return 0.0f;
}

@end
