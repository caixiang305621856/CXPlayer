# CXPlayer

[![CI Status](https://img.shields.io/travis/caixiang305621856/CXPlayer.svg?style=flat)](https://travis-ci.org/caixiang305621856/CXPlayer)
[![Version](https://img.shields.io/cocoapods/v/CXPlayer.svg?style=flat)](https://cocoapods.org/pods/CXPlayer)
[![License](https://img.shields.io/cocoapods/l/CXPlayer.svg?style=flat)](https://cocoapods.org/pods/CXPlayer)
[![Platform](https://img.shields.io/cocoapods/p/CXPlayer.svg?style=flat)](https://cocoapods.org/pods/CXPlayer)

## 使用说明
[](https://upload-images.jianshu.io/upload_images/1767433-84de6ae8799a6999.gif?imageMogr2/auto-orient/)
strip
```obj
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *showPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    showPlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:showPlayerView];
    [self.playerManager playWithUrl:@"http://vfx.mtime.cn/Video/2019/05/07/mp4/190507094456874251.mp4" inView:showPlayerView];
    [self.playerManager seekToTimePlay:14];
}

- (CXPlayerManager *)playerManager {
    if (!_playerManager) {
        _playerManager = [[CXPlayerManager alloc] init];
        _playerManager.disMissBlock = self.disMissBlock;
        _playerManager.shareBlock = self.shareBlock;
        _playerManager.playerStatusBlock = self.playerStatusBlock;
    }
    return _playerManager;
}
```


## Requirements

## Installation

CXPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CXPlayer'
```

## Author

caixiang305621856, yanyan305621856@sina.com

## License

CXPlayer is available under the MIT license. See the LICENSE file for more info.
