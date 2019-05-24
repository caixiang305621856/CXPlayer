//
//  CXDownLoader.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CXDownLoaderDelegate <NSObject>

- (void)downLoaderLoading;

@end

@interface CXDownLoader : NSObject

@property (nonatomic, assign) long long loadedSize;
@property (nonatomic, assign) long long offset;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, assign) long long totalSize;

@property (nonatomic, weak) id<CXDownLoaderDelegate> delegate;

- (void)downLoadWithURL: (NSURL *)url offset: (long long)offset;

@end
