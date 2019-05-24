//
//  NSURL+CXStreaming.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "NSURL+Protocol.h"

static NSString *kCacheScheme = @"CX";

@implementation NSURL (Protocol)

- (NSURL *)streamingURL {
    NSURL *assetURL = [NSURL URLWithString:[kCacheScheme stringByAppendingString:[self absoluteString]]];
    return assetURL;
}

- (NSURL *)httpURL {
    if ([self.absoluteString hasPrefix:kCacheScheme]) {
        NSString *originStr = [self absoluteString];
        originStr = [originStr stringByReplacingOccurrencesOfString:kCacheScheme withString:@""];
        return [NSURL URLWithString:originStr];
    }
    return self;
}

@end
