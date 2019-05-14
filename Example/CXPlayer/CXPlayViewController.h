//
//  CXPlayViewController.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/13.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface CXPlayViewController : UIViewController

@property (nonatomic, copy) dispatch_block_t disMissBlock;

@property (copy, nonatomic) dispatch_block_t shareBlock;

@property (copy, nonatomic) void(^playerStatusBlock)(CXAVPlayerStatus playerStatus);

@end

NS_ASSUME_NONNULL_END
