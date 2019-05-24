//
//  CXPlayFileTool.m
//  CXPlayer_Example
//
//  Created by caixiang on 2019/5/24.
//  Copyright © 2019年 caixiang305621856. All rights reserved.
//

#import "CXPlayFileTool.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define CX_CachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define CX_TmpPath NSTemporaryDirectory()

@implementation CXPlayFileTool


+ (NSString *)cachePathWithURL: (NSURL *)url {
    return [CX_CachePath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (NSString *)tmpPathWithURL: (NSURL *)url {
    return [CX_TmpPath stringByAppendingPathComponent:url.lastPathComponent];
}

+ (BOOL)isCacheFileExists: (NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathWithURL:url]];
}

+ (BOOL)isTmpFileExists: (NSURL *)url {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self tmpPathWithURL:url]];
}

+ (NSString *)contentTypeWithURL: (NSURL *)url {
    NSString *fileExtension = url.absoluteString.pathExtension;
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    return contentType;
}

+ (long long)cacheFileSizeWithURL: (NSURL *)url {
    if (![self isCacheFileExists:url]) {
        return 0;
    }
    NSString *path = [self cachePathWithURL:url];
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfo[NSFileSize] longLongValue];
}

+ (long long)tmpFileSizeWithURL: (NSURL *)url {
    if (![self isTmpFileExists:url]) {
        return 0;
    }
    NSString *path = [self tmpPathWithURL:url];
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfo[NSFileSize] longLongValue];
}

+ (void)removeTmpFileWithURL: (NSURL *)url {
    if ([self isTmpFileExists:url]) {
        [[NSFileManager defaultManager] removeItemAtPath:[self tmpPathWithURL:url] error:nil];
    }
}


+ (void)moveTmpPathToCachePath: (NSURL *)url {
    if ([self isTmpFileExists:url]) {
        NSString *tmpPath = [self tmpPathWithURL:url];
        NSString *cachePath = [self cachePathWithURL:url];
        [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
    }
}


@end
