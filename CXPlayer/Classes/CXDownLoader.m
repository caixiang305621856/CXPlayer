//
//  CXDownLoader.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXDownLoader.h"
#import "CXPlayFileTool.h"

@interface CXDownLoader ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSURL *url;

@end

@implementation CXDownLoader

- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)downLoadWithURL: (NSURL *)url offset: (long long)offset {
    self.url = url;
    self.offset = offset;
    [self cancel];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    [task resume];
}

- (void)cancel {
    [self.session invalidateAndCancel];
    self.session = nil;
    // 清理缓存
    [CXPlayFileTool removeTmpFileWithURL:self.url];
    // 重置数据
    self.loadedSize = 0;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSHTTPURLResponse *httpResponse =  (NSHTTPURLResponse *)response;
    self.totalSize = [[[httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"] lastObject] longLongValue];
    self.contentType = httpResponse.MIMEType;
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:[CXPlayFileTool tmpPathWithURL:self.url] append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    self.loadedSize += data.length;
    [self.outputStream write:data.bytes maxLength:data.length];
    if ([self.delegate respondsToSelector:@selector(downLoaderLoading)]) {
        [self.delegate downLoaderLoading];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        // 判断, 本地下载的大小, 是否等于文件的总大小
        if ([CXPlayFileTool tmpFileSizeWithURL:self.url] == self.totalSize) {
            [CXPlayFileTool moveTmpPathToCachePath:self.url];
        }
    }
}

@end
