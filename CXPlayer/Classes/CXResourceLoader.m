//
//  CXResourceLoader.h
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXDownLoader.h"
#import "CXPlayFileTool.h"
#import "NSURL+Protocol.h"
#import "CXResourceLoader.h"

@interface CXResourceLoader ()<CXDownLoaderDelegate>

@property (nonatomic, strong) CXDownLoader *downLoader;

@property (nonatomic, strong) NSMutableArray <AVAssetResourceLoadingRequest *>*loadingRequests;

@end


@implementation CXResourceLoader

- (CXDownLoader *)downLoader {
    if(!_downLoader) {
        _downLoader = [[CXDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray<AVAssetResourceLoadingRequest *> *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}


- (void)handleAllRequest {
    
    NSLog(@"-----%@", self.loadingRequests);
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString *contentType = self.downLoader.contentType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[CXPlayFileTool tmpPathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[CXPlayFileTool cachePathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength) ;
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        
        [loadingRequest.dataRequest respondWithData:subData];
        
        // 3. 完成请求(必须把所有的关于这个请求的区间数据, 都返回完之后, 才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
    }
    
    [self.loadingRequests removeObjectsInArray:deleteRequests];
    
}

// 只要播放器, 想要播放某个资源, 都会让资源组织者, 命令资源请求者, 调用这个方法, 去发送请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"🚀%@🚀", loadingRequest);
    
    [self.loadingRequests addObject:loadingRequest];
    
    // 下载的url地址
    NSURL *url = [loadingRequest.request.URL httpURL];
    
    long long requestOffSet = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestOffSet = loadingRequest.dataRequest.currentOffset;
    }
    
    if ([CXPlayFileTool isCacheFileExists:url])
    {
        // 三个步骤, 直接响应数据
        [self handleRequestWithLoadingRequest:loadingRequest];
        return YES;
    }
    
    if (self.downLoader.loadedSize == 0) {
        [self.downLoader downLoadWithURL:url offset:0];
        return YES;
    }
    
    if (requestOffSet < self.downLoader.offset || requestOffSet > self.downLoader.offset + self.downLoader.loadedSize + 666) {
        [self.downLoader downLoadWithURL:url offset:0];
        return YES;
    }
    // 请求的数据, 就在正在下载当中
    // 在正在下载数据当中, data -> 播放器
    [self handleAllRequest];
    
    
    return YES;
}

// 取消某个请求的时候调用
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSLog(@"取消请求");
    [self.loadingRequests removeObject:loadingRequest];
}


#pragma mark - 私有方法

- (void)handleRequestWithLoadingRequest: (AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *url = [loadingRequest.request.URL httpURL];
    // 1. 填充信息头
    loadingRequest.contentInformationRequest.contentType = [CXPlayFileTool contentTypeWithURL:url];
    loadingRequest.contentInformationRequest.contentLength = [CXPlayFileTool cacheFileSizeWithURL:url];
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 响应数据
    NSData *data = [NSData dataWithContentsOfFile:[CXPlayFileTool cachePathWithURL:url] options:NSDataReadingMappedIfSafe error:nil];
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long requestLen = loadingRequest.dataRequest.requestedLength;
    
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLen)];
    
    [loadingRequest.dataRequest respondWithData:subData];
    
    // 3. 完成这个请求
    [loadingRequest finishLoading];
}

#pragma mark - 下载协议

- (void)downLoaderLoading {
    [self handleAllRequest];
}


@end
