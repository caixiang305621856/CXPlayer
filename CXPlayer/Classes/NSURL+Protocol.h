//
//  NSURL+CXStreaming.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Protocol)

- (NSURL *)streamingURL;

- (NSURL *)httpURL;

@end

NS_ASSUME_NONNULL_END
